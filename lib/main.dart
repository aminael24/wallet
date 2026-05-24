import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'controllers/auth_controller.dart';
import 'controllers/budget_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/transaction_controller.dart';
import 'utils/app_provider.dart';
import 'utils/app_theme.dart';
import 'views/auth/splash_screen.dart';

/// ============================================================
/// Point d'entrée de l'application Wallet
/// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation de la locale française pour les dates
  await initializeDateFormatting('fr_FR', null);

  // Initialisation des controllers (Singletons)
  final themeController = ThemeController();
  await themeController.loadTheme();

  final authController = AuthController();
  final transactionController = TransactionController();
  final categoryController = CategoryController();
  final budgetController = BudgetController();

  runApp(WalletApp(
    themeController: themeController,
    authController: authController,
    transactionController: transactionController,
    categoryController: categoryController,
    budgetController: budgetController,
  ));
}

/// Widget racine de l'application
class WalletApp extends StatelessWidget {
  final ThemeController themeController;
  final AuthController authController;
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;

  const WalletApp({
    super.key,
    required this.themeController,
    required this.authController,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      themeController: themeController,
      authController: authController,
      transactionController: transactionController,
      categoryController: categoryController,
      budgetController: budgetController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (ctx, _) {
          return MaterialApp(
            title: 'Wallet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: SplashScreen(authController: authController),
          );
        },
      ),
    );
  }
}
