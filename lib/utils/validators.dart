/// Validateurs pour les champs de formulaires
class Validators {
  /// Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  /// Validation du mot de passe (min 6 caractères, au moins 1 chiffre)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    return null;
  }

  /// Validation de la confirmation du mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Validation d'un champ obligatoire
  static String? validateRequired(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }

  /// Validation d'un nom (lettres et espaces uniquement)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Validation d'un montant (nombre positif)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le montant est obligatoire';
    }
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Format de montant invalide';
    }
    if (amount <= 0) {
      return 'Le montant doit être positif';
    }
    if (amount > 999999999) {
      return 'Montant trop élevé';
    }
    return null;
  }
}
