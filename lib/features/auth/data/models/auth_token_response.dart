import 'dart:convert';

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
    return payload?['role']?.toString() ??
        payload?['user_role']?.toString() ??
        rawResponse?['role']?.toString();
  }

  String? get username {
    final payload = jwtPayload;
    return payload?['username']?.toString() ??
        rawResponse?['username']?.toString();
  }

  int? get userId {
    final payload = jwtPayload;
    final idVal = payload?['user_id'] ?? payload?['id'] ?? rawResponse?['id'];
    if (idVal is int) return idVal;
    if (idVal is String) return int.tryParse(idVal);
    return null;
  }
}
