class UserFeedbackRequest {
  final String name;
  final String email;
  final String phone;
  final String message;
  final String companyName;

  const UserFeedbackRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.companyName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'message': message.trim(),
      'company_name': companyName.trim(),
      'companyName': companyName.trim(),
    };
  }

  factory UserFeedbackRequest.fromJson(Map<String, dynamic> json) {
    return UserFeedbackRequest(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      message: json['message'] as String? ?? '',
      companyName: (json['company_name'] ?? json['companyName'] ?? '') as String,
    );
  }
}
