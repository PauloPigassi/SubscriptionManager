import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:subscription_manager_flutter/services/auth_storage.dart';

class ApiClient {
  ApiClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage();

  final AuthStorage _authStorage;

  // For iOS Simulator: use localhost
  // For iOS Physical Device: use your Mac's IP address
  // Find your Mac's IP with: ipconfig getifaddr en0
  // Example: 'http://192.168.1.100:8080'
  static String get baseUrl {
    // Check if running on iOS physical device
    if (Platform.isIOS) {
      // TODO: Replace with your Mac's local IP address when testing on physical device
      // For simulator, localhost works fine
      // For physical device, use: 'http://YOUR_MAC_IP:8080'
      return 'http://localhost:8080';
    }
    // Android emulator can use 10.0.2.2 to access host machine's localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    // Default for other platforms
    return 'http://localhost:8080';
  }

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
