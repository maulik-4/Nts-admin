import '../../../hearings/data/models/hearing_model.dart';

class UpcomingHearingSummary {
  final int? id;
  final String title;
  final String date;
  final String? startTime;
  final String? courtName;

  const UpcomingHearingSummary({
    this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.courtName,
  });

  factory UpcomingHearingSummary.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UpcomingHearingSummary(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? ''),
        title: json['title']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        startTime: json['start_time']?.toString(),
        courtName: json['court_name']?.toString(),
      );
    } else if (json is String) {
      return UpcomingHearingSummary(title: json, date: '');
    }
    return const UpcomingHearingSummary(title: '', date: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'start_time': startTime,
      'court_name': courtName,
    };
  }
}

class Case {
  final int id;
  final String title;
  final String caseNumber;
  final String caseType;
  final String courtName;
  final String status; // 'open' or 'closed'
  final int client;
  final String? clientName;
  final String? assignedName;
  final int? assignedTo;
  final String? nextHearingDate;
  final UpcomingHearingSummary? upcomingHearing;
  final List<Hearing> hearings;
  final int firm;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Case({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.caseType,
    required this.courtName,
    required this.status,
    required this.client,
    this.clientName,
    this.assignedName,
    this.assignedTo,
    this.nextHearingDate,
    this.upcomingHearing,
    this.hearings = const [],
    required this.firm,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOpen => status.toLowerCase() == 'open';

  factory Case.fromJson(Map<String, dynamic> json) {
    List<Hearing> parsedHearings = [];
    if (json['hearings'] is List) {
      parsedHearings = (json['hearings'] as List)
          .map((item) => Hearing.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    UpcomingHearingSummary? parsedUpcoming;
    if (json['upcoming_hearing'] != null) {
      parsedUpcoming = UpcomingHearingSummary.fromJson(
        json['upcoming_hearing'],
      );
    }

    return Case(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      caseNumber: json['case_number']?.toString() ?? '',
      caseType: json['case_type']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      client: json['client'] is int
          ? json['client'] as int
          : int.tryParse(json['client']?.toString() ?? '0') ?? 0,
      clientName: json['client_name']?.toString(),
      assignedName: json['assigned_name']?.toString(),
      assignedTo: json['assigned_to'] is int
          ? json['assigned_to'] as int
          : int.tryParse(json['assigned_to']?.toString() ?? ''),
      nextHearingDate: json['next_hearing_date']?.toString(),
      upcomingHearing: parsedUpcoming,
      hearings: parsedHearings,
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
      'title': title,
      'case_number': caseNumber,
      'case_type': caseType,
      'court_name': courtName,
      'status': status,
      'client': client,
      'client_name': clientName,
      'assigned_name': assignedName,
      'assigned_to': assignedTo,
      'next_hearing_date': nextHearingDate,
      'upcoming_hearing': upcomingHearing?.toJson(),
      'hearings': hearings.map((h) => h.toJson()).toList(),
      'firm': firm,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Case copyWith({
    int? id,
    String? title,
    String? caseNumber,
    String? caseType,
    String? courtName,
    String? status,
    int? client,
    String? clientName,
    String? assignedName,
    int? assignedTo,
    String? nextHearingDate,
    UpcomingHearingSummary? upcomingHearing,
    List<Hearing>? hearings,
    int? firm,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Case(
      id: id ?? this.id,
      title: title ?? this.title,
      caseNumber: caseNumber ?? this.caseNumber,
      caseType: caseType ?? this.caseType,
      courtName: courtName ?? this.courtName,
      status: status ?? this.status,
      client: client ?? this.client,
      clientName: clientName ?? this.clientName,
      assignedName: assignedName ?? this.assignedName,
      assignedTo: assignedTo ?? this.assignedTo,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      upcomingHearing: upcomingHearing ?? this.upcomingHearing,
      hearings: hearings ?? this.hearings,
      firm: firm ?? this.firm,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateCaseRequest {
  final String title;
  final String caseNumber;
  final String caseType;
  final String courtName;
  final String status;
  final int client;
  final int firm;
  final String? nextHearingDate;

  const CreateCaseRequest({
    required this.title,
    required this.caseNumber,
    required this.caseType,
    required this.courtName,
    this.status = 'open',
    required this.client,
    required this.firm,
    this.nextHearingDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'case_number': caseNumber.trim(),
      'case_type': caseType.trim(),
      'court_name': courtName.trim(),
      'status': status,
      'client': client,
      'firm': firm,
    };
    if (nextHearingDate != null && nextHearingDate!.trim().isNotEmpty) {
      map['next_hearing_date'] = nextHearingDate!.trim();
    }
    return map;
  }
}

class UpdateCaseRequest {
  final String? title;
  final String? caseNumber;
  final String? caseType;
  final String? courtName;
  final String? status;
  final int? client;
  final String? nextHearingDate;
  final bool? isActive;

  const UpdateCaseRequest({
    this.title,
    this.caseNumber,
    this.caseType,
    this.courtName,
    this.status,
    this.client,
    this.nextHearingDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title!.trim();
    if (caseNumber != null) map['case_number'] = caseNumber!.trim();
    if (caseType != null) map['case_type'] = caseType!.trim();
    if (courtName != null) map['court_name'] = courtName!.trim();
    if (status != null) map['status'] = status;
    if (client != null) map['client'] = client;
    if (nextHearingDate != null) map['next_hearing_date'] = nextHearingDate;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
