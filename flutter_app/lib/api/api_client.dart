import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:subscription_manager_flutter/services/auth_storage.dart';

class ApiClient {
  ApiClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage();

  final AuthStorage _authStorage;

  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _authStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  Future<http.Response> post(String path, Object body,
      {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }
}
