import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/firms/data/models/tenant_firm.dart';
import 'package:flutter_application_1/features/firms/data/repositories/firms_repository.dart';

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
      if (res is int && res == 404) {
        return ResponseBody.fromString(
          '{"detail": "Not found"}',
          404,
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
  group('TenantFirm Model Tests', () {
    test('TenantFirm parses GST number and admin user details', () {
      final json = {
        'id': 42,
        'name': 'Justice Advocates LLP',
        'email': 'contact@justice.com',
        'phone': '9876543210',
        'city': 'Shimla',
        'state': 'Himachal Pradesh',
        'pan_number': 'ABCDE1234F',
        'gst_number': '02ABCDE1234F1Z5',
        'admin_user_id': 99,
        'admin_username': 'chief_counsel',
        'is_active': true,
        'is_blocked': false,
        'created_at': '2026-01-15T10:00:00Z',
      };

      final firm = TenantFirm.fromJson(json);
      expect(firm.id, 42);
      expect(firm.name, 'Justice Advocates LLP');
      expect(firm.email, 'contact@justice.com');
      expect(firm.phone, '9876543210');
      expect(firm.city, 'Shimla');
      expect(firm.state, 'Himachal Pradesh');
      expect(firm.panNumber, 'ABCDE1234F');
      expect(firm.gstNumber, '02ABCDE1234F1Z5');
      expect(firm.adminUserId, 99);
      expect(firm.adminUsername, 'chief_counsel');
      expect(firm.isActive, isTrue);
      expect(firm.isBlocked, isFalse);

      final copy = firm.copyWith(
        name: 'Justice Advocates & Partners',
        isActive: false,
        isBlocked: true,
      );
      expect(copy.id, 42);
      expect(copy.name, 'Justice Advocates & Partners');
      expect(copy.isActive, isFalse);
      expect(copy.isBlocked, isTrue);
      expect(copy.gstNumber, '02ABCDE1234F1Z5');
    });
  });

  group('FirmsRepository Super Admin API Tests', () {
    late Dio dio;
    late _MockDioAdapter mockAdapter;
    late FirmsRepository firmsRepo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site'));
      mockAdapter = _MockDioAdapter({
        'GET /api/firms/': '''{
          "count": 1,
          "next": null,
          "previous": null,
          "results": [
            {
              "id": 10,
              "name": "Himalayan Legal",
              "email": "himalayan@law.in",
              "gst_number": "02AAACH1234A1Z1",
              "is_active": true,
              "is_blocked": false
            }
          ]
        }''',
        'GET /api/firms/10/stats/': '''{
          "total_cases": 45,
          "active_cases": 28,
          "total_lawyers": 8,
          "total_staff": 4,
          "total_clients": 62,
          "storage_used_mb": 1024
        }''',
        'POST /api/firms/10/toggle_active/': '{"id": 10, "is_active": false}',
        'POST /api/firms/10/toggle_block/': '{"id": 10, "is_blocked": true}',
        'POST /api/auth/change-admin/': '{"status": "admin_changed"}',
      });
      dio.httpClientAdapter = mockAdapter;
      firmsRepo = FirmsRepository(dio);
    });

    test('getFirms parses paginated results payload', () async {
      final firms = await firmsRepo.getFirms();
      expect(firms.length, 1);
      expect(firms.first.id, 10);
      expect(firms.first.name, 'Himalayan Legal');
      expect(firms.first.gstNumber, '02AAACH1234A1Z1');
    });

    test(
      'getFirmStats fetches real metrics from GET /api/firms/{id}/stats/',
      () async {
        final stats = await firmsRepo.getFirmStats(10);
        expect(stats['total_cases'], 45);
        expect(stats['active_cases'], 28);
        expect(stats['total_lawyers'], 8);
        expect(stats['total_staff'], 4);
        expect(stats['total_clients'], 62);
        expect(stats['storage_used_mb'], 1024);

        expect(
          mockAdapter.requests.any(
            (r) => r.path == '/api/firms/10/stats/' && r.method == 'GET',
          ),
          isTrue,
        );
      },
    );

    test(
      'changeAdmin sends correct payload to /api/auth/change-admin/',
      () async {
        await firmsRepo.changeAdmin(10, 15);
        expect(
          mockAdapter.requests.any(
            (r) =>
                r.path == '/api/auth/change-admin/' &&
                r.method == 'POST' &&
                r.data is Map &&
                (r.data as Map)['user_id'] == 15,
          ),
          isTrue,
        );
      },
    );

    test('toggleActive calls POST /api/firms/{id}/toggle_active/', () async {
      final isActive = await firmsRepo.toggleActive(10);
      expect(isActive, isFalse);
      expect(
        mockAdapter.requests.any(
          (r) => r.path == '/api/firms/10/toggle_active/' && r.method == 'POST',
        ),
        isTrue,
      );
    });

    test('toggleBlock calls POST /api/firms/{id}/toggle_block/', () async {
      final isBlocked = await firmsRepo.toggleBlock(10);
      expect(isBlocked, isTrue);
      expect(
        mockAdapter.requests.any(
          (r) => r.path == '/api/firms/10/toggle_block/' && r.method == 'POST',
        ),
        isTrue,
      );
    });
  });
}
