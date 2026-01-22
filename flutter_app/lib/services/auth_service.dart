import 'dart:convert';

import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/models/auth_response.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';

class AuthService {
  AuthService({ApiClient? client, AuthStorage? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? AuthStorage();

  final ApiClient _client;
  final AuthStorage _storage;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/v1/auth/login',
      {'email': email, 'password': password},
      withAuth: false,
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(payload);
    await _storage.persistToken(auth.accessToken);
    await _storage.persistDisplayName(auth.displayName);
    return auth;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.post(
      '/v1/auth/register',
      {'email': email, 'password': password, 'name': name},
      withAuth: false,
    );
    if (response.statusCode != 200) {
      throw Exception('Register failed (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(payload);
    await _storage.persistToken(auth.accessToken);
    await _storage.persistDisplayName(auth.displayName);
    return auth;
  }

  /// Busca /v1/users/me e persiste o displayName (nome ou email) no storage.
  /// Útil quando o app já tem token mas não tem displayName (ex.: atualização).
  Future<void> fetchAndPersistProfile() async {
    final r = await _client.get('/v1/users/me');
    if (r.statusCode != 200) return;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final name = j['name'] as String?;
    final email = j['email'] as String?;
    final d = (name != null && name.trim().isNotEmpty) ? name.trim() : (email ?? 'User');
    await _storage.persistDisplayName(d);
  }
}
