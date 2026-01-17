import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  final String subscriptionId;

  @override
  State<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  final _service = SubscriptionService();
  Subscription? _subscription;
  bool _loading = true;
  String? _error;

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
      final subscriptions = await _service.list();
      if (!mounted) return;
      final subscription = subscriptions.firstWhere(
        (s) => s.id == widget.subscriptionId,
        orElse: () => throw Exception('Subscription not found'),
      );
      setState(() {
        _subscription = subscription;
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

  String _formatCurrency(int cents, String currency) {
    final formatter = NumberFormat.simpleCurrency(name: currency);
    return formatter.format(cents / 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _subscription == null
                  ? const Center(child: Text('Subscription not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _subscription!.name,
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _DetailRow(
                            label: 'Amount',
                            value: _formatCurrency(
                              _subscription!.amountCents,
                              _subscription!.currency,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: 'Billing Cycle',
                            value: _subscription!.billingCycle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _DetailRow(
                            label: 'Next Renewal',
                            value: DateFormat.yMMMd().format(
                              _subscription!.nextRenewalAt,
                            ),
                          ),
                          if (_subscription!.category != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _DetailRow(
                              label: 'Category',
                              value: _subscription!.category!,
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
