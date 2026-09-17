import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:flutter_application_1/features/payments/data/models/payment_model.dart';
import 'package:flutter_application_1/features/payments/data/repositories/payments_repository.dart';

class MockPaymentsRemoteDataSource implements PaymentsRemoteDataSource {
  final List<Payment> _payments = [
    const Payment(
      id: 2,
      amount: '15000.00',
      status: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      paymentMethodDisplay: 'UPI',
      clientName: 'Test Client 1',
      caseTitle: 'State vs Sharma',
      firm: 15,
      caseId: 4,
      clientId: 4,
    ),
  ];

  bool shouldThrowError = false;

  @override
  Future<List<Payment>> getPayments() async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Failed to fetch payments');
    }
    return _payments;
  }

  @override
  Future<Payment> getPayment(int id) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Payment not found');
    }
    return _payments.firstWhere((p) => p.id == id);
  }

  @override
  Future<Payment> createPayment(CreatePaymentRequest request) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Creation failed');
    }
    final payment = Payment(
      id: _payments.length + 1,
      amount: request.amount,
      status: request.status,
      paymentMethod: request.paymentMethod,
      caseId: request.caseId,
      clientId: request.clientId,
      firm: 15,
    );
    _payments.add(payment);
    return payment;
  }

  @override
  Future<Payment> updatePayment(int id, UpdatePaymentRequest request) async {
    if (shouldThrowError) throw const ApiException(message: 'Update failed');
    final index = _payments.indexWhere((p) => p.id == id);
    if (index == -1) throw const ApiException(message: 'Not found');
    final updated = _payments[index];
    return updated;
  }

  @override
  Future<void> deletePayment(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Delete failed');
    _payments.removeWhere((p) => p.id == id);
  }

  @override
  Future<String> notifyEmail(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Email failed');
    return 'Invoice emailed to client1@example.com';
  }

  @override
  Future<String> notifyWhatsapp(int id) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Twilio not configured');
    }
    return 'Receipt sent via WhatsApp';
  }
}

void main() {
  group('PaymentsRepository Tests', () {
    late MockPaymentsRemoteDataSource mockDataSource;
    late PaymentsRepository repository;

    setUp(() {
      mockDataSource = MockPaymentsRemoteDataSource();
      repository = PaymentsRepository(mockDataSource);
    });

    test('getPayments returns list of payments', () async {
      final payments = await repository.getPayments();
      expect(payments.length, 1);
      expect(payments.first.amount, '15000.00');
    });

    test('createPayment creates and stores payment', () async {
      const req = CreatePaymentRequest(
        amount: '8000.00',
        status: PaymentStatus.pending,
        paymentMethod: PaymentMethod.cash,
      );
      final created = await repository.createPayment(req);
      expect(created.amount, '8000.00');
      expect(created.status, PaymentStatus.pending);

      final all = await repository.getPayments();
      expect(all.length, 2);
    });

    test('deletePayment removes payment', () async {
      await repository.deletePayment(2);
      final all = await repository.getPayments();
      expect(all.isEmpty, true);
    });

    test('notifyEmail sends invoice receipt', () async {
      final msg = await repository.notifyEmail(2);
      expect(msg, contains('Invoice emailed'));
    });

    test('notifyWhatsapp sends WhatsApp receipt or reports error', () async {
      final msg = await repository.notifyWhatsapp(2);
      expect(msg, contains('WhatsApp'));

      mockDataSource.shouldThrowError = true;
      expect(() => repository.notifyWhatsapp(2), throwsA(isA<ApiException>()));
    });
  });
}
