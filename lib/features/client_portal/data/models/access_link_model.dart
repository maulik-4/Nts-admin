class DocumentAccessLink {
  final String downloadUrl;
  final String downloadPath;
  final String token;
  final int expiresInSeconds;

  const DocumentAccessLink({
    required this.downloadUrl,
    required this.downloadPath,
    required this.token,
    required this.expiresInSeconds,
  });

  factory DocumentAccessLink.fromJson(Map<String, dynamic> json) {
    return DocumentAccessLink(
      downloadUrl: json['download_url']?.toString() ?? '',
      downloadPath: json['download_path']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      expiresInSeconds: json['expires_in_seconds'] is int
          ? json['expires_in_seconds'] as int
          : int.tryParse(json['expires_in_seconds']?.toString() ?? '300') ??
                300,
    );
  }
}
