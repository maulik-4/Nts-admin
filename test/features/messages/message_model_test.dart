import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/messages/data/models/message_model.dart';

void main() {
  group('MessageModel Tests', () {
    test('parses JSON and serializes back correctly', () {
      final json = {
        'id': 505,
        'content': 'Please review the bail application draft by 5 PM.',
        'firm': 15,
        'sender': 3,
        'receiver': 4,
        'is_read': false,
        'case': 12,
        'created_at': '2025-03-05T11:20:00Z',
      };

      final msg = MessageModel.fromJson(json);

      expect(msg.id, 505);
      expect(msg.content, 'Please review the bail application draft by 5 PM.');
      expect(msg.firmId, 15);
      expect(msg.senderId, 3);
      expect(msg.receiverId, 4);
      expect(msg.isRead, isFalse);
      expect(msg.caseId, 12);
      expect(msg.createdAt, DateTime.parse('2025-03-05T11:20:00Z'));

      final encoded = msg.toJson();
      expect(encoded['id'], 505);
      expect(encoded['case'], 12);
      expect(
        encoded['content'],
        'Please review the bail application draft by 5 PM.',
      );
    });
  });
}
