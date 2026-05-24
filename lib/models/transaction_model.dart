/// ============================================================
/// MODEL : Transaction
/// Représente une opération financière (revenu ou dépense)
/// ============================================================
class Transaction {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final String type;        // 'income' ou 'expense'
  final String title;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  // Champs joints depuis la table category (pour l'affichage)
  final String? categoryName;
  final int? categoryIconCodePoint;
  final int? categoryColorIndex;

  Transaction({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.title,
    this.note,
    required this.date,
    required this.createdAt,
    this.categoryName,
    this.categoryIconCodePoint,
    this.categoryColorIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'title': title,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      categoryName: map['category_name'] as String?,
      categoryIconCodePoint: map['icon_code_point'] as int?,
      categoryColorIndex: map['color_index'] as int?,
    );
  }

  Transaction copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    String? type,
    String? title,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName,
      categoryIconCodePoint: categoryIconCodePoint,
      categoryColorIndex: categoryColorIndex,
    );
  }
}
