import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/data/models/user_feedback_request.dart';

void main() {
  group('UserFeedbackRequest', () {
    test('serializes fields correctly to JSON for user_feedback API', () {
      const request = UserFeedbackRequest(
        name: 'Advocate Rajesh',
        email: 'rajesh@legalchambers.com',
        phone: '+919876543210',
        companyName: 'Rajesh & Associates',
        message: 'Looking for firm onboarding assistance',
      );

      final json = request.toJson();

      expect(json['name'], 'Advocate Rajesh');
      expect(json['email'], 'rajesh@legalchambers.com');
      expect(json['phone'], '+919876543210');
      expect(json['company_name'], 'Rajesh & Associates');
      expect(json['message'], 'Looking for firm onboarding assistance');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'name': 'Maulik',
        'email': 'maulik@example.com',
        'phone': '1234567890',
        'company_name': 'Test Firm',
        'message': 'Test message',
      };

      final model = UserFeedbackRequest.fromJson(json);

      expect(model.name, 'Maulik');
      expect(model.email, 'maulik@example.com');
      expect(model.phone, '1234567890');
      expect(model.companyName, 'Test Firm');
      expect(model.message, 'Test message');
    });
  });
}
