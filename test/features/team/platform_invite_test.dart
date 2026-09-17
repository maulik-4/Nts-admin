import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/team/data/models/team_member.dart';
import 'package:flutter_application_1/features/team/data/repositories/team_repository.dart';
import 'package:flutter_application_1/features/team/presentation/providers/team_notifier.dart';

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
  group('TeamMember Super Admin Tests', () {
    test('parses json correctly for super_admin role', () {
      final json = {
        'id': 1,
        'username': 'platform_director',
        'email': 'director@hphighcourt.site',
        'role': 'super_admin',
        'firm': null,
      };

      final member = TeamMember.fromJson(json);

      expect(member.id, 1);
      expect(member.username, 'platform_director');
      expect(member.email, 'director@hphighcourt.site');
      expect(member.role, 'super_admin');
      expect(member.displayRole, 'Super Admin');
      expect(member.isSuperAdmin, isTrue);
      expect(member.isAdmin, isTrue);
      expect(member.firm.isEmpty, isTrue);
    });
  });

  group('TeamRepository & TeamNotifier Platform Invite Tests', () {
    late Dio dio;
    late _MockDioAdapter mockAdapter;
    late TeamRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site'));
      mockAdapter = _MockDioAdapter({
        'GET /api/auth/users/': '''[
          {
            "id": 1,
            "username": "super_user",
            "email": "super@platform.gov",
            "role": "super_admin",
            "firm": null
          }
        ]''',
        'POST /api/auth/invite/platform/':
            '{"status": "invited", "email": "new_super@platform.gov"}',
      });
      dio.httpClientAdapter = mockAdapter;
      repo = TeamRepository(dio);
    });

    test(
      'TeamRepository.invitePlatformUser calls POST /api/auth/invite/platform/',
      () async {
        await repo.invitePlatformUser(
          email: 'new_super@platform.gov',
          role: 'super_admin',
        );

        expect(
          mockAdapter.requests.any(
            (r) =>
                r.path == '/api/auth/invite/platform/' &&
                r.method == 'POST' &&
                r.data is Map &&
                (r.data as Map)['email'] == 'new_super@platform.gov' &&
                (r.data as Map)['role'] == 'super_admin',
          ),
          isTrue,
        );
      },
    );

    test(
      'TeamNotifier.invitePlatformUser invokes repository and reloads list',
      () async {
        final notifier = TeamNotifier(repo);
        await notifier.loadTeamMembers();

        expect(notifier.state.value?.length, 1);

        await notifier.invitePlatformUser(
          email: 'analyst@platform.gov',
          role: 'super_admin',
        );

        expect(
          mockAdapter.requests.any(
            (r) =>
                r.path == '/api/auth/invite/platform/' &&
                r.method == 'POST' &&
                r.data is Map &&
                (r.data as Map)['email'] == 'analyst@platform.gov',
          ),
          isTrue,
        );
      },
    );
  });
}
