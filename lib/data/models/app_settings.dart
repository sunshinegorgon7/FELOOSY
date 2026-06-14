class AppSettings {
  final int id;
  final String currencyCode;
  final String currencySymbol;
  final bool currencySymbolLeading;
  final int monthStartDay;
  final String themeMode;
  final int? favoriteAccountId;
  final bool googleBackupEnabled;
  final double defaultMonthlyBudget;
  final DateTime? lastBackupAt;
  final DateTime updatedAt;
  final bool tutorialCompleted;
  final DateTime? privacyAcceptedAt;
  // BCP-47 language tag (e.g. 'en', 'ar'). Empty string = follow system locale.
  final String languageCode;
  final bool smsOptIn;
  final bool discreetMode;

  const AppSettings({
    this.id = 1,
    this.currencyCode = 'AED',
    this.currencySymbol = 'AED',
    this.currencySymbolLeading = false,
    this.monthStartDay = 1,
    this.themeMode = 'system',
    this.favoriteAccountId,
    this.googleBackupEnabled = false,
    this.defaultMonthlyBudget = 0,
    this.lastBackupAt,
    required this.updatedAt,
    this.tutorialCompleted = false,
    this.privacyAcceptedAt,
    this.languageCode = '',
    this.smsOptIn = false,
    this.discreetMode = false,
  });

  static AppSettings get defaults => AppSettings(updatedAt: DateTime.now());

  AppSettings copyWith({
    String? currencyCode,
    String? currencySymbol,
    bool? currencySymbolLeading,
    int? monthStartDay,
    String? themeMode,
    int? favoriteAccountId,
    bool? googleBackupEnabled,
    double? defaultMonthlyBudget,
    DateTime? lastBackupAt,
    bool? tutorialCompleted,
    DateTime? privacyAcceptedAt,
    String? languageCode,
    bool? smsOptIn,
    bool? discreetMode,
  }) {
    return AppSettings(
      id: id,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencySymbolLeading:
          currencySymbolLeading ?? this.currencySymbolLeading,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      themeMode: themeMode ?? this.themeMode,
      favoriteAccountId: favoriteAccountId ?? this.favoriteAccountId,
      googleBackupEnabled: googleBackupEnabled ?? this.googleBackupEnabled,
      defaultMonthlyBudget: defaultMonthlyBudget ?? this.defaultMonthlyBudget,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      updatedAt: DateTime.now(),
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      privacyAcceptedAt: privacyAcceptedAt ?? this.privacyAcceptedAt,
      languageCode: languageCode ?? this.languageCode,
      smsOptIn: smsOptIn ?? this.smsOptIn,
      discreetMode: discreetMode ?? this.discreetMode,
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
      favoriteAccountId: map['favorite_account_id'] as int?,
      googleBackupEnabled: (map['google_backup_enabled'] as int) == 1,
      defaultMonthlyBudget:
          (map['default_monthly_budget'] as num?)?.toDouble() ?? 0,
      lastBackupAt: map['last_backup_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_backup_at'] as int)
          : null,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      tutorialCompleted: (map['tutorial_completed'] as int? ?? 0) == 1,
      privacyAcceptedAt: map['privacy_accepted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['privacy_accepted_at'] as int)
          : null,
      languageCode: map['language_code'] as String? ?? '',
      smsOptIn: (map['sms_opt_in'] as int? ?? 0) == 1,
      discreetMode: (map['discreet_mode'] as int? ?? 0) == 1,
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
      'favorite_account_id': favoriteAccountId,
      'google_backup_enabled': googleBackupEnabled ? 1 : 0,
      'default_monthly_budget': defaultMonthlyBudget,
      'last_backup_at': lastBackupAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'tutorial_completed': tutorialCompleted ? 1 : 0,
      'privacy_accepted_at': privacyAcceptedAt?.millisecondsSinceEpoch,
      'language_code': languageCode,
      'sms_opt_in': smsOptIn ? 1 : 0,
      'discreet_mode': discreetMode ? 1 : 0,
    };
  }
}
