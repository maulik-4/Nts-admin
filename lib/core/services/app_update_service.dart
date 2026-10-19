import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_update_info.dart';

class AppUpdateService {
  final Dio _dio;

  // Current client build defaults (from pubspec version: 1.0.1+2)
  static const String currentAppVersion = '1.0.1';
  static const int currentAppBuildNumber = 2;

  AppUpdateService(this._dio);

  Future<AppUpdateInfo> checkForUpdate({
    String currentVersion = currentAppVersion,
    int currentBuildNumber = currentAppBuildNumber,
  }) async {
    try {
      final response = await _dio.get(
        '/app/version/',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return AppUpdateInfo.fromJson(
          json: response.data as Map<String, dynamic>,
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
        );
      }
    } catch (e) {
      debugPrint(
        '[APP_UPDATE] Version check endpoint not reachable or using offline defaults: $e',
      );
    }

    // Default to up-to-date if server check fails or endpoint is not active yet
    return AppUpdateInfo(
      status: AppUpdateStatus.upToDate,
      currentVersion: currentVersion,
      currentBuildNumber: currentBuildNumber,
      latestVersion: currentVersion,
      latestBuildNumber: currentBuildNumber,
      minRequiredVersion: currentVersion,
      minRequiredBuildNumber: currentBuildNumber,
    );
  }

  Future<bool> launchUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[APP_UPDATE] Error opening update URL: $e');
    }
    return false;
  }
}
