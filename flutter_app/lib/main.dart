import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/stellar_wise_preview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubscriptionManagerApp());
}

class SubscriptionManagerApp extends StatelessWidget {
  const SubscriptionManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stellar Wise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5CE2)),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const StellarWisePreviewScreen(),
    );
  }
}
