class AppSettings {
  final int id;
  final String currencyCode;
  final String currencySymbol;
  final bool currencySymbolLeading;
  final int monthStartDay;
  final String themeMode;
  final bool googleBackupEnabled;
  final double defaultMonthlyBudget;
  final DateTime? lastBackupAt;
  final DateTime updatedAt;

  const AppSettings({
    this.id = 1,
    this.currencyCode = 'AED',
    this.currencySymbol = 'AED',
    this.currencySymbolLeading = false,
    this.monthStartDay = 1,
    this.themeMode = 'system',
    this.googleBackupEnabled = false,
    this.defaultMonthlyBudget = 0,
    this.lastBackupAt,
    required this.updatedAt,
  });

  static AppSettings get defaults => AppSettings(updatedAt: DateTime.now());

  AppSettings copyWith({
    String? currencyCode,
    String? currencySymbol,
    bool? currencySymbolLeading,
    int? monthStartDay,
    String? themeMode,
    bool? googleBackupEnabled,
    double? defaultMonthlyBudget,
    DateTime? lastBackupAt,
  }) {
    return AppSettings(
      id: id,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencySymbolLeading:
          currencySymbolLeading ?? this.currencySymbolLeading,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      themeMode: themeMode ?? this.themeMode,
      googleBackupEnabled: googleBackupEnabled ?? this.googleBackupEnabled,
      defaultMonthlyBudget: defaultMonthlyBudget ?? this.defaultMonthlyBudget,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      updatedAt: DateTime.now(),
    );
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int,
      currencyCode: map['currency_code'] as String,
      currencySymbol: map['currency_symbol'] as String,
      currencySymbolLeading: (map['currency_symbol_leading'] as int) == 1,
      monthStartDay: map['month_start_day'] as int,
      themeMode: map['theme_mode'] as String,
      googleBackupEnabled: (map['google_backup_enabled'] as int) == 1,
      defaultMonthlyBudget:
          (map['default_monthly_budget'] as num?)?.toDouble() ?? 0,
      lastBackupAt: map['last_backup_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_backup_at'] as int)
          : null,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'currency_symbol_leading': currencySymbolLeading ? 1 : 0,
      'month_start_day': monthStartDay,
      'theme_mode': themeMode,
      'google_backup_enabled': googleBackupEnabled ? 1 : 0,
      'default_monthly_budget': defaultMonthlyBudget,
      'last_backup_at': lastBackupAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
