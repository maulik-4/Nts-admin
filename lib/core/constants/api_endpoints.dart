class ApiEndpoints {
  ApiEndpoints._();

  // Authentication endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String acceptInvite = '/auth/accept-invite/';
  static const String forgotPassword = '/auth/forgot-password/';
  static const String resetPassword = '/auth/reset-password/';
  static const String addUser = '/auth/add-user/';
  static const String inviteFirm = '/auth/invite/firm/';
  static const String invitePlatform = '/auth/invite/platform/';
  static const String users = '/auth/users/';
  static const String changeAdmin = '/auth/change-admin/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String userFeedback = '/user_feedback/';

  // Super Admin & Firms
  static const String adminCreateFirm = '/admin/create-firm/';
  static const String firms = '/firms/';

  // User and Firm Profile
  static const String profileMe = '/profile/me/';
  static const String profileFirm = '/profile/firm/';
  static const String profileFirmWebsite = '/profile/firm/website/';

  // Clients
  static const String clients = '/clients/';
  static const String clientUsage = '/clients/usage/';

  // Cases & Hearings
  static const String cases = '/cases/';
  static const String hearings = '/hearings/';
  static const String upcomingHearings = '/hearings/upcoming_hearings/';

  // Documents
  static const String documents = '/documents/';

  // Payments & Billing
  static const String payments = '/payments/';

  // Subscriptions & Plans
  static const String plans = '/plans/';
  static const String subscriptions = '/subscriptions/';
  static const String activeSubscription = '/subscriptions/active/';
  static const String createOrder = '/subscriptions/create-order/';
  static const String verifyPayment = '/subscriptions/verify-payment/';

  // Tasks
  static const String tasks = '/tasks/';
  static const String taskStats = '/tasks/stats/';

  // Support Tickets
  static const String support = '/support/';
  static const String supportStats = '/support/stats/';

  // Notifications
  static const String notifications = '/notifications/list/';
  static const String notificationPrefs = '/notifications/preferences/';
  static const String saveFcmToken = '/notifications/save-token/';

  // Messaging
  static const String messages = '/messages/';
}
