import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/utils/currency_format.dart';
import 'package:subscription_manager_flutter/models/dashboard_summary.dart';
import 'package:subscription_manager_flutter/screens/subscriptions_screen.dart';
import 'package:subscription_manager_flutter/screens/notifications_screen.dart';
import 'package:subscription_manager_flutter/services/dashboard_service.dart';
import 'package:subscription_manager_flutter/services/notification_storage.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';
import 'package:subscription_manager_flutter/utils/category_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.displayName,
    required this.onLogout,
    required this.onOpenSettings,
  });

  final String? displayName;
  final VoidCallback onLogout;
  final void Function(BuildContext context) onOpenSettings;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final _dashboardService = DashboardService();
  final _notificationStorage = NotificationStorage();
  DashboardSummary? _summary;
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationStorage.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        children: [
                          TextSpan(text: l10n.hello),
                          TextSpan(
                            text: widget.displayName?.isNotEmpty == true
                                ? widget.displayName!
                                : 'User',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' 👋'),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  size: 22, color: AppColors.textPrimary),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                _loadUnreadCount();
                              },
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              size: 22, color: AppColors.textPrimary),
                          onPressed: () => widget.onOpenSettings(context),
                        ),
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
                Text(l10n.monthlySpend, style: textTheme.bodyMedium),
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
                    Text(l10n.upcomingRenewals, style: textTheme.titleMedium),
                    TextButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionsScreen()),
                        );
                        if (!mounted) return;
                        _load();
                      },
                      child: Text(l10n.seeAll, style: textTheme.labelMedium),
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
                        l10n.noUpcomingRenewals,
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
                                        l10n.renewsOn(DateFormat('MMM d', Localizations.localeOf(context).toString()).format(item.nextRenewalAt)),
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
                                      _formatDate(context, item.nextRenewalAt),
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
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SubscriptionsScreen()),
                          );
                          if (!mounted) return;
                          _load();
                        },
                        borderRadius: AppRadii.md,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.manageSubscriptions,
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
