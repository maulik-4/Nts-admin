import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_models.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsNotifierProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationItem>>
    >((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationsNotifier(repository);
    });

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsNotifierProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final NotificationsRepository _repository;

  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getNotifications());
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    state.whenData((list) {
      state = AsyncValue.data(
        list
            .map(
              (n) => NotificationItem(
                id: n.id,
                title: n.title,
                message: n.message,
                isRead: true,
                notificationType: n.notificationType,
                redirectUrl: n.redirectUrl,
                createdAt: n.createdAt,
              ),
            )
            .toList(),
      );
    });
  }

  Future<void> markAsRead(int id) async {
    await _repository.markAsRead(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list
            .map(
              (n) => n.id == id
                  ? NotificationItem(
                      id: n.id,
                      title: n.title,
                      message: n.message,
                      isRead: true,
                      notificationType: n.notificationType,
                      redirectUrl: n.redirectUrl,
                      createdAt: n.createdAt,
                    )
                  : n,
            )
            .toList(),
      );
    });
  }
}
