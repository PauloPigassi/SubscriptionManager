import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';
import 'package:subscription_manager_flutter/utils/currency_format.dart';
import 'package:subscription_manager_flutter/screens/add_subscription_screen.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';
import 'package:subscription_manager_flutter/utils/category_icons.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _service = SubscriptionService();
  bool _loading = true;
  String? _error;
  List<Subscription> _subscriptions = const [];
  /// null = todas, "" = sem categoria, ou o valor da categoria
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subs = await _service.list();
      if (!mounted) return;
      setState(() {
        _subscriptions = subs;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatCurrency(int cents, String currency) =>
      formatCurrency(cents, currency);

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference < 0) return l10n.overdue;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.tomorrow;
    final dateStr = DateFormat('MMM d', locale).format(date);
    return '$dateStr (${l10n.daysLeft(difference)})';
  }

  IconData _getCategoryIcon(String? category) =>
      CategoryIcons.getIcon(category);

  Future<void> _archive(Subscription subscription) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveSubscription),
        content: Text(l10n.archiveConfirm(subscription.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.archive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.archive(subscription.id);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.archived(subscription.name))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.archiveFailed(error.toString()))),
      );
    }
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
    );
    if (created == true) {
      _load();
    }
  }

  Future<void> _openEdit(Subscription subscription) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddSubscriptionScreen(subscriptionToEdit: subscription),
      ),
    );
    if (updated == true) {
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.subscriptionUpdated)),
      );
    }
  }

  Future<void> _openEditCategory(Subscription subscription) async {
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _EditCategoryDialog(subscription: subscription),
    );
    if (value == null) return;
    try {
      await _service.updateCategory(subscription.id, value);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryUpdated)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.archiveFailed(error.toString()))),
      );
    }
  }

  List<Subscription> get _filtered {
    if (_filterCategory == null) return _subscriptions;
    if (_filterCategory == '') {
      return _subscriptions
          .where((s) => s.category == null || s.category!.isEmpty)
          .toList();
    }
    return _subscriptions.where((s) => s.category == _filterCategory).toList();
  }

  /// Agrupa por categoria: mapa de (categoria ou "") -> lista. Chave "" = sem categoria.
  Map<String, List<Subscription>> get _byCategory {
    final m = <String, List<Subscription>>{};
    for (final s in _filtered) {
      final k = s.category?.trim().isEmpty == true ? '' : (s.category ?? '');
      m.putIfAbsent(k, () => []).add(s);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(l10n.subscriptions, style: textTheme.titleLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textPrimary),
                    onPressed: _openAdd,
                  ),
                ],
              ),
            ),
            _subscriptions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text(l10n.filterAll),
                            selected: _filterCategory == null,
                            onSelected: (_) =>
                                setState(() => _filterCategory = null),
                          ),
                          if (_subscriptions
                              .any((s) =>
                                  s.category == null || s.category!.isEmpty))
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(l10n.uncategorized),
                                selected: _filterCategory == '',
                                onSelected: (_) =>
                                    setState(() => _filterCategory = ''),
                              ),
                            ),
                          ...(_subscriptions
                                  .map((s) => s.category)
                                  .where((c) =>
                                      c != null && c.trim().isNotEmpty)
                                  .cast<String>()
                                  .toSet()
                                  .toList()
                                ..sort())
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: FilterChip(
                                      label: Text(CategoryIcons.displayName(c)),
                                      selected: _filterCategory == c,
                                      onSelected: (_) =>
                                          setState(() => _filterCategory = c),
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            if (_subscriptions.isNotEmpty) const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: _loading && _subscriptions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _error!,
                                  style: textTheme.bodyMedium?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ElevatedButton(
                                  onPressed: _load,
                                  child: Text(l10n.retry),
                                ),
                              ],
                            ),
                          )
                        : _subscriptions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: AppColors.muted,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      l10n.noSubscriptionsYet,
                                      style: textTheme.titleMedium
                                          ?.copyWith(color: AppColors.muted),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      l10n.addFirstSubscription,
                                      style: textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.muted),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    ElevatedButton(
                                      onPressed: _openAdd,
                                      child: Text(l10n.addSubscription),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg),
                                children: [
                                  ...(() {
                                    final keys = _byCategory.keys.toList()
                                      ..sort((a, b) => a.isEmpty
                                          ? 1
                                          : (b.isEmpty
                                              ? -1
                                              : a.compareTo(b)));
                                    return keys.expand((key) {
                                      final subs = _byCategory[key]!;
                                      final label = key.isEmpty
                                          ? l10n.uncategorized
                                          : CategoryIcons.displayName(key);
                                      return [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, bottom: 6),
                                          child: Row(
                                            children: [
                                              Icon(CategoryIcons.getIcon(
                                                  key.isEmpty ? null : key),
                                                  size: 18,
                                                  color: AppColors.muted),
                                              const SizedBox(width: 6),
                                              Text(label,
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                          color:
                                                              AppColors.muted)),
                                            ],
                                          ),
                                        ),
                                        ...subs.map(
                                          (subscription) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: AppSpacing.md),
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                  AppSpacing.md),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius: AppRadii.md,
                                                boxShadow: AppShadows.subtle,
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        AppColors.background,
                                                    child: Icon(
                                                      _getCategoryIcon(
                                                          subscription
                                                              .category),
                                                      size: 18,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: AppSpacing.md),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            subscription.name,
                                                            style: textTheme
                                                                .labelLarge),
                                                        const SizedBox(
                                                            height:
                                                                AppSpacing.xs),
                                                        Text(
                                                          '${_formatCurrency(subscription.amountCents, subscription.currency)} · ${subscription.billingCycle}',
                                                          style:
                                                              textTheme
                                                                  .labelMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          _formatDate(context,
                                                              subscription
                                                                  .nextRenewalAt),
                                                          style: textTheme
                                                              .labelMedium
                                                              ?.copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .accent),
                                                        ),
                                                        const SizedBox(
                                                            height:
                                                                AppSpacing.xs),
                                                        PopupMenuButton<String>(
                                                          icon: Icon(
                                                            Icons.more_vert,
                                                            size: 20,
                                                            color: AppColors.muted,
                                                          ),
                                                          padding: EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(minWidth: 40, minHeight: 40),
                                                          onSelected: (v) {
                                                            if (v == 'edit') {
                                                              _openEdit(subscription);
                                                            } else if (v == 'category') {
                                                              _openEditCategory(subscription);
                                                            } else if (v == 'archive') {
                                                              _archive(subscription);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.edit_outlined, size: 18),
                                                                  const SizedBox(width: 8),
                                                                  Text(l10n.editSubscription),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'category',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.label_outline, size: 18),
                                                                  const SizedBox(width: 8),
                                                                  Text(l10n.editCategory),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'archive',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.delete_outline, size: 18),
                                                                  const SizedBox(width: 8),
                                                                  Text(l10n.archiveSubscription),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ];
                                    });
                                  })(),
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  const _EditCategoryDialog({required this.subscription});

  final Subscription subscription;

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late String _selectedCategory;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final c = widget.subscription.category;
    if (c == null || c.isEmpty) {
      _selectedCategory = '';
      _customController = TextEditingController(text: '');
    } else if (CategoryIcons.builtIn.contains(c)) {
      _selectedCategory = c;
      _customController = TextEditingController(text: '');
    } else {
      _selectedCategory = '__new__';
      _customController = TextEditingController(text: c);
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _resolveValue() {
    if (_selectedCategory == '__new__') {
      final t = _customController.text.trim();
      return t.isEmpty ? '' : t;
    }
    return _selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.editCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.uncategorized)),
                ...CategoryIcons.builtIn.map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(CategoryIcons.displayName(c)),
                  ),
                ),
                DropdownMenuItem(
                  value: '__new__',
                  child: Text(l10n.newCategory),
                ),
              ],
              onChanged: (v) => setState(() => _selectedCategory = v ?? ''),
              decoration: InputDecoration(labelText: l10n.category),
            ),
            if (_selectedCategory == '__new__') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Fitness',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_resolveValue()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
