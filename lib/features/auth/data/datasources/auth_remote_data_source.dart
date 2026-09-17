import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/accept_invite_request.dart';
import '../models/auth_token_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_profile.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
});

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthTokenResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return AuthTokenResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw const ApiException(
          message: 'Unexpected server response format during login.',
        );
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Registration successful'};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> acceptInvite(AcceptInviteRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.acceptInvite,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Invite accepted successfully'};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Password reset request submitted successfully.'};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'password': password},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Password updated successfully.'};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profileMe);
      if (response.data is Map<String, dynamic>) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid profile response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>?> getFirmProfile() async {
    try {
      final response = await _dio.get('/api/profile/firm/');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
