import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/dashboard_screen.dart';
import 'package:subscription_manager_flutter/screens/login_screen.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubscriptionManagerApp());
}

class SubscriptionManagerApp extends StatefulWidget {
  const SubscriptionManagerApp({super.key});

  @override
  State<SubscriptionManagerApp> createState() => _SubscriptionManagerAppState();
}

class _SubscriptionManagerAppState extends State<SubscriptionManagerApp> {
  final AuthStorage _authStorage = AuthStorage();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _authStorage.readToken();
    if (!mounted) return;
    setState(() {
      _token = token;
    });
  }

  void _handleLoggedIn(String token) {
    setState(() {
      _token = token;
    });
  }

  Future<void> _handleLogout() async {
    await _authStorage.clearToken();
    if (!mounted) return;
    setState(() {
      _token = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: _token == null
          ? LoginScreen(onLoggedIn: _handleLoggedIn)
          : DashboardScreen(onLogout: _handleLogout),
    );
  }
}
