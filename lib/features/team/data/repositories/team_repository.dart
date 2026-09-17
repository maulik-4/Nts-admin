import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/team_member.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TeamRepository(dio);
});

class TeamRepository {
  final Dio _dio;

  TeamRepository(this._dio);

  Future<List<TeamMember>> getTeamMembers() async {
    try {
      final response = await _dio.get('/api/auth/users/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => TeamMember.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['results'] is List) {
        return (response.data['results'] as List)
            .map((item) => TeamMember.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
    int? firmId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };
      if (firmId != null) {
        payload['firm'] = firmId;
      }
      await _dio.post('/api/auth/add-user/', data: payload);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    try {
      await _dio.post(
        '/api/auth/invite/firm/',
        data: {'email': email, 'role': role},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> invitePlatformUser({
    required String email,
    required String role,
  }) async {
    try {
      await _dio.post(
        '/api/auth/invite/platform/',
        data: {'email': email, 'role': role},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
