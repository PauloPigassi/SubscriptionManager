import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';

class ApiClient {
  ApiClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage();

  final AuthStorage _authStorage;

  /// Timeout for the whole HTTP call (request + response)
  static const Duration _timeout = Duration(seconds: 15);

  static http.Client? _client;
  static http.Client get _httpClient {
    _client ??= () {
      final c = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8)
        ..idleTimeout = const Duration(seconds: 10);
      return IOClient(c);
    }();
    return _client!;
  }

  /// Override in debug to force a different base URL (e.g. 127.0.0.1 no simulador).
  /// Ex.: ApiClient.baseUrlOverride = 'http://127.0.0.1:8080';
  static String? baseUrlOverride;

  // For iOS Simulator: 127.0.0.1 works. For iOS device: use Mac's IP (ipconfig getifaddr en0).
  static String get baseUrl {
    if (baseUrlOverride != null && baseUrlOverride!.isNotEmpty) {
      return baseUrlOverride!.endsWith('/')
          ? baseUrlOverride!.substring(0, baseUrlOverride!.length - 1)
          : baseUrlOverride!;
    }
    if (Platform.isIOS) {
      const macIp = '192.168.1.5';
      return 'http://$macIp:8080';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
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

  Future<http.Response> _request(
    String method,
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    if (kDebugMode) {
      debugPrint('[ApiClient] $method $uri');
    }
    final headers = await _headers(withAuth: withAuth);
    try {
      Future<http.Response> future;
      switch (method) {
        case 'GET':
          future = _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          future = _httpClient.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          future = _httpClient.delete(uri, headers: headers);
          break;
        default:
          throw UnsupportedError('$method');
      }
      final r = await future.timeout(_timeout, onTimeout: () {
        if (kDebugMode) {
          debugPrint('[ApiClient] TIMEOUT $method $uri');
        }
        throw Exception('Connection timeout. Backend at $baseUrl? Same WiFi?');
      });
      if (kDebugMode && r.statusCode >= 400) {
        debugPrint('[ApiClient] $method $uri => ${r.statusCode} ${r.body}');
      }
      return r;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ApiClient] $method $uri => $e');
        debugPrint('[ApiClient] $st');
      }
      rethrow;
    }
  }

  Future<http.Response> get(String path, {bool withAuth = true}) async {
    return _request('GET', path, withAuth: withAuth);
  }

  Future<http.Response> post(String path, Object body,
      {bool withAuth = true}) async {
    return _request('POST', path, body: body, withAuth: withAuth);
  }

  Future<http.Response> delete(String path) async {
    return _request('DELETE', path);
  }
}
