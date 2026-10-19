import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/communication_preference_model.dart';
import '../models/whatsapp_message_model.dart';
import '../models/whatsapp_template_model.dart';

final whatsappRepositoryProvider = Provider<WhatsAppRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WhatsAppRepository(dio);
});

class WhatsAppRepository {
  final Dio _dio;

  WhatsAppRepository(this._dio);

  /// Endpoint 4.2: List Available WhatsApp Templates
  Future<List<WhatsAppTemplate>> getTemplates() async {
    try {
      final response = await _dio.get(ApiEndpoints.whatsappTemplates);
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => WhatsAppTemplate.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 4.1: Send WhatsApp Message
  Future<WhatsAppSendResult> sendMessage({
    required String recipientNumber,
    required String recipientName,
    required String template,
    required Map<String, dynamic> templateParams,
    int? clientId,
    int? caseId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.whatsappSend,
        data: {
          'recipient_number': recipientNumber.trim(),
          'recipient_name': recipientName.trim(),
          'template': template,
          'template_params': templateParams,
          'client_id': ?clientId,
          'case_id': ?caseId,
        },
      );
      return WhatsAppSendResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 4.3: Client Communication Preferences
  Future<CommunicationPreference> getPreferences(int clientId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.whatsappPreferences(clientId),
      );
      return CommunicationPreference.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> updatePreferences(
    int clientId,
    CommunicationPreference preference,
  ) async {
    try {
      await _dio.post(
        ApiEndpoints.whatsappPreferences(clientId),
        data: preference.toJson(),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
