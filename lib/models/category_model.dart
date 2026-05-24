/// ============================================================
/// MODEL : Category
/// Catégorie pour classer les transactions
/// ============================================================
class Category {
  final int? id;
  final int userId;
  final String name;
  final String type;        // 'income' ou 'expense'
  final int iconCodePoint;  // CodePoint Font Awesome
  final int colorIndex;     // Index dans AppColors.categoryColors

  Category({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon_code_point': iconCodePoint,
      'color_index': colorIndex,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      iconCodePoint: map['icon_code_point'] as int,
      colorIndex: map['color_index'] as int,
    );
  }

  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    int? iconCodePoint,
    int? colorIndex,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
