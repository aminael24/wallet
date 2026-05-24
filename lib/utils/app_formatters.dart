import 'package:intl/intl.dart';

/// Utilitaires de formatage (devises, dates)
class AppFormatters {
  /// Formate un montant avec la devise (ex: 1 234,56 MAD)
  static String formatCurrency(double amount, {String currency = 'MAD'}) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  /// Formate un montant compact (ex: 1.2K, 3.4M)
  static String formatCompactCurrency(double amount, {String currency = 'MAD'}) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return '${amount.toStringAsFixed(2)} $currency';
  }

  /// Formate une date courte (ex: 23/05/2026)
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formate une date longue (ex: Samedi 23 mai 2026)
  static String formatLongDate(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formate une date avec heure (ex: 23/05/2026 à 14:30)
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  /// Formate le mois et l'année (ex: Mai 2026)
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Renvoie une date relative (ex: Aujourd'hui, Hier, ...)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Aujourd\'hui';
    if (dateOnly == yesterday) return 'Hier';
    if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(date);
    }
    return formatDate(date);
  }
}
