class ClientPortalDashboardData {
  final String clientName;
  final String clientEmail;
  final FirmInfo? firm;
  final List<LegalPersonnel> firmAdmins;
  final List<LegalPersonnel> assignedLawyers;
  final HearingItem? nextHearing;
  final List<HearingItem> hearings;
  final List<ClientCaseItem> cases;

  const ClientPortalDashboardData({
    required this.clientName,
    required this.clientEmail,
    this.firm,
    required this.firmAdmins,
    required this.assignedLawyers,
    this.nextHearing,
    required this.hearings,
    required this.cases,
  });

  factory ClientPortalDashboardData.fromJson(Map<String, dynamic> json) {
    return ClientPortalDashboardData(
      clientName: json['client_name']?.toString() ?? '',
      clientEmail: json['client_email']?.toString() ?? '',
      firm: json['firm'] is Map<String, dynamic>
          ? FirmInfo.fromJson(json['firm'] as Map<String, dynamic>)
          : null,
      firmAdmins: (json['firm_admins'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => LegalPersonnel.fromJson(e))
          .toList(),
      assignedLawyers: (json['assigned_lawyers'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => LegalPersonnel.fromJson(e))
          .toList(),
      nextHearing: json['next_hearing'] is Map<String, dynamic>
          ? HearingItem.fromJson(json['next_hearing'] as Map<String, dynamic>)
          : null,
      hearings: (json['hearings'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => HearingItem.fromJson(e))
          .toList(),
      cases: (json['cases'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ClientCaseItem.fromJson(e))
          .toList(),
    );
  }
}

class FirmInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String whatsapp;
  final String address;

  const FirmInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
  });

  factory FirmInfo.fromJson(Map<String, dynamic> json) {
    return FirmInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class LegalPersonnel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String role;
  final String? caseTitle;

  const LegalPersonnel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    this.caseTitle,
  });

  factory LegalPersonnel.fromJson(Map<String, dynamic> json) {
    return LegalPersonnel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'Legal Counsel',
      caseTitle: json['case_title']?.toString(),
    );
  }
}

class HearingItem {
  final int id;
  final String title;
  final String date;
  final String? startTime;
  final String? endTime;
  final String courtName;
  final String judgeName;
  final String notes;
  final int caseId;
  final String caseTitle;
  final String caseNumber;
  final String caseType;
  final bool isUpcoming;

  const HearingItem({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    required this.courtName,
    required this.judgeName,
    required this.notes,
    required this.caseId,
    required this.caseTitle,
    required this.caseNumber,
    required this.caseType,
    required this.isUpcoming,
  });

  factory HearingItem.fromJson(Map<String, dynamic> json) {
    return HearingItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Hearing Session',
      date: json['date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      courtName: json['court_name']?.toString() ?? 'Court Room',
      judgeName: json['judge_name']?.toString() ?? 'Honorable Judge',
      notes: json['notes']?.toString() ?? '',
      caseId: json['case_id'] is int
          ? json['case_id'] as int
          : int.tryParse(json['case_id']?.toString() ?? '0') ?? 0,
      caseTitle: json['case_title']?.toString() ?? '',
      caseNumber: json['case_number']?.toString() ?? '',
      caseType: json['case_type']?.toString() ?? '',
      isUpcoming: json['is_upcoming'] == true,
    );
  }
}

class ClientCaseItem {
  final int id;
  final String title;
  final String caseNumber;
  final String caseType;
  final String courtName;
  final String status;
  final String lawyerName;

  const ClientCaseItem({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.caseType,
    required this.courtName,
    required this.status,
    required this.lawyerName,
  });

  factory ClientCaseItem.fromJson(Map<String, dynamic> json) {
    return ClientCaseItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      caseNumber: json['case_number']?.toString() ?? '',
      caseType: json['case_type']?.toString() ?? '',
      courtName: json['court_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'in_progress',
      lawyerName: json['lawyer_name']?.toString() ?? 'Assigned Counsel',
    );
  }
}
