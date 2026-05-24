import '../models/category_model.dart';
import 'database_helper.dart';

/// ============================================================
/// SERVICE : CategoryService
/// CRUD pour les catégories
/// ============================================================
class CategoryService {
  /// Récupère toutes les catégories de l'utilisateur
  Future<List<Category>> getAllCategories(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'type ASC, name ASC',
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Récupère les catégories filtrées par type
  Future<List<Category>> getCategoriesByType(int userId, String type) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Récupère une catégorie par son id
  Future<Category?> getCategoryById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Crée une nouvelle catégorie
  Future<Category> createCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  /// Met à jour une catégorie
  Future<int> updateCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Supprime une catégorie (et les transactions/budgets associés via CASCADE)
  Future<int> deleteCategory(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
