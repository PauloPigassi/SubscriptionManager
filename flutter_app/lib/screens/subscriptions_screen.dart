import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subscription_manager_flutter/models/subscription.dart';
import 'package:subscription_manager_flutter/screens/add_subscription_screen.dart';
import 'package:subscription_manager_flutter/services/subscription_service.dart';

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

  Future<void> _archive(Subscription subscription) async {
    await _service.archive(subscription.id);
    _load();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            onPressed: _openAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (!_loading && _subscriptions.isEmpty)
              const Text('No active subscriptions yet.'),
            ..._subscriptions.map(
              (subscription) => Card(
                child: ListTile(
                  title: Text(subscription.name),
                  subtitle: Text(
                    '${_formatCurrency(subscription.amountCents, subscription.currency)} · ${subscription.billingCycle}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: () => _archive(subscription),
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
