import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/subscription_preview_screen.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubscriptionManagerApp());
}

class SubscriptionManagerApp extends StatelessWidget {
  const SubscriptionManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Manager',
      theme: AppTheme.buildTheme(),
      home: const SubscriptionPreviewScreen(),
    );
  }
}
