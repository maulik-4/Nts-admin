import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/payment_gateway_model.dart';
import '../../data/repositories/subscriptions_repository.dart';

final adminPaymentGatewayProvider =
    FutureProvider.autoDispose<PlatformPaymentGateway?>((ref) async {
      final repo = ref.watch(subscriptionsRepositoryProvider);
      return repo.getPaymentGateway();
    });

final adminTransactionsProvider =
    FutureProvider.autoDispose<List<AdminSubscriptionTransaction>>((ref) async {
      final repo = ref.watch(subscriptionsRepositoryProvider);
      return repo.getSubscriptionTransactions();
    });
