import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/dark_theme.dart';
import 'pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KrazeMarketplaceApp());
}

class KrazeMarketplaceApp extends StatelessWidget {
  const KrazeMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraze Marketplace',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const SplashPage(),
    );
  }
}
