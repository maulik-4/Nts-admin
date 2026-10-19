class ClientDocumentItem {
  final int id;
  final String title;
  final String mimeType;
  final int fileSize;
  final String? caseTitle;
  final String accessPolicy;
  final String createdAt;
  final String? sharedAt;
  final String? expiresAt;
  final String sharedByName;
  final String firmName;
  final String fileName;
  final String fileExt;

  const ClientDocumentItem({
    required this.id,
    required this.title,
    required this.mimeType,
    required this.fileSize,
    this.caseTitle,
    required this.accessPolicy,
    required this.createdAt,
    this.sharedAt,
    this.expiresAt,
    required this.sharedByName,
    required this.firmName,
    required this.fileName,
    required this.fileExt,
  });

  bool get isPdf => fileExt.toLowerCase() == 'pdf' || mimeType.contains('pdf');
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(fileExt.toLowerCase()) ||
      mimeType.startsWith('image/');

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory ClientDocumentItem.fromJson(Map<String, dynamic> json) {
    return ClientDocumentItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title:
          json['title']?.toString() ??
          json['file_name']?.toString() ??
          'Document',
      mimeType: json['mime_type']?.toString() ?? 'application/octet-stream',
      fileSize: json['file_size'] is int
          ? json['file_size'] as int
          : int.tryParse(json['file_size']?.toString() ?? '0') ?? 0,
      caseTitle: json['case_title']?.toString(),
      accessPolicy: json['access_policy']?.toString() ?? 'shared',
      createdAt: json['created_at']?.toString() ?? '',
      sharedAt: json['shared_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      sharedByName: json['shared_by_name']?.toString() ?? 'Legal Counsel',
      firmName: json['firm_name']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? 'document',
      fileExt: json['file_ext']?.toString() ?? '',
    );
  }
}
