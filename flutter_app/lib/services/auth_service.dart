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
    return auth;
  }
}
