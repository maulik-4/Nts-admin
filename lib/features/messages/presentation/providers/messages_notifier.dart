import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/messages_repository.dart';

final messagesNotifierProvider =
    StateNotifierProvider<MessagesNotifier, AsyncValue<List<MessageModel>>>((
      ref,
    ) {
      final repository = ref.watch(messagesRepositoryProvider);
      return MessagesNotifier(repository);
    });

class MessagesNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final MessagesRepository _repository;

  MessagesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMessages());
  }

  Future<void> sendMessage({
    required String content,
    required int firmId,
    required int senderId,
    required int receiverId,
    int? caseId,
  }) async {
    final msg = await _repository.sendMessage(
      content: content,
      firmId: firmId,
      senderId: senderId,
      receiverId: receiverId,
      caseId: caseId,
    );
    state.whenData((list) {
      state = AsyncValue.data([...list, msg]);
    });
  }
}
