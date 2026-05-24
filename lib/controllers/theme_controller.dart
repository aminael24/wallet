import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

/// ============================================================
/// CONTROLLER : ThemeController
/// Gère le mode clair/sombre et le persiste
/// ============================================================
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Charge le thème sauvegardé au démarrage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefKeyTheme);
    switch (saved) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Bascule entre clair et sombre
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _save();
    notifyListeners();
  }

  /// Définit explicitement le thème
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (_themeMode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString(AppConstants.prefKeyTheme, value);
  }
}
