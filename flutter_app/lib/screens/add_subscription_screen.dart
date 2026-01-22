import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/models/catalog_service.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';
import 'package:subscription_manager_flutter/services/catalog_service.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';
import 'package:subscription_manager_flutter/utils/category_icons.dart';
import 'package:subscription_manager_flutter/utils/currency_format.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key, this.subscriptionToEdit});

  /// Se preenchido, abre em modo edição.
  final Subscription? subscriptionToEdit;

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _service = SubscriptionService();
  final _catalogService = CatalogServiceApi();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loading = false;
  String? _error;
  DateTime _nextRenewal = DateTime.now().add(const Duration(days: 30));
  String _billingCycle = 'MONTHLY';
  int _intervalCount = 1;
  String _intervalUnit = 'MONTH';
  List<CatalogService> _catalog = const [];
  CatalogService? _selectedCatalog;

  /// null ou "" = sem categoria; "__new__" = nova (usar _customCategory); senão a chave.
  String? _selectedCategory;
  String _customCategory = '';

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    final s = widget.subscriptionToEdit;
    if (s != null) {
      _nameController.text = s.name;
      _amountController.text = (s.amountCents / 100).toStringAsFixed(2);
      _notesController.text = s.notes ?? '';
      _nextRenewal = s.nextRenewalAt;
      _billingCycle = s.billingCycle;
      _intervalCount = s.intervalCount;
      _intervalUnit = s.intervalUnit;
      final c = s.category;
      if (c == null || c.isEmpty) {
        _selectedCategory = '';
        _customCategory = '';
      } else if (CategoryIcons.builtIn.contains(c)) {
        _selectedCategory = c;
        _customCategory = '';
      } else {
        _selectedCategory = '__new__';
        _customCategory = c;
      }
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final items = await _catalogService.top();
      if (!mounted) return;
      setState(() {
        _catalog = items;
      });
    } catch (_) {
      // Catalog is optional; ignore errors.
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final amountCents = (parseAmount(_amountController.text) * 100).round();
      final name = _nameController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final category = _resolveCategory();

      if (widget.subscriptionToEdit != null) {
        await _service.updateFull(
          id: widget.subscriptionToEdit!.id,
          name: name,
          amountCents: amountCents,
          billingCycle: _billingCycle,
          intervalCount: _intervalCount,
          intervalUnit: _intervalUnit,
          nextRenewalAt: _nextRenewal,
          category: category ?? '',
          notes: notes ?? '',
        );
      } else {
        await _service.create(
          name: name,
          amountCents: amountCents,
          billingCycle: _billingCycle,
          intervalCount: _intervalCount,
          intervalUnit: _intervalUnit,
          nextRenewalAt: _nextRenewal,
          category: category,
          catalogServiceId: _selectedCatalog?.id,
          notes: notes,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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

  String? _resolveCategory() {
    if (_selectedCategory == '__new__') {
      final t = _customCategory.trim();
      return t.isEmpty ? null : t;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) return null;
    return _selectedCategory;
  }

  Widget _buildCategoryField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategory ?? '',
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.uncategorized)),
            ...CategoryIcons.builtIn.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(CategoryIcons.displayName(c)),
                )),
            DropdownMenuItem(value: '__new__', child: Text(l10n.newCategory)),
          ],
          onChanged: (v) => setState(() => _selectedCategory = v),
          decoration: InputDecoration(labelText: l10n.category),
        ),
        if (_selectedCategory == '__new__') ...[
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => setState(() => _customCategory = v),
            decoration: InputDecoration(
              labelText: l10n.newCategory,
              hintText: 'e.g. Fitness',
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickRenewal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _nextRenewal = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    widget.subscriptionToEdit != null
                        ? AppLocalizations.of(context)!.editSubscriptionTitle
                        : AppLocalizations.of(context)!.addSubscriptionTitle,
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  if (_catalog.isNotEmpty && widget.subscriptionToEdit == null)
                    DropdownButtonFormField<CatalogService>(
                      value: _selectedCatalog,
                      items: _catalog
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCatalog = value;
                          final cat = value?.category;
                          if (cat != null &&
                              cat.isNotEmpty &&
                              !CategoryIcons.builtIn
                                  .contains(cat.toLowerCase())) {
                            _selectedCategory = '__new__';
                            _customCategory = cat;
                          } else {
                            _selectedCategory = cat?.isEmpty == true ? '' : cat;
                          }
                          _nameController.text =
                              value?.name ?? _nameController.text;
                          if (value?.defaultPriceCents != null) {
                            _amountController.text =
                                (value!.defaultPriceCents! / 100)
                                    .toStringAsFixed(2);
                          }
                        });
                      },
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.catalogService),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.amountHint),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _billingCycle,
                    items: [
                      DropdownMenuItem(
                          value: 'MONTHLY',
                          child: Text(AppLocalizations.of(context)!.monthly)),
                      DropdownMenuItem(
                          value: 'YEARLY',
                          child: Text(AppLocalizations.of(context)!.yearly)),
                      DropdownMenuItem(
                          value: 'WEEKLY',
                          child: Text(AppLocalizations.of(context)!.weekly)),
                      DropdownMenuItem(
                          value: 'CUSTOM',
                          child: Text(
                              AppLocalizations.of(context)!.customInterval)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _billingCycle = value;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.billingCycle),
                  ),
                  const SizedBox(height: 12),
                  if (_billingCycle == 'CUSTOM')
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .intervalCount),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _intervalCount = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _intervalUnit,
                            items: [
                              DropdownMenuItem(
                                  value: 'MONTH',
                                  child: Text(
                                      AppLocalizations.of(context)!.month)),
                              DropdownMenuItem(
                                  value: 'YEAR',
                                  child:
                                      Text(AppLocalizations.of(context)!.year)),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _intervalUnit = value;
                              });
                            },
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.intervalUnit),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  _buildCategoryField(context),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.nextRenewal),
                    subtitle: Text(DateFormat.yMMMd(
                            Localizations.localeOf(context).toString())
                        .format(_nextRenewal)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickRenewal,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.notesOptional),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: AppRadii.md,
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              AppLocalizations.of(context)!.saveSubscription),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
