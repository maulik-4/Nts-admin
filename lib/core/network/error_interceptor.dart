import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../constants/api_endpoints.dart';
import '../errors/api_exception.dart';
import '../storage/secure_token_storage.dart';

typedef UnauthorizedCallback = void Function();

class ErrorInterceptor extends Interceptor {
  final SecureTokenStorage tokenStorage;
  UnauthorizedCallback? onUnauthorized;
  Dio? retryDio;

  // Synchronization mutex preventing multiple concurrent token refreshes
  Completer<String?>? _refreshCompleter;

  ErrorInterceptor({
    required this.tokenStorage,
    this.onUnauthorized,
    this.retryDio,
  });

  static const List<String> _authExemptFromAutoLogout = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.acceptInvite,
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    final isAuthEndpoint = _authExemptFromAutoLogout.any(
      (ep) => path.contains(ep),
    );

    // =========================================================================
    // 401 UNAUTHORIZED: TOKEN REFRESH & SILENT RE-AUTH LIFECYCLE
    // =========================================================================
    if (statusCode == 401 && !isAuthEndpoint) {
      final isRetry = err.requestOptions.extra['is_retry'] == true;

      // Avoid infinite retry loops
      if (isRetry) {
        debugPrint(
          '[AUTH] Retried request failed with 401. Rejecting request.',
        );
        return _rejectWithError(err, handler);
      }

      // If a refresh/re-auth is already underway, wait for it (single-flight mutex)
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        debugPrint(
          '[AUTH] Concurrent 401 detected; waiting for in-flight session refresh.',
        );
        try {
          final newAccessToken = await _refreshCompleter!.future;
          if (newAccessToken != null && retryDio != null) {
            final retriedResponse = await _retryRequest(
              err.requestOptions,
              newAccessToken,
            );
            return handler.resolve(retriedResponse);
          }
        } catch (_) {
          // If waiting failed, proceed to rejection
        }
        return _rejectWithError(err, handler);
      }

      // Start new refresh operation
      _refreshCompleter = Completer<String?>();
      debugPrint(
        '[AUTH] Access token expired or invalid (HTTP 401). Initiating session refresh...',
      );

      try {
        final newAccessToken = await _executeRefresh();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          _refreshCompleter!.complete(newAccessToken);

          // Retry the original failed request with the new access token
          if (retryDio != null) {
            final retriedResponse = await _retryRequest(
              err.requestOptions,
              newAccessToken,
            );
            return handler.resolve(retriedResponse);
          }
        } else {
          _refreshCompleter!.complete(null);
          return _rejectWithError(err, handler);
        }
      } catch (refreshErr) {
        debugPrint('[AUTH] Error during session refresh: $refreshErr');
        _refreshCompleter!.complete(null);
        return _rejectWithError(err, handler);
      }
    }

    // =========================================================================
    // 403 FORBIDDEN: ROLE / ACCESS RESTRICTED (DO NOT LOG OUT!)
    // =========================================================================
    return _rejectWithError(err, handler);
  }

  Future<String?> _executeRefresh() async {
    final client = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Attempt token refresh endpoint if refreshToken exists
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      try {
        debugPrint('[AUTH] Attempting token refresh via refresh token...');
        final response = await client.post(
          ApiEndpoints.tokenRefresh,
          data: {'refresh': refreshToken},
        );

        if (response.statusCode == 200 &&
            response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final newAccess =
              data['access']?.toString() ?? data['token']?.toString();
          final newRefresh = data['refresh']?.toString();

          if (newAccess != null && newAccess.isNotEmpty) {
            await tokenStorage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh ?? refreshToken,
            );
            debugPrint('[AUTH] Token refresh successful.');
            return newAccess;
          }
        }
      } catch (_) {
        debugPrint(
          '[AUTH] Refresh endpoint unavailable or rejected. Falling back to credentials.',
        );
      }
    }

    // 2. Silent re-authentication using securely stored credentials
    final credentials = await tokenStorage.getCredentials();
    if (credentials != null) {
      final username = credentials['username'];
      final password = credentials['password'];

      if (username != null && password != null) {
        try {
          debugPrint(
            '[AUTH] Attempting silent re-authentication for session renewal...',
          );
          final response = await client.post(
            ApiEndpoints.login,
            data: {'username': username, 'password': password},
          );

          if (response.statusCode == 200 &&
              response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            final newAccess =
                data['access']?.toString() ?? data['token']?.toString();
            final newRefresh = data['refresh']?.toString();

            if (newAccess != null && newAccess.isNotEmpty) {
              await tokenStorage.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );
              debugPrint(
                '[AUTH] Silent re-authentication successful. Session renewed.',
              );
              return newAccess;
            }
          }
        } on DioException catch (dioErr) {
          final status = dioErr.response?.statusCode;
          if (status == 400 || status == 401 || status == 403) {
            // Backend explicitly rejected credentials (e.g. password changed or account blocked)
            debugPrint(
              '[AUTH] Silent re-auth rejected with HTTP $status. Clearing session.',
            );
            await _clearSessionAndNotify();
            return null;
          } else {
            // Temporary network error or server 5xx: DO NOT LOG OUT!
            debugPrint(
              '[AUTH] Network/server error during re-auth ($status). Preserving session.',
            );
            return null;
          }
        } catch (e) {
          debugPrint(
            '[AUTH] Unexpected error during re-auth: $e. Preserving session.',
          );
          return null;
        }
      }
    }

    // If both refresh token and credentials failed or are missing
    debugPrint(
      '[AUTH] No valid session refresh mechanism available. Clearing session.',
    );
    await _clearSessionAndNotify();
    return null;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) async {
    final newOptions = options.copyWith(
      headers: Map<String, dynamic>.from(options.headers)
        ..['Authorization'] = 'Bearer $newAccessToken',
      extra: Map<String, dynamic>.from(options.extra)..['is_retry'] = true,
    );
    return await retryDio!.fetch(newOptions);
  }

  Future<void> _clearSessionAndNotify() async {
    debugPrint('[AUTH] Clearing tokens and notifying session expiration.');
    await tokenStorage.clearTokens();
    onUnauthorized?.call();
  }

  void _rejectWithError(DioException err, ErrorInterceptorHandler handler) {
    ApiException customException;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      customException = ApiException.network();
    } else if (err.response != null) {
      customException = ApiException.fromResponse(
        err.response?.statusCode,
        err.response?.data,
      );
    } else {
      customException = ApiException(
        message: err.message ?? 'An unexpected network error occurred.',
        statusCode: null,
      );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: customException,
        message: customException.message,
      ),
    );
  }
}
