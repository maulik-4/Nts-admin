class MessageModel {
  final int id;
  final String content;
  final int firmId;
  final int senderId;
  final int receiverId;
  final bool isRead;
  final int? caseId;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.firmId,
    required this.senderId,
    required this.receiverId,
    this.isRead = false,
    this.caseId,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      firmId: json['firm'] as int? ?? 0,
      senderId: json['sender'] as int? ?? 0,
      receiverId: json['receiver'] as int? ?? 0,
      isRead: json['is_read'] as bool? ?? false,
      caseId: json['case'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'firm': firmId,
    'sender': senderId,
    'receiver': receiverId,
    'case': caseId,
  };
}
