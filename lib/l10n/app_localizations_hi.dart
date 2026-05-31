// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'अगला';

  @override
  String get skip => 'छोड़ें';

  @override
  String get grant => 'अनुमति दें';

  @override
  String get change => 'बदलें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get import => 'आयात करें';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get expense => 'खर्च';

  @override
  String get income => 'आय';

  @override
  String get both => 'दोनों';

  @override
  String get recurring => 'आवर्ती';

  @override
  String get daily => 'दैनिक';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get annually => 'वार्षिक';

  @override
  String get search => 'खोजें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get history => 'इतिहास';

  @override
  String get budget => 'बजट';

  @override
  String get currency => 'मुद्रा';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get version => 'संस्करण';

  @override
  String get auto => 'ऑटो';

  @override
  String get noCategory => 'कोई श्रेणी नहीं';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get setBudget => 'बजट सेट करें';

  @override
  String get homeSearchHint => 'लेनदेन खोजें…';

  @override
  String get homeAllWallets => 'सभी वॉलेट';

  @override
  String get homeSwitchWallet => 'वॉलेट बदलें';

  @override
  String get homeWallet => 'वॉलेट';

  @override
  String get homePreviousMonth => 'पिछला महीना';

  @override
  String get homeNextMonth => 'अगला महीना';

  @override
  String get homeTapReturnCurrentMonth =>
      'वर्तमान महीने पर वापस जाने के लिए टैप करें';

  @override
  String get homeNoBudget => 'कोई बजट सेट नहीं।';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'इस महीने शेष · $percent% खर्च';
  }

  @override
  String homeOverBudget(int percent) {
    return 'बजट से अधिक · $percent% खर्च';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount पिछले महीने से आगे बढ़ाया गया';
  }

  @override
  String get homeNoTransactions =>
      'अभी तक कोई लेनदेन नहीं।\nएक जोड़ने के लिए + दबाएं।';

  @override
  String get homeNoTransactionsDay => 'इस दिन कोई लेनदेन नहीं।';

  @override
  String get homeNoTransactionsCategory =>
      'इस अवधि में इस\nश्रेणी में कोई लेनदेन नहीं।';

  @override
  String get homeByDay => 'दिन के अनुसार';

  @override
  String get homeByCategory => 'श्रेणी के अनुसार';

  @override
  String get homeDeleteTitle => 'लेनदेन हटाएं?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" स्थायी रूप से हटा दिया जाएगा।';
  }

  @override
  String get homeSeeAll => 'सभी देखें';

  @override
  String get homeRecentTransactions => 'हाल के लेनदेन';

  @override
  String get budgetRemaining => 'शेष';

  @override
  String get budgetSpent => 'खर्च किया';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% उपयोग';
  }

  @override
  String get budgetNoSet => 'इस महीने के लिए अभी तक कोई बजट सेट नहीं।';

  @override
  String setBudgetForPeriod(String period) {
    return '$period के लिए बजट सेट करें';
  }

  @override
  String get setBudgetHint =>
      'यह वह कुल राशि है जिसे आप इस महीने ट्रैक करना चाहते हैं।';

  @override
  String get setBudgetAmount => 'बजट राशि';

  @override
  String get setBudgetEnterAmount => 'एक राशि दर्ज करें';

  @override
  String get setBudgetValidAmount => 'एक वैध राशि दर्ज करें';

  @override
  String get setBudgetSave => 'बजट सहेजें';

  @override
  String get historyMonth => 'महीना';

  @override
  String get historyYear => 'वर्ष';

  @override
  String get transactionTitleEdit => 'लेनदेन संपादित करें';

  @override
  String get transactionTitleNew => 'नया लेनदेन';

  @override
  String get transactionValidAmount => 'एक वैध राशि दर्ज करें।';

  @override
  String get transactionAddDescription => 'विवरण जोड़ें।';

  @override
  String get transactionSelectCategory => 'श्रेणी चुनें।';

  @override
  String get transactionRepeats => 'दोहराता है';

  @override
  String get transactionDescription => 'विवरण';

  @override
  String get transactionFrequent => 'बार-बार';

  @override
  String get transactionNewCategory => 'नई';

  @override
  String get transactionEnterCategoryName => 'श्रेणी का नाम दर्ज करें';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'जारी रखने के लिए $fields जोड़ें';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'नियम: $keyword  •  संपादित करने के लिए टैप करें';
  }

  @override
  String get transactionDeleteTitle => 'लेनदेन हटाएं?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" स्थायी रूप से हटा दिया जाएगा।';
  }

  @override
  String get transactionDeleteRecurringTitle => 'आवर्ती लेनदेन हटाएं';

  @override
  String get transactionDeleteRecurringQuestion =>
      'आप इसे कैसे हटाना चाहते हैं?';

  @override
  String get transactionDeleteOnlyThis => 'केवल यह';

  @override
  String get transactionDeleteThisAndFuture => 'यह और भविष्य के';

  @override
  String get categoriesNoExpense => 'अभी तक कोई खर्च श्रेणी नहीं।';

  @override
  String get categoriesNoIncome => 'अभी तक कोई आय श्रेणी नहीं।';

  @override
  String categoriesActiveCount(int count) {
    return '$count सक्रिय';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'इस महीने अप्रयुक्त · $count';
  }

  @override
  String get categoriesUnused => 'अप्रयुक्त';

  @override
  String categoriesPercentSpend(String percent) {
    return 'खर्च का $percent%';
  }

  @override
  String get editCategoryTitleEdit => 'श्रेणी संपादित करें';

  @override
  String get editCategoryTitleAdd => 'श्रेणी जोड़ें';

  @override
  String get editCategoryName => 'नाम';

  @override
  String get editCategoryUsedFor => 'इसके लिए उपयोग';

  @override
  String get editCategoryColour => 'रंग';

  @override
  String get editCategoryIcon => 'आइकन';

  @override
  String get editCategoryChartNote =>
      'चार्ट बार रंग अंतर्निहित श्रेणियों के लिए थीम द्वारा प्रबंधित होता है।';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsMonthStartsOn => 'महीना शुरू होता है';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'दिन $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'फरवरी अनुकूलता सुनिश्चित करने के लिए दिन 29-31 अनुपलब्ध हैं।';

  @override
  String get settingsDefaultMonthlyBudget => 'डिफ़ॉल्ट मासिक बजट';

  @override
  String get settingsNotSet => 'सेट नहीं';

  @override
  String get settingsManageCategories => 'श्रेणियाँ प्रबंधित करें';

  @override
  String get settingsWallets => 'वॉलेट';

  @override
  String get settingsManageWallets => 'वॉलेट प्रबंधित करें';

  @override
  String get settingsAutomations => 'स्वचालन';

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsAbout => 'के बारे में';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsDeveloperTools => 'डेवलपर टूल्स';

  @override
  String get settingsDangerZone => 'खतरा क्षेत्र';

  @override
  String get settingsResetApp => 'ऐप रीसेट करें';

  @override
  String get settingsResetAppDesc =>
      'सभी लेनदेन और बजट मिटाएं, डिफ़ॉल्ट पुनर्स्थापित करें';

  @override
  String get settingsSelectCurrency => 'मुद्रा चुनें';

  @override
  String get settingsMonthStartOnDay => 'महीना दिन से शुरू होता है…';

  @override
  String get settingsResetTitle => 'ऐप रीसेट करें?';

  @override
  String get settingsResetMessage =>
      'इससे स्थायी रूप से हट जाएगा:\n  • सभी लेनदेन\n  • सभी बजट\n  • सभी कस्टम श्रेणियाँ\n\nसेटिंग्स डिफ़ॉल्ट पर पुनर्स्थापित होंगी और आप Google से साइन आउट हो जाएंगे। बैकअप से पुनर्स्थापित करने के लिए बाद में फिर से साइन इन करें।\n\nइसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get settingsResetConfirm => 'सब कुछ रीसेट करें';

  @override
  String get settingsChangeStartDayTitle => 'प्रारंभ दिन बदलें?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'दिन $from से दिन $to में बदलने से सभी महीनों की अवधि सीमाएं बदल जाएंगी। मौजूदा लेनदेन जैसे हैं वैसे रहेंगे।';
  }

  @override
  String get settingsBackupToDrive => 'Google Drive पर बैकअप करें';

  @override
  String get settingsSignInForBackup => 'बैकअप सक्षम करने के लिए साइन इन करें';

  @override
  String settingsLastBackup(String time) {
    return 'अंतिम बैकअप: $time';
  }

  @override
  String get settingsNoBackupYet => 'अभी तक कोई बैकअप नहीं';

  @override
  String get settingsBackupNow => 'अभी बैकअप करें';

  @override
  String get settingsRestoreFromDrive => 'Drive से पुनर्स्थापित करें';

  @override
  String get settingsRestoreFromDriveDesc =>
      'स्थानीय डेटा को Drive बैकअप से बदलें';

  @override
  String get settingsSignOut => 'साइन आउट';

  @override
  String get settingsBackupSaved => 'बैकअप Google Drive पर सहेजा गया।';

  @override
  String get settingsBackupNoChanges =>
      'अंतिम बैकअप के बाद कोई बदलाव नहीं — छोड़ दिया।';

  @override
  String settingsBackupFailed(String error) {
    return 'बैकअप विफल: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'बैकअप सूचीबद्ध नहीं किए जा सके: $error';
  }

  @override
  String get settingsNoBackupFound => 'Google Drive में कोई बैकअप नहीं मिला।';

  @override
  String get settingsReplaceLocalTitle => 'सभी स्थानीय डेटा बदलें?';

  @override
  String get settingsReplaceLocalMessage =>
      'Google Drive से पुनर्स्थापित करने से इस डिवाइस पर सब कुछ स्थायी रूप से हट जाएगा — सभी लेनदेन, बजट और श्रेणियाँ — और उन्हें बैकअप से बदल दिया जाएगा।\n\nइसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get settingsReplaceMyData => 'मेरा डेटा बदलें';

  @override
  String get settingsDataRestored => 'Google Drive से डेटा पुनर्स्थापित।';

  @override
  String settingsRestoreFailed(String error) {
    return 'पुनर्स्थापना विफल: $error';
  }

  @override
  String get settingsSelectBackup => 'पुनर्स्थापित करने के लिए बैकअप चुनें';

  @override
  String get settingsExportBackup => 'बैकअप निर्यात करें';

  @override
  String get settingsExportBackupDesc =>
      'सभी डेटा को JSON फ़ाइल के रूप में सहेजें';

  @override
  String get settingsRestoreFromFile => 'फ़ाइल से पुनर्स्थापित करें';

  @override
  String get settingsRestoreFromFileDesc =>
      'स्थानीय डेटा को निर्यात किए गए बैकअप से बदलें';

  @override
  String settingsExportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'फ़ाइल नहीं पढ़ी जा सकती: $error';
  }

  @override
  String get settingsImportTitle => 'बैकअप आयात करें?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'मिला:\n  • $transactions लेनदेन\n  • $budgets बजट\n  • $categories श्रेणियाँ\n\nयह सभी स्थानीय डेटा बदल देगा। इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get settingsImportConfirm => 'आयात करें';

  @override
  String settingsImportDone(int count) {
    return '$count लेनदेन सफलतापूर्वक आयात किए गए।';
  }

  @override
  String settingsImportFailed(String error) {
    return 'आयात विफल: $error';
  }

  @override
  String get settingsSmsRules => 'SMS नियम';

  @override
  String get settingsSmsRulesDesc =>
      'आने वाले संदेशों से स्वचालित रूप से लेनदेन बनाएं';

  @override
  String get settingsThemeLight => 'हल्का';

  @override
  String get settingsThemeDark => 'गहरा';

  @override
  String get settingsThemeAuto => 'ऑटो';

  @override
  String get settingsCarryOver => 'अप्रयुक्त बजट आगे बढ़ाएं';

  @override
  String get settingsCarryOverDesc => 'अधिशेष अगले महीने में जुड़ता है';

  @override
  String get settingsDefaultBudgetApplied =>
      'जब वर्तमान महीने के लिए कोई बजट सेट नहीं होता तो स्वचालित रूप से लागू होता है।';

  @override
  String get settingsJustNow => 'अभी';

  @override
  String settingsMinutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String settingsHoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsSelectLanguage => 'भाषा चुनें';

  @override
  String get manageWalletsTitle => 'वॉलेट प्रबंधित करें';

  @override
  String get manageWalletsNone => 'अभी तक कोई वॉलेट नहीं।';

  @override
  String get manageWalletsAdd => 'वॉलेट जोड़ें';

  @override
  String get manageWalletsEditTitle => 'वॉलेट संपादित करें';

  @override
  String get manageWalletsName => 'वॉलेट का नाम';

  @override
  String get manageWalletsDefaultBudget => 'डिफ़ॉल्ट मासिक बजट (वैकल्पिक)';

  @override
  String get manageWalletsLeaveEmpty => 'अक्षम करने के लिए खाली छोड़ें';

  @override
  String get manageWalletsMonthStart => 'महीना शुरू होता है (वैकल्पिक)';

  @override
  String get manageWalletsAppDefault => 'ऐप डिफ़ॉल्ट';

  @override
  String manageWalletsDay(int day) {
    return 'दिन $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'अगर सेट नहीं है तो ऐप डिफ़ॉल्ट के रूप में छोड़ें';

  @override
  String get manageWalletsDefaultLabel => 'डिफ़ॉल्ट वॉलेट';

  @override
  String get manageWalletsSetAsDefault => 'डिफ़ॉल्ट के रूप में सेट करें';

  @override
  String get manageWalletsNoBudget => 'कोई डिफ़ॉल्ट बजट नहीं';

  @override
  String get manageWalletsAlreadyExists => 'इस नाम का वॉलेट पहले से मौजूद है';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · आगे बढ़ाना चालू';
  }

  @override
  String get smsRulesTitle => 'SMS नियम';

  @override
  String get smsRulesScanPast => 'पिछले SMS स्कैन करें';

  @override
  String get smsRulesPermissionTitle => 'SMS अनुमति आवश्यक';

  @override
  String get smsRulesPermissionMessage =>
      'आने वाले संदेशों को आपके नियमों से मिलाने के लिए पहुंच दें।';

  @override
  String get smsRulesNone => 'अभी तक कोई नियम नहीं';

  @override
  String get smsRulesNoneMessage =>
      'बैंक SMS प्राप्त होने पर स्वचालित रूप से लेनदेन बनाने के लिए एक नियम जोड़ें।';

  @override
  String get smsRulesAddFirst => 'पहला नियम जोड़ें';

  @override
  String get smsRulesDeleteTitle => 'नियम हटाएं?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return '\"$keyword\" के लिए नियम हटा दिया जाएगा। इसके द्वारा बनाए गए लेनदेन प्रभावित नहीं होंगे।';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$date को $count लेनदेन बनाए गए — उन्हें देखने के लिए होम स्क्रीन पर जाएं।';
  }

  @override
  String get smsRulesNoImports => 'कोई लेनदेन आयात नहीं किया गया।';

  @override
  String get smsRuleFormTitleEdit => 'नियम संपादित करें';

  @override
  String get smsRuleFormTitleNew => 'नया नियम';

  @override
  String get smsRuleFormKeyword => 'कीवर्ड';

  @override
  String get smsRuleFormKeywordHint => 'उदा. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'SMS बॉडी में कहीं भी केस-असंवेदनशील मिलान।';

  @override
  String get smsRuleFormLabel => 'लेनदेन लेबल';

  @override
  String get smsRuleFormLabelHint =>
      'उदा. पेट्रोल, कॉफी, किराना (कीवर्ड उपयोग करने के लिए खाली छोड़ें)';

  @override
  String get smsRuleFormLabelHelper =>
      'लेनदेन विवरण के रूप में दिखाया जाता है। कीवर्ड पर डिफ़ॉल्ट।';

  @override
  String get smsRuleFormType => 'लेनदेन प्रकार';

  @override
  String get smsRuleFormCategory => 'श्रेणी';

  @override
  String get smsRuleFormSelectCategory => 'श्रेणी चुनें';

  @override
  String get smsRuleFormWallet => 'वॉलेट';

  @override
  String get smsRuleFormAdvanced => 'उन्नत';

  @override
  String get smsRuleFormCustomRegex => 'कस्टम राशि रेगेक्स';

  @override
  String get smsRuleFormRegexHint => 'राशि रेगेक्स (वैकल्पिक)';

  @override
  String get smsRuleFormRegexHelper =>
      'राशि निकालने के लिए कैप्चर ग्रुप 1 का उपयोग करें। अंतर्निहित पहचान के लिए खाली छोड़ें।';

  @override
  String get smsRuleFormSaveChanges => 'बदलाव सहेजें';

  @override
  String get smsRuleFormSaveNew => 'नियम सहेजें';

  @override
  String get smsRuleFormDeleteRule => 'नियम हटाएं';

  @override
  String get smsRuleFormEnterKeyword => 'कृपया एक कीवर्ड दर्ज करें।';

  @override
  String get smsRuleFormSelectCategoryError => 'कृपया एक श्रेणी चुनें।';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return '\"$keyword\" के लिए नियम स्थायी रूप से हटा दिया जाएगा।';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'श्रेणी चुनें';

  @override
  String get smsScanTitle => 'मौजूदा SMS स्कैन करें';

  @override
  String get smsScanDesc =>
      'अपने इनबॉक्स में पहले से मौजूद संदेशों पर अपने सक्रिय नियम लागू करें।';

  @override
  String get smsScanDateRange => 'तारीख सीमा';

  @override
  String get smsScan3Days => '3 दिन';

  @override
  String get smsScan7Days => '7 दिन';

  @override
  String get smsScan30Days => '30 दिन';

  @override
  String get smsScanCustom => 'कस्टम…';

  @override
  String get smsScanSelectRange => 'तारीख सीमा चुनें';

  @override
  String get smsScanPermissionRequired =>
      'संदेश स्कैन करने के लिए SMS अनुमति आवश्यक है।';

  @override
  String get smsScanScanning => 'संदेश स्कैन हो रहे हैं…';

  @override
  String get smsScanNoMatches => 'कोई मिलान नहीं मिला';

  @override
  String get smsScanNoMatchesMessage =>
      'इस सीमा में कोई संदेश आपके सक्रिय नियमों से मेल नहीं खाता।\nव्यापक सीमा आज़माएं या अपने नियम कीवर्ड जाँचें।';

  @override
  String get smsScanTryDifferent => 'अलग सीमा आज़माएं';

  @override
  String smsScanMatchesFound(int count) {
    return '$count मिलान मिले';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count आज पहले से मौजूद हैं — डिफ़ॉल्ट रूप से अनचेक';
  }

  @override
  String smsScanImportButton(int count) {
    return '$count लेनदेन आयात करें';
  }

  @override
  String get smsScanNothingSelected => 'कुछ चुना नहीं';

  @override
  String get smsScanEditLabel => 'लेबल संपादित करें';

  @override
  String get smsScanTransactionDesc => 'लेनदेन विवरण';

  @override
  String get smsScanExists => 'मौजूद है';

  @override
  String get smsScanDupWarning =>
      'इस दिन इस राशि और श्रेणी के लिए लेनदेन पहले से मौजूद है';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'सब कुछ अनलॉक, एक बार। कोई सदस्यता नहीं।';

  @override
  String paywallUnlock(String price) {
    return 'हमेशा के लिए अनलॉक करें — $price';
  }

  @override
  String get paywallRestore => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get paywallRestoreNote => 'एकमुश्त खरीदारी · कोई आवर्ती शुल्क नहीं';

  @override
  String get paywallTrialEnded =>
      'आपका 14-दिन का मुफ्त ट्रायल समाप्त हो गया है';

  @override
  String get paywallProUnlocked => 'Pro अनलॉक';

  @override
  String get paywallFeatureWallets => 'असीमित वॉलेट';

  @override
  String get paywallFeatureTransactions => 'असीमित लेनदेन';

  @override
  String get paywallFeatureHistory => 'पूरा लेनदेन इतिहास';

  @override
  String get paywallFeatureBackup => 'Google Drive बैकअप';

  @override
  String get paywallFeatureExport => 'अपना डेटा निर्यात करें';

  @override
  String get paywallFeatureCategories => 'कस्टम श्रेणियाँ';

  @override
  String get paywallFeatureSms => 'SMS ऑटो-पार्सिंग (Android)';

  @override
  String get paywallNoRestoreFound =>
      'इस खाते के लिए कोई पिछली खरीदारी नहीं मिली।';

  @override
  String paywallRestoreFailed(String error) {
    return 'पुनर्स्थापना विफल: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$total में से $current';
  }

  @override
  String get tutorialGetStarted => 'शुरू करें';

  @override
  String get tutorialWelcomeTitle => 'FELOOSY में आपका स्वागत है';

  @override
  String get tutorialWelcomeMessage =>
      'आपका व्यक्तिगत बजट, खूबसूरती से सरल।\nआइए मुख्य सुविधाओं का त्वरित दौरा करें।';

  @override
  String get tutorialBudgetTitle => 'मासिक बजट';

  @override
  String get tutorialBudgetMessage =>
      'यह कार्ड महीने के लिए आपका बजट बनाम खर्च दिखाता है। अपनी मासिक सीमा निर्धारित करने के लिए \"बजट सेट करें\" टैप करें।';

  @override
  String get tutorialCarryoverTitle => 'अधिशेष आगे बढ़ाएं';

  @override
  String get tutorialCarryoverMessage =>
      'किसी भी वॉलेट के लिए सेटिंग्स → वॉलेट प्रबंधित करें में आगे बढ़ाना सक्षम करें। पिछले महीने का अप्रयुक्त बजट इस महीने में स्वचालित रूप से जुड़ जाता है।';

  @override
  String get tutorialAddTitle => 'लेनदेन जोड़ें';

  @override
  String get tutorialAddMessage =>
      'खरीदारी, बिल या आय दर्ज करने के लिए + बटन टैप करें। यह देखने के लिए कि आपका पैसा कहाँ जाता है, एक श्रेणी चुनें।';

  @override
  String get tutorialBrowseTitle => 'पिछले महीने देखें';

  @override
  String get tutorialBrowseMessage =>
      'किसी भी पिछले महीने की समीक्षा करने के लिए होम स्क्रीन पर तीरों पर टैप करें या बाएं/दाएं स्वाइप करें।';

  @override
  String get tutorialSettingsTitle => 'सेटिंग्स और अधिक';

  @override
  String get tutorialSettingsMessage =>
      'यहाँ से मुद्रा बदलें, खाते प्रबंधित करें, श्रेणियाँ अनुकूलित करें और अपना डेटा बैकअप करें।';

  @override
  String get tutorialDoneTitle => 'आप तैयार हैं!';

  @override
  String get tutorialDoneMessage =>
      'अपना पहला लेनदेन जोड़कर शुरुआत करें। FELOOSY बाकी ट्रैक करेगा।';

  @override
  String get privacyTitle => 'शुरू करने से पहले';

  @override
  String get privacySmsTitle => 'SMS ऑटो-डिटेक्शन';

  @override
  String get privacySmsMessage =>
      'यदि आप SMS अनुमति देते हैं, तो आने वाले बैंक संदेशों को मेमोरी में आपके नियमों से मिलाया जाता है। संदेश टेक्स्ट कभी भी सहेजा या साझा नहीं किया जाता।';

  @override
  String get privacyDataTitle => 'आपका डेटा आपके डिवाइस पर रहता है';

  @override
  String get privacyDataMessage =>
      'लेनदेन और बजट स्थानीय रूप से संग्रहीत हैं। हमारे पास कोई सर्वर नहीं है और हम आपका वित्तीय डेटा नहीं देख सकते।';

  @override
  String get privacyAiTitle => 'AI विश्लेषण (वैकल्पिक)';

  @override
  String get privacyAiMessage =>
      'यदि आप AI सुविधा का उपयोग करते हैं, तो अनामीकृत खर्च सारांश (श्रेणी योग, कोई कच्चे SMS नहीं) Google Gemini को भेजे जाते हैं।';

  @override
  String get privacyReadPolicy => 'पूरी नीति पढ़ें';

  @override
  String get privacyAccept => 'स्वीकार करें और जारी रखें';
}
