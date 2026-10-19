import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_gateway_model.dart';
import '../models/subscription_models.dart';

final subscriptionsRepositoryProvider = Provider<SubscriptionsRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return SubscriptionsRepository(dio);
});

class SubscriptionsRepository {
  final Dio _dio;

  SubscriptionsRepository(this._dio);

  Future<FirmSubscription?> getActiveSubscription() async {
    try {
      final response = await _dio.get('/api/subscriptions/active/');
      if (response.data is Map<String, dynamic>) {
        return FirmSubscription.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No active subscription currently
      }
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<List<FirmSubscription>> getSubscriptionsHistory() async {
    try {
      final response = await _dio.get('/api/subscriptions/');
      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) => FirmSubscription.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<ClientUsage> getClientUsage() async {
    try {
      final response = await _dio.get('/api/clients/usage/');
      if (response.data is Map<String, dynamic>) {
        return ClientUsage.fromJson(response.data as Map<String, dynamic>);
      }
      return const ClientUsage(used: 0, unlimited: true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        return const ClientUsage(used: 0, unlimited: true);
      }
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _dio.get('/api/plans/');
      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.data is Map && response.data['results'] is List) {
        return (response.data['results'] as List)
            .map(
              (item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SubscriptionPlan> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _dio.post('/api/plans/', data: planData);
      return SubscriptionPlan.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SubscriptionPlan> updatePlan(
    int planId,
    Map<String, dynamic> planData,
  ) async {
    try {
      final response = await _dio.put('/api/plans/$planId/', data: planData);
      return SubscriptionPlan.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deletePlan(int planId) async {
    try {
      await _dio.delete('/api/plans/$planId/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> subscribeToPlan(
    int planId, {
    String billing = 'monthly',
  }) async {
    try {
      final response = await _dio.post(
        '/api/plans/$planId/subscribe/',
        data: {'billing': billing},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'message': 'Plan activated'};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder({
    required int planId,
    required String billingCycle,
  }) async {
    try {
      final response = await _dio.post(
        '/subscriptions/create-order/',
        data: {
          'plan_id': planId,
          'billing': billingCycle,
          'billing_cycle': billingCycle,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      await _dio.post(
        '/subscriptions/verify-payment/',
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Super Admin: Retrieve platform Razorpay payment gateway credentials
  Future<PlatformPaymentGateway?> getPaymentGateway() async {
    try {
      final response = await _dio.get('/admin/payment-gateway/');
      if (response.data is Map<String, dynamic>) {
        return PlatformPaymentGateway.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Super Admin: Configure platform Razorpay payment gateway credentials
  Future<PlatformPaymentGateway> savePaymentGateway(
    PlatformPaymentGateway config,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/payment-gateway/',
        data: config.toJson(),
      );
      return PlatformPaymentGateway.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Super Admin: Audit all firm subscription transactions
  Future<List<AdminSubscriptionTransaction>>
  getSubscriptionTransactions() async {
    try {
      final response = await _dio.get('/admin/subscription-transactions/');
      final data = response.data;
      if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => AdminSubscriptionTransaction.fromJson(e))
            .toList();
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => AdminSubscriptionTransaction.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
