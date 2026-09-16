import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return ErrorInterceptor(tokenStorage: tokenStorage);
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  final errorInterceptor = ref.watch(errorInterceptorProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
      sendTimeout: EnvConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([AuthInterceptor(tokenStorage), errorInterceptor]);

  return dio;
});
