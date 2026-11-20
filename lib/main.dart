import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/theme_settings.dart';
import 'screens/registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialDarkMode = prefs.getBool('app_theme_dark_mode') ?? false;

  runApp(
    ChangeNotifierProvider<ThemeSettings>(
      create: (_) => ThemeSettings(prefs, initialDarkMode),
      child: ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: ChangeNotifierProvider(
          create: (_) => CatalogProvider(),
          child: const ExpenseTrackerApp(),
        ),
      ),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeSettings>().isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF02569B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const RegistrationScreen(),
    );
  }
}
