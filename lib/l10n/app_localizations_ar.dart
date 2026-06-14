// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get done => 'تم';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get grant => 'منح';

  @override
  String get change => 'تغيير';

  @override
  String get clear => 'مسح';

  @override
  String get import => 'استيراد';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get expense => 'مصروف';

  @override
  String get income => 'دخل';

  @override
  String get both => 'كلاهما';

  @override
  String get recurring => 'متكرر';

  @override
  String get carryOver => 'ترحيل';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get annually => 'سنوي';

  @override
  String get search => 'بحث';

  @override
  String get settings => 'الإعدادات';

  @override
  String get history => 'السجل';

  @override
  String get budget => 'الميزانية';

  @override
  String get currency => 'العملة';

  @override
  String get categories => 'الفئات';

  @override
  String get version => 'الإصدار';

  @override
  String get auto => 'تلقائي';

  @override
  String get noCategory => 'بلا فئة';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get setBudget => 'تعيين الميزانية';

  @override
  String get homeSearchHint => 'ابحث في المعاملات…';

  @override
  String get discreetModeShow => 'إظهار المبالغ';

  @override
  String get discreetModeHide => 'إخفاء المبالغ';

  @override
  String get homeAllWallets => 'جميع المحافظ';

  @override
  String get homeSwitchWallet => 'تبديل المحفظة';

  @override
  String get homeWallet => 'المحفظة';

  @override
  String get homePreviousMonth => 'الشهر السابق';

  @override
  String get homeNextMonth => 'الشهر التالي';

  @override
  String get homeTapReturnCurrentMonth => 'اضغط للعودة إلى الشهر الحالي';

  @override
  String get homeNoBudget => 'لم تُحدَّد ميزانية.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'متبقٍ هذا الشهر · $percent% مُنفق';
  }

  @override
  String homeOverBudget(int percent) {
    return 'تجاوز الميزانية · $percent% مُنفق';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount مُرحَّل من الشهر الماضي';
  }

  @override
  String get homeNoTransactions => 'لا توجد معاملات بعد.\nاضغط + لإضافة واحدة.';

  @override
  String get homeNoTransactionsDay => 'لا توجد معاملات في هذا اليوم.';

  @override
  String get homeNoTransactionsCategory =>
      'لا توجد معاملات في هذه\nالفئة لهذه الفترة.';

  @override
  String get homeByDay => 'حسب اليوم';

  @override
  String get homeByCategory => 'حسب الفئة';

  @override
  String get homeDeleteTitle => 'حذف المعاملة؟';

  @override
  String homeDeleteMessage(String description) {
    return 'سيتم حذف \"$description\" نهائياً.';
  }

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeRecentTransactions => 'المعاملات الأخيرة';

  @override
  String get budgetRemaining => 'متبقٍ';

  @override
  String get budgetSpent => 'مُنفق';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% مستخدم';
  }

  @override
  String get budgetNoSet => 'لم تُحدَّد ميزانية لهذا الشهر بعد.';

  @override
  String setBudgetForPeriod(String period) {
    return 'تعيين الميزانية لـ $period';
  }

  @override
  String get setBudgetHint =>
      'هذا هو المبلغ الإجمالي الذي تريد تتبعه هذا الشهر.';

  @override
  String get setBudgetAmount => 'مبلغ الميزانية';

  @override
  String get setBudgetEnterAmount => 'أدخل مبلغاً';

  @override
  String get setBudgetValidAmount => 'أدخل مبلغاً صحيحاً';

  @override
  String get setBudgetSave => 'حفظ الميزانية';

  @override
  String get historyMonth => 'شهر';

  @override
  String get historyYear => 'سنة';

  @override
  String get transactionTitleEdit => 'تعديل المعاملة';

  @override
  String get transactionTitleNew => 'معاملة جديدة';

  @override
  String get transactionValidAmount => 'أدخل مبلغاً صحيحاً.';

  @override
  String get transactionAddDescription => 'أضف وصفاً.';

  @override
  String get transactionSelectCategory => 'اختر فئة.';

  @override
  String get transactionRepeats => 'يتكرر';

  @override
  String get transactionDescription => 'الوصف';

  @override
  String get transactionFrequent => 'متكرر';

  @override
  String get transactionNewCategory => 'جديد';

  @override
  String get transactionEnterCategoryName => 'أدخل اسم الفئة';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'أضف $fields للمتابعة';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'القاعدة: $keyword  •  اضغط للتعديل';
  }

  @override
  String get transactionDeleteTitle => 'حذف المعاملة؟';

  @override
  String transactionDeleteMessage(String description) {
    return 'سيتم حذف \"$description\" نهائياً.';
  }

  @override
  String get transactionDeleteRecurringTitle => 'حذف المعاملة المتكررة';

  @override
  String get transactionDeleteRecurringQuestion => 'كيف تريد الحذف؟';

  @override
  String get transactionDeleteOnlyThis => 'هذه فقط';

  @override
  String get transactionDeleteThisAndFuture => 'هذه والمستقبلية';

  @override
  String get categoriesNoExpense => 'لا توجد فئات مصروفات بعد.';

  @override
  String get categoriesNoIncome => 'لا توجد فئات دخل بعد.';

  @override
  String categoriesActiveCount(int count) {
    return '$count نشطة';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'غير مستخدمة هذا الشهر · $count';
  }

  @override
  String get categoriesUnused => 'غير مستخدمة';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% من الإنفاق';
  }

  @override
  String get editCategoryTitleEdit => 'تعديل الفئة';

  @override
  String get editCategoryTitleAdd => 'إضافة فئة';

  @override
  String get editCategoryName => 'الاسم';

  @override
  String get editCategoryUsedFor => 'تُستخدم لـ';

  @override
  String get editCategoryColour => 'اللون';

  @override
  String get editCategoryIcon => 'الأيقونة';

  @override
  String get editCategoryChartNote =>
      'لون شريط المخطط تديره السمة للفئات المدمجة.';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsMonthStartsOn => 'يبدأ الشهر في';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'اليوم $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'الأيام 29-31 غير متاحة لضمان التوافق مع فبراير.';

  @override
  String get settingsDefaultMonthlyBudget => 'الميزانية الشهرية الافتراضية';

  @override
  String get settingsNotSet => 'غير محددة';

  @override
  String get settingsManageCategories => 'إدارة الفئات';

  @override
  String get settingsWallets => 'المحافظ';

  @override
  String get settingsManageWallets => 'إدارة المحافظ';

  @override
  String get settingsAutomations => 'الأتمتة';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsDeveloperTools => 'أدوات المطور';

  @override
  String get settingsDangerZone => 'منطقة الخطر';

  @override
  String get settingsResetApp => 'إعادة ضبط التطبيق';

  @override
  String get settingsResetAppDesc =>
      'حذف جميع المعاملات والميزانيات واستعادة الإعدادات الافتراضية';

  @override
  String get settingsSelectCurrency => 'اختر العملة';

  @override
  String get settingsMonthStartOnDay => 'يبدأ الشهر في اليوم…';

  @override
  String get settingsResetTitle => 'إعادة ضبط التطبيق؟';

  @override
  String get settingsResetMessage =>
      'سيؤدي هذا إلى الحذف الدائم لـ:\n  • جميع المعاملات\n  • جميع الميزانيات\n  • جميع الفئات المخصصة\n\nستتم استعادة الإعدادات الافتراضية وسيتم تسجيل خروجك من Google. سجّل الدخول مرة أخرى لاستعادة النسخة الاحتياطية.\n\nلا يمكن التراجع عن هذا.';

  @override
  String get settingsResetConfirm => 'إعادة ضبط كل شيء';

  @override
  String get settingsChangeStartDayTitle => 'تغيير يوم البدء؟';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'سيؤدي التغيير من اليوم $from إلى اليوم $to إلى إزاحة حدود الفترة لجميع الأشهر. تبقى المعاملات الموجودة كما هي.';
  }

  @override
  String get settingsBackupToDrive => 'نسخ احتياطي إلى Google Drive';

  @override
  String get settingsSignInForBackup => 'سجّل الدخول لتفعيل النسخ الاحتياطي';

  @override
  String settingsLastBackup(String time) {
    return 'آخر نسخة احتياطية: $time';
  }

  @override
  String get settingsNoBackupYet => 'لا توجد نسخة احتياطية بعد';

  @override
  String get settingsBackupNow => 'نسخ احتياطي الآن';

  @override
  String get settingsRestoreFromDrive => 'استعادة من Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'استبدال البيانات المحلية بالنسخة الاحتياطية على Drive';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsBackupSaved =>
      'تم حفظ النسخة الاحتياطية على Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'لا توجد تغييرات منذ آخر نسخة احتياطية — تم التخطي.';

  @override
  String settingsBackupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'تعذّر عرض النسخ الاحتياطية: $error';
  }

  @override
  String get settingsNoBackupFound =>
      'لم يتم العثور على نسخة احتياطية في Google Drive.';

  @override
  String get settingsReplaceLocalTitle => 'استبدال جميع البيانات المحلية؟';

  @override
  String get settingsReplaceLocalMessage =>
      'ستؤدي الاستعادة من Google Drive إلى الحذف الدائم لكل شيء على هذا الجهاز — جميع المعاملات والميزانيات والفئات — واستبدالها بالنسخة الاحتياطية.\n\nلا يمكن التراجع عن هذا.';

  @override
  String get settingsReplaceMyData => 'استبدال بياناتي';

  @override
  String get settingsDataRestored => 'تمت استعادة البيانات من Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get settingsSelectBackup => 'اختر نسخة احتياطية للاستعادة';

  @override
  String get settingsExportBackup => 'تصدير النسخة الاحتياطية';

  @override
  String get settingsExportBackupDesc => 'حفظ جميع البيانات كملف JSON';

  @override
  String get settingsRestoreFromFile => 'استعادة من ملف';

  @override
  String get settingsRestoreFromFileDesc =>
      'استبدال البيانات المحلية بنسخة احتياطية مُصدَّرة';

  @override
  String settingsExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'تعذّر قراءة الملف: $error';
  }

  @override
  String get settingsImportTitle => 'استيراد النسخة الاحتياطية؟';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'تم العثور على:\n  • $transactions معاملة\n  • $budgets ميزانية\n  • $categories فئة\n\nسيستبدل هذا جميع البيانات المحلية. لا يمكن التراجع عن هذا.';
  }

  @override
  String get settingsImportConfirm => 'استيراد';

  @override
  String settingsImportDone(int count) {
    return 'تم استيراد $count معاملة بنجاح.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get settingsSmsRules => 'قواعد الرسائل القصيرة';

  @override
  String get settingsSmsRulesDesc =>
      'إنشاء معاملات تلقائياً من الرسائل الواردة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeAuto => 'تلقائي';

  @override
  String get settingsCarryOver => 'ترحيل الميزانية غير المستخدمة';

  @override
  String get settingsCarryOverDesc => 'يُضاف الفائض إلى الشهر التالي';

  @override
  String get settingsDefaultBudgetApplied =>
      'يُطبَّق تلقائياً عندما لا تُحدَّد ميزانية للشهر الحالي.';

  @override
  String get settingsJustNow => 'الآن';

  @override
  String settingsMinutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String settingsHoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSelectLanguage => 'اختر اللغة';

  @override
  String get manageWalletsTitle => 'إدارة المحافظ';

  @override
  String get manageWalletsNone => 'لا توجد محافظ بعد.';

  @override
  String get manageWalletsAdd => 'إضافة محفظة';

  @override
  String get manageWalletsEditTitle => 'تعديل المحفظة';

  @override
  String get manageWalletsName => 'اسم المحفظة';

  @override
  String get manageWalletsDefaultBudget =>
      'الميزانية الشهرية الافتراضية (اختياري)';

  @override
  String get manageWalletsLeaveEmpty => 'اتركه فارغاً لتعطيل';

  @override
  String get manageWalletsMonthStart => 'يبدأ الشهر في (اختياري)';

  @override
  String get manageWalletsAppDefault => 'افتراضي التطبيق';

  @override
  String manageWalletsDay(int day) {
    return 'اليوم $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'اتركه كافتراضي للتطبيق إذا لم يُحدَّد';

  @override
  String get manageWalletsDefaultLabel => 'المحفظة الافتراضية';

  @override
  String get manageWalletsSetAsDefault => 'تعيين كافتراضي';

  @override
  String get manageWalletsNoBudget => 'لا توجد ميزانية افتراضية';

  @override
  String get manageWalletsAlreadyExists => 'توجد محفظة بهذا الاسم بالفعل';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · الترحيل مفعّل';
  }

  @override
  String get manageWalletsCarryOverSuffix => '· الترحيل مفعّل';

  @override
  String get smsRulesTitle => 'قواعد الرسائل القصيرة';

  @override
  String get smsRulesScanPast => 'مسح الرسائل السابقة';

  @override
  String get smsRulesPermissionTitle => 'مطلوب إذن الرسائل القصيرة';

  @override
  String get smsRulesPermissionMessage =>
      'امنح الوصول حتى تتمكن الرسائل الواردة من المطابقة مع قواعدك.';

  @override
  String get smsRulesNone => 'لا توجد قواعد بعد';

  @override
  String get smsRulesNoneMessage =>
      'أضف قاعدة لإنشاء معاملات تلقائياً عند استلام رسائل SMS من البنك.';

  @override
  String get smsRulesAddFirst => 'إضافة أول قاعدة';

  @override
  String get smsRulesDeleteTitle => 'حذف القاعدة؟';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'سيتم حذف قاعدة \"$keyword\". لن تتأثر المعاملات التي أنشأتها.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return 'تم إنشاء $count معاملة بتاريخ $date — عُد إلى الشاشة الرئيسية لرؤيتها.';
  }

  @override
  String get smsRulesNoImports => 'لم يتم استيراد أي معاملات.';

  @override
  String get smsRuleFormTitleEdit => 'تعديل القاعدة';

  @override
  String get smsRuleFormTitleNew => 'قاعدة جديدة';

  @override
  String get smsRuleFormKeyword => 'الكلمة المفتاحية';

  @override
  String get smsRuleFormKeywordHint => 'مثال: Carrefour، VODAFONE، Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'مطابقة غير حساسة لحالة الأحرف في أي مكان بنص الرسالة.';

  @override
  String get smsRuleFormLabel => 'تسمية المعاملة';

  @override
  String get smsRuleFormLabelHint =>
      'مثال: بنزين، قهوة، بقالة (اتركه فارغاً لاستخدام الكلمة المفتاحية)';

  @override
  String get smsRuleFormLabelHelper =>
      'يظهر كوصف للمعاملة. الافتراضي هو الكلمة المفتاحية.';

  @override
  String get smsRuleFormType => 'نوع المعاملة';

  @override
  String get smsRuleFormCategory => 'الفئة';

  @override
  String get smsRuleFormSelectCategory => 'اختر فئة';

  @override
  String get smsRuleFormWallet => 'المحفظة';

  @override
  String get smsRuleFormAdvanced => 'متقدم';

  @override
  String get smsRuleFormCustomRegex => 'تعبير نمطي مخصص للمبلغ';

  @override
  String get smsRuleFormRegexHint => 'تعبير نمطي للمبلغ (اختياري)';

  @override
  String get smsRuleFormRegexHelper =>
      'استخدم مجموعة الالتقاط 1 لاستخراج المبلغ. اتركه فارغاً للاكتشاف التلقائي.';

  @override
  String get smsRuleFormSaveChanges => 'حفظ التغييرات';

  @override
  String get smsRuleFormSaveNew => 'حفظ القاعدة';

  @override
  String get smsRuleFormDeleteRule => 'حذف القاعدة';

  @override
  String get smsRuleFormEnterKeyword => 'الرجاء إدخال كلمة مفتاحية.';

  @override
  String get smsRuleFormSelectCategoryError => 'الرجاء اختيار فئة.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'سيتم حذف قاعدة \"$keyword\" نهائياً.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'اختر الفئة';

  @override
  String get smsScanTitle => 'مسح الرسائل القصيرة الموجودة';

  @override
  String get smsScanDesc =>
      'تطبيق قواعدك النشطة على الرسائل الموجودة في صندوق الوارد.';

  @override
  String get smsScanDateRange => 'نطاق التاريخ';

  @override
  String get smsScan3Days => '3 أيام';

  @override
  String get smsScanCustom => 'مخصص…';

  @override
  String get smsScanSelectRange => 'اختر نطاق التاريخ';

  @override
  String get smsScanPermissionRequired =>
      'مطلوب إذن الرسائل القصيرة لمسح الرسائل.';

  @override
  String get smsScanScanning => 'جاري المسح…';

  @override
  String get smsScanNoMatches => 'لا توجد نتائج';

  @override
  String get smsScanNoMatchesMessage =>
      'لا توجد رسائل في هذا النطاق تتطابق مع قواعدك النشطة.\nجرّب نطاقاً أوسع أو تحقق من كلمات قواعدك.';

  @override
  String get smsScanTryDifferent => 'جرّب نطاقاً مختلفاً';

  @override
  String smsScanMatchesFound(int count) {
    return 'تم العثور على $count نتيجة';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count موجودة اليوم بالفعل — غير محددة افتراضياً';
  }

  @override
  String smsScanImportButton(int count) {
    return 'استيراد $count معاملة';
  }

  @override
  String get smsScanNothingSelected => 'لم يتم تحديد شيء';

  @override
  String get smsScanEditLabel => 'تعديل التسمية';

  @override
  String get smsScanTransactionDesc => 'وصف المعاملة';

  @override
  String get smsScanExists => 'موجودة';

  @override
  String get smsScanDupWarning =>
      'توجد معاملة بهذا المبلغ والفئة في هذا اليوم بالفعل';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'كل شيء مفتوح، مرة واحدة. لا اشتراكات.';

  @override
  String paywallUnlock(String price) {
    return 'افتح للأبد — $price';
  }

  @override
  String get paywallRestore => 'استعادة الشراء';

  @override
  String get paywallRestoreNote => 'شراء لمرة واحدة · بلا رسوم متكررة';

  @override
  String get paywallTrialEnded => 'انتهت فترة التجربة المجانية لمدة 14 يوماً';

  @override
  String get paywallProUnlocked => 'Pro مفتوح';

  @override
  String get paywallFeatureWallets => 'محافظ غير محدودة';

  @override
  String get paywallFeatureTransactions => 'معاملات غير محدودة';

  @override
  String get paywallFeatureHistory => 'سجل كامل للمعاملات';

  @override
  String get paywallFeatureBackup => 'النسخ الاحتياطي على Google Drive';

  @override
  String get paywallFeatureExport => 'تصدير بياناتك';

  @override
  String get paywallFeatureCategories => 'فئات مخصصة';

  @override
  String get paywallFeatureSms => 'تحليل الرسائل القصيرة تلقائياً (Android)';

  @override
  String get paywallNoRestoreFound =>
      'لم يتم العثور على شراء سابق لهذا الحساب.';

  @override
  String paywallRestoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String get tutorialGetStarted => 'ابدأ الآن';

  @override
  String get tutorialWelcomeTitle => 'مرحباً بك في FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'ميزانيتك الشخصية، بشكل جميل وبسيط.\nلنأخذ جولة سريعة على الميزات الرئيسية.';

  @override
  String get tutorialBudgetTitle => 'الميزانية الشهرية';

  @override
  String get tutorialBudgetMessage =>
      'تعرض هذه البطاقة ميزانيتك مقابل إنفاقك للشهر. اضغط \"تعيين الميزانية\" لتحديد حدك الشهري.';

  @override
  String get tutorialCarryoverTitle => 'ترحيل الفائض';

  @override
  String get tutorialCarryoverMessage =>
      'فعّل الترحيل في الإعدادات ← إدارة المحافظ لأي محفظة. الميزانية غير المستخدمة من الشهر الماضي تُضاف تلقائياً لهذا الشهر.';

  @override
  String get tutorialAddTitle => 'إضافة معاملة';

  @override
  String get tutorialAddMessage =>
      'اضغط زر + لتسجيل مشتريات أو فواتير أو دخل. اختر فئة لترى أين يذهب مالك.';

  @override
  String get tutorialBrowseTitle => 'تصفح الأشهر السابقة';

  @override
  String get tutorialBrowseMessage =>
      'اضغط الأسهم أو اسحب يساراً/يميناً على الشاشة الرئيسية لمراجعة أي شهر سابق.';

  @override
  String get tutorialSettingsTitle => 'الإعدادات والمزيد';

  @override
  String get tutorialSettingsMessage =>
      'غيّر العملة، وأدر الحسابات، وخصّص الفئات، وانسخ بياناتك احتياطياً من هنا.';

  @override
  String get tutorialDoneTitle => 'أنت جاهز!';

  @override
  String get tutorialDoneMessage =>
      'ابدأ بإضافة أول معاملة. سيتتبع FELOOSY الباقي.';

  @override
  String get consentTitle => 'قبل البدء';

  @override
  String get consentDataTitle => 'بياناتك تبقى على جهازك';

  @override
  String get consentDataBody =>
      'يتم تخزين المعاملات والميزانيات محلياً في SQLite. لا توجد لدينا خوادم ولا يمكننا الوصول إلى بياناتك المالية.';

  @override
  String get consentBackupTitle => 'النسخ الاحتياطي السحابي (اختياري)';

  @override
  String get consentBackupBody =>
      'يمكنك ربط Google Drive لنسخ بياناتك احتياطياً. تذهب إلى مجلد Drive الخاص بك فقط — نحن لا نراها.';

  @override
  String get consentReadPolicy => 'قراءة السياسة الكاملة';

  @override
  String get consentAccept => 'قبول والمتابعة';

  @override
  String get smsOptInTitle => 'استيراد الرسائل القصيرة تلقائياً';

  @override
  String get smsOptInBody =>
      'يستطيع FELOOSY قراءة رسائل البنك القصيرة وإنشاء معاملات تلقائياً. تتم المطابقة محلياً — لا يتم تخزين نص الرسائل أو مشاركته.';

  @override
  String get smsOptInEnable => 'تفعيل SMS';

  @override
  String get smsOptInSkip => 'تخطي';

  @override
  String get smsToggleLabel => 'استيراد الرسائل القصيرة تلقائياً';

  @override
  String get smsToggleSubtitle => 'إنشاء معاملات تلقائياً من رسائل البنك';

  @override
  String get smsTermsTitle => 'تفعيل استيراد الرسائل القصيرة؟';

  @override
  String get smsTermsBody =>
      'سيقرأ FELOOSY رسائل البنك القصيرة الواردة ويطابقها مع قواعدك لإنشاء معاملات تلقائياً. لا يتم تخزين نص الرسائل أو مشاركته. يمكنك تعطيل هذا في أي وقت.';

  @override
  String get smsTermsEnable => 'تفعيل';
}
