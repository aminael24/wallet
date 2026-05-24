import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'database_helper.dart';

/// ============================================================
/// SERVICE : AuthService
/// Gère l'authentification (inscription, connexion, déconnexion)
/// ============================================================
class AuthService {
  /// Hash le mot de passe avec SHA-256 + sel (sécurité minimale)
  String _hashPassword(String password) {
    const salt = 'wallet_app_ensa_2026'; // sel statique pour le projet
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Inscription d'un nouvel utilisateur
  /// Retourne le User créé ou lance une exception
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final normalizedEmail = email.trim().toLowerCase();

    // Vérifier si l'email existe déjà
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Créer l'utilisateur
    final newUser = User(
      fullName: fullName.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    final id = await db.insert('users', newUser.toMap());
    final createdUser = newUser.copyWith(id: id);

    // Créer les catégories par défaut pour cet utilisateur
    await _createDefaultCategories(id);

    // Sauvegarder la session
    await _saveSession(id);

    return createdUser;
  }

  /// Connexion d'un utilisateur
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final normalizedEmail = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    final results = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [normalizedEmail, hash],
    );

    if (results.isEmpty) {
      throw Exception('Email ou mot de passe incorrect');
    }

    final user = User.fromMap(results.first);
    await _saveSession(user.id!);
    return user;
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyCurrentUserId);
  }

  /// Récupère l'utilisateur connecté (ou null)
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.prefKeyCurrentUserId);
    if (userId == null) return null;

    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  /// Mise à jour des informations utilisateur
  Future<User> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  /// Changement de mot de passe
  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final oldHash = _hashPassword(oldPassword);

    final results = await db.query(
      'users',
      where: 'id = ? AND password_hash = ?',
      whereArgs: [userId, oldHash],
    );

    if (results.isEmpty) {
      throw Exception('Ancien mot de passe incorrect');
    }

    await db.update(
      'users',
      {'password_hash': _hashPassword(newPassword)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Sauvegarde l'id utilisateur dans SharedPreferences
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefKeyCurrentUserId, userId);
  }

  /// Crée les catégories par défaut pour un nouvel utilisateur
  Future<void> _createDefaultCategories(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (final cat in AppConstants.defaultCategories) {
      batch.insert('categories', {
        'user_id': userId,
        'name': cat['name'],
        'type': cat['type'],
        'icon_code_point': cat['icon'],
        'color_index': cat['color'],
      });
    }
    await batch.commit(noResult: true);
  }
}
