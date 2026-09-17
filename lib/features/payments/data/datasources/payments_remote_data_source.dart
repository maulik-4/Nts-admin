import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return PaymentsRemoteDataSource(dio);
});

class PaymentsRemoteDataSource {
  final Dio _dio;

  PaymentsRemoteDataSource(this._dio);

  Future<List<Payment>> getPayments() async {
    try {
      final response = await _dio.get(ApiEndpoints.payments);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Payment.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Payment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Payment> getPayment(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.payments}$id/');
      if (response.data is Map<String, dynamic>) {
        return Payment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid payment response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Payment> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.payments,
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Payment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from payment creation.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Payment> updatePayment(int id, UpdatePaymentRequest request) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.payments}$id/',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Payment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from payment update.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.payments}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<String> notifyEmail(int id) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.payments}$id/notify-email/',
        data: {},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ??
            'Invoice sent via email successfully.';
      }
      return 'Invoice emailed successfully.';
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<String> notifyWhatsapp(int id) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.payments}$id/notify-whatsapp/',
        data: {},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ??
            'Receipt sent via WhatsApp successfully.';
      }
      return 'Receipt sent via WhatsApp.';
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
