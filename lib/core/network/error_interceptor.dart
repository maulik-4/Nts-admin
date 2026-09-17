import 'dart:async';

import 'package:dio/dio.dart';

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
    // 401 UNAUTHORIZED: TOKEN REFRESH FLOW
    // =========================================================================
    if (statusCode == 401 && !isAuthEndpoint) {
      final isRetry = err.requestOptions.extra['is_retry'] == true;

      // Avoid infinite refresh loops
      if (isRetry) {
        await _clearSessionAndNotify();
        return _rejectWithError(err, handler);
      }

      // If a refresh is already underway, wait for it
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
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
        await _clearSessionAndNotify();
        return _rejectWithError(err, handler);
      }

      // Start new refresh operation
      _refreshCompleter = Completer<String?>();
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.trim().isEmpty) {
        _refreshCompleter!.complete(null);
        await _clearSessionAndNotify();
        return _rejectWithError(err, handler);
      }

      try {
        final newAccessToken = await _executeRefresh(refreshToken);
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
          await _clearSessionAndNotify();
          return _rejectWithError(err, handler);
        }
      } catch (refreshErr) {
        _refreshCompleter!.complete(null);
        await _clearSessionAndNotify();
        return _rejectWithError(err, handler);
      }
    }

    // =========================================================================
    // 403 FORBIDDEN: ROLE / ACCESS RESTRICTED (DO NOT LOG OUT!)
    // =========================================================================
    // 403 Forbidden is handled without clearing tokens or triggering onUnauthorized
    return _rejectWithError(err, handler);
  }

  Future<String?> _executeRefresh(String refreshToken) async {
    try {
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

      final response = await client.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final newAccess =
            data['access']?.toString() ?? data['token']?.toString();
        final newRefresh = data['refresh']?.toString();

        if (newAccess != null && newAccess.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh ?? refreshToken,
          );
          return newAccess;
        }
      }
    } catch (_) {
      // Backend does not support refresh endpoint or token expired
    }
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
