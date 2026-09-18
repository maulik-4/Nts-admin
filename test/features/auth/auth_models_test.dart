import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/data/models/accept_invite_request.dart';
import 'package:flutter_application_1/features/auth/data/models/auth_token_response.dart';
import 'package:flutter_application_1/features/auth/data/models/login_request.dart';
import 'package:flutter_application_1/features/auth/data/models/register_request.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';

void main() {
  group('Auth Models Tests', () {
    test('LoginRequest serializes accurately', () {
      const req = LoginRequest(
        username: 'lawyer1',
        password: 'secure_password',
      );
      final json = req.toJson();
      expect(json['username'], 'lawyer1');
      expect(json['password'], 'secure_password');
      expect(json.length, 2);
    });

    test('LoginRequest includes fcm_token when provided', () {
      const req = LoginRequest(
        username: 'lawyer1',
        password: 'secure_password',
        fcmToken: 'sample_fcm_token_xyz',
      );
      final json = req.toJson();
      expect(json['username'], 'lawyer1');
      expect(json['password'], 'secure_password');
      expect(json['fcm_token'], 'sample_fcm_token_xyz');
      expect(json.length, 3);
    });

    test('AuthTokenResponse parses DRF access token', () {
      final json = {
        'access': 'sample_jwt_access_token',
        'refresh': 'sample_jwt_refresh_token',
      };
      final tokenResp = AuthTokenResponse.fromJson(json);
      expect(tokenResp.accessToken, 'sample_jwt_access_token');
      expect(tokenResp.refreshToken, 'sample_jwt_refresh_token');
    });

    test('AuthTokenResponse handles token key fallback', () {
      final json = {'token': 'legacy_auth_token'};
      final tokenResp = AuthTokenResponse.fromJson(json);
      expect(tokenResp.accessToken, 'legacy_auth_token');
      expect(tokenResp.refreshToken, isNull);
    });

    test('RegisterRequest serializes all required fields according to OpenAPI schema', () {
      const req = RegisterRequest(
        username: 'admin.firm',
        email: 'admin@firm.com',
        password: 'password123',
        firmName: 'Sharma & Associates',
        phone: '9876543210',
        address: '123 High Court Road',
        city: 'Shimla',
        state: 'Himachal Pradesh',
        pincode: '171001',
        panNumber: 'ABCDE1234F',
        gstNumber: '02ABCDE1234F1Z5',
      );

      final json = req.toJson();
      expect(json['username'], 'admin.firm');
      expect(json['email'], 'admin@firm.com');
      expect(json['password'], 'password123');
      expect(json['firm_name'], 'Sharma & Associates');
      expect(json['phone'], '9876543210');
      expect(json['address'], '123 High Court Road');
      expect(json['city'], 'Shimla');
      expect(json['state'], 'Himachal Pradesh');
      expect(json['pincode'], '171001');
      expect(json['pan_number'], 'ABCDE1234F');
      expect(json['gst_number'], '02ABCDE1234F1Z5');
    });

    test('AcceptInviteRequest serializes token, username, and password', () {
      const req = AcceptInviteRequest(
        token: 'invite_xyz_123',
        username: 'new_staff',
        password: 'staff_pass_123',
      );

      final json = req.toJson();
      expect(json['token'], 'invite_xyz_123');
      expect(json['username'], 'new_staff');
      expect(json['password'], 'staff_pass_123');
    });

    test('UserProfile roundtrip serialization', () {
      const profile = UserProfile(
        id: 42,
        username: 'counsel.advocate',
        email: 'counsel@highcourt.in',
        role: 'lawyer',
        firmId: 7,
        firmName: 'Apex Legal Group',
      );

      final jsonStr = profile.toJsonString();
      final restored = UserProfile.fromJsonString(jsonStr);

      expect(restored.id, 42);
      expect(restored.username, 'counsel.advocate');
      expect(restored.email, 'counsel@highcourt.in');
      expect(restored.role, 'lawyer');
      expect(restored.firmId, 7);
      expect(restored.firmName, 'Apex Legal Group');
    });
  });
}
