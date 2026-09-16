class ApiEndpoints {
  ApiEndpoints._();

  // Authentication endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String acceptInvite = '/auth/accept-invite/';
  static const String addUser = '/auth/add-user/';
  static const String inviteFirm = '/auth/invite/firm/';
  static const String invitePlatform = '/auth/invite/platform/';
  static const String users = '/auth/users/';

  // User and Firm Profile
  static const String profileMe = '/profile/me/';
  static const String profileFirm = '/profile/firm/';
  static const String profileFirmWebsite = '/profile/firm/website/';
}
