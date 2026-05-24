/// ============================================================
/// MODEL : User
/// Représente un utilisateur de l'application
/// ============================================================
class User {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  /// Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Création depuis une Map SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Crée une copie avec des champs modifiés
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
