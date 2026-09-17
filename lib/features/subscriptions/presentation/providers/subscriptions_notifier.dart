import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription_models.dart';
import '../../data/repositories/subscriptions_repository.dart';

class SubscriptionOverviewState {
  final FirmSubscription? activeSubscription;
  final ClientUsage? clientUsage;
  final List<SubscriptionPlan> availablePlans;
  final bool isRenewing;

  const SubscriptionOverviewState({
    this.activeSubscription,
    this.clientUsage,
    this.availablePlans = const [],
    this.isRenewing = false,
  });

  SubscriptionOverviewState copyWith({
    FirmSubscription? activeSubscription,
    ClientUsage? clientUsage,
    List<SubscriptionPlan>? availablePlans,
    bool? isRenewing,
  }) {
    return SubscriptionOverviewState(
      activeSubscription: activeSubscription ?? this.activeSubscription,
      clientUsage: clientUsage ?? this.clientUsage,
      availablePlans: availablePlans ?? this.availablePlans,
      isRenewing: isRenewing ?? this.isRenewing,
    );
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<
      SubscriptionNotifier,
      AsyncValue<SubscriptionOverviewState>
    >((ref) {
      final repository = ref.watch(subscriptionsRepositoryProvider);
      return SubscriptionNotifier(repository);
    });

class SubscriptionNotifier
    extends StateNotifier<AsyncValue<SubscriptionOverviewState>> {
  final SubscriptionsRepository _repository;

  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSubscriptionData();
  }

  Future<void> loadSubscriptionData() async {
    state = const AsyncValue.loading();
    try {
      final active = await _repository.getActiveSubscription();
      final usage = await _repository.getClientUsage();
      final plans = await _repository.getPlans();

      state = AsyncValue.data(
        SubscriptionOverviewState(
          activeSubscription: active,
          clientUsage: usage,
          availablePlans: plans,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> activatePlan(int planId, {String billing = 'monthly'}) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(isRenewing: true));
    }
    try {
      await _repository.subscribeToPlan(planId, billing: billing);
      await loadSubscriptionData();
    } catch (e, st) {
      if (current != null) {
        state = AsyncValue.data(current.copyWith(isRenewing: false));
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final platformPlansNotifierProvider =
    StateNotifierProvider<
      PlatformPlansNotifier,
      AsyncValue<List<SubscriptionPlan>>
    >((ref) {
      final repository = ref.watch(subscriptionsRepositoryProvider);
      return PlatformPlansNotifier(repository);
    });

class PlatformPlansNotifier
    extends StateNotifier<AsyncValue<List<SubscriptionPlan>>> {
  final SubscriptionsRepository _repository;

  PlatformPlansNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPlans();
  }

  Future<void> loadPlans() async {
    state = const AsyncValue.loading();
    try {
      final plans = await _repository.getPlans();
      state = AsyncValue.data(plans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPlan(Map<String, dynamic> data) async {
    await _repository.createPlan(data);
    await loadPlans();
  }

  Future<void> updatePlan(int planId, Map<String, dynamic> data) async {
    final updated = await _repository.updatePlan(planId, data);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((p) => p.id == planId ? updated : p).toList(),
    );
  }

  Future<void> deletePlan(int planId) async {
    await _repository.deletePlan(planId);
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((p) => p.id != planId).toList());
  }
}
