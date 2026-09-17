class Client {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String? city;
  final String? idProof;
  final int firm;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    this.city,
    this.idProof,
    required this.firm,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString(),
      idProof: json['id_proof']?.toString(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'id_proof': idProof,
      'firm': firm,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? idProof,
    int? firm,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      idProof: idProof ?? this.idProof,
      firm: firm ?? this.firm,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateClientRequest {
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String? city;
  final int firm;

  const CreateClientRequest({
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    this.city,
    required this.firm,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'firm': firm,
    };
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (city != null && city!.trim().isNotEmpty) {
      map['city'] = city!.trim();
    }
    return map;
  }
}

class UpdateClientRequest {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final bool? isActive;

  const UpdateClientRequest({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name!.trim();
    if (phone != null) map['phone'] = phone!.trim();
    if (email != null) map['email'] = email!.trim();
    if (address != null) map['address'] = address!.trim();
    if (city != null) map['city'] = city!.trim();
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
