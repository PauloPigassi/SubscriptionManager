import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';
import 'package:subscription_manager_flutter/screens/add_subscription_screen.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

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

  String _formatCurrency(int cents, String currency) {
    final formatter = NumberFormat.simpleCurrency(name: currency);
    return formatter.format(cents / 100.0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      final dateStr = DateFormat('MMM d').format(date);
      return '$dateStr ($difference days left)';
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'streaming':
        return Icons.movie_filter_outlined;
      case 'music':
        return Icons.headphones_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'games':
        return Icons.sports_esports_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Future<void> _archive(Subscription subscription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Subscription'),
        content: Text('Are you sure you want to archive ${subscription.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
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
        SnackBar(content: Text('${subscription.name} archived')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive: $error')),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text('Subscriptions', style: textTheme.titleLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textPrimary),
                    onPressed: _openAdd,
                  ),
                ],
              ),
            ),
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
                                  child: const Text('Retry'),
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
                                      'No subscriptions yet',
                                      style: textTheme.titleMedium
                                          ?.copyWith(color: AppColors.muted),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Add your first subscription to get started',
                                      style: textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.muted),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    ElevatedButton(
                                      onPressed: _openAdd,
                                      child: const Text('Add Subscription'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg),
                                children: [
                                  ..._subscriptions.map(
                                    (subscription) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.md),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(AppSpacing.md),
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
                                                    subscription.category),
                                                size: 18,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.md),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(subscription.name,
                                                      style:
                                                          textTheme.labelLarge),
                                                  const SizedBox(
                                                      height: AppSpacing.xs),
                                                  Text(
                                                    '${_formatCurrency(subscription.amountCents, subscription.currency)} · ${subscription.billingCycle}',
                                                    style:
                                                        textTheme.labelMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatDate(subscription
                                                      .nextRenewalAt),
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                          color:
                                                              AppColors.accent),
                                                ),
                                                const SizedBox(
                                                    height: AppSpacing.xs),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.archive_outlined,
                                                      size: 18),
                                                  color: AppColors.muted,
                                                  onPressed: () =>
                                                      _archive(subscription),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
