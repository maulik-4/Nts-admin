import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/subscriptions/presentation/screens/firm_suspended_screen.dart';
import 'package:flutter_application_1/features/subscriptions/presentation/screens/subscription_expired_screen.dart';

void main() {
  group('Paywall Barrier Screens Widget Tests', () {
    testWidgets(
      'FirmSuspendedScreen renders suspension title, message, and correlation ID',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FirmSuspendedScreen(
                message:
                    'Account suspended due to outstanding compliance review.',
                requestId: 'req-susp-9901',
              ),
            ),
          ),
        );

        expect(find.text('Firm Workspace Suspended'), findsOneWidget);
        expect(
          find.text('Account suspended due to outstanding compliance review.'),
          findsOneWidget,
        );
        expect(find.textContaining('req-susp-9901'), findsOneWidget);
        expect(find.text('Email Support'), findsOneWidget);
      },
    );

    testWidgets(
      'SubscriptionExpiredScreen renders expiration alert and renew CTA',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubscriptionExpiredScreen(
                message: 'Your active subscription period has lapsed.',
                requestId: 'req-exp-4455',
              ),
            ),
          ),
        );

        expect(find.text('Subscription Plan Expired'), findsOneWidget);
        expect(
          find.text('Your active subscription period has lapsed.'),
          findsOneWidget,
        );
        expect(find.textContaining('req-exp-4455'), findsOneWidget);
      },
    );
  });
}
