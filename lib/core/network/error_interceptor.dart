import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../errors/api_exception.dart';
import '../storage/secure_token_storage.dart';

typedef UnauthorizedCallback = void Function();

class ErrorInterceptor extends Interceptor {
  final SecureTokenStorage tokenStorage;
  UnauthorizedCallback? onUnauthorized;

  ErrorInterceptor({required this.tokenStorage, this.onUnauthorized});

  static const List<String> _authExemptFromAutoLogout = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.acceptInvite,
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Check if this is an unauthorized (401) response on an authenticated endpoint
    final isAuthEndpoint = _authExemptFromAutoLogout.any(
      (ep) => path.contains(ep),
    );

    if (statusCode == 401 && !isAuthEndpoint) {
      // Clear credentials and notify auth system
      await tokenStorage.clearTokens();
      onUnauthorized?.call();
    }

    // Convert DioException into our typed ApiException
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

    // Pass wrapped error forward
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
