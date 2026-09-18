import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    test('NotificationService singleton instance is not null', () {
      final service1 = NotificationService.instance;
      final service2 = NotificationService.instance;
      expect(identical(service1, service2), isTrue);
    });

    test('Notification channel constants are properly configured', () {
      expect(NotificationService.channelId, 'vidhanta_notifications');
      expect(NotificationService.channelName, 'Vidhanta Notifications');
      expect(NotificationService.channelDescription.isNotEmpty, isTrue);
    });

    test(
      'NotificationService initialize does not throw in test environment',
      () async {
        final service = NotificationService.instance;
        // In a unit test environment without native Firebase/channels,
        // initialize() must handle missing native bindings gracefully without throwing.
        await expectLater(service.initialize(), completes);
        expect(service.isInitialized, isTrue);
      },
    );
  });
}
