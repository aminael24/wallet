import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

/// ============================================================
/// CONTROLLER : TransactionController
/// Gère les transactions et les statistiques associées
/// ============================================================
class TransactionController extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<Transaction> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  bool _isLoading = false;

  // Getters
  List<Transaction> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get monthlyBalance => _monthlyIncome - _monthlyExpense;
  bool get isLoading => _isLoading;

  /// Charge toutes les transactions et calcule les totaux
  Future<void> loadTransactions(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _service.getAllTransactions(userId);
      _totalIncome = await _service.getTotalIncome(userId);
      _totalExpense = await _service.getTotalExpense(userId);

      final now = DateTime.now();
      _monthlyIncome = await _service.getMonthlyIncome(userId, now.year, now.month);
      _monthlyExpense = await _service.getMonthlyExpense(userId, now.year, now.month);
    } catch (e) {
      debugPrint('Erreur chargement transactions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Récupère les transactions filtrées par type
  List<Transaction> getFilteredTransactions(String? type) {
    if (type == null) return _transactions;
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Ajoute une transaction
  Future<bool> addTransaction({
    required int userId,
    required int categoryId,
    required double amount,
    required String type,
    required String title,
    String? note,
    required DateTime date,
  }) async {
    try {
      final t = Transaction(
        userId: userId,
        categoryId: categoryId,
        amount: amount,
        type: type,
        title: title,
        note: note,
        date: date,
        createdAt: DateTime.now(),
      );
      await _service.createTransaction(t);
      await loadTransactions(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur ajout transaction: $e');
      return false;
    }
  }

  /// Met à jour une transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      await _service.updateTransaction(transaction);
      await loadTransactions(transaction.userId);
      return true;
    } catch (e) {
      debugPrint('Erreur mise à jour transaction: $e');
      return false;
    }
  }

  /// Supprime une transaction
  Future<bool> deleteTransaction(int id, int userId) async {
    try {
      await _service.deleteTransaction(id);
      await loadTransactions(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur suppression transaction: $e');
      return false;
    }
  }

  /// Statistiques pour un mois (utilisé par l'écran statistiques)
  Future<List<Map<String, dynamic>>> getExpensesByCategory(
      int userId, int year, int month) async {
    return await _service.getExpensesByCategory(userId, year, month);
  }

  /// Évolution sur N derniers mois (graphique barres)
  Future<List<Map<String, dynamic>>> getMonthlyEvolution(
      int userId, {int monthsBack = 6}) async {
    return await _service.getMonthlyEvolution(userId, monthsBack: monthsBack);
  }
}
