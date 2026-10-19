class ClientDocumentAccessItem {
  final int id;
  final int documentId;
  final String documentTitle;
  final String? caseTitle;
  final String sharedByName;
  final String sharedAt;
  final String status;
  final String? expiresAt;
  final String? revokedAt;

  const ClientDocumentAccessItem({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    this.caseTitle,
    required this.sharedByName,
    required this.sharedAt,
    required this.status,
    this.expiresAt,
    this.revokedAt,
  });

  bool get isActive => status == 'active';

  factory ClientDocumentAccessItem.fromJson(Map<String, dynamic> json) {
    return ClientDocumentAccessItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      documentId: json['document_id'] is int
          ? json['document_id'] as int
          : int.tryParse(json['document_id']?.toString() ?? '0') ?? 0,
      documentTitle:
          json['document_title']?.toString() ??
          'Document #${json['document_id']}',
      caseTitle: json['case_title']?.toString(),
      sharedByName: json['shared_by_name']?.toString() ?? 'Counsel',
      sharedAt: json['shared_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      expiresAt: json['expires_at']?.toString(),
      revokedAt: json['revoked_at']?.toString(),
    );
  }
}
