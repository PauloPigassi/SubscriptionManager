import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/dashboard_summary.dart';
import 'package:subscription_manager_flutter/screens/subscriptions_screen.dart';
import 'package:subscription_manager_flutter/services/dashboard_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardService = DashboardService();
  DashboardSummary? _summary;
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
      final summary = await _dashboardService.fetchSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = _summary;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.titleMedium
                            ?.copyWith(color: AppColors.textPrimary),
                        children: const [
                          TextSpan(text: 'Hello, '),
                          TextSpan(
                            text: 'User',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' 👋'),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surface,
                          child: IconButton(
                            icon: const Icon(Icons.logout,
                                size: 18, color: AppColors.textPrimary),
                            onPressed: widget.onLogout,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Monthly Spend', style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                if (_loading)
                  const LinearProgressIndicator()
                else if (summary != null)
                  Text(
                    _formatCurrency(
                        summary.monthlyTotalCents, summary.currency),
                    style: textTheme.displaySmall,
                  )
                else
                  Text('--', style: textTheme.displaySmall),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _error!,
                    style: textTheme.labelMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Renewals', style: textTheme.titleMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionsScreen()),
                        );
                      },
                      child: Text('See All', style: textTheme.labelMedium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading && summary == null)
                  const Center(child: CircularProgressIndicator())
                else if (summary != null && summary.nextRenewals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.md,
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Center(
                      child: Text(
                        'No upcoming renewals',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  )
                else if (summary != null)
                  ...summary.nextRenewals.take(5).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadii.md,
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.background,
                                  child: Icon(
                                    _getCategoryIcon(item.category),
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: textTheme.labelLarge),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Renews on ${DateFormat('MMM d').format(item.nextRenewalAt)}',
                                        style: textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(
                                          item.amountCents, item.currency),
                                      style: textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _formatDate(item.nextRenewalAt),
                                      style: textTheme.labelMedium
                                          ?.copyWith(color: AppColors.accent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.md,
                    boxShadow: AppShadows.soft,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionsScreen()),
                        );
                      },
                      borderRadius: AppRadii.md,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Manage Subscriptions',
                              style: textTheme.labelLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
