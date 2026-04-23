class Category {
  final int? id;
  final String uuid;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final String iconFontFamily;
  final bool isCustom;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.uuid,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.isCustom = false,
    this.isActive = true,
    required this.sortOrder,
    required this.createdAt,
  });

  Category copyWith({
    String? name,
    int? colorValue,
    int? iconCodePoint,
    bool? isActive,
    int? sortOrder,
  }) {
    return Category(
      id: id,
      uuid: uuid,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily,
      isCustom: isCustom,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      iconCodePoint: map['icon_code_point'] as int,
      iconFontFamily: map['icon_font_family'] as String,
      isCustom: (map['is_custom'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      sortOrder: map['sort_order'] as int,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'icon_font_family': iconFontFamily,
      'is_custom': isCustom ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
