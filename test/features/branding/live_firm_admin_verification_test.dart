import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/core/routing/role_guard.dart';
import 'package:flutter_application_1/core/theme/firm_theme.dart';
import 'package:flutter_application_1/features/auth/domain/models/auth_response.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/branding/data/models/firm_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Live Firm Admin, Subscription, Branding & Same-Firm Lawyer Verification',
    () async {
      final client = HttpClient();

      // 1. FIRM ADMIN LOGIN & VERIFICATION
      final adminLoginReq = await client.postUrl(
        Uri.parse('https://api.hphighcourt.site/api/auth/login/'),
      );
      adminLoginReq.headers.contentType = ContentType.json;
      adminLoginReq.write(
        jsonEncode({
          'username': 'testlawyer_fe69b5',
          'password': 'TestPassword@123',
        }),
      );
      final adminLoginResp = await adminLoginReq.close();
      final adminLoginBody = await utf8.decodeStream(adminLoginResp);
      final adminData = jsonDecode(adminLoginBody) as Map<String, dynamic>;
      final adminAuth = AuthResponse.fromJson(adminData);
      final adminToken = adminAuth.access;

      expect(adminAuth.userRole, equals(UserRole.firmAdmin));
      expect(canManageFirmSubscription(adminAuth.userRole), isTrue);
      expect(canEditFirmBranding(adminAuth.userRole), isTrue);

      // Plans API
      final plansReq = await client.getUrl(
        Uri.parse('https://api.hphighcourt.site/api/plans/'),
      );
      plansReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $adminToken',
      );
      final plansResp = await plansReq.close();
      final plansBody = await utf8.decodeStream(plansResp);
      final plansList = jsonDecode(plansBody) as List;
      expect(plansResp.statusCode, equals(200));
      expect(plansList.isNotEmpty, isTrue);

      // Active Subscription API
      final activeReq = await client.getUrl(
        Uri.parse('https://api.hphighcourt.site/api/subscriptions/active/'),
      );
      activeReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $adminToken',
      );
      final activeResp = await activeReq.close();
      expect(
        activeResp.statusCode == 200 || activeResp.statusCode == 404,
        isTrue,
      );

      // Subscribe API with monthly billing
      final subReq = await client.postUrl(
        Uri.parse('https://api.hphighcourt.site/api/plans/1/subscribe/'),
      );
      subReq.headers.set(HttpHeaders.authorizationHeader, 'Bearer $adminToken');
      subReq.headers.contentType = ContentType.json;
      subReq.write(jsonEncode({'billing': 'monthly'}));
      final subResp = await subReq.close();
      expect(subResp.statusCode, equals(200));

      // Firm Profile GET
      final firmReq = await client.getUrl(
        Uri.parse('https://api.hphighcourt.site/api/profile/firm/'),
      );
      firmReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $adminToken',
      );
      final firmResp = await firmReq.close();
      final firmBody = await utf8.decodeStream(firmResp);
      final firmProfileJson = jsonDecode(firmBody) as Map<String, dynamic>;
      final adminFirmProfile = FirmProfile.fromJson(firmProfileJson);
      expect(firmResp.statusCode, equals(200));
      expect(adminFirmProfile.name.isNotEmpty, isTrue);

      // Firm Branding PATCH
      final patchReq = await client.patchUrl(
        Uri.parse('https://api.hphighcourt.site/api/profile/firm/'),
      );
      patchReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $adminToken',
      );
      patchReq.headers.contentType = ContentType.json;
      patchReq.write(
        jsonEncode({
          'theme_color': '#0D1B2A',
          'accent_color': '#C9A84C',
          'font_family': 'DM Sans, sans-serif',
          'sidebar_dark': true,
        }),
      );
      final patchResp = await patchReq.close();
      expect(patchResp.statusCode, equals(200));

      // 2. SAME-FIRM LAWYER LOGIN & INHERITANCE VERIFICATION
      final lawyerLoginReq = await client.postUrl(
        Uri.parse('https://api.hphighcourt.site/api/auth/login/'),
      );
      lawyerLoginReq.headers.contentType = ContentType.json;
      lawyerLoginReq.write(
        jsonEncode({
          'username': 'lawyer_7cc7d',
          'password': 'TestPassword@123',
        }),
      );
      final lawyerLoginResp = await lawyerLoginReq.close();
      final lawyerLoginBody = await utf8.decodeStream(lawyerLoginResp);
      final lawyerData = jsonDecode(lawyerLoginBody) as Map<String, dynamic>;
      final lawyerAuth = AuthResponse.fromJson(lawyerData);
      final lawyerToken = lawyerAuth.access;

      expect(lawyerAuth.userRole, equals(UserRole.lawyer));
      expect(lawyerAuth.user.firm, equals(adminAuth.user.firm));
      expect(canManageFirmSubscription(lawyerAuth.userRole), isFalse);
      expect(canEditFirmBranding(lawyerAuth.userRole), isFalse);
      expect(canViewFirmBranding(lawyerAuth.userRole), isTrue);

      // Lawyer GET /api/profile/firm/ inherits same firm branding
      final lawyerFirmReq = await client.getUrl(
        Uri.parse('https://api.hphighcourt.site/api/profile/firm/'),
      );
      lawyerFirmReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $lawyerToken',
      );
      final lawyerFirmResp = await lawyerFirmReq.close();
      final lawyerFirmBody = await utf8.decodeStream(lawyerFirmResp);
      final lawyerFirmProfile = FirmProfile.fromJson(
        jsonDecode(lawyerFirmBody),
      );
      final lawyerTheme = FirmTheme.fromProfile(lawyerFirmProfile);

      expect(lawyerFirmResp.statusCode, equals(200));
      expect(lawyerFirmProfile.id, equals(adminFirmProfile.id));
      expect(lawyerTheme.fontFamily, equals('DM Sans'));

      // Lawyer PATCH /api/profile/firm/ must be 403 Forbidden!
      final lawyerPatchReq = await client.patchUrl(
        Uri.parse('https://api.hphighcourt.site/api/profile/firm/'),
      );
      lawyerPatchReq.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $lawyerToken',
      );
      lawyerPatchReq.headers.contentType = ContentType.json;
      lawyerPatchReq.write(jsonEncode({'theme_color': '#990000'}));
      final lawyerPatchResp = await lawyerPatchReq.close();
      expect(lawyerPatchResp.statusCode, equals(403));

      // RouteGuard tests for Lawyer
      final lawyerBrandingRoute = RoleGuard.evaluate(
        userRole: lawyerAuth.userRole,
        currentPath: '/app/more/branding',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(lawyerBrandingRoute, equals('/app/more'));

      final lawyerSubRoute = RoleGuard.evaluate(
        userRole: lawyerAuth.userRole,
        currentPath: '/app/more/subscriptions',
        isAuthenticated: true,
        isInitial: false,
      );
      expect(lawyerSubRoute, equals('/app/more'));

      client.close();
    },
  );
}
