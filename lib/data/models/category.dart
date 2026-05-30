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
  // 'expense', 'income', or null for custom categories that appear in both tabs
  final String? transactionType;
  // Clearbit logo URL — when set the icon is rendered as a network image
  final String? logoUrl;
  // ISO currency code this brand category belongs to (null = all currencies)
  final String? currencyHint;

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
    this.transactionType,
    this.logoUrl,
    this.currencyHint,
  });

  // Sentinel so copyWith can explicitly set logoUrl to null (clear it).
  static const _keep = Object();

  Category copyWith({
    String? name,
    int? colorValue,
    int? iconCodePoint,
    bool? isActive,
    int? sortOrder,
    String? transactionType,
    Object? logoUrl = _keep,
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
      transactionType: transactionType ?? this.transactionType,
      logoUrl: logoUrl == _keep ? this.logoUrl : logoUrl as String?,
      currencyHint: currencyHint,
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
      transactionType: map['transaction_type'] as String?,
      logoUrl: map['logo_url'] as String?,
      currencyHint: map['currency_hint'] as String?,
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
      'transaction_type': transactionType,
      'logo_url': logoUrl,
      'currency_hint': currencyHint,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
