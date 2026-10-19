class CommunicationPreference {
  final String preferredChannel;
  final bool whatsappConsent;
  final String? whatsappNumber;

  const CommunicationPreference({
    required this.preferredChannel,
    required this.whatsappConsent,
    this.whatsappNumber,
  });

  factory CommunicationPreference.fromJson(Map<String, dynamic> json) {
    return CommunicationPreference(
      preferredChannel: json['preferred_channel']?.toString() ?? 'both',
      whatsappConsent: json['whatsapp_consent'] == true,
      whatsappNumber: json['whatsapp_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'preferred_channel': preferredChannel,
    'whatsapp_consent': whatsappConsent,
    if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
  };
}
