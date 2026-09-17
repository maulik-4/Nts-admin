class Document {
  final int id;
  final int caseId;
  final String? caseTitle;
  final int firm;
  final String file;
  final int? uploadedBy;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Document({
    required this.id,
    required this.caseId,
    this.caseTitle,
    required this.firm,
    required this.file,
    this.uploadedBy,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fileName {
    try {
      final uri = Uri.parse(file);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return Uri.decodeComponent(segments.last);
      }
    } catch (_) {}
    return 'document_$id';
  }

  String get fileExtension {
    final name = fileName;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  bool get isPdf => fileExtension == 'pdf';
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(fileExtension);
  bool get isDoc => ['doc', 'docx', 'txt', 'rtf'].contains(fileExtension);

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      caseId: json['case'] is int
          ? json['case'] as int
          : int.tryParse(json['case']?.toString() ?? '0') ?? 0,
      caseTitle: json['case_title']?.toString(),
      firm: json['firm'] is int
          ? json['firm'] as int
          : int.tryParse(json['firm']?.toString() ?? '0') ?? 0,
      file: json['file']?.toString() ?? '',
      uploadedBy: json['uploaded_by'] is int
          ? json['uploaded_by'] as int
          : int.tryParse(json['uploaded_by']?.toString() ?? ''),
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
    'case': caseId,
    'case_title': caseTitle,
    'firm': firm,
    'file': file,
    'uploaded_by': uploadedBy,
    'is_active': isActive,
    'is_deleted': isDeleted,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
