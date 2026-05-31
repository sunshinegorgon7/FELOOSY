// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'حذف کریں';

  @override
  String get edit => 'ترمیم';

  @override
  String get done => 'مکمل';

  @override
  String get next => 'اگلا';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get grant => 'اجازت دیں';

  @override
  String get change => 'تبدیل کریں';

  @override
  String get clear => 'صاف کریں';

  @override
  String get import => 'درآمد';

  @override
  String get today => 'آج';

  @override
  String get yesterday => 'کل';

  @override
  String get expense => 'خرچہ';

  @override
  String get income => 'آمدنی';

  @override
  String get both => 'دونوں';

  @override
  String get recurring => 'بار بار';

  @override
  String get daily => 'روزانہ';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get annually => 'سالانہ';

  @override
  String get search => 'تلاش';

  @override
  String get settings => 'ترتیبات';

  @override
  String get history => 'تاریخ';

  @override
  String get budget => 'بجٹ';

  @override
  String get currency => 'کرنسی';

  @override
  String get categories => 'زمرے';

  @override
  String get version => 'ورژن';

  @override
  String get auto => 'خودکار';

  @override
  String get noCategory => 'کوئی زمرہ نہیں';

  @override
  String get selectCategory => 'زمرہ منتخب کریں';

  @override
  String get setBudget => 'بجٹ مقرر کریں';

  @override
  String get homeSearchHint => 'لین دین تلاش کریں…';

  @override
  String get homeAllWallets => 'تمام والٹس';

  @override
  String get homeSwitchWallet => 'والٹ تبدیل کریں';

  @override
  String get homeWallet => 'والٹ';

  @override
  String get homePreviousMonth => 'پچھلا مہینہ';

  @override
  String get homeNextMonth => 'اگلا مہینہ';

  @override
  String get homeTapReturnCurrentMonth =>
      'موجودہ مہینے پر واپس جانے کے لیے ٹیپ کریں';

  @override
  String get homeNoBudget => 'کوئی بجٹ مقرر نہیں۔';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'اس مہینے باقی · $percent% خرچ';
  }

  @override
  String homeOverBudget(int percent) {
    return 'بجٹ سے زیادہ · $percent% خرچ';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount پچھلے مہینے سے منتقل';
  }

  @override
  String get homeNoTransactions =>
      'ابھی تک کوئی لین دین نہیں۔\nایک شامل کرنے کے لیے + دبائیں۔';

  @override
  String get homeNoTransactionsDay => 'اس دن کوئی لین دین نہیں۔';

  @override
  String get homeNoTransactionsCategory =>
      'اس مدت کے لیے اس\nزمرے میں کوئی لین دین نہیں۔';

  @override
  String get homeByDay => 'دن کے مطابق';

  @override
  String get homeByCategory => 'زمرے کے مطابق';

  @override
  String get homeDeleteTitle => 'لین دین حذف کریں؟';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" مستقل طور پر ہٹا دیا جائے گا۔';
  }

  @override
  String get homeSeeAll => 'سب دیکھیں';

  @override
  String get homeRecentTransactions => 'حالیہ لین دین';

  @override
  String get budgetRemaining => 'باقی';

  @override
  String get budgetSpent => 'خرچ';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% استعمال';
  }

  @override
  String get budgetNoSet => 'اس مہینے کے لیے ابھی تک کوئی بجٹ مقرر نہیں۔';

  @override
  String setBudgetForPeriod(String period) {
    return '$period کے لیے بجٹ مقرر کریں';
  }

  @override
  String get setBudgetHint =>
      'یہ وہ کل رقم ہے جو آپ اس مہینے ٹریک کرنا چاہتے ہیں۔';

  @override
  String get setBudgetAmount => 'بجٹ رقم';

  @override
  String get setBudgetEnterAmount => 'رقم درج کریں';

  @override
  String get setBudgetValidAmount => 'درست رقم درج کریں';

  @override
  String get setBudgetSave => 'بجٹ محفوظ کریں';

  @override
  String get historyMonth => 'مہینہ';

  @override
  String get historyYear => 'سال';

  @override
  String get transactionTitleEdit => 'لین دین ترمیم کریں';

  @override
  String get transactionTitleNew => 'نیا لین دین';

  @override
  String get transactionValidAmount => 'درست رقم درج کریں۔';

  @override
  String get transactionAddDescription => 'تفصیل شامل کریں۔';

  @override
  String get transactionSelectCategory => 'زمرہ منتخب کریں۔';

  @override
  String get transactionRepeats => 'دہراتا ہے';

  @override
  String get transactionDescription => 'تفصیل';

  @override
  String get transactionFrequent => 'کثرت سے';

  @override
  String get transactionNewCategory => 'نیا';

  @override
  String get transactionEnterCategoryName => 'زمرے کا نام درج کریں';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'جاری رکھنے کے لیے $fields شامل کریں';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'اصول: $keyword  •  ترمیم کے لیے ٹیپ کریں';
  }

  @override
  String get transactionDeleteTitle => 'لین دین حذف کریں؟';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" مستقل طور پر ہٹا دیا جائے گا۔';
  }

  @override
  String get transactionDeleteRecurringTitle => 'بار بار لین دین حذف کریں';

  @override
  String get transactionDeleteRecurringQuestion =>
      'آپ اسے کیسے حذف کرنا چاہتے ہیں؟';

  @override
  String get transactionDeleteOnlyThis => 'صرف یہ';

  @override
  String get transactionDeleteThisAndFuture => 'یہ اور مستقبل کے';

  @override
  String get categoriesNoExpense => 'ابھی تک کوئی خرچے کا زمرہ نہیں۔';

  @override
  String get categoriesNoIncome => 'ابھی تک کوئی آمدنی کا زمرہ نہیں۔';

  @override
  String categoriesActiveCount(int count) {
    return '$count فعال';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'اس مہینے غیر استعمال شدہ · $count';
  }

  @override
  String get categoriesUnused => 'غیر استعمال شدہ';

  @override
  String categoriesPercentSpend(String percent) {
    return 'خرچ کا $percent%';
  }

  @override
  String get editCategoryTitleEdit => 'زمرہ ترمیم کریں';

  @override
  String get editCategoryTitleAdd => 'زمرہ شامل کریں';

  @override
  String get editCategoryName => 'نام';

  @override
  String get editCategoryUsedFor => 'استعمال برائے';

  @override
  String get editCategoryColour => 'رنگ';

  @override
  String get editCategoryIcon => 'آئیکن';

  @override
  String get editCategoryChartNote =>
      'چارٹ بار رنگ بلٹ ان زمروں کے لیے تھیم کے ذریعے منظم ہوتا ہے۔';

  @override
  String get settingsAppearance => 'ظاہری شکل';

  @override
  String get settingsMonthStartsOn => 'مہینہ شروع ہوتا ہے';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'دن $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'فروری مطابقت یقینی بنانے کے لیے دن 29-31 دستیاب نہیں۔';

  @override
  String get settingsDefaultMonthlyBudget => 'ڈیفالٹ ماہانہ بجٹ';

  @override
  String get settingsNotSet => 'مقرر نہیں';

  @override
  String get settingsManageCategories => 'زمرے منظم کریں';

  @override
  String get settingsWallets => 'والٹس';

  @override
  String get settingsManageWallets => 'والٹس منظم کریں';

  @override
  String get settingsAutomations => 'خودکاری';

  @override
  String get settingsData => 'ڈیٹا';

  @override
  String get settingsAbout => 'بارے میں';

  @override
  String get settingsPrivacyPolicy => 'رازداری کی پالیسی';

  @override
  String get settingsDeveloperTools => 'ڈویلپر ٹولز';

  @override
  String get settingsDangerZone => 'خطرے کا علاقہ';

  @override
  String get settingsResetApp => 'ایپ ری سیٹ کریں';

  @override
  String get settingsResetAppDesc =>
      'تمام لین دین اور بجٹ مٹائیں، ڈیفالٹ بحال کریں';

  @override
  String get settingsSelectCurrency => 'کرنسی منتخب کریں';

  @override
  String get settingsMonthStartOnDay => 'مہینہ دن سے شروع ہوتا ہے…';

  @override
  String get settingsResetTitle => 'ایپ ری سیٹ کریں؟';

  @override
  String get settingsResetMessage =>
      'یہ مستقل طور پر حذف کر دے گا:\n  • تمام لین دین\n  • تمام بجٹ\n  • تمام کسٹم زمرے\n\nترتیبات ڈیفالٹ پر بحال ہو جائیں گی اور آپ Google سے سائن آؤٹ ہو جائیں گے۔ بیک اپ سے بحال کرنے کے لیے بعد میں دوبارہ سائن ان کریں۔\n\nیہ واپس نہیں کیا جا سکتا۔';

  @override
  String get settingsResetConfirm => 'سب کچھ ری سیٹ کریں';

  @override
  String get settingsChangeStartDayTitle => 'شروع دن تبدیل کریں؟';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'دن $from سے دن $to میں تبدیلی تمام مہینوں کی مدت کی حدود کو بدل دے گی۔ موجودہ لین دین جوں کے توں رہیں گے۔';
  }

  @override
  String get settingsBackupToDrive => 'Google Drive پر بیک اپ کریں';

  @override
  String get settingsSignInForBackup => 'بیک اپ فعال کرنے کے لیے سائن ان کریں';

  @override
  String settingsLastBackup(String time) {
    return 'آخری بیک اپ: $time';
  }

  @override
  String get settingsNoBackupYet => 'ابھی تک کوئی بیک اپ نہیں';

  @override
  String get settingsBackupNow => 'ابھی بیک اپ کریں';

  @override
  String get settingsRestoreFromDrive => 'Drive سے بحال کریں';

  @override
  String get settingsRestoreFromDriveDesc =>
      'مقامی ڈیٹا کو Drive بیک اپ سے بدلیں';

  @override
  String get settingsSignOut => 'سائن آؤٹ';

  @override
  String get settingsBackupSaved => 'بیک اپ Google Drive پر محفوظ ہو گیا۔';

  @override
  String get settingsBackupNoChanges =>
      'آخری بیک اپ کے بعد کوئی تبدیلی نہیں — چھوڑ دیا۔';

  @override
  String settingsBackupFailed(String error) {
    return 'بیک اپ ناکام: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'بیک اپ فہرست نہیں کیے جا سکے: $error';
  }

  @override
  String get settingsNoBackupFound => 'Google Drive میں کوئی بیک اپ نہیں ملا۔';

  @override
  String get settingsReplaceLocalTitle => 'تمام مقامی ڈیٹا بدلیں؟';

  @override
  String get settingsReplaceLocalMessage =>
      'Google Drive سے بحال کرنا اس آلے پر موجود ہر چیز — تمام لین دین، بجٹ، اور زمرے — کو مستقل طور پر حذف کر دے گا اور بیک اپ سے بدل دے گا۔\n\nیہ واپس نہیں کیا جا سکتا۔';

  @override
  String get settingsReplaceMyData => 'میرا ڈیٹا بدلیں';

  @override
  String get settingsDataRestored => 'Google Drive سے ڈیٹا بحال ہو گیا۔';

  @override
  String settingsRestoreFailed(String error) {
    return 'بحالی ناکام: $error';
  }

  @override
  String get settingsSelectBackup => 'بحالی کے لیے بیک اپ منتخب کریں';

  @override
  String get settingsExportBackup => 'بیک اپ برآمد کریں';

  @override
  String get settingsExportBackupDesc =>
      'تمام ڈیٹا کو JSON فائل کے طور پر محفوظ کریں';

  @override
  String get settingsRestoreFromFile => 'فائل سے بحال کریں';

  @override
  String get settingsRestoreFromFileDesc =>
      'مقامی ڈیٹا کو برآمد شدہ بیک اپ سے بدلیں';

  @override
  String settingsExportFailed(String error) {
    return 'برآمد ناکام: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'فائل نہیں پڑھی جا سکتی: $error';
  }

  @override
  String get settingsImportTitle => 'بیک اپ درآمد کریں؟';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'ملا:\n  • $transactions لین دین\n  • $budgets بجٹ\n  • $categories زمرے\n\nیہ تمام مقامی ڈیٹا بدل دے گا۔ یہ واپس نہیں کیا جا سکتا۔';
  }

  @override
  String get settingsImportConfirm => 'درآمد';

  @override
  String settingsImportDone(int count) {
    return '$count لین دین کامیابی سے درآمد ہوئے۔';
  }

  @override
  String settingsImportFailed(String error) {
    return 'درآمد ناکام: $error';
  }

  @override
  String get settingsSmsRules => 'SMS اصول';

  @override
  String get settingsSmsRulesDesc =>
      'آنے والے پیغامات سے خودکار طریقے سے لین دین بنائیں';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeDark => 'گہرا';

  @override
  String get settingsThemeAuto => 'خودکار';

  @override
  String get settingsCarryOver => 'غیر استعمال شدہ بجٹ آگے بڑھائیں';

  @override
  String get settingsCarryOverDesc => 'فاضل رقم اگلے مہینے میں شامل ہوتی ہے';

  @override
  String get settingsDefaultBudgetApplied =>
      'جب موجودہ مہینے کے لیے کوئی بجٹ مقرر نہ ہو تو خودکار طریقے سے لاگو ہوتا ہے۔';

  @override
  String get settingsJustNow => 'ابھی';

  @override
  String settingsMinutesAgo(int minutes) {
    return '$minutes منٹ پہلے';
  }

  @override
  String settingsHoursAgo(int hours) {
    return '$hours گھنٹے پہلے';
  }

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsSelectLanguage => 'زبان منتخب کریں';

  @override
  String get manageWalletsTitle => 'والٹس منظم کریں';

  @override
  String get manageWalletsNone => 'ابھی تک کوئی والٹ نہیں۔';

  @override
  String get manageWalletsAdd => 'والٹ شامل کریں';

  @override
  String get manageWalletsEditTitle => 'والٹ ترمیم کریں';

  @override
  String get manageWalletsName => 'والٹ کا نام';

  @override
  String get manageWalletsDefaultBudget => 'ڈیفالٹ ماہانہ بجٹ (اختیاری)';

  @override
  String get manageWalletsLeaveEmpty => 'غیر فعال کرنے کے لیے خالی چھوڑیں';

  @override
  String get manageWalletsMonthStart => 'مہینہ شروع ہوتا ہے (اختیاری)';

  @override
  String get manageWalletsAppDefault => 'ایپ ڈیفالٹ';

  @override
  String manageWalletsDay(int day) {
    return 'دن $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'اگر مقرر نہ ہو تو ایپ ڈیفالٹ کے طور پر چھوڑیں';

  @override
  String get manageWalletsDefaultLabel => 'ڈیفالٹ والٹ';

  @override
  String get manageWalletsSetAsDefault => 'ڈیفالٹ مقرر کریں';

  @override
  String get manageWalletsNoBudget => 'کوئی ڈیفالٹ بجٹ نہیں';

  @override
  String get manageWalletsAlreadyExists => 'اس نام کا والٹ پہلے سے موجود ہے';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · منتقلی فعال';
  }

  @override
  String get smsRulesTitle => 'SMS اصول';

  @override
  String get smsRulesScanPast => 'پچھلے SMS اسکین کریں';

  @override
  String get smsRulesPermissionTitle => 'SMS اجازت درکار ہے';

  @override
  String get smsRulesPermissionMessage =>
      'آنے والے پیغامات کو آپ کے اصولوں سے ملانے کے لیے رسائی دیں۔';

  @override
  String get smsRulesNone => 'ابھی تک کوئی اصول نہیں';

  @override
  String get smsRulesNoneMessage =>
      'بینک SMS موصول ہونے پر خودکار طریقے سے لین دین بنانے کے لیے ایک اصول شامل کریں۔';

  @override
  String get smsRulesAddFirst => 'پہلا اصول شامل کریں';

  @override
  String get smsRulesDeleteTitle => 'اصول حذف کریں؟';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return '\"$keyword\" کا اصول حذف کر دیا جائے گا۔ اس سے بنائے گئے لین دین متاثر نہیں ہوں گے۔';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$date کو $count لین دین بنائے گئے — انہیں دیکھنے کے لیے ہوم اسکرین پر جائیں۔';
  }

  @override
  String get smsRulesNoImports => 'کوئی لین دین درآمد نہیں ہوا۔';

  @override
  String get smsRuleFormTitleEdit => 'اصول ترمیم کریں';

  @override
  String get smsRuleFormTitleNew => 'نیا اصول';

  @override
  String get smsRuleFormKeyword => 'کلیدی لفظ';

  @override
  String get smsRuleFormKeywordHint => 'مثلاً Carrefour، VODAFONE، Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'SMS متن میں کہیں بھی کیس غیر حساس مطابقت۔';

  @override
  String get smsRuleFormLabel => 'لین دین لیبل';

  @override
  String get smsRuleFormLabelHint =>
      'مثلاً پیٹرول، قہوہ، کریانہ (کلیدی لفظ استعمال کرنے کے لیے خالی چھوڑیں)';

  @override
  String get smsRuleFormLabelHelper =>
      'لین دین کی تفصیل کے طور پر دکھایا جاتا ہے۔ ڈیفالٹ کلیدی لفظ ہے۔';

  @override
  String get smsRuleFormType => 'لین دین کی قسم';

  @override
  String get smsRuleFormCategory => 'زمرہ';

  @override
  String get smsRuleFormSelectCategory => 'زمرہ منتخب کریں';

  @override
  String get smsRuleFormWallet => 'والٹ';

  @override
  String get smsRuleFormAdvanced => 'اعلی درجہ';

  @override
  String get smsRuleFormCustomRegex => 'کسٹم رقم ریجیکس';

  @override
  String get smsRuleFormRegexHint => 'رقم ریجیکس (اختیاری)';

  @override
  String get smsRuleFormRegexHelper =>
      'رقم نکالنے کے لیے کیپچر گروپ 1 استعمال کریں۔ بلٹ ان پہچان کے لیے خالی چھوڑیں۔';

  @override
  String get smsRuleFormSaveChanges => 'تبدیلیاں محفوظ کریں';

  @override
  String get smsRuleFormSaveNew => 'اصول محفوظ کریں';

  @override
  String get smsRuleFormDeleteRule => 'اصول حذف کریں';

  @override
  String get smsRuleFormEnterKeyword => 'براہ کرم کلیدی لفظ درج کریں۔';

  @override
  String get smsRuleFormSelectCategoryError => 'براہ کرم زمرہ منتخب کریں۔';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return '\"$keyword\" کا اصول مستقل طور پر حذف کر دیا جائے گا۔';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'زمرہ منتخب کریں';

  @override
  String get smsScanTitle => 'موجودہ SMS اسکین کریں';

  @override
  String get smsScanDesc =>
      'اپنے ان باکس میں پہلے سے موجود پیغامات پر اپنے فعال اصول لاگو کریں۔';

  @override
  String get smsScanDateRange => 'تاریخ کی حد';

  @override
  String get smsScan3Days => '3 دن';

  @override
  String get smsScan7Days => '7 دن';

  @override
  String get smsScan30Days => '30 دن';

  @override
  String get smsScanCustom => 'کسٹم…';

  @override
  String get smsScanSelectRange => 'تاریخ کی حد منتخب کریں';

  @override
  String get smsScanPermissionRequired =>
      'پیغامات اسکین کرنے کے لیے SMS اجازت درکار ہے۔';

  @override
  String get smsScanScanning => 'پیغامات اسکین ہو رہے ہیں…';

  @override
  String get smsScanNoMatches => 'کوئی مطابقت نہیں ملی';

  @override
  String get smsScanNoMatchesMessage =>
      'اس حد میں کوئی پیغام آپ کے فعال اصولوں سے میل نہیں کھاتا۔\nوسیع حد آزمائیں یا اپنے اصولوں کے کلیدی الفاظ چیک کریں۔';

  @override
  String get smsScanTryDifferent => 'مختلف حد آزمائیں';

  @override
  String smsScanMatchesFound(int count) {
    return '$count مطابقتیں ملیں';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count آج پہلے سے موجود ہیں — ڈیفالٹ کے طور پر غیر نشان زد';
  }

  @override
  String smsScanImportButton(int count) {
    return '$count لین دین درآمد کریں';
  }

  @override
  String get smsScanNothingSelected => 'کچھ منتخب نہیں';

  @override
  String get smsScanEditLabel => 'لیبل ترمیم کریں';

  @override
  String get smsScanTransactionDesc => 'لین دین کی تفصیل';

  @override
  String get smsScanExists => 'موجود ہے';

  @override
  String get smsScanDupWarning =>
      'اس دن اس رقم اور زمرے کے لیے لین دین پہلے سے موجود ہے';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'سب کچھ انلاک، ایک بار۔ کوئی سبسکرپشن نہیں۔';

  @override
  String paywallUnlock(String price) {
    return 'ہمیشہ کے لیے انلاک کریں — $price';
  }

  @override
  String get paywallRestore => 'خریداری بحال کریں';

  @override
  String get paywallRestoreNote => 'یک بار خریداری · کوئی بار بار فیس نہیں';

  @override
  String get paywallTrialEnded => 'آپ کا 14 دن کا مفت آزمائشی دور ختم ہو گیا';

  @override
  String get paywallProUnlocked => 'Pro انلاک';

  @override
  String get paywallFeatureWallets => 'لامحدود والٹس';

  @override
  String get paywallFeatureTransactions => 'لامحدود لین دین';

  @override
  String get paywallFeatureHistory => 'مکمل لین دین تاریخ';

  @override
  String get paywallFeatureBackup => 'Google Drive بیک اپ';

  @override
  String get paywallFeatureExport => 'اپنا ڈیٹا برآمد کریں';

  @override
  String get paywallFeatureCategories => 'کسٹم زمرے';

  @override
  String get paywallFeatureSms => 'SMS خودکار تجزیہ (Android)';

  @override
  String get paywallNoRestoreFound =>
      'اس اکاؤنٹ کے لیے کوئی سابقہ خریداری نہیں ملی۔';

  @override
  String paywallRestoreFailed(String error) {
    return 'بحالی ناکام: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$total میں سے $current';
  }

  @override
  String get tutorialGetStarted => 'شروع کریں';

  @override
  String get tutorialWelcomeTitle => 'FELOOSY میں خوش آمدید';

  @override
  String get tutorialWelcomeMessage =>
      'آپ کا ذاتی بجٹ، خوبصورت طریقے سے سادہ۔\nآئیں اہم خصوصیات کا فوری دورہ کریں۔';

  @override
  String get tutorialBudgetTitle => 'ماہانہ بجٹ';

  @override
  String get tutorialBudgetMessage =>
      'یہ کارڈ مہینے کے لیے آپ کا بجٹ بمقابلہ خرچ دکھاتا ہے۔ اپنی ماہانہ حد مقرر کرنے کے لیے \"بجٹ مقرر کریں\" ٹیپ کریں۔';

  @override
  String get tutorialCarryoverTitle => 'فاضل رقم آگے بڑھائیں';

  @override
  String get tutorialCarryoverMessage =>
      'کسی بھی والٹ کے لیے ترتیبات ← والٹس منظم کریں میں منتقلی فعال کریں۔ پچھلے مہینے کا غیر استعمال شدہ بجٹ اس مہینے میں خودکار طریقے سے شامل ہوتا ہے۔';

  @override
  String get tutorialAddTitle => 'لین دین شامل کریں';

  @override
  String get tutorialAddMessage =>
      'خریداری، بل یا آمدنی ریکارڈ کرنے کے لیے + بٹن ٹیپ کریں۔ یہ دیکھنے کے لیے کہ آپ کا پیسہ کہاں جاتا ہے، زمرہ چنیں۔';

  @override
  String get tutorialBrowseTitle => 'پچھلے مہینے دیکھیں';

  @override
  String get tutorialBrowseMessage =>
      'کسی بھی پچھلے مہینے کا جائزہ لینے کے لیے ہوم اسکرین پر تیروں پر ٹیپ کریں یا بائیں/دائیں سوائپ کریں۔';

  @override
  String get tutorialSettingsTitle => 'ترتیبات اور مزید';

  @override
  String get tutorialSettingsMessage =>
      'کرنسی تبدیل کریں، اکاؤنٹ منظم کریں، زمرے حسب ضرورت بنائیں، اور یہاں سے اپنا ڈیٹا بیک اپ کریں۔';

  @override
  String get tutorialDoneTitle => 'آپ تیار ہیں!';

  @override
  String get tutorialDoneMessage =>
      'اپنا پہلا لین دین شامل کر کے شروع کریں۔ FELOOSY باقی ٹریک کرے گا۔';

  @override
  String get privacyTitle => 'شروع کرنے سے پہلے';

  @override
  String get privacySmsTitle => 'SMS خودکار پہچان';

  @override
  String get privacySmsMessage =>
      'اگر آپ SMS اجازت دیتے ہیں، تو آنے والے بینک پیغامات میموری میں آپ کے اصولوں سے ملائے جاتے ہیں۔ پیغام کا متن کبھی محفوظ یا شیئر نہیں کیا جاتا۔';

  @override
  String get privacyDataTitle => 'آپ کا ڈیٹا آپ کے آلے پر رہتا ہے';

  @override
  String get privacyDataMessage =>
      'لین دین اور بجٹ مقامی طور پر محفوظ ہوتے ہیں۔ ہمارے پاس کوئی سرور نہیں ہے اور ہم آپ کا مالی ڈیٹا نہیں دیکھ سکتے۔';

  @override
  String get privacyAiTitle => 'AI تجزیہ (اختیاری)';

  @override
  String get privacyAiMessage =>
      'اگر آپ AI خصوصیت استعمال کرتے ہیں، تو گمنام خرچ کے خلاصے (زمرے کی کل رقم، کوئی خام SMS نہیں) Google Gemini کو بھیجے جاتے ہیں۔';

  @override
  String get privacyReadPolicy => 'مکمل پالیسی پڑھیں';

  @override
  String get privacyAccept => 'قبول کریں اور جاری رکھیں';
}
