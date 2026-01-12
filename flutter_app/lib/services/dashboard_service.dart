import 'dart:convert';

import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/models/dashboard_summary.dart';

class DashboardService {
  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<DashboardSummary> fetchSummary() async {
    final response = await _client.get('/v1/dashboard/summary');
    if (response.statusCode != 200) {
      throw Exception('Failed to load summary (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardSummary.fromJson(payload);
  }
}
