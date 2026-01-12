import 'dart:convert';

import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';

class SubscriptionService {
  SubscriptionService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Subscription>> list() async {
    final response = await _client.get('/v1/subscriptions');
    if (response.statusCode != 200) {
      throw Exception('Failed to load subscriptions (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map((item) => Subscription.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String name,
    required int amountCents,
    required String billingCycle,
    required DateTime nextRenewalAt,
    int intervalCount = 1,
    String intervalUnit = 'MONTH',
    String? category,
    String? catalogServiceId,
    String? notes,
  }) async {
    final response = await _client.post('/v1/subscriptions', {
      'catalogServiceId': catalogServiceId,
      'name': name,
      'category': category,
      'amountCents': amountCents,
      'billingCycle': billingCycle,
      'intervalCount': intervalCount,
      'intervalUnit': intervalUnit,
      'nextRenewalAt': nextRenewalAt.toUtc().toIso8601String(),
      'notes': notes,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to create subscription (${response.statusCode})');
    }
  }

  Future<void> archive(String id) async {
    final response = await _client.delete('/v1/subscriptions/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to archive subscription (${response.statusCode})');
    }
  }
}
