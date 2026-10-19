class WhatsAppTemplate {
  final String name;
  final String label;
  final List<String> params;

  const WhatsAppTemplate({
    required this.name,
    required this.label,
    required this.params,
  });

  factory WhatsAppTemplate.fromJson(Map<String, dynamic> json) {
    return WhatsAppTemplate(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      params: (json['params'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
