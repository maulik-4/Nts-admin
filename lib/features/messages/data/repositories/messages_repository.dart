import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/message_model.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MessagesRepository(dio);
});

class MessagesRepository {
  final Dio _dio;

  MessagesRepository(this._dio);

  Future<List<MessageModel>> getMessages() async {
    try {
      final response = await _dio.get('/api/messages/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<MessageModel> sendMessage({
    required String content,
    required int firmId,
    required int senderId,
    required int receiverId,
    int? caseId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content,
        'firm': firmId,
        'sender': senderId,
        'receiver': receiverId,
      };
      if (caseId != null) {
        payload['case'] = caseId;
      }
      final response = await _dio.post('/api/messages/', data: payload);
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
