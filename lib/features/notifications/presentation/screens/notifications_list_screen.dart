import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../data/models/notification_models.dart';
import '../providers/notifications_notifier.dart';

class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LexColors.canvasDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: LexColors.accentGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark Read'),
              style: TextButton.styleFrom(
                foregroundColor: LexColors.accentGold,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(notificationsNotifierProvider.notifier)
                      .markAllAsRead();
                  if (context.mounted) {
                    AppAlerts.showSuccess(
                      context,
                      'All notifications marked as read',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppAlerts.showError(context, 'Failed to update: $e');
                  }
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(notificationsNotifierProvider.notifier)
                .loadNotifications(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) => ShimmerBox(
            width: double.infinity,
            height: 90,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading notifications: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(notificationsNotifierProvider.notifier)
                      .loadNotifications(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LexColors.slatePrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? LexColors.surfaceDark : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 54,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Case updates, hearing reminders, and task alerts will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildNotificationCard(
              context,
              ref,
              notifications[idx],
              isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    bool isDark,
  ) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () {
        if (isUnread) {
          ref.read(notificationsNotifierProvider.notifier).markAsRead(item.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: LexCard(
        borderRadius: 16,
        leftAccentColor: isUnread ? LexColors.accentGold : null,
        backgroundColor: isDark
            ? (isUnread ? const Color(0xFF1E293B) : LexColors.surfaceDark)
            : (isUnread ? const Color(0xFFFBF8F1) : Colors.white),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread
                    ? LexColors.accentGold.withValues(alpha: 0.15)
                    : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_outlined,
                size: 20,
                color: isUnread
                    ? LexColors.accentGold
                    : (isDark ? Colors.white60 : Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : LexColors.slatePrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: LexColors.accentGold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.yMMMd().add_jm().format(item.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
