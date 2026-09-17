class Hearing {
  final int id;
  final String title;
  final String date;
  final String? startTime;
  final String? endTime;
  final String courtName;
  final String? judgeName;
  final String? notes;
  final int caseId;
  final String? start;
  final String? end;
  final int? createdBy;

  const Hearing({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    required this.courtName,
    this.judgeName,
    this.notes,
    required this.caseId,
    this.start,
    this.end,
    this.createdBy,
  });

  factory Hearing.fromJson(Map<String, dynamic> json) {
    return Hearing(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      courtName: json['court_name']?.toString() ?? '',
      judgeName: json['judge_name']?.toString(),
      notes: json['notes']?.toString(),
      caseId: json['case'] is int
          ? json['case'] as int
          : int.tryParse(json['case']?.toString() ?? '0') ?? 0,
      start: json['start']?.toString(),
      end: json['end']?.toString(),
      createdBy: json['created_by'] is int
          ? json['created_by'] as int
          : int.tryParse(json['created_by']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'court_name': courtName,
      'judge_name': judgeName,
      'notes': notes,
      'case': caseId,
      'start': start,
      'end': end,
      'created_by': createdBy,
    };
  }

  DateTime? get parsedDate => DateTime.tryParse(date);
}

class CreateHearingRequest {
  final String title;
  final String date;
  final String? startTime;
  final String? endTime;
  final String courtName;
  final String? judgeName;
  final String? notes;
  final int caseId;

  const CreateHearingRequest({
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    required this.courtName,
    this.judgeName,
    this.notes,
    required this.caseId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'date': date.trim(),
      'court_name': courtName.trim(),
      'case': caseId,
    };
    if (startTime != null && startTime!.trim().isNotEmpty) {
      map['start_time'] = startTime!.trim();
    }
    if (endTime != null && endTime!.trim().isNotEmpty) {
      map['end_time'] = endTime!.trim();
    }
    if (judgeName != null && judgeName!.trim().isNotEmpty) {
      map['judge_name'] = judgeName!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

class UpdateHearingRequest {
  final String? title;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? courtName;
  final String? judgeName;
  final String? notes;
  final int? caseId;

  const UpdateHearingRequest({
    this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.courtName,
    this.judgeName,
    this.notes,
    this.caseId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title!.trim();
    if (date != null) map['date'] = date!.trim();
    if (startTime != null) map['start_time'] = startTime!.trim();
    if (endTime != null) map['end_time'] = endTime!.trim();
    if (courtName != null) map['court_name'] = courtName!.trim();
    if (judgeName != null) map['judge_name'] = judgeName!.trim();
    if (notes != null) map['notes'] = notes!.trim();
    if (caseId != null) map['case'] = caseId;
    return map;
  }
}
