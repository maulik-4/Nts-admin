import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/tenant_firm.dart';

final firmsRepositoryProvider = Provider<FirmsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FirmsRepository(dio);
});

class FirmsRepository {
  final Dio _dio;

  FirmsRepository(this._dio);

  Future<List<TenantFirm>> getFirms() async {
    try {
      final response = await _dio.get('/api/firms/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => TenantFirm.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['results'] is List) {
        return (response.data['results'] as List)
            .map((item) => TenantFirm.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> createFirm(Map<String, dynamic> firmData) async {
    try {
      await _dio.post('/api/admin/create-firm/', data: firmData);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<TenantFirm> updateFirm(int firmId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/firms/$firmId/', data: data);
      return TenantFirm.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteFirm(int firmId) async {
    try {
      await _dio.delete('/api/firms/$firmId/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<bool> toggleActive(int firmId) async {
    try {
      final response = await _dio.post(
        '/api/firms/$firmId/toggle_active/',
        data: {},
      );
      if (response.data is Map && response.data['is_active'] != null) {
        return response.data['is_active'] == true;
      }
      return true;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<bool> toggleBlock(int firmId) async {
    try {
      final response = await _dio.post(
        '/api/firms/$firmId/toggle_block/',
        data: {},
      );
      if (response.data is Map && response.data['is_blocked'] != null) {
        return response.data['is_blocked'] == true;
      }
      return true;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> getFirmStats(int firmId) async {
    try {
      final response = await _dio.get('/api/firms/$firmId/stats/');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> changeAdmin(int firmId, int userId) async {
    try {
      await _dio.post('/api/auth/change-admin/', data: {'user_id': userId});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback to documented sub-path in OpenAPI schema if direct path 404s
        await _dio.post(
          '/api/admin/api/auth/change-admin/',
          data: {'user_id': userId},
        );
        return;
      }
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
