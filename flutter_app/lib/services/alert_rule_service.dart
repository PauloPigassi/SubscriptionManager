import 'dart:convert';

import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/models/alert_rule.dart';

class AlertRuleService {
  AlertRuleService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AlertRule>> list() async {
    final response = await _client.get('/v1/alert-rules');
    if (response.statusCode != 200) {
      throw Exception('Failed to load reminders (${response.statusCode})');
    }
    return _parse(response.body);
  }

  /// Substitui todas as regras do usuário pelas informadas.
  Future<List<AlertRule>> replace(List<AlertRule> rules) async {
    final response = await _client.put('/v1/alert-rules', {
      'rules': rules.map((r) => r.toJson()).toList(),
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to save reminders (${response.statusCode})');
    }
    return _parse(response.body);
  }

  List<AlertRule> _parse(String body) {
    final payload = jsonDecode(body) as List<dynamic>;
    return payload
        .map((item) => AlertRule.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
