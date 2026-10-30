import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/models/alert_rule.dart';
import 'package:subscription_manager_flutter/services/alert_rule_service.dart';
import 'package:subscription_manager_flutter/services/locale_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Locale? currentLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Opções de lembrete exibidas (dias antes da renovação).
  static const _reminderOptions = [14, 7, 3, 1, 0];

  final _alertRuleService = AlertRuleService();
  List<AlertRule>? _rules;
  bool _rulesError = false;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() => _rulesError = false);
    try {
      final rules = await _alertRuleService.list();
      if (mounted) setState(() => _rules = rules);
    } catch (_) {
      if (mounted) setState(() => _rulesError = true);
    }
  }

  bool _isReminderEnabled(int days) =>
      _rules?.any((r) => r.daysBefore == days && r.enabled) ?? false;

  Future<void> _toggleReminder(int days, bool enabled) async {
    final previous = _rules ?? const <AlertRule>[];
    // Mantém regras fora das opções exibidas (ex.: criadas por outro cliente)
    final updated = [
      ...previous.where((r) => r.daysBefore != days),
      AlertRule(daysBefore: days, enabled: enabled),
    ]..sort((a, b) => b.daysBefore.compareTo(a.daysBefore));

    setState(() => _rules = updated);
    try {
      final saved = await _alertRuleService.replace(updated);
      if (mounted) setState(() => _rules = saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _rules = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.remindersSaveFailed)),
      );
    }
  }

  List<Widget> _buildReminderTiles(AppLocalizations l10n, TextTheme textTheme) {
    if (_rulesError) {
      return [
        ListTile(
          title: Text(l10n.remindersLoadFailed),
          trailing: TextButton(onPressed: _loadRules, child: Text(l10n.retry)),
        ),
      ];
    }
    if (_rules == null) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    return [
      for (final days in _reminderOptions)
        SwitchListTile(
          title: Text(
              days == 0 ? l10n.reminderOnDay : l10n.reminderDaysBefore(days)),
          value: _isReminderEnabled(days),
          onChanged: (v) => _toggleReminder(days, v),
        ),
      ListTile(
        title: Text(
          l10n.remindersDesc,
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          _Section(
            title: l10n.language,
            children: [
              _LanguageTile(
                label: l10n.english,
                locale: LocaleService.en,
                isSelected: widget.currentLocale == null ||
                    widget.currentLocale?.languageCode == 'en',
                onTap: () => _select(LocaleService.en),
              ),
              _LanguageTile(
                label: l10n.portuguese,
                locale: LocaleService.pt,
                isSelected: widget.currentLocale?.languageCode == 'pt',
                onTap: () => _select(LocaleService.pt),
              ),
              ListTile(
                title: Text(
                  l10n.languageDesc,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: l10n.reminders,
            children: _buildReminderTiles(l10n, textTheme),
          ),
        ],
      ),
    );
  }

  void _select(Locale locale) async {
    await LocaleService.setLocale(locale);
    widget.onLocaleChanged(locale);
    if (mounted) setState(() {});
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.md,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}
