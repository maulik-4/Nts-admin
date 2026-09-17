class SubscriptionPlan {
  final int id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final int maxClients;
  final int maxTeamMembers;
  final int storageLimitGb;
  final int? messageLimit;
  final String? description;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxClients,
    required this.maxTeamMembers,
    required this.storageLimitGb,
    this.messageLimit,
    this.description,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  SubscriptionPlan copyWith({
    int? id,
    String? name,
    double? monthlyPrice,
    double? yearlyPrice,
    int? maxClients,
    int? maxTeamMembers,
    int? storageLimitGb,
    int? messageLimit,
    String? description,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      maxClients: maxClients ?? this.maxClients,
      maxTeamMembers: maxTeamMembers ?? this.maxTeamMembers,
      storageLimitGb: storageLimitGb ?? this.storageLimitGb,
      messageLimit: messageLimit ?? this.messageLimit,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Standard Plan',
      monthlyPrice:
          double.tryParse(json['monthly_price']?.toString() ?? '0') ?? 0.0,
      yearlyPrice:
          double.tryParse(json['yearly_price']?.toString() ?? '0') ?? 0.0,
      maxClients: json['max_clients'] as int? ?? 0,
      maxTeamMembers: json['max_team_members'] as int? ?? 0,
      storageLimitGb: json['storage_limit_gb'] as int? ?? 0,
      messageLimit: json['message_limit'] as int?,
      description: json['description']?.toString(),
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
    'name': name,
    'monthly_price': monthlyPrice.toStringAsFixed(2),
    'yearly_price': yearlyPrice.toStringAsFixed(2),
    'max_clients': maxClients,
    'max_team_members': maxTeamMembers,
    'storage_limit_gb': storageLimitGb,
    'message_limit': messageLimit,
    if (description != null) 'description': description,
    'is_active': isActive,
    'is_deleted': isDeleted,
  };
}

class FirmSubscription {
  final int id;
  final int firmId;
  final int? planId;
  final String? planName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String billingCycle;
  final bool isActive;
  final bool isTrial;

  const FirmSubscription({
    required this.id,
    required this.firmId,
    this.planId,
    this.planName,
    this.startDate,
    this.endDate,
    this.billingCycle = 'monthly',
    this.isActive = true,
    this.isTrial = false,
  });

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  factory FirmSubscription.fromJson(Map<String, dynamic> json) {
    return FirmSubscription(
      id: json['id'] as int? ?? 0,
      firmId: json['firm'] as int? ?? 0,
      planId: json['plan'] as int?,
      planName: json['plan_name'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      billingCycle: json['billing_cycle']?.toString() ?? 'monthly',
      isActive: json['is_active'] as bool? ?? true,
      isTrial: json['is_trial'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firm': firmId,
    'plan': planId,
    'plan_name': planName,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'billing_cycle': billingCycle,
    'is_active': isActive,
    'is_trial': isTrial,
  };
}

class ClientUsage {
  final int used;
  final int? limit;
  final String? planName;
  final bool unlimited;

  const ClientUsage({
    required this.used,
    this.limit,
    this.planName,
    this.unlimited = false,
  });

  double get usagePercentage {
    if (unlimited || limit == null || limit! <= 0) return 0.0;
    return (used / limit!).clamp(0.0, 1.0);
  }

  factory ClientUsage.fromJson(Map<String, dynamic> json) {
    return ClientUsage(
      used: json['used'] as int? ?? 0,
      limit: json['limit'] as int?,
      planName: json['plan_name'] as String?,
      unlimited: json['unlimited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'used': used,
    'limit': limit,
    'plan_name': planName,
    'unlimited': unlimited,
  };
}
