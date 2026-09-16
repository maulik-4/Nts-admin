class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firmName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String panNumber;
  final String? gstNumber;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firmName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.panNumber,
    this.gstNumber,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'firm_name': firmName,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'pan_number': panNumber,
    };
    if (gstNumber != null && gstNumber!.trim().isNotEmpty) {
      map['gst_number'] = gstNumber!.trim();
    }
    return map;
  }
}
