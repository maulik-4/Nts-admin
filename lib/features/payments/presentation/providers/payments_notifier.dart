import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/payment_model.dart';
import '../../data/repositories/payments_repository.dart';

final paymentSearchQueryProvider = StateProvider<String>((ref) => '');
final paymentStatusFilterProvider = StateProvider<PaymentStatus?>(
  (ref) => null,
);
final paymentMethodFilterProvider = StateProvider<PaymentMethod?>(
  (ref) => null,
);

final paymentsNotifierProvider =
    StateNotifierProvider<PaymentsNotifier, AsyncValue<List<Payment>>>((ref) {
      final repository = ref.watch(paymentsRepositoryProvider);
      return PaymentsNotifier(repository);
    });

final filteredPaymentsProvider = Provider<AsyncValue<List<Payment>>>((ref) {
  final paymentsAsync = ref.watch(paymentsNotifierProvider);
  final searchQuery = ref
      .watch(paymentSearchQueryProvider)
      .toLowerCase()
      .trim();
  final statusFilter = ref.watch(paymentStatusFilterProvider);
  final methodFilter = ref.watch(paymentMethodFilterProvider);

  return paymentsAsync.whenData((payments) {
    return payments.where((p) {
      if (statusFilter != null && p.status != statusFilter) {
        return false;
      }
      if (methodFilter != null && p.paymentMethod != methodFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesClient =
            p.clientName?.toLowerCase().contains(searchQuery) ?? false;
        final matchesCase =
            p.caseTitle?.toLowerCase().contains(searchQuery) ?? false;
        final matchesMethod =
            p.paymentMethodDisplay?.toLowerCase().contains(searchQuery) ??
            p.paymentMethod.displayName.toLowerCase().contains(searchQuery);
        final matchesAmount = p.amount.contains(searchQuery);
        return matchesClient || matchesCase || matchesMethod || matchesAmount;
      }
      return true;
    }).toList();
  });
});

final paymentDetailProvider = FutureProvider.family<Payment, int>((
  ref,
  id,
) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  return repository.getPayment(id);
});

class PaymentsNotifier extends StateNotifier<AsyncValue<List<Payment>>> {
  final PaymentsRepository _repository;

  PaymentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getPayments());
  }

  Future<Payment> createPayment(CreatePaymentRequest request) async {
    final newPayment = await _repository.createPayment(request);
    state.whenData((list) {
      state = AsyncValue.data([newPayment, ...list]);
    });
    return newPayment;
  }

  Future<Payment> updatePayment(int id, UpdatePaymentRequest request) async {
    final updated = await _repository.updatePayment(id, request);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((p) => p.id == id ? updated : p).toList(),
      );
    });
    return updated;
  }

  Future<void> deletePayment(int id) async {
    await _repository.deletePayment(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((p) => p.id != id).toList());
    });
  }

  Future<String> notifyEmail(int id) => _repository.notifyEmail(id);

  Future<String> notifyWhatsapp(int id) => _repository.notifyWhatsapp(id);
}
