import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportRepository(dio);
});

class SupportRepository {
  final Dio _dio;

  SupportRepository(this._dio);

  Future<List<SupportTicket>> getTickets() async {
    try {
      final response = await _dio.get('/api/support/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SupportStats> getStats() async {
    try {
      final response = await _dio.get('/api/support/stats/');
      if (response.data is Map<String, dynamic>) {
        return SupportStats.fromJson(response.data as Map<String, dynamic>);
      }
      return const SupportStats();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final response = await _dio.post(
        '/api/support/',
        data: {
          'subject': subject,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      return SupportTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SupportTicket> getTicketDetail(int id) async {
    try {
      final response = await _dio.get('/api/support/$id/');
      return SupportTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<TicketReply> replyTicket(int id, String message) async {
    try {
      final response = await _dio.post(
        '/api/support/$id/reply/',
        data: {'message': message},
      );
      return TicketReply.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<SupportTicket> resolveTicket(int id) async {
    try {
      final response = await _dio.post('/api/support/$id/resolve/', data: {});
      return SupportTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
