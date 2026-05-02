class Account {
  final int? id;
  final String name;
  final String currencyCode;
  final String currencySymbol;
  final bool currencySymbolLeading;
  final double? defaultMonthlyBudget;
  final bool isFavorite;
  final int? monthStartDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySymbolLeading,
    required this.defaultMonthlyBudget,
    required this.isFavorite,
    this.monthStartDay,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? name,
    String? currencyCode,
    String? currencySymbol,
    bool? currencySymbolLeading,
    double? defaultMonthlyBudget,
    bool clearDefaultMonthlyBudget = false,
    bool? isFavorite,
    int? monthStartDay,
    bool clearMonthStartDay = false,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencySymbolLeading:
          currencySymbolLeading ?? this.currencySymbolLeading,
      defaultMonthlyBudget: clearDefaultMonthlyBudget
          ? null
          : (defaultMonthlyBudget ?? this.defaultMonthlyBudget),
      isFavorite: isFavorite ?? this.isFavorite,
      monthStartDay: clearMonthStartDay ? null : (monthStartDay ?? this.monthStartDay),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      currencyCode: map['currency_code'] as String,
      currencySymbol: map['currency_symbol'] as String,
      currencySymbolLeading: (map['currency_symbol_leading'] as int) == 1,
      defaultMonthlyBudget:
          (map['default_monthly_budget'] as num?)?.toDouble(),
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      monthStartDay: map['month_start_day'] as int?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'name': name,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'currency_symbol_leading': currencySymbolLeading ? 1 : 0,
      'default_monthly_budget': defaultMonthlyBudget,
      'is_favorite': isFavorite ? 1 : 0,
      'month_start_day': monthStartDay,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
