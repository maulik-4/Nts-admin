import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/communications/data/models/whatsapp_template_model.dart';
import 'package:flutter_application_1/features/communications/data/models/whatsapp_message_model.dart';
import 'package:flutter_application_1/features/communications/data/models/communication_preference_model.dart';

void main() {
  group('WhatsApp Communications Models Tests', () {
    test('WhatsAppTemplate parses list of templates correctly', () {
      final json = {
        'name': 'hearing_reminder',
        'label': 'Hearing Reminder',
        'body_preview': 'Dear {{1}}, reminder for case {{2}} on {{3}}.',
        'params': ['client_name', 'case_title', 'hearing_date'],
      };

      final tpl = WhatsAppTemplate.fromJson(json);

      expect(tpl.name, 'hearing_reminder');
      expect(tpl.label, 'Hearing Reminder');
      expect(tpl.params.length, 3);
      expect(tpl.params, contains('hearing_date'));
    });

    test('WhatsAppSendResult parses success response', () {
      final json = {
        'id': 101,
        'recipient_number': '+919876543210',
        'recipient_name': 'Ramesh Kumar',
        'template': 'hearing_reminder',
        'body': 'Reminder for case hearing',
        'provider': 'meta_cloud',
        'status': 'sent',
      };

      final result = WhatsAppSendResult.fromJson(json);

      expect(result.id, 101);
      expect(result.isSent, true);
      expect(result.status, 'sent');
      expect(result.provider, 'meta_cloud');
    });

    test('CommunicationPreference serialization & round-trip', () {
      const pref = CommunicationPreference(
        preferredChannel: 'whatsapp',
        whatsappConsent: true,
        whatsappNumber: '+919876543210',
      );

      final json = pref.toJson();
      expect(json['preferred_channel'], 'whatsapp');
      expect(json['whatsapp_consent'], true);
      expect(json['whatsapp_number'], '+919876543210');

      final restored = CommunicationPreference.fromJson(json);
      expect(restored.preferredChannel, 'whatsapp');
      expect(restored.whatsappConsent, true);
      expect(restored.whatsappNumber, '+919876543210');
    });
  });
}
