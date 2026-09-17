import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_models.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return NotificationsRepository(dio);
});

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _dio.get('/api/notifications/list/');
      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) => NotificationItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/api/notifications/list/mark_all_as_read/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.post('/api/notifications/list/$id/mark_as_read/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _dio.get('/api/notifications/preferences/');
      if (response.data is Map<String, dynamic>) {
        return NotificationPreferences.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const NotificationPreferences();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      await _dio.patch('/api/notifications/preferences/', data: prefs);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Register device token with backend FCM endpoint.
  /// Handles missing DB tables/backend errors gracefully without throwing.
  Future<bool> saveDeviceToken(String token) async {
    try {
      await _dio.post('/api/notifications/save-token/', data: {'token': token});
      return true;
    } catch (e) {
      developer.log(
        'FCM token registration omitted or not supported by backend DB: $e',
        name: 'NotificationsRepository',
      );
      return false;
    }
  }
}
