import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/events/app_events.dart';

/// Global widget listener monitoring AppEventBus for FIRM_BLOCKED and SUBSCRIPTION_EXPIRED events.
class PaywallBarrierListener extends ConsumerStatefulWidget {
  final Widget child;

  const PaywallBarrierListener({super.key, required this.child});

  @override
  ConsumerState<PaywallBarrierListener> createState() =>
      _PaywallBarrierListenerState();
}

class _PaywallBarrierListenerState
    extends ConsumerState<PaywallBarrierListener> {
  StreamSubscription<AppEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = AppEventBus.instance.stream.listen((event) {
      if (!mounted) return;
      if (event is FirmBlockedEvent) {
        context.go(
          '/firm-blocked',
          extra: {'message': event.message, 'requestId': event.requestId},
        );
      } else if (event is SubscriptionExpiredEvent) {
        context.go(
          '/subscription-expired',
          extra: {'message': event.message, 'requestId': event.requestId},
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
