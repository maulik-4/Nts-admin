import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/branding_models.dart';

final brandingRepositoryProvider = Provider<BrandingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BrandingRepository(dio);
});

class BrandingRepository {
  final Dio _dio;

  BrandingRepository(this._dio);

  Future<FirmWebsiteBranding> getWebsiteBranding() async {
    try {
      final response = await _dio.get('/api/profile/firm/website/');
      if (response.data is Map<String, dynamic>) {
        return FirmWebsiteBranding.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const FirmWebsiteBranding();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> updateWebsiteBranding(Map<String, dynamic> data) async {
    try {
      await _dio.patch('/api/profile/firm/website/', data: data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<FirmDetails> getFirmDetails() async {
    try {
      final response = await _dio.get('/api/profile/firm/');
      if (response.data is Map<String, dynamic>) {
        return FirmDetails.fromJson(response.data as Map<String, dynamic>);
      }
      return const FirmDetails(id: 0, name: '', email: '');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> updateFirmDetails(Map<String, dynamic> data) async {
    try {
      await _dio.patch('/api/profile/firm/', data: data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
