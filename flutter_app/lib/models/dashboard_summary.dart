import 'package:subscription_manager_flutter/models/subscription.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.monthlyTotalCents,
    required this.currency,
    required this.activeCount,
    required this.nextRenewals,
  });

  final int monthlyTotalCents;
  final String currency;
  final int activeCount;
  final List<Subscription> nextRenewals;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final renewals = (json['nextRenewals'] as List<dynamic>? ?? [])
        .map((item) => Subscription.fromJson(item as Map<String, dynamic>))
        .toList();
    return DashboardSummary(
      monthlyTotalCents: json['monthlyTotalCents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'BRL',
      activeCount: json['activeCount'] as int? ?? 0,
      nextRenewals: renewals,
    );
  }
}
