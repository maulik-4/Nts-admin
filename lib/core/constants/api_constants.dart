import '../config/env_config.dart';
import 'api_endpoints.dart';

/// Centralized API constants for the application.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = EnvConfig.baseUrl;
  static const String apiBaseUrl = EnvConfig.apiBaseUrl;

  // Re-export common endpoints
  static const String login = ApiEndpoints.login;
  static const String register = ApiEndpoints.register;
  static const String acceptInvite = ApiEndpoints.acceptInvite;
  static const String profileMe = ApiEndpoints.profileMe;
  static const String tokenRefresh = '/auth/token/refresh/';
}
