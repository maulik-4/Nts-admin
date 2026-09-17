import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/subscriptions/data/models/subscription_models.dart';

void main() {
  group('Subscription Models Tests', () {
    test('SubscriptionPlan parses JSON and formats prices correctly', () {
      final json = {
        'id': 2,
        'name': 'Pro Firm Plan',
        'monthly_price': '2999.00',
        'yearly_price': '29999.00',
        'max_clients': 100,
        'max_team_members': 10,
        'storage_limit_gb': 50,
        'message_limit': 5000,
        'is_active': true,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.id, 2);
      expect(plan.name, 'Pro Firm Plan');
      expect(plan.monthlyPrice, 2999.0);
      expect(plan.yearlyPrice, 29999.0);
      expect(plan.maxClients, 100);
      expect(plan.maxTeamMembers, 10);
      expect(plan.storageLimitGb, 50);
      expect(plan.messageLimit, 5000);
      expect(plan.isActive, isTrue);

      final encoded = plan.toJson();
      expect(encoded['name'], 'Pro Firm Plan');
      expect(encoded['monthly_price'], '2999.00');
    });

    test('FirmSubscription parses JSON and checks expiration', () {
      final pastDate = DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String();
      final json = {
        'id': 10,
        'firm': 15,
        'plan': 2,
        'plan_name': 'Pro Firm Plan',
        'start_date': '2025-01-01T00:00:00Z',
        'end_date': pastDate,
        'billing_cycle': 'monthly',
        'is_active': true,
        'is_trial': false,
      };

      final sub = FirmSubscription.fromJson(json);

      expect(sub.id, 10);
      expect(sub.firmId, 15);
      expect(sub.planId, 2);
      expect(sub.planName, 'Pro Firm Plan');
      expect(sub.billingCycle, 'monthly');
      expect(sub.isExpired, isTrue);
    });

    test('ClientUsage calculates usage percentage correctly', () {
      final capped = ClientUsage.fromJson({
        'used': 25,
        'limit': 50,
        'plan_name': 'Standard',
        'unlimited': false,
      });

      expect(capped.usagePercentage, 0.5);

      final unlimited = ClientUsage.fromJson({
        'used': 150,
        'limit': null,
        'plan_name': 'Enterprise',
        'unlimited': true,
      });

      expect(unlimited.usagePercentage, 0.0);
    });
  });
}
