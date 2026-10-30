class AlertRule {
  const AlertRule({required this.daysBefore, required this.enabled});

  final int daysBefore;
  final bool enabled;

  factory AlertRule.fromJson(Map<String, dynamic> json) {
    return AlertRule(
      daysBefore: json['daysBefore'] as int,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'daysBefore': daysBefore,
        'enabled': enabled,
      };
}
