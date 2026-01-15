import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/dashboard_screen.dart';
import 'package:subscription_manager_flutter/screens/login_screen.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

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
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _authStorage.readToken();
    setState(() {
      _token = token;
      _checkingAuth = false;
    });
  }

  void _handleLoggedIn(String token) {
    setState(() {
      _token = token;
    });
  }

  Future<void> _handleLogout() async {
    await _authStorage.clearToken();
    setState(() {
      _token = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return MaterialApp(
        title: 'Subscription Manager',
        theme: AppTheme.buildTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Subscription Manager',
      theme: AppTheme.buildTheme(),
      home: _token == null
          ? LoginScreen(onLoggedIn: _handleLoggedIn)
          : DashboardScreen(onLogout: _handleLogout),
    );
  }
}
