import 'package:flutter/foundation.dart' hide Category;
import '../models/category_model.dart';
import '../services/category_service.dart';

/// ============================================================
/// CONTROLLER : CategoryController
/// Gère le CRUD des catégories
/// ============================================================
class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();
  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();
  bool get isLoading => _isLoading;

  /// Charge toutes les catégories de l'utilisateur
  Future<void> loadCategories(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _service.getAllCategories(userId);
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Ajoute une catégorie
  Future<bool> addCategory({
    required int userId,
    required String name,
    required String type,
    required int iconCodePoint,
    required int colorIndex,
  }) async {
    try {
      final cat = Category(
        userId: userId,
        name: name,
        type: type,
        iconCodePoint: iconCodePoint,
        colorIndex: colorIndex,
      );
      await _service.createCategory(cat);
      await loadCategories(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur ajout catégorie: $e');
      return false;
    }
  }

  /// Met à jour une catégorie
  Future<bool> updateCategory(Category category) async {
    try {
      await _service.updateCategory(category);
      await loadCategories(category.userId);
      return true;
    } catch (e) {
      debugPrint('Erreur mise à jour catégorie: $e');
      return false;
    }
  }

  /// Supprime une catégorie
  Future<bool> deleteCategory(int id, int userId) async {
    try {
      await _service.deleteCategory(id);
      await loadCategories(userId);
      return true;
    } catch (e) {
      debugPrint('Erreur suppression catégorie: $e');
      return false;
    }
  }

  /// Cherche une catégorie par id
  Category? getById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
