import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/dashboard_screen.dart';
import 'package:subscription_manager_flutter/screens/login_screen.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';
import 'package:subscription_manager_flutter/services/fcm_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only on iOS/Android (not macOS)
  if (Platform.isIOS || Platform.isAndroid) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        debugPrint('✅ Firebase initialized successfully');
      } else {
        debugPrint('✅ Firebase already initialized');
      }
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      debugPrint('Continuing without Firebase');
    }
  } else {
    debugPrint(
        '⚠️ Skipping Firebase initialization (not iOS/Android platform)');
  }

  runApp(const SubscriptionManagerApp());
}

class SubscriptionManagerApp extends StatefulWidget {
  const SubscriptionManagerApp({super.key});

  @override
  State<SubscriptionManagerApp> createState() => _SubscriptionManagerAppState();
}

class _SubscriptionManagerAppState extends State<SubscriptionManagerApp> {
  final AuthStorage _authStorage = AuthStorage();
  final FcmService _fcmService = FcmService();
  String? _token;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkAuth();

    // Initialize FCM if user is already logged in
    if (_token != null && Firebase.apps.isNotEmpty) {
      try {
        await _fcmService.initialize();
      } catch (e) {
        debugPrint('FCM initialization error: $e');
      }
    }
  }

  Future<void> _checkAuth() async {
    final token = await _authStorage.readToken();
    setState(() {
      _token = token;
      _checkingAuth = false;
    });
  }

  Future<void> _handleLoggedIn(String token) async {
    debugPrint(
        '[Main] _handleLoggedIn called with token: ${token.substring(0, math.min(10, token.length))}...');

    setState(() {
      _token = token;
    });

    // Wait a bit to ensure token is saved to storage
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize FCM after login/register (only on iOS/Android)
    if (Platform.isIOS || Platform.isAndroid) {
      // Try to initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        debugPrint(
            '[Main] ⚠️ Firebase apps is empty, attempting to initialize...');
        try {
          await Firebase.initializeApp();
          debugPrint(
              '[Main] ✅ Firebase initialized successfully in _handleLoggedIn');
        } catch (e) {
          debugPrint('[Main] ❌ Failed to initialize Firebase: $e');
          debugPrint(
              '[Main] Continuing without FCM (Firebase may not be configured for this platform)');
          return;
        }
      } else {
        debugPrint('[Main] Firebase already initialized');
      }

      // Initialize FCM after login/register
      debugPrint('[Main] Initializing FCM...');
      try {
        await _fcmService.initialize();
        debugPrint('[Main] ✅ FCM initialized after login');
      } catch (e, stackTrace) {
        debugPrint('[Main] ❌ FCM initialization error after login: $e');
        debugPrint('[Main] Stack trace: $stackTrace');
      }
    } else {
      debugPrint(
          '[Main] ⚠️ Skipping FCM initialization (not iOS/Android platform)');
    }
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
