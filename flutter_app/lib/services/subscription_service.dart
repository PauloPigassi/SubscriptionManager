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
    String? iconUrl,
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
      'iconUrl': iconUrl,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to create subscription (${response.statusCode})');
    }
  }

  Future<void> updateCategory(String id, String category) async {
    final response = await _client.patch('/v1/subscriptions/$id', {
      'category': category,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to update category (${response.statusCode})');
    }
  }

  /// Atualização parcial (apenas campos enviados são aplicados).
  Future<void> update(
    String id, {
    String? name,
    int? amountCents,
    String? billingCycle,
    int? intervalCount,
    String? intervalUnit,
    DateTime? nextRenewalAt,
    String? category,
    String? notes,
    String? iconUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (amountCents != null) body['amountCents'] = amountCents;
    if (billingCycle != null) body['billingCycle'] = billingCycle;
    if (intervalCount != null) body['intervalCount'] = intervalCount;
    if (intervalUnit != null) body['intervalUnit'] = intervalUnit;
    if (nextRenewalAt != null) {
      body['nextRenewalAt'] = nextRenewalAt.toUtc().toIso8601String();
    }
    if (category != null) body['category'] = category;
    if (notes != null) body['notes'] = notes;
    if (iconUrl != null) body['iconUrl'] = iconUrl;
    if (body.isEmpty) return;
    final response = await _client.patch('/v1/subscriptions/$id', body);
    if (response.statusCode != 200) {
      throw Exception('Failed to update subscription (${response.statusCode})');
    }
  }

  /// Atualização completa: envia todos os campos no body (usado pela tela de edição).
  Future<void> updateFull({
    required String id,
    required String name,
    required int amountCents,
    required String billingCycle,
    required int intervalCount,
    required String intervalUnit,
    required DateTime nextRenewalAt,
    required String category,
    required String notes,
    required String iconUrl,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'amountCents': amountCents,
      'billingCycle': billingCycle,
      'intervalCount': intervalCount,
      'intervalUnit': intervalUnit,
      'nextRenewalAt': nextRenewalAt.toUtc().toIso8601String(),
      'category': category,
      'notes': notes,
      'iconUrl': iconUrl,
    };
    // Debug: log do body sendo enviado
    print('[DEBUG] updateFull body: $body');
    final response = await _client.patch('/v1/subscriptions/$id', body);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update subscription (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> archive(String id) async {
    final response = await _client.delete('/v1/subscriptions/$id');
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to archive subscription (${response.statusCode})');
    }
  }
}
