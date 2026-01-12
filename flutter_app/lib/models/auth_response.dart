class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.plan,
  });

  final String accessToken;
  final String userId;
  final String email;
  final String plan;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      plan: json['plan'] as String? ?? 'FREE',
    );
  }
}
