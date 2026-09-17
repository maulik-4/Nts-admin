class NotificationItem {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? notificationType;
  final String? redirectUrl;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.notificationType,
    this.redirectUrl,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      notificationType: json['notification_type'] as String?,
      redirectUrl: json['redirect_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'is_read': isRead,
    'notification_type': notificationType,
    'redirect_url': redirectUrl,
    'created_at': createdAt?.toIso8601String(),
  };
}

class NotificationPreferences {
  final Map<String, bool> emailPreferences;
  final Map<String, bool> pushPreferences;

  const NotificationPreferences({
    this.emailPreferences = const {},
    this.pushPreferences = const {},
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final email = json['email'] is Map
        ? (json['email'] as Map).map(
            (k, v) => MapEntry(k.toString(), v == true),
          )
        : <String, bool>{};
    final push = json['push'] is Map
        ? (json['push'] as Map).map((k, v) => MapEntry(k.toString(), v == true))
        : <String, bool>{};

    return NotificationPreferences(
      emailPreferences: email,
      pushPreferences: push,
    );
  }
}
