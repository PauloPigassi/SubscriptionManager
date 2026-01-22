class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.currency,
    required this.billingCycle,
    required this.intervalCount,
    required this.intervalUnit,
    required this.nextRenewalAt,
    this.category,
    this.notes,
    this.iconUrl,
  });

  final String id;
  final String name;
  final int amountCents;
  final String currency;
  final String billingCycle;
  final int intervalCount;
  final String intervalUnit;
  final DateTime nextRenewalAt;
  final String? category;
  final String? notes;
  final String? iconUrl;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      amountCents: json['amountCents'] as int,
      currency: json['currency'] as String? ?? 'BRL',
      billingCycle: json['billingCycle'] as String,
      intervalCount: json['intervalCount'] as int? ?? 1,
      intervalUnit: json['intervalUnit'] as String? ?? 'MONTH',
      nextRenewalAt: DateTime.parse(json['nextRenewalAt'] as String),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}
