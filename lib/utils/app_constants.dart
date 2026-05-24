import 'package:flutter/material.dart';

/// Constantes globales de l'application
class AppConstants {
  // Clés SharedPreferences
  static const String prefKeyTheme = 'app_theme_mode';
  static const String prefKeyCurrentUserId = 'current_user_id';
  static const String prefKeyCurrency = 'currency_symbol';

  // Devise par défaut
  static const String defaultCurrency = 'MAD'; // Dirham marocain

  // Catégories par défaut - on utilise Material Icons (toujours disponibles)
  // Le codePoint est utilisé tel quel avec IconData(fontFamily: 'MaterialIcons')
  static const List<Map<String, dynamic>> defaultCategories = [
    // Dépenses
    {'name': 'Alimentation', 'type': 'expense', 'icon': 0xe25a, 'color': 0},      // restaurant
    {'name': 'Transport', 'type': 'expense', 'icon': 0xe1d5, 'color': 1},         // directions_car
    {'name': 'Loisirs', 'type': 'expense', 'icon': 0xe40f, 'color': 2},           // sports_esports
    {'name': 'Santé', 'type': 'expense', 'icon': 0xe305, 'color': 3},             // local_hospital
    {'name': 'Éducation', 'type': 'expense', 'icon': 0xe80c, 'color': 4},         // school
    {'name': 'Shopping', 'type': 'expense', 'icon': 0xe59c, 'color': 5},          // shopping_cart
    {'name': 'Logement', 'type': 'expense', 'icon': 0xe88a, 'color': 6},          // home
    {'name': 'Factures', 'type': 'expense', 'icon': 0xe53e, 'color': 7},          // receipt
    {'name': 'Autre dépense', 'type': 'expense', 'icon': 0xe5d3, 'color': 8},     // more_horiz
    // Revenus
    {'name': 'Salaire', 'type': 'income', 'icon': 0xe263, 'color': 10},           // work
    {'name': 'Bourse', 'type': 'income', 'icon': 0xe80c, 'color': 11},            // school
    {'name': 'Cadeau', 'type': 'income', 'icon': 0xe8f6, 'color': 2},             // card_giftcard
    {'name': 'Investissement', 'type': 'income', 'icon': 0xe6e1, 'color': 1},     // trending_up
    {'name': 'Autre revenu', 'type': 'income', 'icon': 0xe145, 'color': 10},      // add_circle
  ];

  // Types de transactions
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';
}

/// Helper pour convertir un codePoint Material Icons en IconData
IconData iconFromCodePoint(int codePoint) {
  return IconData(codePoint, fontFamily: 'MaterialIcons');
}
