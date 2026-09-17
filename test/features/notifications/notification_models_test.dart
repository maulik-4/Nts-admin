import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/notifications/data/models/notification_models.dart';

void main() {
  group('Notification Models Tests', () {
    test('NotificationItem parses JSON and converts to JSON correctly', () {
      final json = {
        'id': 7,
        'title': 'Case Update',
        'message': 'Hearing scheduled for tomorrow at 10:30 AM',
        'is_read': false,
        'notification_type': 'case_hearing',
        'redirect_url': '/cases/12',
        'created_at': '2025-03-01T09:00:00Z',
      };

      final item = NotificationItem.fromJson(json);

      expect(item.id, 7);
      expect(item.title, 'Case Update');
      expect(item.message, 'Hearing scheduled for tomorrow at 10:30 AM');
      expect(item.isRead, isFalse);
      expect(item.notificationType, 'case_hearing');
      expect(item.redirectUrl, '/cases/12');
      expect(item.createdAt, DateTime.parse('2025-03-01T09:00:00Z'));

      final encoded = item.toJson();
      expect(encoded['id'], 7);
      expect(encoded['is_read'], isFalse);
    });

    test('NotificationPreferences handles nested maps and missing keys', () {
      final json = {
        'email': {'case_updates': true, 'daily_digest': false},
        'push': {'hearing_reminders': true},
      };

      final prefs = NotificationPreferences.fromJson(json);

      expect(prefs.emailPreferences['case_updates'], isTrue);
      expect(prefs.emailPreferences['daily_digest'], isFalse);
      expect(prefs.pushPreferences['hearing_reminders'], isTrue);

      final emptyPrefs = NotificationPreferences.fromJson({});
      expect(emptyPrefs.emailPreferences, isEmpty);
      expect(emptyPrefs.pushPreferences, isEmpty);
    });
  });
}
