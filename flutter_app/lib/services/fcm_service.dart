import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/api/api_client.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';

/// Service for handling Firebase Cloud Messaging (FCM)
class FcmService {
  FcmService({ApiClient? client, AuthStorage? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? AuthStorage();

  final ApiClient _client;
  final AuthStorage _storage;
  FirebaseMessaging? _messaging;

  /// Get FirebaseMessaging instance (lazy initialization)
  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      debugPrint('FCM: Starting initialization...');

      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('FCM: ❌ Firebase not initialized, skipping FCM setup');
        return;
      }

      debugPrint('FCM: Firebase is initialized, requesting permissions...');

      // Request notification permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('FCM: User granted provisional permission');
      } else {
        debugPrint('FCM: User declined or has not accepted permission');
        return;
      }

      // On iOS, get APNS token first, then FCM token
      if (Platform.isIOS) {
        debugPrint('FCM: Getting APNS token (required for iOS)...');

        // Wait for APNS token with multiple retries
        String? apnsToken;
        int retries = 0;
        const maxRetries = 10;
        const retryDelay = Duration(milliseconds: 500);

        while (apnsToken == null && retries < maxRetries) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) {
            debugPrint(
                'FCM: ✅ APNS token obtained: ${apnsToken.substring(0, math.min(20, apnsToken.length))}...');
            break;
          } else {
            retries++;
            if (retries < maxRetries) {
              debugPrint(
                  'FCM: ⚠️ APNS token not available yet, retrying... (${retries}/${maxRetries})');
              await Future.delayed(retryDelay);
            }
          }
        }

        if (apnsToken == null) {
          debugPrint(
              'FCM: ⚠️ APNS token not available after ${maxRetries} retries, continuing anyway...');
          debugPrint(
              'FCM: This may happen in simulator or if notifications are not fully configured');
          // Continue anyway - FCM token might still work
        }
      }

      // Get FCM token
      debugPrint('FCM: Getting FCM token...');
      String? token = await messaging.getToken();
      if (token != null) {
        debugPrint(
            'FCM: ✅ FCM token obtained: ${token.substring(0, math.min(20, token.length))}...');
        await _registerToken(token);
      } else {
        debugPrint('FCM: ❌ Failed to get FCM token (token is null)');
        // On iOS, if FCM token is null, try waiting a bit more
        if (Platform.isIOS) {
          debugPrint('FCM: Waiting and retrying FCM token on iOS...');
          await Future.delayed(const Duration(seconds: 2));
          token = await messaging.getToken();
          if (token != null) {
            debugPrint(
                'FCM: ✅ FCM token obtained after retry: ${token.substring(0, math.min(20, token.length))}...');
            await _registerToken(token);
          } else {
            debugPrint('FCM: ❌ FCM token still null after retry');
          }
        }
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        _registerToken(newToken);
      });

      // Configure foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configure background message handler (must be top-level function)
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle notification taps (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    debugPrint('FCM: ========== _registerToken called ==========');
    debugPrint(
        'FCM: Token received: ${token.substring(0, math.min(20, token.length))}...');

    try {
      debugPrint('FCM: Step 1 - Attempting to register token...');

      debugPrint('FCM: Step 2 - Reading auth token from storage...');
      final authToken = await _storage.readToken();
      debugPrint(
          'FCM: Auth token value: ${authToken != null ? (authToken.isEmpty ? "EMPTY" : "${authToken.substring(0, math.min(10, authToken.length))}...") : "NULL"}');

      if (authToken == null || authToken.isEmpty) {
        debugPrint('FCM: ❌ No auth token, skipping registration');
        debugPrint(
            'FCM: This means the user is not logged in yet or token was not saved properly');
        return;
      }

      debugPrint('FCM: Step 3 - Getting platform...');
      final platform = _getPlatform();
      debugPrint('FCM: Platform: $platform');
      debugPrint('FCM: Step 4 - Preparing request data...');
      debugPrint(
          'FCM: Registering token - Platform: $platform, Token: ${token.substring(0, math.min(20, token.length))}...');

      debugPrint('FCM: Step 5 - Making POST request to /v1/devices...');
      final response = await _client.post(
        '/v1/devices',
        {
          'platform': platform,
          'fcmToken': token,
        },
        withAuth: true,
      );

      debugPrint('FCM: Step 6 - Response received!');
      debugPrint('FCM: Response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
            'FCM: ✅ Token registered successfully! Status: ${response.statusCode}');
      } else {
        debugPrint('FCM: ❌ Token registration failed: ${response.statusCode}');
        debugPrint('FCM: Response body: ${response.body}');
      }
      debugPrint('FCM: ========== _registerToken completed ==========');
    } catch (e, stackTrace) {
      debugPrint('FCM: ❌ Token registration error at step: $e');
      debugPrint('FCM: Error type: ${e.runtimeType}');
      debugPrint('FCM: Stack trace: $stackTrace');
      debugPrint('FCM: ========== _registerToken failed ==========');
    }
  }

  String _getPlatform() {
    if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isMacOS) {
      return 'MACOS';
    }
    return 'UNKNOWN';
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground message: ${message.messageId}');
    debugPrint('  Title: ${message.notification?.title}');
    debugPrint('  Body: ${message.notification?.body}');
    debugPrint('  Data: ${message.data}');

    // You can show a local notification or update UI here
    // For now, we'll just log it
  }

  /// Handle notification tap (deep link)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM notification tapped: ${message.messageId}');
    debugPrint('  Data: ${message.data}');

    final deepLink = message.data['deepLink'] as String?;
    final subscriptionId = message.data['subscriptionId'] as String?;

    if (deepLink != null || subscriptionId != null) {
      // Navigate to subscription details
      // This will be handled by the main app using a navigator key
      _navigateToSubscription(subscriptionId);
    }
  }

  void _navigateToSubscription(String? subscriptionId) {
    // This will be set by the main app
    if (_navigationCallback != null && subscriptionId != null) {
      _navigationCallback!(subscriptionId);
    }
  }

  static Function(String)? _navigationCallback;

  /// Set callback for navigation (called from main app)
  static void setNavigationCallback(Function(String) callback) {
    _navigationCallback = callback;
  }
}

/// Top-level background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase only if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  debugPrint('FCM background message: ${message.messageId}');
  debugPrint('  Title: ${message.notification?.title}');
  debugPrint('  Body: ${message.notification?.body}');
  debugPrint('  Data: ${message.data}');
}
