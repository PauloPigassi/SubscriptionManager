class CatalogService {
  const CatalogService({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.defaultPriceCents,
    required this.currency,
  });

  final String id;
  final String name;
  final String? category;
  final String? logoUrl;
  final int? defaultPriceCents;
  final String? currency;

  factory CatalogService.fromJson(Map<String, dynamic> json) {
    return CatalogService(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      logoUrl: json['logoUrl'] as String?,
      defaultPriceCents: json['defaultPriceCents'] as int?,
      currency: json['currency'] as String?,
    );
  }
}
