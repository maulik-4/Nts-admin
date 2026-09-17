import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/branding_models.dart';
import '../models/firm_profile.dart';

final brandingRepositoryProvider = Provider<BrandingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BrandingRepository(dio);
});

class BrandingRepository {
  final Dio _dio;

  BrandingRepository(this._dio);

  /// Fetches complete law firm profile including branding, colors, typography, and logo.
  Future<FirmProfile> getFirmProfile() async {
    try {
      final response = await _dio.get('/api/profile/firm/');
      if (response.data is Map<String, dynamic>) {
        return FirmProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return const FirmProfile(id: 0, name: '');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Updates firm branding configuration with multipart/form-data support for logo upload.
  Future<FirmProfile> updateFirmBranding({
    required String themeColor,
    required String accentColor,
    required String fontFamily,
    required bool sidebarDark,
    String? logoFilePath,
    String? logoFileName,
    List<int>? logoBytes,
  }) async {
    try {
      final map = <String, dynamic>{
        'theme_color': themeColor,
        'accent_color': accentColor,
        'font_family': fontFamily,
        'sidebar_dark': sidebarDark,
      };

      if (logoFilePath != null && logoFilePath.isNotEmpty) {
        map['logo'] = await MultipartFile.fromFile(
          logoFilePath,
          filename: logoFileName ?? 'logo.png',
        );
      } else if (logoBytes != null && logoBytes.isNotEmpty) {
        map['logo'] = MultipartFile.fromBytes(
          logoBytes,
          filename: logoFileName ?? 'logo.png',
        );
      }

      final formData = FormData.fromMap(map);
      await _dio.patch('/api/profile/firm/', data: formData);
      return await getFirmProfile();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

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
