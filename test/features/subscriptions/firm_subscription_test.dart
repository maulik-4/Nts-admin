import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/subscriptions/data/models/subscription_models.dart';
import 'package:flutter_application_1/features/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription Models Tests', () {
    test('SubscriptionPlan parses monthly and yearly prices and quotas', () {
      final json = {
        'id': 1,
        'name': 'Professional Plan',
        'monthly_price': '2999.00',
        'yearly_price': '29990.00',
        'max_clients': 50,
        'max_team_members': 5,
        'storage_limit_gb': 10,
        'message_limit': 500,
        'is_active': true,
      };

      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.id, equals(1));
      expect(plan.name, equals('Professional Plan'));
      expect(plan.monthlyPrice, equals(2999.0));
      expect(plan.yearlyPrice, equals(29990.0));
      expect(plan.maxClients, equals(50));
      expect(plan.maxTeamMembers, equals(5));
      expect(plan.storageLimitGb, equals(10));
      expect(plan.messageLimit, equals(500));
    });

    test('ActiveSubscription model parses active backend structure', () {
      final json = {
        'plan': 1,
        'plan_name': 'Professional Plan',
        'billing_cycle': 'yearly',
      };

      final active = ActiveSubscription.fromJson(json);
      expect(active.plan, equals(1));
      expect(active.planName, equals('Professional Plan'));
      expect(active.billingCycle, equals('yearly'));
    });

    test('FirmSubscription parses active response even without dates', () {
      final json = {'plan': 1, 'plan_name': 'Professional Plan'};

      final sub = FirmSubscription.fromJson(json);
      expect(sub.planId, equals(1));
      expect(sub.planName, equals('Professional Plan'));
      expect(sub.billingCycle, equals('monthly'));
    });
  });

  group('SubscriptionsRepository Subscription Flow Tests', () {
    late Dio dio;
    late SubscriptionsRepository repository;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site/api'));
      repository = SubscriptionsRepository(dio);
    });

    test('getActiveSubscription handles 404 gracefully as null', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/api/subscriptions/active/')) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                    data: {'message': 'No active plan'},
                  ),
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final active = await repository.getActiveSubscription();
      expect(active, isNull);
    });

    test(
      'subscribeToPlan sends correct billing payload (monthly and yearly)',
      () async {
        String? capturedPath;
        Map<String, dynamic>? capturedBody;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.contains('/subscribe/')) {
                capturedPath = options.path;
                capturedBody = options.data as Map<String, dynamic>?;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'message': 'Plan activated',
                      'plan': 'Professional Plan',
                    },
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );

        // 1. Monthly subscription
        final monthlyResult = await repository.subscribeToPlan(
          2,
          billing: 'monthly',
        );
        expect(capturedPath, equals('/api/plans/2/subscribe/'));
        expect(capturedBody, equals({'billing': 'monthly'}));
        expect(monthlyResult['message'], equals('Plan activated'));

        // 2. Yearly subscription
        final yearlyResult = await repository.subscribeToPlan(
          5,
          billing: 'yearly',
        );
        expect(capturedPath, equals('/api/plans/5/subscribe/'));
        expect(capturedBody, equals({'billing': 'yearly'}));
        expect(yearlyResult['message'], equals('Plan activated'));
      },
    );
  });
}
