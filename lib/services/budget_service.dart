import '../models/budget_model.dart';
import 'database_helper.dart';

/// ============================================================
/// SERVICE : BudgetService
/// CRUD pour les budgets mensuels
/// ============================================================
class BudgetService {
  /// Récupère les budgets d'un mois donné (avec montant dépensé calculé)
  Future<List<Budget>> getBudgetsForMonth(int userId, int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final maps = await db.rawQuery('''
      SELECT
        b.*,
        c.name AS category_name,
        c.icon_code_point,
        c.color_index,
        COALESCE((
          SELECT SUM(t.amount)
          FROM transactions t
          WHERE t.category_id = b.category_id
            AND t.user_id = b.user_id
            AND t.type = 'expense'
            AND t.date >= ?
            AND t.date < ?
        ), 0) AS spent_amount
      FROM budgets b
      INNER JOIN categories c ON b.category_id = c.id
      WHERE b.user_id = ? AND b.year = ? AND b.month = ?
      ORDER BY b.created_at DESC
    ''', [start, end, userId, year, month]);

    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  /// Récupère un budget par sa catégorie et son mois (ou null)
  Future<Budget?> getBudgetForCategory(int userId, int categoryId, int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'budgets',
      where: 'user_id = ? AND category_id = ? AND year = ? AND month = ?',
      whereArgs: [userId, categoryId, year, month],
    );
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  /// Crée un nouveau budget
  Future<Budget> createBudget(Budget budget) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('budgets', budget.toMap());
    return budget.copyWith(id: id);
  }

  /// Met à jour un budget
  Future<int> updateBudget(Budget budget) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Supprime un budget
  Future<int> deleteBudget(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
