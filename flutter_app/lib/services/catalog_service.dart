import 'dart:convert';

import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/models/catalog_service.dart';

class CatalogServiceApi {
  CatalogServiceApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<CatalogService>> top() async {
    final response = await _client.get('/v1/catalog/top', withAuth: false);
    if (response.statusCode != 200) {
      throw Exception('Failed to load catalog (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map((item) => CatalogService.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
