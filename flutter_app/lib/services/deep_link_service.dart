import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart'; // Package not installed
import 'dart:async';

/// Service for handling deep links
class DeepLinkService {
  StreamSubscription<String?>? _linkSubscription;
  Function(String subscriptionId)? onSubscriptionLink;

  DeepLinkService({this.onSubscriptionLink});

  /// Initialize deep link listening
  void initialize() {
    // Deep links disabled - uni_links package not installed
    debugPrint('DeepLinkService: Deep links disabled (uni_links package not installed)');
    // _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Disabled - uni_links package not installed
    /*
    try {
      // Handle initial link (if app was opened via deep link)
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }

      // Listen for incoming links while app is running
      _linkSubscription = linkStream.listen(
        (String? link) {
          if (link != null) {
            _handleLink(link);
          }
        },
        onError: (err) {
          debugPrint('Deep link error: $err');
        },
      );
    } catch (e) {
      debugPrint('Deep link initialization error: $e');
    }
    */
  }

  /// Handle deep link
  void _handleLink(String link) {
    debugPrint('Deep link received: $link');

    // Parse subscriptionmanager://subscription/{subscriptionId}
    final uri = Uri.parse(link);
    if (uri.scheme == 'subscriptionmanager' && uri.host == 'subscription') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final subscriptionId = pathSegments.first;
        if (onSubscriptionLink != null) {
          onSubscriptionLink!(subscriptionId);
        }
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
