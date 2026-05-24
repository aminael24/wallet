import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/theme_controller.dart';

/// ============================================================
/// AppProvider : InheritedWidget pour accéder aux controllers
/// depuis n'importe quel endroit de l'arbre de widgets.
/// ============================================================
class AppProvider extends InheritedWidget {
  final AuthController authController;
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;
  final ThemeController themeController;

  const AppProvider({
    super.key,
    required this.authController,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
    required this.themeController,
    required super.child,
  });

  /// Accès depuis n'importe quel widget enfant
  static AppProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider non trouvé dans le contexte');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) => false;
}
