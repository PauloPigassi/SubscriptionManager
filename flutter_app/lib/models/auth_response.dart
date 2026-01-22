class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.email,
    this.name,
    required this.plan,
  });

  final String accessToken;
  final String userId;
  final String email;
  final String? name;
  final String plan;

  /// Nome para exibição: nome se existir, senão email.
  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : email;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      plan: json['plan'] as String? ?? 'FREE',
    );
  }
}
