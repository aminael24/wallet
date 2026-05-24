/// ============================================================
/// MODEL : Budget
/// Budget mensuel pour une catégorie de dépense
/// ============================================================
class Budget {
  final int? id;
  final int userId;
  final int categoryId;
  final double limitAmount;
  final int month;       // 1-12
  final int year;
  final DateTime createdAt;

  // Champs joints
  final String? categoryName;
  final int? categoryIconCodePoint;
  final int? categoryColorIndex;
  final double? spentAmount; // Calculé dynamiquement

  Budget({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.categoryName,
    this.categoryIconCodePoint,
    this.categoryColorIndex,
    this.spentAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      categoryName: map['category_name'] as String?,
      categoryIconCodePoint: map['icon_code_point'] as int?,
      categoryColorIndex: map['color_index'] as int?,
      spentAmount: map['spent_amount'] != null ? (map['spent_amount'] as num).toDouble() : null,
    );
  }

  /// Pourcentage utilisé du budget (0.0 à 1.0+)
  double get usageRatio {
    if (limitAmount <= 0) return 0;
    return (spentAmount ?? 0) / limitAmount;
  }

  /// Montant restant
  double get remainingAmount => limitAmount - (spentAmount ?? 0);

  /// Le budget est-il dépassé ?
  bool get isExceeded => (spentAmount ?? 0) > limitAmount;

  /// Le budget est-il proche du dépassement (>= 80%) ?
  bool get isWarning => usageRatio >= 0.8 && !isExceeded;

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? limitAmount,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName,
      categoryIconCodePoint: categoryIconCodePoint,
      categoryColorIndex: categoryColorIndex,
      spentAmount: spentAmount,
    );
  }
}
