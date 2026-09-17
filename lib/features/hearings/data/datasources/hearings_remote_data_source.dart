import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/hearing_model.dart';

final hearingsRemoteDataSourceProvider = Provider<HearingsRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return HearingsRemoteDataSource(dio);
});

class HearingsRemoteDataSource {
  final Dio _dio;

  HearingsRemoteDataSource(this._dio);

  Future<List<Hearing>> getHearings() async {
    try {
      final response = await _dio.get(ApiEndpoints.hearings);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Hearing.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Hearing.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Hearing> getHearing(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.hearings}$id/');
      if (response.data is Map<String, dynamic>) {
        return Hearing.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid hearing response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Hearing> createHearing(CreateHearingRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hearings,
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Hearing.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from hearing creation.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Hearing> updateHearing(int id, UpdateHearingRequest request) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.hearings}$id/',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Hearing.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from hearing update.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<List<Hearing>> getUpcomingHearings({int days = 7}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.upcomingHearings,
        queryParameters: {'days': days},
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Hearing.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Hearing.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> notifyClient(int id) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.hearings}$id/notify-client/',
        data: {},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Client notified successfully.'};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteHearing(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.hearings}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
