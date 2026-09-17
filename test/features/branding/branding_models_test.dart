import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/branding/data/models/branding_models.dart';

void main() {
  group('Branding Models Tests', () {
    test('FirmWebsiteBranding parses JSON and serializes back correctly', () {
      final json = {
        'tagline': 'Integrity in Justice',
        'about_text':
            'Premier litigation firm specializing in High Court matters',
        'theme_color': '#112233',
        'accent_color': '#FFD700',
        'website_phone': '+91 98765 43210',
        'website_email': 'contact@lexfirm.com',
        'whatsapp_number': '+91 98765 43210',
        'website_enabled': true,
        'website_template': 'modern',
      };

      final branding = FirmWebsiteBranding.fromJson(json);

      expect(branding.tagline, 'Integrity in Justice');
      expect(
        branding.aboutText,
        'Premier litigation firm specializing in High Court matters',
      );
      expect(branding.themeColor, '#112233');
      expect(branding.accentColor, '#FFD700');
      expect(branding.websitePhone, '+91 98765 43210');
      expect(branding.websiteEmail, 'contact@lexfirm.com');
      expect(branding.whatsappNumber, '+91 98765 43210');
      expect(branding.websiteEnabled, isTrue);
      expect(branding.websiteTemplate, 'modern');

      final serialized = branding.toJson();
      expect(serialized['tagline'], 'Integrity in Justice');
      expect(serialized['theme_color'], '#112233');
      expect(serialized['website_enabled'], isTrue);
    });

    test('FirmDetails parses JSON accurately', () {
      final json = {
        'id': 15,
        'name': 'Sharma & Associates',
        'email': 'office@sharma.law',
        'phone': '011-2345678',
        'address': 'Room 402, High Court Complex',
        'city': 'Shimla',
        'state': 'Himachal Pradesh',
        'pincode': '171001',
        'gstin': '02AAAAA0000A1Z5',
        'bar_registration': 'HP/123/2010',
      };

      final details = FirmDetails.fromJson(json);

      expect(details.id, 15);
      expect(details.name, 'Sharma & Associates');
      expect(details.city, 'Shimla');
      expect(details.gstin, '02AAAAA0000A1Z5');
      expect(details.barRegistration, 'HP/123/2010');
    });
  });
}
