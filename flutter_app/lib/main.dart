import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/core/platform.dart' as platform;
import 'package:subscription_manager_flutter/gen_l10n/app_localizations.dart';
import 'package:subscription_manager_flutter/screens/dashboard_screen.dart';
import 'package:subscription_manager_flutter/screens/login_screen.dart';
import 'package:subscription_manager_flutter/screens/settings_screen.dart';
import 'package:subscription_manager_flutter/services/auth_service.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';
import 'package:subscription_manager_flutter/services/locale_service.dart';
import 'package:subscription_manager_flutter/services/fcm_service.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Simulador iOS: use 127.0.0.1. No dispositivo, use o IP do Mac (api_client.dart).
  // Para forçar localhost: flutter run --dart-define=USE_LOCALHOST=true
  if (const bool.fromEnvironment('USE_LOCALHOST', defaultValue: false)) {
    ApiClient.baseUrlOverride = 'http://127.0.0.1:8080';
  }

  // Initialize Firebase only on iOS/Android (not web, not macOS)
  if (!kIsWeb && (platform.isIOS || platform.isAndroid)) {
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
  late final AuthService _authService = AuthService(storage: _authStorage);
  final FcmService _fcmService = FcmService();
  String? _token;
  String? _displayName;
  bool _checkingAuth = true;
  Locale? _savedLocale;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _savedLocale = await LocaleService.getSavedLocale();
    if (mounted) setState(() {});
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
    var displayName = await _authStorage.readDisplayName();
    if (token != null && (displayName == null || displayName.isEmpty)) {
      try {
        await _authService.fetchAndPersistProfile();
        displayName = await _authStorage.readDisplayName();
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _token = token;
        _displayName = displayName;
        _checkingAuth = false;
      });
    }
  }

  Future<void> _handleLoggedIn(String token) async {
    debugPrint(
        '[Main] _handleLoggedIn called with token: ${token.substring(0, math.min(10, token.length))}...');

    await Future.delayed(const Duration(milliseconds: 100));
    final displayName = await _authStorage.readDisplayName();
    if (mounted) {
      setState(() {
        _token = token;
        _displayName = displayName;
      });
    }

    // Initialize FCM after login/register (only on iOS/Android)
    if (platform.isIOS || platform.isAndroid) {
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
    if (mounted) setState(() {
      _token = null;
      _displayName = null;
    });
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentLocale: _savedLocale,
          onLocaleChanged: (l) => setState(() => _savedLocale = l),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return MaterialApp(
        title: 'Subscription Manager',
        theme: AppTheme.buildTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _savedLocale,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Subscription Manager',
      theme: AppTheme.buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _savedLocale,
      home: _token == null
          ? LoginScreen(onLoggedIn: _handleLoggedIn)
          : DashboardScreen(
              displayName: _displayName,
              onLogout: _handleLogout,
              onOpenSettings: _openSettings,
            ),
    );
  }
}
