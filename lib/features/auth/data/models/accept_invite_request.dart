class AcceptInviteRequest {
  final String token;
  final String username;
  final String password;

  const AcceptInviteRequest({
    required this.token,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'token': token, 'username': username, 'password': password};
  }
}
