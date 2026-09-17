import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/case_model.dart';

final casesRemoteDataSourceProvider = Provider<CasesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CasesRemoteDataSource(dio);
});

class CasesRemoteDataSource {
  final Dio _dio;

  CasesRemoteDataSource(this._dio);

  Future<List<Case>> getCases() async {
    try {
      final response = await _dio.get(ApiEndpoints.cases);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Case.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Case.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Case> getCase(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.cases}$id/');
      if (response.data is Map<String, dynamic>) {
        return Case.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid case response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Case> createCase(CreateCaseRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.cases,
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Case.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from case creation.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Case> updateCase(int id, UpdateCaseRequest request) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.cases}$id/',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Case.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from case update.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteCase(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.cases}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
