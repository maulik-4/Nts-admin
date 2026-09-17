import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/firms/data/repositories/firms_repository.dart';
import 'package:flutter_application_1/features/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:flutter_application_1/features/team/data/repositories/team_repository.dart';

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
  group('Super Admin Platform Management Tests', () {
    late Dio dio;
    late _MockDioAdapter mockAdapter;
    late FirmsRepository firmsRepo;
    late SubscriptionsRepository subsRepo;
    late TeamRepository teamRepo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site'));
      mockAdapter = _MockDioAdapter({
        'GET /api/firms/': '''[
          {
            "id": 1,
            "name": "Apex Legal Firm",
            "email": "contact@apex.law",
            "is_active": true,
            "is_blocked": false
          }
        ]''',
        'POST /api/admin/create-firm/': '{"status": "created"}',
        'PUT /api/firms/1/': '''{
          "id": 1,
          "name": "Apex Legal Firm Updated",
          "email": "updated@apex.law",
          "is_active": true,
          "is_blocked": false
        }''',
        'DELETE /api/firms/1/': '{"status": "deleted"}',
        'POST /api/firms/1/toggle_active/': '{"id": 1, "is_active": false}',
        'POST /api/firms/1/toggle_block/': '{"id": 1, "is_blocked": true}',
        'GET /api/plans/': '''[
          {
            "id": 1,
            "name": "Starter",
            "monthly_price": "999.00",
            "yearly_price": "9999.00",
            "max_clients": 20,
            "max_team_members": 3,
            "storage_limit_gb": 5,
            "is_active": true
          }
        ]''',
        'POST /api/plans/': '''{
          "id": 2,
          "name": "Enterprise",
          "monthly_price": "4999.00",
          "yearly_price": "49999.00",
          "max_clients": 500,
          "max_team_members": 50,
          "storage_limit_gb": 100,
          "is_active": true
        }''',
        'PUT /api/plans/1/': '''{
          "id": 1,
          "name": "Starter Plus",
          "monthly_price": "1299.00",
          "yearly_price": "12999.00",
          "max_clients": 30,
          "max_team_members": 5,
          "storage_limit_gb": 10,
          "is_active": true
        }''',
        'DELETE /api/plans/1/': '{"status": "deleted"}',
        'POST /api/auth/add-user/': '{"status": "user_added"}',
      });
      dio.httpClientAdapter = mockAdapter;
      firmsRepo = FirmsRepository(dio);
      subsRepo = SubscriptionsRepository(dio);
      teamRepo = TeamRepository(dio);
    });

    test('FirmsRepository getFirms parses list of tenant firms', () async {
      final firms = await firmsRepo.getFirms();
      expect(firms.length, 1);
      expect(firms.first.id, 1);
      expect(firms.first.name, 'Apex Legal Firm');
    });

    test('FirmsRepository createFirm sends request payload', () async {
      await firmsRepo.createFirm({
        'firm_name': 'New Firm',
        'email': 'admin@newfirm.com',
        'username': 'admin_new',
        'password': 'password123',
      });
      expect(
        mockAdapter.requests.any(
          (r) => r.path == '/api/admin/create-firm/' && r.method == 'POST',
        ),
        isTrue,
      );
    });

    test(
      'FirmsRepository updateFirm calls PUT and returns updated firm',
      () async {
        final updated = await firmsRepo.updateFirm(1, {
          'name': 'Apex Legal Firm Updated',
        });
        expect(updated.id, 1);
        expect(updated.name, 'Apex Legal Firm Updated');
      },
    );

    test('FirmsRepository deleteFirm dispatches DELETE', () async {
      await firmsRepo.deleteFirm(1);
      expect(
        mockAdapter.requests.any(
          (r) => r.path == '/api/firms/1/' && r.method == 'DELETE',
        ),
        isTrue,
      );
    });

    test(
      'FirmsRepository toggleActive and toggleBlock calls correct endpoints',
      () async {
        await firmsRepo.toggleActive(1);
        await firmsRepo.toggleBlock(1);
        expect(
          mockAdapter.requests.any(
            (r) => r.path == '/api/firms/1/toggle_active/',
          ),
          isTrue,
        );
        expect(
          mockAdapter.requests.any(
            (r) => r.path == '/api/firms/1/toggle_block/',
          ),
          isTrue,
        );
      },
    );

    test(
      'SubscriptionsRepository creates, updates, and deletes plans',
      () async {
        final created = await subsRepo.createPlan({
          'name': 'Enterprise',
          'monthly_price': '4999.00',
          'yearly_price': '49999.00',
          'max_clients': 500,
          'max_team_members': 50,
          'storage_limit_gb': 100,
        });
        expect(created.id, 2);
        expect(created.name, 'Enterprise');

        final updated = await subsRepo.updatePlan(1, {
          'name': 'Starter Plus',
          'monthly_price': '1299.00',
        });
        expect(updated.name, 'Starter Plus');

        await subsRepo.deletePlan(1);
        expect(
          mockAdapter.requests.any(
            (r) => r.path == '/api/plans/1/' && r.method == 'DELETE',
          ),
          isTrue,
        );
      },
    );

    test('TeamRepository addUser supports optional firm ID for platform provisioning', () async {
      await teamRepo.addUser(
        username: 'staff_user',
        email: 'staff@firm.com',
        password: 'password123',
        role: 'staff',
        firmId: 15,
      );
      expect(
        mockAdapter.requests.any(
          (r) =>
              r.path == '/api/auth/add-user/' &&
              r.data is Map &&
              (r.data as Map)['firm'] == 15,
        ),
        isTrue,
      );
    });
  });
}
