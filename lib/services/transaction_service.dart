import '../models/transaction_model.dart';
import 'database_helper.dart';

/// ============================================================
/// SERVICE : TransactionService
/// CRUD pour les transactions + requêtes statistiques
/// ============================================================
class TransactionService {
  /// Récupère toutes les transactions de l'utilisateur (avec catégorie jointe)
  Future<List<Transaction>> getAllTransactions(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name AS category_name, c.icon_code_point, c.color_index
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ?
      ORDER BY t.date DESC, t.id DESC
    ''', [userId]);
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  /// Récupère les transactions filtrées par type
  Future<List<Transaction>> getTransactionsByType(int userId, String type) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name AS category_name, c.icon_code_point, c.color_index
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = ?
      ORDER BY t.date DESC, t.id DESC
    ''', [userId, type]);
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  /// Récupère les transactions pour un mois donné
  Future<List<Transaction>> getTransactionsByMonth(int userId, int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final maps = await db.rawQuery('''
      SELECT t.*, c.name AS category_name, c.icon_code_point, c.color_index
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.date >= ? AND t.date < ?
      ORDER BY t.date DESC, t.id DESC
    ''', [userId, start, end]);
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  /// Crée une nouvelle transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  /// Met à jour une transaction
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Supprime une transaction
  Future<int> deleteTransaction(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Calcule le total des revenus de l'utilisateur (toutes périodes)
  Future<double> getTotalIncome(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND type = 'income'
    ''', [userId]);
    return (result.first['total'] as num).toDouble();
  }

  /// Calcule le total des dépenses de l'utilisateur (toutes périodes)
  Future<double> getTotalExpense(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND type = 'expense'
    ''', [userId]);
    return (result.first['total'] as num).toDouble();
  }

  /// Total revenus pour un mois
  Future<double> getMonthlyIncome(int userId, int year, int month) async {
    return _getMonthlyTotal(userId, 'income', year, month);
  }

  /// Total dépenses pour un mois
  Future<double> getMonthlyExpense(int userId, int year, int month) async {
    return _getMonthlyTotal(userId, 'expense', year, month);
  }

  /// Helper interne : total par mois et par type
  Future<double> _getMonthlyTotal(int userId, String type, int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND type = ? AND date >= ? AND date < ?
    ''', [userId, type, start, end]);
    return (result.first['total'] as num).toDouble();
  }

  /// Dépenses par catégorie pour un mois donné (pour graphique camembert)
  Future<List<Map<String, dynamic>>> getExpensesByCategory(int userId, int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    return await db.rawQuery('''
      SELECT
        c.id AS category_id,
        c.name AS category_name,
        c.icon_code_point,
        c.color_index,
        COALESCE(SUM(t.amount), 0) AS total
      FROM categories c
      LEFT JOIN transactions t
        ON t.category_id = c.id
        AND t.date >= ?
        AND t.date < ?
      WHERE c.user_id = ? AND c.type = 'expense'
      GROUP BY c.id
      HAVING total > 0
      ORDER BY total DESC
    ''', [start, end, userId]);
  }

  /// Évolution mensuelle des revenus et dépenses (6 derniers mois) - pour graphique barres
  Future<List<Map<String, dynamic>>> getMonthlyEvolution(int userId, {int monthsBack = 6}) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = [];

    for (int i = monthsBack - 1; i >= 0; i--) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final income = await db.rawQuery('''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM transactions
        WHERE user_id = ? AND type = 'income' AND date >= ? AND date < ?
      ''', [userId, targetMonth.toIso8601String(), nextMonth.toIso8601String()]);

      final expense = await db.rawQuery('''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM transactions
        WHERE user_id = ? AND type = 'expense' AND date >= ? AND date < ?
      ''', [userId, targetMonth.toIso8601String(), nextMonth.toIso8601String()]);

      results.add({
        'year': targetMonth.year,
        'month': targetMonth.month,
        'income': (income.first['total'] as num).toDouble(),
        'expense': (expense.first['total'] as num).toDouble(),
      });
    }
    return results;
  }
}
