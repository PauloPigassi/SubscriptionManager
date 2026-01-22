import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/models/notification.dart';
import 'package:subscription_manager_flutter/services/notification_storage.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _storage = NotificationStorage();
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final notifications = await _storage.getAll();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.read) return;
    await _storage.markAsRead(notification.id);
    _load();
  }

  Future<void> _markAllAsRead() async {
    await _storage.markAllAsRead();
    _load();
  }

  Future<void> _delete(AppNotification notification) async {
    await _storage.delete(notification.id);
    _load();
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return AppLocalizations.of(context)!.justNow;
        }
        return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
      }
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd(locale).format(date);
    }
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
                      Text(l10n.notifications, style: textTheme.titleLarge),
                    ],
                  ),
                  if (_notifications.isNotEmpty)
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(l10n.markAllAsRead),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 64,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  l10n.noNotifications,
                                  style: textTheme.titleMedium
                                      ?.copyWith(color: AppColors.muted),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  l10n.noNotificationsDesc,
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.muted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return Dismissible(
                                key: Key(notification.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.lg),
                                  color: Theme.of(context).colorScheme.error,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) => _delete(notification),
                                child: InkWell(
                                  onTap: () => _markAsRead(notification),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    margin: const EdgeInsets.only(
                                        bottom: AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: notification.read
                                          ? AppColors.surface
                                          : AppColors.primary.withOpacity(0.05),
                                      borderRadius: AppRadii.md,
                                      border: notification.read
                                          ? null
                                          : Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.notifications_outlined,
                                          color: notification.read
                                              ? AppColors.muted
                                              : AppColors.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification.title,
                                                style: textTheme.labelLarge
                                                    ?.copyWith(
                                                  fontWeight: notification.read
                                                      ? FontWeight.normal
                                                      : FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                notification.body,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                _formatDate(
                                                    context,
                                                    notification.receivedAt),
                                                style: textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: AppColors.muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!notification.read)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
