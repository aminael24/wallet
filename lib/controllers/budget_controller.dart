import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

/// ============================================================
/// CONTROLLER : BudgetController
/// Gère les budgets mensuels
/// ============================================================
class BudgetController extends ChangeNotifier {
  final BudgetService _service = BudgetService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  /// Nombre de budgets dépassés (pour les alertes)
  int get exceededCount => _budgets.where((b) => b.isExceeded).length;
  int get warningCount => _budgets.where((b) => b.isWarning).length;

  /// Change le mois sélectionné et recharge
  Future<void> changeMonth(int userId, int year, int month) async {
    _selectedYear = year;
    _selectedMonth = month;
    await loadBudgets(userId);
  }

  /// Charge les budgets du mois sélectionné
  Future<void> loadBudgets(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _budgets = await _service.getBudgetsForMonth(userId, _selectedYear, _selectedMonth);
    } catch (e) {
      debugPrint('Erreur chargement budgets: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Ajoute un budget
  Future<bool> addBudget({
    required int userId,
    required int categoryId,
    required double limitAmount,
    required int month,
    required int year,
  }) async {
    try {
      // Vérifier qu'il n'existe pas déjà
      final existing = await _service.getBudgetForCategory(userId, categoryId, year, month);
      if (existing != null) {
        // Update au lieu de create
        final updated = existing.copyWith(limitAmount: limitAmount);
        await _service.updateBudget(updated);
      } else {
        final budget = Budget(
          userId: userId,
          categoryId: categoryId,
          limitAmount: limitAmount,
          month: month,
          year: year,
          createdAt: DateTime.now(),
        );
        await _service.createBudget(budget);
      }
      await loadBudgets(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur ajout budget: $e');
      return false;
    }
  }

  /// Met à jour un budget
  Future<bool> updateBudget(Budget budget) async {
    try {
      await _service.updateBudget(budget);
      await loadBudgets(budget.userId);
      return true;
    } catch (e) {
      debugPrint('Erreur mise à jour budget: $e');
      return false;
    }
  }

  /// Supprime un budget
  Future<bool> deleteBudget(int id, int userId) async {
    try {
      await _service.deleteBudget(id);
      await loadBudgets(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur suppression budget: $e');
      return false;
    }
  }
}
