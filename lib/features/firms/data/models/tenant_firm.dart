class TenantFirm {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? panNumber;
  final String? gstNumber;
  final bool isActive;
  final bool isBlocked;
  final bool isVerified;
  final DateTime? createdAt;
  final int? adminUserId;
  final String? adminUsername;

  const TenantFirm({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.panNumber,
    this.gstNumber,
    this.isActive = true,
    this.isBlocked = false,
    this.isVerified = false,
    this.createdAt,
    this.adminUserId,
    this.adminUsername,
  });

  TenantFirm copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? panNumber,
    String? gstNumber,
    bool? isActive,
    bool? isBlocked,
    bool? isVerified,
    DateTime? createdAt,
    int? adminUserId,
    String? adminUsername,
  }) {
    return TenantFirm(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      panNumber: panNumber ?? this.panNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      adminUserId: adminUserId ?? this.adminUserId,
      adminUsername: adminUsername ?? this.adminUsername,
    );
  }

  factory TenantFirm.fromJson(Map<String, dynamic> json) {
    return TenantFirm(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['firm_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      panNumber: json['pan_number']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      isActive: json['is_active'] == true,
      isBlocked: json['is_blocked'] == true,
      isVerified: json['is_verified'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      adminUserId: json['admin_user_id'] is int
          ? json['admin_user_id'] as int
          : (json['admin'] is Map ? json['admin']['id'] as int? : null),
      adminUsername: json['admin_username']?.toString() ??
          (json['admin'] is Map ? json['admin']['username']?.toString() : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'pan_number': panNumber,
      'gst_number': gstNumber,
      'is_active': isActive,
      'is_blocked': isBlocked,
      'is_verified': isVerified,
    };
  }
}
