import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/finance_provider.dart';
import 'screens/registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final cardsBox = await Hive.openBox<Map>('virtual_cards');
  final transactionsBox = await Hive.openBox<Map>('finance_transactions');
  runApp(
    ProviderScope(
      overrides: [
        financeProvider.overrideWith(
          (ref) => FinanceController(
            cardsBox: cardsBox,
            transactionsBox: transactionsBox,
          ),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
        useMaterial3: true,
      ),
      home: const RegistrationScreen(),
    );
  }
}