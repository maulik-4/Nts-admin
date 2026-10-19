class PlatformPaymentGateway {
  final int id;
  final String provider;
  final String keyId;
  final String keySecret;
  final String webhookSecret;
  final bool isActive;
  final bool isTestMode;

  const PlatformPaymentGateway({
    this.id = 0,
    this.provider = 'razorpay',
    required this.keyId,
    required this.keySecret,
    this.webhookSecret = '',
    this.isActive = true,
    this.isTestMode = true,
  });

  factory PlatformPaymentGateway.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentGateway(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      provider: json['provider']?.toString() ?? 'razorpay',
      keyId: json['key_id']?.toString() ?? '',
      keySecret: json['key_secret']?.toString() ?? '',
      webhookSecret: json['webhook_secret']?.toString() ?? '',
      isActive: json['is_active'] == true,
      isTestMode: json['is_test_mode'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'key_id': keyId,
    'key_secret': keySecret,
    'webhook_secret': webhookSecret,
    'is_active': isActive,
    'is_test_mode': isTestMode,
  };
}

class AdminSubscriptionTransaction {
  final int id;
  final String orderId;
  final String? paymentId;
  final String firmName;
  final String planName;
  final double amount;
  final String status;
  final DateTime? createdAt;

  const AdminSubscriptionTransaction({
    required this.id,
    required this.orderId,
    this.paymentId,
    required this.firmName,
    required this.planName,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  factory AdminSubscriptionTransaction.fromJson(Map<String, dynamic> json) {
    return AdminSubscriptionTransaction(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id']?.toString() ?? json['id']?.toString() ?? '',
      paymentId: json['payment_id']?.toString(),
      firmName:
          json['firm_name']?.toString() ??
          (json['firm'] is Map ? json['firm']['name']?.toString() : null) ??
          'Firm',
      planName:
          json['plan_name']?.toString() ??
          (json['plan'] is Map ? json['plan']['name']?.toString() : null) ??
          'Subscription',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'completed',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
