import 'dart:convert';

import '../../domain/models/auth_response.dart';
import '../../domain/models/user.dart';

class AuthTokenResponse {
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? rawResponse;

  const AuthTokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.rawResponse,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    // Look for common token keys returned by DRF JWT or Token Auth
    String token = '';
    if (json['access'] != null) {
      token = json['access'].toString();
    } else if (json['token'] != null) {
      token = json['token'].toString();
    } else if (json['key'] != null) {
      token = json['key'].toString();
    } else if (json['jwt'] != null) {
      token = json['jwt'].toString();
    }

    String? refresh;
    if (json['refresh'] != null) {
      refresh = json['refresh'].toString();
    }

    return AuthTokenResponse(
      accessToken: token,
      refreshToken: refresh,
      rawResponse: json,
    );
  }

  /// Strongly typed User parsed directly from the login response.
  User? get user {
    if (rawResponse != null) {
      final userMap = rawResponse!['user'] is Map<String, dynamic>
          ? rawResponse!['user'] as Map<String, dynamic>
          : rawResponse!;
      if (userMap.containsKey('role') || userMap.containsKey('id')) {
        return User.fromJson(userMap);
      }
    }
    return null;
  }

  AuthResponse toAuthResponse() {
    final parsedUser =
        user ??
        User(
          id: userId ?? 0,
          username: username ?? '',
          email: '',
          role: role ?? '',
        );
    return AuthResponse(
      access: accessToken,
      refresh: refreshToken ?? '',
      user: parsedUser,
      rawResponse: rawResponse,
    );
  }

  Map<String, dynamic>? get jwtPayload {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      String normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payloadString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? get role {
    final payload = jwtPayload;
    final userMap = rawResponse?['user'] is Map<String, dynamic>
        ? rawResponse!['user'] as Map<String, dynamic>
        : null;
    return userMap?['role']?.toString() ??
        payload?['role']?.toString() ??
        payload?['user_role']?.toString() ??
        rawResponse?['role']?.toString();
  }

  String? get username {
    final payload = jwtPayload;
    final userMap = rawResponse?['user'] is Map<String, dynamic>
        ? rawResponse!['user'] as Map<String, dynamic>
        : null;
    return userMap?['username']?.toString() ??
        payload?['username']?.toString() ??
        rawResponse?['username']?.toString();
  }

  int? get userId {
    final payload = jwtPayload;
    final userMap = rawResponse?['user'] is Map<String, dynamic>
        ? rawResponse!['user'] as Map<String, dynamic>
        : null;
    final idVal =
        userMap?['id'] ??
        payload?['user_id'] ??
        payload?['id'] ??
        rawResponse?['id'];
    if (idVal is int) return idVal;
    if (idVal is String) return int.tryParse(idVal);
    return null;
  }
}
