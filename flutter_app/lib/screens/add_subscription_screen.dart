import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/catalog_service.dart';
import 'package:subscription_manager_flutter/services/catalog_service.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadCatalog();
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
      final amountCents = (double.tryParse(_amountController.text) ?? 0) * 100;
      await _service.create(
        name: _nameController.text.trim(),
        amountCents: amountCents.round(),
        billingCycle: _billingCycle,
        intervalCount: _intervalCount,
        intervalUnit: _intervalUnit,
        nextRenewalAt: _nextRenewal,
        category: _selectedCatalog?.category,
        catalogServiceId: _selectedCatalog?.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add subscription')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_catalog.isNotEmpty)
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
                  _nameController.text = value?.name ?? _nameController.text;
                  if (value?.defaultPriceCents != null) {
                    _amountController.text =
                        (value!.defaultPriceCents! / 100).toStringAsFixed(2);
                  }
                });
              },
              decoration: const InputDecoration(labelText: 'Catalog service'),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount (e.g. 29.90)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _billingCycle,
            items: const [
              DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
              DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
              DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
              DropdownMenuItem(value: 'CUSTOM', child: Text('Custom interval')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _billingCycle = value;
              });
            },
            decoration: const InputDecoration(labelText: 'Billing cycle'),
          ),
          const SizedBox(height: 12),
          if (_billingCycle == 'CUSTOM')
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: 'Interval count'),
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
                    items: const [
                      DropdownMenuItem(value: 'MONTH', child: Text('Month')),
                      DropdownMenuItem(value: 'YEAR', child: Text('Year')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _intervalUnit = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Interval unit'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Next renewal'),
            subtitle: Text(DateFormat.yMMMd().format(_nextRenewal)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickRenewal,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
