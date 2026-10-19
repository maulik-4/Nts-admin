class WhatsAppSendResult {
  final int id;
  final String recipientNumber;
  final String recipientName;
  final String template;
  final String body;
  final String provider;
  final String status;
  final String? chatUrl;
  final String? failureCode;
  final String? failureReason;

  const WhatsAppSendResult({
    required this.id,
    required this.recipientNumber,
    required this.recipientName,
    required this.template,
    required this.body,
    required this.provider,
    required this.status,
    this.chatUrl,
    this.failureCode,
    this.failureReason,
  });

  bool get isSent =>
      status == 'sent' || status == 'delivered' || status == 'read';

  factory WhatsAppSendResult.fromJson(Map<String, dynamic> json) {
    return WhatsAppSendResult(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      recipientNumber: json['recipient_number']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      template: json['template']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'click_to_chat',
      status: json['status']?.toString() ?? 'sent',
      chatUrl: json['chat_url']?.toString(),
      failureCode: json['failure_code']?.toString(),
      failureReason: json['failure_reason']?.toString(),
    );
  }
}
