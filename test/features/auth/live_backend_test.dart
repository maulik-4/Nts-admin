import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/domain/models/auth_response.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/core/routing/role_guard.dart';

void main() {
  test('Live Backend API Authentication & RBAC Verification', () async {
    final client = HttpClient();

    final accounts = [
      {'u': 'testlawyer_fe69b5', 'p': 'TestPassword@123', 'expectedRole': UserRole.admin},
      {'u': 'lawyer_7cc7d', 'p': 'TestPassword@123', 'expectedRole': UserRole.lawyer},
      {'u': 'staff_7cc7d', 'p': 'TestPassword@123', 'expectedRole': UserRole.staff},
    ];

    for (final acc in accounts) {
      final req = await client.postUrl(Uri.parse('https://api.hphighcourt.site/api/auth/login/'));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'username': acc['u'], 'password': acc['p']}));
      final resp = await req.close();
      final body = await utf8.decodeStream(resp);

      expect(resp.statusCode, 200);

      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(jsonMap);

      expect(authResponse.access.isNotEmpty, isTrue);
      expect(authResponse.refresh.isNotEmpty, isTrue);
      expect(authResponse.userRole, acc['expectedRole']);
      expect(authResponse.user.firm, 15);

      // Verify route guards for this role:
      final blockedSuperAdmin = RoleGuard.evaluate(
        userRole: authResponse.userRole,
        currentPath: '/app/firms',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(blockedSuperAdmin, '/app/dashboard');
    }

    client.close();
  });
}
