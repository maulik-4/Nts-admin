enum PaymentStatus {
  paid,
  pending;

  String get value => name;

  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  static PaymentStatus fromString(String? val) {
    if (val == null) return PaymentStatus.pending;
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  cash,
  upi,
  bankTransfer,
  card;

  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.card:
        return 'card';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Card';
    }
  }

  static PaymentMethod fromString(String? val) {
    if (val == null) return PaymentMethod.cash;
    final normalized = val.toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'upi':
        return PaymentMethod.upi;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'card':
        return PaymentMethod.card;
      case 'cash':
      default:
        return PaymentMethod.cash;
    }
  }
}

class Payment {
  final int id;
  final String amount;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentMethodDisplay;
  final DateTime? paymentDate;
  final int? caseId;
  final String? caseTitle;
  final int? clientId;
  final String? clientName;
  final int firm;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.amount,
    this.status = PaymentStatus.pending,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentMethodDisplay,
    this.paymentDate,
    this.caseId,
    this.caseTitle,
    this.clientId,
    this.clientName,
    required this.firm,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == PaymentStatus.paid;

  double get amountValue => double.tryParse(amount) ?? 0.0;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      status: PaymentStatus.fromString(json['status']?.toString()),
      paymentMethod: PaymentMethod.fromString(
        json['payment_method']?.toString(),
      ),
      paymentMethodDisplay: json['payment_method_display']?.toString(),
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString())
          : null,
      caseId: json['case'] is int
          ? json['case'] as int
          : int.tryParse(json['case']?.toString() ?? ''),
      caseTitle: json['case_title']?.toString(),
      clientId: json['client'] is int
          ? json['client'] as int
          : int.tryParse(json['client']?.toString() ?? ''),
      clientName: json['client_name']?.toString(),
      firm: json['firm'] is int
          ? json['firm'] as int
          : int.tryParse(json['firm']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'status': status.value,
    'payment_method': paymentMethod.value,
    'payment_method_display': paymentMethodDisplay,
    'payment_date': paymentDate?.toIso8601String(),
    'case': caseId,
    'case_title': caseTitle,
    'client': clientId,
    'client_name': clientName,
    'firm': firm,
    'is_active': isActive,
    'is_deleted': isDeleted,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class CreatePaymentRequest {
  final String amount;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final int? caseId;
  final int? clientId;

  const CreatePaymentRequest({
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.caseId,
    this.clientId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'status': status.value,
      'payment_method': paymentMethod.value,
    };
    if (caseId != null) map['case'] = caseId;
    if (clientId != null) map['client'] = clientId;
    return map;
  }
}

class UpdatePaymentRequest {
  final String? amount;
  final PaymentStatus? status;
  final PaymentMethod? paymentMethod;
  final int? caseId;
  final int? clientId;

  const UpdatePaymentRequest({
    this.amount,
    this.status,
    this.paymentMethod,
    this.caseId,
    this.clientId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (amount != null) map['amount'] = amount;
    if (status != null) map['status'] = status!.value;
    if (paymentMethod != null) map['payment_method'] = paymentMethod!.value;
    if (caseId != null) map['case'] = caseId;
    if (clientId != null) map['client'] = clientId;
    return map;
  }
}
