import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/subscriptions/data/models/subscription_models.dart';
import 'package:flutter_application_1/features/subscriptions/data/repositories/subscriptions_repository.dart';

class _MockDioAdapter implements HttpClientAdapter {
  final Map<String, dynamic> responses;
  final List<RequestOptions> requests = [];

  _MockDioAdapter(this.responses);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final key = '${options.method} ${options.path}';
    if (responses.containsKey(key)) {
      final res = responses[key];
      if (res is int) {
        return ResponseBody.fromString(
          '{"detail": "Error $res"}',
          res,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        res is String ? res : res.toString(),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"status": "ok"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('Platform SubscriptionPlan Model Tests', () {
    test('SubscriptionPlan parses is_deleted, description, and audit timestamps', () {
      final json = {
        'id': 5,
        'name': 'Gold Tier Plan',
        'monthly_price': '1499.00',
        'yearly_price': '14999.00',
        'max_clients': 250,
        'max_team_members': 25,
        'storage_limit_gb': 100,
        'message_limit': 10000,
        'is_active': true,
        'is_deleted': false,
        'description': 'Full-featured enterprise legal plan with priority support',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-02-01T00:00:00Z',
      };

      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.id, 5);
      expect(plan.name, 'Gold Tier Plan');
      expect(plan.isDeleted, isFalse);
      expect(plan.description, 'Full-featured enterprise legal plan with priority support');
      expect(plan.createdAt, isNotNull);
      expect(plan.updatedAt, isNotNull);

      final copy = plan.copyWith(
        isDeleted: true,
        description: 'Deprecated plan',
      );
      expect(copy.id, 5);
      expect(copy.isDeleted, isTrue);
      expect(copy.description, 'Deprecated plan');
      expect(copy.monthlyPrice, 1499.0);
    });
  });

  group('SubscriptionsRepository Super Admin Plans Tests', () {
    late Dio dio;
    late _MockDioAdapter mockAdapter;
    late SubscriptionsRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site'));
      mockAdapter = _MockDioAdapter({
        'GET /api/plans/': '''{
          "count": 2,
          "results": [
            {
              "id": 1,
              "name": "Standard Plan",
              "monthly_price": "999.00",
              "yearly_price": "9999.00",
              "max_clients": 50,
              "max_team_members": 5,
              "storage_limit_gb": 10,
              "is_active": true,
              "is_deleted": false,
              "description": "Base plan"
            },
            {
              "id": 2,
              "name": "Deleted Plan",
              "monthly_price": "500.00",
              "yearly_price": "5000.00",
              "max_clients": 10,
              "max_team_members": 2,
              "storage_limit_gb": 2,
              "is_active": false,
              "is_deleted": true,
              "description": "Legacy plan"
            }
          ]
        }''',
        'GET /api/clients/usage/': 403,
      });
      dio.httpClientAdapter = mockAdapter;
      repo = SubscriptionsRepository(dio);
    });

    test('getPlans parses paginated response and extracts all plans', () async {
      final plans = await repo.getPlans();
      expect(plans.length, 2);
      expect(plans.first.name, 'Standard Plan');
      expect(plans.first.isDeleted, isFalse);
      expect(plans[1].name, 'Deleted Plan');
      expect(plans[1].isDeleted, isTrue);
    });

    test('getClientUsage handles 403 gracefully for firm-less Super Admin', () async {
      final usage = await repo.getClientUsage();
      expect(usage.unlimited, isTrue);
      expect(usage.used, 0);
    });
  });
}
