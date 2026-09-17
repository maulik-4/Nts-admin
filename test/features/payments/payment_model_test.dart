import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/payments/data/models/payment_model.dart';

void main() {
  group('Payment Model & Enums Tests', () {
    test('PaymentStatus parsing and display names', () {
      expect(PaymentStatus.fromString('paid'), PaymentStatus.paid);
      expect(PaymentStatus.fromString('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('unknown'), PaymentStatus.pending);
      expect(PaymentStatus.fromString(null), PaymentStatus.pending);

      expect(PaymentStatus.paid.displayName, 'Paid');
      expect(PaymentStatus.pending.displayName, 'Pending');
    });

    test('PaymentMethod parsing and display names', () {
      expect(PaymentMethod.fromString('cash'), PaymentMethod.cash);
      expect(PaymentMethod.fromString('upi'), PaymentMethod.upi);
      expect(
        PaymentMethod.fromString('bank_transfer'),
        PaymentMethod.bankTransfer,
      );
      expect(PaymentMethod.fromString('card'), PaymentMethod.card);
      expect(PaymentMethod.fromString(null), PaymentMethod.cash);

      expect(PaymentMethod.bankTransfer.displayName, 'Bank Transfer');
      expect(PaymentMethod.upi.displayName, 'UPI');
    });

    test('parses Payment from backend json accurately', () {
      final json = {
        'id': 2,
        'client_name': 'Test Client 1',
        'case_title': 'State vs Sharma',
        'payment_method_display': 'UPI',
        'created_at': '2026-09-16T08:12:08.235506Z',
        'updated_at': '2026-09-16T08:12:08.235575Z',
        'is_active': true,
        'is_deleted': false,
        'amount': '15000.00',
        'status': 'paid',
        'payment_date': '2026-09-16T08:12:08.235674Z',
        'payment_method': 'upi',
        'firm': 15,
        'case': 4,
        'client': 4,
      };

      final payment = Payment.fromJson(json);

      expect(payment.id, 2);
      expect(payment.amount, '15000.00');
      expect(payment.amountValue, 15000.0);
      expect(payment.status, PaymentStatus.paid);
      expect(payment.isPaid, true);
      expect(payment.paymentMethod, PaymentMethod.upi);
      expect(payment.paymentMethodDisplay, 'UPI');
      expect(payment.clientName, 'Test Client 1');
      expect(payment.caseTitle, 'State vs Sharma');
      expect(payment.firm, 15);
      expect(payment.caseId, 4);
      expect(payment.clientId, 4);
      expect(payment.isActive, true);
    });

    test('CreatePaymentRequest and UpdatePaymentRequest formatting', () {
      const createReq = CreatePaymentRequest(
        amount: '25000.00',
        status: PaymentStatus.paid,
        paymentMethod: PaymentMethod.bankTransfer,
        caseId: 4,
        clientId: 2,
      );

      final cJson = createReq.toJson();
      expect(cJson['amount'], '25000.00');
      expect(cJson['status'], 'paid');
      expect(cJson['payment_method'], 'bank_transfer');
      expect(cJson['case'], 4);
      expect(cJson['client'], 2);

      const updateReq = UpdatePaymentRequest(status: PaymentStatus.paid);
      final uJson = updateReq.toJson();
      expect(uJson['status'], 'paid');
      expect(uJson.containsKey('amount'), false);
    });
  });
}
