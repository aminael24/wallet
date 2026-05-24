import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// ============================================================
/// CONTROLLER : AuthController
/// Gère l'état d'authentification (utilisateur courant, login, logout)
/// ============================================================
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// Vérifie au démarrage s'il y a une session active
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _currentUser = null;
    }
    _setLoading(false);
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _authService.login(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Inscription
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Mise à jour du profil utilisateur
  Future<bool> updateProfile({required String fullName}) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final updated = _currentUser!.copyWith(fullName: fullName);
      _currentUser = await _authService.updateUser(updated);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Changement de mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.changePassword(
        userId: _currentUser!.id!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
