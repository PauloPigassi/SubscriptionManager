import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/dashboard_summary.dart';
import 'package:subscription_manager_flutter/screens/subscriptions_screen.dart';
import 'package:subscription_manager_flutter/services/dashboard_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly spend',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          if (summary != null)
                            Text(
                              _formatCurrency(
                                summary.monthlyTotalCents,
                                summary.currency,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                          if (summary == null && _loading)
                            const LinearProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary?.activeCount.toString() ?? '--',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Your subscriptions'),
              subtitle: const Text('Create, review, or archive plans'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Next renewals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (summary != null)
              ...summary.nextRenewals.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      '${_formatCurrency(item.amountCents, item.currency)} · ${item.billingCycle}',
                    ),
                    trailing: Text(
                      DateFormat.yMMMd().format(item.nextRenewalAt),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
