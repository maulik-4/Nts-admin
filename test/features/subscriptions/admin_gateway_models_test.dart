import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/subscriptions/data/models/payment_gateway_model.dart';

void main() {
  group('Admin Gateway & Subscription Transactions Tests', () {
    test('PlatformPaymentGateway parses and serializes configuration', () {
      final json = {
        'id': 1,
        'provider': 'razorpay',
        'key_id': 'rzp_live_abcdef123456',
        'key_secret': 'super_secret_key_123',
        'webhook_secret': 'whsec_test99',
        'is_test_mode': false,
        'is_active': true,
      };

      final gateway = PlatformPaymentGateway.fromJson(json);

      expect(gateway.provider, 'razorpay');
      expect(gateway.keyId, 'rzp_live_abcdef123456');
      expect(gateway.keySecret, 'super_secret_key_123');
      expect(gateway.webhookSecret, 'whsec_test99');
      expect(gateway.isTestMode, false);
      expect(gateway.isActive, true);

      final outJson = gateway.toJson();
      expect(outJson['provider'], 'razorpay');
      expect(outJson['key_id'], 'rzp_live_abcdef123456');
      expect(outJson['key_secret'], 'super_secret_key_123');
      expect(outJson['webhook_secret'], 'whsec_test99');
      expect(outJson['is_test_mode'], false);
      expect(outJson['is_active'], true);
    });

    test('AdminSubscriptionTransaction parses backend transactions list', () {
      final json = {
        'id': 9988,
        'firm_name': 'Apex Advocates LLP',
        'plan_name': 'Enterprise Law Firm',
        'amount': '15000.00',
        'status': 'captured',
        'payment_id': 'pay_Rzp123456',
        'order_id': 'order_Rzp123456',
        'created_at': '2026-10-15T14:30:00Z',
      };

      final tx = AdminSubscriptionTransaction.fromJson(json);

      expect(tx.id, 9988);
      expect(tx.firmName, 'Apex Advocates LLP');
      expect(tx.planName, 'Enterprise Law Firm');
      expect(tx.amount, 15000.0);
      expect(tx.status, 'captured');
      expect(tx.paymentId, 'pay_Rzp123456');
      expect(tx.orderId, 'order_Rzp123456');
      expect(tx.createdAt, isNotNull);
    });
  });
}
