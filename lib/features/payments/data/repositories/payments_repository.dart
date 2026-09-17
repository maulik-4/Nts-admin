import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/payments_remote_data_source.dart';
import '../models/payment_model.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final remoteDataSource = ref.watch(paymentsRemoteDataSourceProvider);
  return PaymentsRepository(remoteDataSource);
});

class PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepository(this._remoteDataSource);

  Future<List<Payment>> getPayments() => _remoteDataSource.getPayments();

  Future<Payment> getPayment(int id) => _remoteDataSource.getPayment(id);

  Future<Payment> createPayment(CreatePaymentRequest request) =>
      _remoteDataSource.createPayment(request);

  Future<Payment> updatePayment(int id, UpdatePaymentRequest request) =>
      _remoteDataSource.updatePayment(id, request);

  Future<void> deletePayment(int id) => _remoteDataSource.deletePayment(id);

  Future<String> notifyEmail(int id) => _remoteDataSource.notifyEmail(id);

  Future<String> notifyWhatsapp(int id) => _remoteDataSource.notifyWhatsapp(id);
}
