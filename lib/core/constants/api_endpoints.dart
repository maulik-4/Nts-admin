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

  // Client Portal Endpoints
  static const String clientLogin = '/client-portal/login/';
  static const String clientAcceptInvite = '/client-portal/accept-invite/';
  static const String clientInvite = '/client-portal/invite/';
  static const String clientHearings = '/client-portal/hearings/';
  static const String clientDocuments = '/client-portal/documents/';
  static String clientDocumentAccessLink(int docId) =>
      '/client-portal/documents/$docId/access-link/';
  static String clientDocumentDownload(
    int docId,
    String token, {
    String disposition = 'attachment',
  }) =>
      '/client-portal/documents/download/$docId/?token=$token&disposition=$disposition';

  // Firm Document Sharing & Preview Endpoints
  static String clientShareDocument(int clientId, int docId) =>
      '/clients/$clientId/documents/$docId/share/';
  static String clientSharedDocuments(int clientId) =>
      '/clients/$clientId/shared-documents/';
  static String documentPreview(int docId) => '/documents/$docId/preview/';

  // WhatsApp Communications Endpoints
  static const String whatsappSend = '/communications/whatsapp/send/';
  static const String whatsappTemplates = '/communications/whatsapp/templates/';
  static String whatsappPreferences(int clientId) =>
      '/clients/$clientId/communication-preferences/';
  static String whatsappMessageStatus(int msgId) =>
      '/communications/messages/$msgId/';

  // Admin Payment Gateway & Billing Transactions
  static const String adminPaymentGateway = '/admin/payment-gateway/';
  static const String adminSubscriptionTransactions =
      '/admin/subscription-transactions/';
}
