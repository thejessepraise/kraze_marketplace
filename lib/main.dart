import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/dark_theme.dart';
import 'pages/splash/splash_page.dart';

/// The very first function that runs when the app launches.
/// runApp() takes a widget and makes it the root of the entire app.
void main() async {
  // Firebase needs the Flutter binding ready before it can talk to
  // platform channels, and initializeApp() must finish before any
  // screen tries to touch Auth/Firestore/Storage.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KrazeMarketplaceApp());
}

/// The root widget of the app.
///
/// WHY MaterialApp:
/// MaterialApp sets up everything the rest of the app expects to exist —
/// theming, navigation, default fonts, and Material Design behavior
/// (ripple effects on taps, etc.). Every Flutter app that follows Material
/// Design starts with this widget at the top.
class KrazeMarketplaceApp extends StatelessWidget {
  const KrazeMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kraze Marketplace',
      debugShowCheckedModeBanner: false, // hides the red "DEBUG" ribbon
      theme: darkTheme,
      home: const SplashPage(),
    );
  }
}