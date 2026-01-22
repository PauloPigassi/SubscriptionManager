import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:subscription_manager_flutter/services/auth_storage.dart';

import 'api_client_io.dart' if (dart.library.html) 'api_client_web.dart'
    as impl;

class ApiClient {
  ApiClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage();

  final AuthStorage _authStorage;

  /// Timeout for the whole HTTP call (request + response)
  static const Duration _timeout = Duration(seconds: 15);
  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static http.Client? _client;

  /// Override in debug to force a different base URL (e.g. 127.0.0.1 no simulador).
  /// Ex.: ApiClient.baseUrlOverride = 'http://127.0.0.1:8080';
  static String? baseUrlOverride;

  /// Web: localhost:8080. iOS/Android: veja baseUrl.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.endsWith('/')
          ? _envBaseUrl.substring(0, _envBaseUrl.length - 1)
          : _envBaseUrl;
    }
    if (baseUrlOverride != null && baseUrlOverride!.isNotEmpty) {
      return baseUrlOverride!.endsWith('/')
          ? baseUrlOverride!.substring(0, baseUrlOverride!.length - 1)
          : baseUrlOverride!;
    }
    if (impl.isIOS) {
      const macIp = '192.168.1.5';
      return 'http://$macIp:8080';
    }
    if (impl.isAndroid) return 'http://10.0.2.2:8080';
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
      if (body != null) {
        debugPrint('[ApiClient] Body: ${jsonEncode(body)}');
      }
    }
    final headers = await _headers(withAuth: withAuth);

    Future<http.Response> future;
    if (kIsWeb) {
      switch (method) {
        case 'GET':
          future = http.get(uri, headers: headers);
          break;
        case 'POST':
          future = http.post(uri,
              headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PATCH':
          future = http.patch(uri,
              headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          future = http.delete(uri, headers: headers);
          break;
        default:
          throw UnsupportedError('$method');
      }
    } else {
      _client ??= impl.createHttpClient();
      switch (method) {
        case 'GET':
          future = _client!.get(uri, headers: headers);
          break;
        case 'POST':
          future = _client!.post(uri,
              headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PATCH':
          future = _client!.patch(uri,
              headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          future = _client!.delete(uri, headers: headers);
          break;
        default:
          throw UnsupportedError('$method');
      }
    }

    try {
      final r = await future.timeout(_timeout, onTimeout: () {
        if (kDebugMode) debugPrint('[ApiClient] TIMEOUT $method $uri');
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

  Future<http.Response> patch(String path, Object body,
      {bool withAuth = true}) async {
    return _request('PATCH', path, body: body, withAuth: withAuth);
  }

  Future<http.Response> delete(String path) async {
    return _request('DELETE', path);
  }
}
