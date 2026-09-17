import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_models.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSource(dio);
});

class DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSource(this._dio);

  Future<ClientUsage?> getClientUsage() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientUsage);
      if (response.data is Map<String, dynamic>) {
        return ClientUsage.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<TaskStats?> getTaskStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.taskStats);
      if (response.data is Map<String, dynamic>) {
        return TaskStats.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<SupportStats?> getSupportStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.supportStats);
      if (response.data is Map<String, dynamic>) {
        return SupportStats.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<SubscriptionInfo> getActiveSubscription() async {
    try {
      final response = await _dio.get(ApiEndpoints.activeSubscription);
      if (response.data is Map<String, dynamic>) {
        return SubscriptionInfo.fromJson(response.data as Map<String, dynamic>);
      }
      return SubscriptionInfo.none();
    } on DioException catch (e) {
      // 404 means no active plan, which is a normal state
      if (e.response?.statusCode == 404) {
        return SubscriptionInfo.none();
      }
      return SubscriptionInfo.none();
    } catch (_) {
      return SubscriptionInfo.none();
    }
  }
}
