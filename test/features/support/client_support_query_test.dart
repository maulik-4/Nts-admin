import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/routing/role_guard.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/support/data/models/support_ticket.dart';
import 'package:flutter_application_1/features/support/data/repositories/support_repository.dart';

void main() {
  group('Client Support & Help Queries Tests', () {
    test('Client role possesses viewSupport and viewDashboard capabilities', () {
      expect(
        RoleCapabilities.hasCapability(
          UserRole.client,
          UserCapability.viewSupport,
        ),
        isTrue,
      );
      expect(
        RoleCapabilities.hasCapability(
          UserRole.client,
          UserCapability.viewDashboard,
        ),
        isTrue,
      );
      expect(
        RoleCapabilities.hasCapability(
          UserRole.client,
          UserCapability.viewProfile,
        ),
        isTrue,
      );
    });

    test('RoleGuard allows client to access /client/support routes', () {
      final resList = RoleGuard.evaluate(
        userRole: UserRole.client,
        currentPath: '/client/support',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(resList, isNull);

      final resDetail = RoleGuard.evaluate(
        userRole: UserRole.client,
        currentPath: '/client/support/12',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(resDetail, isNull);
    });

    test('RoleGuard redirects client accessing firm support paths to client support view', () {
      final resRedirect = RoleGuard.evaluate(
        userRole: UserRole.client,
        currentPath: '/app/more/support',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(resRedirect, equals('/client/support'));

      final resDetailRedirect = RoleGuard.evaluate(
        userRole: UserRole.client,
        currentPath: '/app/more/support/42',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(resDetailRedirect, equals('/client/support/42'));

      final resDirectRedirect = RoleGuard.evaluate(
        userRole: UserRole.client,
        currentPath: '/app/support',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(resDirectRedirect, equals('/client/support'));
    });

    test('SupportTicket correctly parses client-submitted legal query payload', () {
      final json = {
        'id': 7,
        'ticket_number': 'HP-130616',
        'firm': 15,
        'firm_name': 'Test Firm fe69b5',
        'created_by': {
          'id': 36,
          'username': 'test_client_uniq',
          'email': 'client_test_unique_123@example.com',
        },
        'assigned_to': null,
        'subject': 'Client legal assistance needed',
        'description': 'Need help reviewing hearing documents',
        'category': 'legal',
        'priority': 'normal',
        'status': 'open',
        'created_at': '2026-10-19T09:27:10.000537Z',
        'updated_at': '2026-10-19T09:27:10.000582Z',
        'resolved_at': null,
        'replies': [
          {
            'id': 2,
            'author': {'username': 'test_client_uniq'},
            'message': 'Client follow-up inquiry',
            'is_staff_reply': false,
            'created_at': '2026-10-19T09:29:42.053558Z',
          },
        ],
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, 7);
      expect(ticket.ticketNumber, 'HP-130616');
      expect(ticket.subject, 'Client legal assistance needed');
      expect(ticket.category, 'legal');
      expect(ticket.priority, 'normal');
      expect(ticket.status, 'open');
      expect(ticket.isResolved, isFalse);
      expect(ticket.replies.length, 1);
      expect(ticket.replies.first.authorName, 'test_client_uniq');
      expect(ticket.replies.first.isStaffReply, isFalse);
      expect(ticket.replies.first.message, 'Client follow-up inquiry');
    });

    test('SupportRepository createTicket posts correct payload structure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.hphighcourt.site'));
      dio.httpClientAdapter = _MockHttpClientAdapter((options) async {
        if (options.path == '/api/support/' && options.method == 'POST') {
          final data = options.data as Map<String, dynamic>;
          expect(data['subject'], 'Urgent Court Query');
          expect(data['description'], 'Clarification for upcoming hearing date');
          expect(data['category'], 'legal');
          expect(data['priority'], 'high');

          return ResponseBody.fromString(
            '{"id":99,"ticket_number":"HP-999999","subject":"Urgent Court Query","description":"Clarification for upcoming hearing date","category":"legal","priority":"high","status":"open"}',
            201,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not found', 404);
      });

      final repository = SupportRepository(dio);
      final ticket = await repository.createTicket(
        subject: 'Urgent Court Query',
        description: 'Clarification for upcoming hearing date',
        category: 'legal',
        priority: 'high',
      );

      expect(ticket.id, 99);
      expect(ticket.ticketNumber, 'HP-999999');
      expect(ticket.category, 'legal');
      expect(ticket.priority, 'high');
      expect(ticket.status, 'open');
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) _handler;

  _MockHttpClientAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
