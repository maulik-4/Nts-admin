import 'user.dart';
import 'user_role.dart';

/// Strongly typed authentication response returned by backend login.
class AuthResponse {
  final String access;
  final String refresh;
  final User user;
  final Map<String, dynamic>? rawResponse;

  const AuthResponse({
    required this.access,
    required this.refresh,
    required this.user,
    this.rawResponse,
  });

  String get role => user.role;
  UserRole get userRole => user.userRole;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = (json['access'] ?? json['token'] ?? json['key'] ?? json['jwt'])?.toString() ?? '';
    final refreshToken = (json['refresh'] ?? '')?.toString() ?? '';

    final userObj = User.fromJson(
      json['user'] is Map<String, dynamic>
          ? json['user'] as Map<String, dynamic>
          : json,
    );

    return AuthResponse(
      access: accessToken,
      refresh: refreshToken,
      user: userObj,
      rawResponse: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'user': user.toJson(),
    };
  }
}
