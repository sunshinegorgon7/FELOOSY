class AppSettings {
  final int id;
  final String currencyCode;
  final String currencySymbol;
  final bool currencySymbolLeading;
  final int monthStartDay;
  final String themeMode;
  final bool googleBackupEnabled;
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
      'last_backup_at': lastBackupAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
