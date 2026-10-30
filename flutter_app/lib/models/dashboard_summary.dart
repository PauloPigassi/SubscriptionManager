import 'package:subscription_manager_flutter/models/subscription.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.monthlyTotalCents,
    required this.yearlyTotalCents,
    required this.currency,
    required this.activeCount,
    required this.nextRenewals,
    required this.categoryBreakdown,
  });

  final int monthlyTotalCents;
  final int yearlyTotalCents;
  final String currency;
  final int activeCount;
  final List<Subscription> nextRenewals;
  final List<CategorySpend> categoryBreakdown;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final renewals = (json['nextRenewals'] as List<dynamic>? ?? [])
        .map((item) => Subscription.fromJson(item as Map<String, dynamic>))
        .toList();
    final breakdown = (json['categoryBreakdown'] as List<dynamic>? ?? [])
        .map((item) => CategorySpend.fromJson(item as Map<String, dynamic>))
        .toList();
    return DashboardSummary(
      monthlyTotalCents: json['monthlyTotalCents'] as int? ?? 0,
      yearlyTotalCents: json['yearlyTotalCents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'BRL',
      activeCount: json['activeCount'] as int? ?? 0,
      nextRenewals: renewals,
      categoryBreakdown: breakdown,
    );
  }
}

class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.monthlyCents,
    required this.count,
  });

  /// null = sem categoria
  final String? category;
  final int monthlyCents;
  final int count;

  factory CategorySpend.fromJson(Map<String, dynamic> json) {
    return CategorySpend(
      category: json['category'] as String?,
      monthlyCents: json['monthlyCents'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}
