class EnvConfig {
  EnvConfig._();

  static const String baseUrl = 'https://api.hphighcourt.site/';
  static const String apiBaseUrl = 'https://api.hphighcourt.site/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
