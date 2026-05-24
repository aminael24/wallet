import 'package:flutter/material.dart';

/// ============================================================
/// PALETTE DE COULEURS DE L'APPLICATION WALLET
/// Style fintech moderne : violet primaire + teal accent
/// ============================================================
class AppColors {
  // ----- Couleurs principales -----
  static const Color primary = Color(0xFF6C5CE7);       // Violet doux
  static const Color primaryDark = Color(0xFF5849D6);
  static const Color primaryLight = Color(0xFF8B7FF5);

  // ----- Couleur secondaire (accent) -----
  static const Color accent = Color(0xFF00CEC9);        // Teal/Cyan
  static const Color accentDark = Color(0xFF00A8A3);

  // ----- Couleurs sémantiques -----
  static const Color income = Color(0xFF00B894);        // Vert (revenus)
  static const Color expense = Color(0xFFE17055);       // Orange-rouge (dépenses)
  static const Color warning = Color(0xFFFDCB6E);       // Jaune (alertes)
  static const Color danger = Color(0xFFD63031);        // Rouge (erreurs)

  // ----- Mode clair -----
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightDivider = Color(0xFFE5E5E5);

  // ----- Mode sombre -----
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF252544);
  static const Color darkCard = Color(0xFF2D2D4A);
  static const Color darkText = Color(0xFFF5F6FA);
  static const Color darkTextSecondary = Color(0xFFB2BEC3);
  static const Color darkDivider = Color(0xFF3D3D5C);

  // ----- Couleurs pour les catégories (12 couleurs) -----
  static const List<Color> categoryColors = [
    Color(0xFF6C5CE7), // Violet
    Color(0xFF00CEC9), // Teal
    Color(0xFFFD79A8), // Rose
    Color(0xFFFAB1A0), // Pêche
    Color(0xFF55EFC4), // Vert menthe
    Color(0xFFFFEAA7), // Jaune pâle
    Color(0xFF74B9FF), // Bleu ciel
    Color(0xFFA29BFE), // Lavande
    Color(0xFFE17055), // Orange
    Color(0xFFFD9644), // Orange foncé
    Color(0xFF26DE81), // Vert
    Color(0xFF45AAF2), // Bleu
  ];

  // ----- Gradients pour les cartes -----
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE17055), Color(0xFFFAB1A0)],
  );
}
