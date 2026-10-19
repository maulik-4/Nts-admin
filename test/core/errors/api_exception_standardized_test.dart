import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';

void main() {
  group('ApiException Standardized Envelope & Request ID Tests', () {
    test('parses standardized backend error format: { success: false, error: { ... } }', () {
      final json = {
        'success': false,
        'error': {
          'code': 'FIRM_BLOCKED',
          'message': 'Your firm has been suspended due to overdue billing.',
          'request_id': 'req-98765-xyz',
          'field_errors': {
            'account': ['Account inactive'],
          },
        },
      };

      final ex = ApiException.fromResponse(403, json);

      expect(ex.statusCode, 403);
      expect(ex.errorCode, 'FIRM_BLOCKED');
      expect(
        ex.message,
        'Your firm has been suspended due to overdue billing.',
      );
      expect(ex.requestId, 'req-98765-xyz');
      expect(ex.isFirmBlocked, true);
      expect(ex.isSubscriptionExpired, false);
      expect(ex.fieldErrors?['account'], contains('Account inactive'));
    });

    test('parses SUBSCRIPTION_EXPIRED code accurately', () {
      final json = {
        'code': 'SUBSCRIPTION_EXPIRED',
        'message': 'Your firm trial has lapsed. Please renew.',
        'request_id': 'req-sub-001',
      };

      final ex = ApiException.fromResponse(402, json);

      expect(ex.statusCode, 402);
      expect(ex.errorCode, 'SUBSCRIPTION_EXPIRED');
      expect(ex.isSubscriptionExpired, true);
      expect(ex.isFirmBlocked, false);
      expect(ex.requestId, 'req-sub-001');
    });

    test('extracts correlation ID from header if not in payload body', () {
      final ex = ApiException.fromResponse(500, {
        'detail': 'Internal database connection timeout',
      }, requestIdHeader: 'x-req-trace-777');

      expect(ex.statusCode, 500);
      expect(ex.message, 'Internal database connection timeout');
      expect(ex.requestId, 'x-req-trace-777');
    });
  });
}
