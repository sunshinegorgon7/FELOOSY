// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get grant => 'Grant';

  @override
  String get change => 'Change';

  @override
  String get clear => 'Clear';

  @override
  String get import => 'Import';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get both => 'Both';

  @override
  String get recurring => 'Recurring';

  @override
  String get carryOver => 'Carry-over';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get annually => 'Annually';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Currency';

  @override
  String get categories => 'Categories';

  @override
  String get version => 'Version';

  @override
  String get auto => 'Auto';

  @override
  String get noCategory => 'No category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get homeSearchHint => 'Search transactions…';

  @override
  String get homeAllWallets => 'All wallets';

  @override
  String get homeSwitchWallet => 'Switch wallet';

  @override
  String get homeWallet => 'Wallet';

  @override
  String get homePreviousMonth => 'Previous month';

  @override
  String get homeNextMonth => 'Next month';

  @override
  String get homeTapReturnCurrentMonth => 'Tap to return to current month';

  @override
  String get homeNoBudget => 'No budget set.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'remaining this month · $percent% spent';
  }

  @override
  String homeOverBudget(int percent) {
    return 'over budget · $percent% spent';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount carried from last month';
  }

  @override
  String get homeNoTransactions => 'No transactions yet.\nTap + to add one.';

  @override
  String get homeNoTransactionsDay => 'No transactions on this day.';

  @override
  String get homeNoTransactionsCategory =>
      'No transactions in this\ncategory for this period.';

  @override
  String get homeByDay => 'By Day';

  @override
  String get homeByCategory => 'By Category';

  @override
  String get homeDeleteTitle => 'Delete transaction?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" will be permanently removed.';
  }

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeRecentTransactions => 'Recent Transactions';

  @override
  String get budgetRemaining => 'remaining';

  @override
  String get budgetSpent => 'Spent';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% used';
  }

  @override
  String get budgetNoSet => 'No budget set for this month yet.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Set budget for $period';
  }

  @override
  String get setBudgetHint =>
      'This is the total amount you want to track this month.';

  @override
  String get setBudgetAmount => 'Budget amount';

  @override
  String get setBudgetEnterAmount => 'Enter an amount';

  @override
  String get setBudgetValidAmount => 'Enter a valid amount';

  @override
  String get setBudgetSave => 'Save Budget';

  @override
  String get historyMonth => 'Month';

  @override
  String get historyYear => 'Year';

  @override
  String get transactionTitleEdit => 'Edit Transaction';

  @override
  String get transactionTitleNew => 'New Transaction';

  @override
  String get transactionValidAmount => 'Enter a valid amount.';

  @override
  String get transactionAddDescription => 'Add a description.';

  @override
  String get transactionSelectCategory => 'Select a category.';

  @override
  String get transactionRepeats => 'Repeats';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionFrequent => 'FREQUENT';

  @override
  String get transactionNewCategory => 'New';

  @override
  String get transactionEnterCategoryName => 'Enter a category name';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Add $fields to continue';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Rule: $keyword  •  tap to edit';
  }

  @override
  String get transactionDeleteTitle => 'Delete transaction?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" will be permanently removed.';
  }

  @override
  String get transactionDeleteRecurringTitle => 'Delete recurring transaction';

  @override
  String get transactionDeleteRecurringQuestion =>
      'How would you like to delete this?';

  @override
  String get transactionDeleteOnlyThis => 'Only this';

  @override
  String get transactionDeleteThisAndFuture => 'This & future';

  @override
  String get categoriesNoExpense => 'No expense categories yet.';

  @override
  String get categoriesNoIncome => 'No income categories yet.';

  @override
  String categoriesActiveCount(int count) {
    return '$count active';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'UNUSED THIS MONTH · $count';
  }

  @override
  String get categoriesUnused => 'unused';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% of spend';
  }

  @override
  String get editCategoryTitleEdit => 'Edit Category';

  @override
  String get editCategoryTitleAdd => 'Add Category';

  @override
  String get editCategoryName => 'Name';

  @override
  String get editCategoryUsedFor => 'Used for';

  @override
  String get editCategoryColour => 'Colour';

  @override
  String get editCategoryIcon => 'Icon';

  @override
  String get editCategoryChartNote =>
      'Chart bar colour is theme-managed for built-in categories.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsMonthStartsOn => 'Month starts on';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Day $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Days 29–31 unavailable to ensure February compatibility.';

  @override
  String get settingsDefaultMonthlyBudget => 'Default monthly budget';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get settingsManageCategories => 'Manage categories';

  @override
  String get settingsWallets => 'Wallets';

  @override
  String get settingsManageWallets => 'Manage wallets';

  @override
  String get settingsAutomations => 'Automations';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsDeveloperTools => 'Developer Tools';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsResetApp => 'Reset app';

  @override
  String get settingsResetAppDesc =>
      'Erase all transactions and budgets, restore defaults';

  @override
  String get settingsSelectCurrency => 'Select Currency';

  @override
  String get settingsMonthStartOnDay => 'Month starts on day…';

  @override
  String get settingsResetTitle => 'Reset app?';

  @override
  String get settingsResetMessage =>
      'This will permanently delete:\n  • All transactions\n  • All budgets\n  • All custom categories\n\nSettings will be restored to defaults and you will be signed out of Google. Sign in again afterwards to restore from a backup.\n\nThis cannot be undone.';

  @override
  String get settingsResetConfirm => 'Reset Everything';

  @override
  String get settingsChangeStartDayTitle => 'Change start day?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Changing from day $from to day $to will shift the period boundaries for all months. Existing transactions stay as-is.';
  }

  @override
  String get settingsBackupToDrive => 'Back up to Google Drive';

  @override
  String get settingsSignInForBackup => 'Sign in to enable backup';

  @override
  String settingsLastBackup(String time) {
    return 'Last backup: $time';
  }

  @override
  String get settingsNoBackupYet => 'No backup yet';

  @override
  String get settingsBackupNow => 'Back up now';

  @override
  String get settingsRestoreFromDrive => 'Restore from Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Replace local data with Drive backup';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsBackupSaved => 'Backup saved to Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'No changes since last backup — skipped.';

  @override
  String settingsBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Could not list backups: $error';
  }

  @override
  String get settingsNoBackupFound => 'No backup found in Google Drive.';

  @override
  String get settingsReplaceLocalTitle => 'Replace all local data?';

  @override
  String get settingsReplaceLocalMessage =>
      'Restoring from Google Drive will permanently delete everything currently on this device — all transactions, budgets, and categories — and replace it with the backup.\n\nThis cannot be undone.';

  @override
  String get settingsReplaceMyData => 'Replace my data';

  @override
  String get settingsDataRestored => 'Data restored from Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get settingsSelectBackup => 'Select backup to restore';

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsExportBackupDesc => 'Save all data as a JSON file';

  @override
  String get settingsRestoreFromFile => 'Restore from file';

  @override
  String get settingsRestoreFromFileDesc =>
      'Replace local data with an exported backup';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Cannot read file: $error';
  }

  @override
  String get settingsImportTitle => 'Import backup?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Found:\n  • $transactions transactions\n  • $budgets budgets\n  • $categories categories\n\nThis will replace all local data. This cannot be undone.';
  }

  @override
  String get settingsImportConfirm => 'Import';

  @override
  String settingsImportDone(int count) {
    return 'Imported $count transactions successfully.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsSmsRules => 'SMS Rules';

  @override
  String get settingsSmsRulesDesc =>
      'Auto-create transactions from incoming messages';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsCarryOver => 'Carry over unused budget';

  @override
  String get settingsCarryOverDesc => 'Surplus rolls into the next month';

  @override
  String get settingsDefaultBudgetApplied =>
      'Applied automatically when no budget has been set for the current month.';

  @override
  String get settingsJustNow => 'Just now';

  @override
  String settingsMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String settingsHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get manageWalletsTitle => 'Manage Wallets';

  @override
  String get manageWalletsNone => 'No wallets yet.';

  @override
  String get manageWalletsAdd => 'Add wallet';

  @override
  String get manageWalletsEditTitle => 'Edit wallet';

  @override
  String get manageWalletsName => 'Wallet name';

  @override
  String get manageWalletsDefaultBudget => 'Default monthly budget (optional)';

  @override
  String get manageWalletsLeaveEmpty => 'Leave empty to disable';

  @override
  String get manageWalletsMonthStart => 'Month starts on (optional)';

  @override
  String get manageWalletsAppDefault => 'App default';

  @override
  String manageWalletsDay(int day) {
    return 'Day $day';
  }

  @override
  String get manageWalletsLeaveAsDefault => 'Leave as app default if not set';

  @override
  String get manageWalletsDefaultLabel => 'Default wallet';

  @override
  String get manageWalletsSetAsDefault => 'Set as default';

  @override
  String get manageWalletsNoBudget => 'No default budget';

  @override
  String get manageWalletsAlreadyExists =>
      'A wallet with this name already exists';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Carry-over on';
  }

  @override
  String get smsRulesTitle => 'SMS Rules';

  @override
  String get smsRulesScanPast => 'Scan past SMS';

  @override
  String get smsRulesPermissionTitle => 'SMS permission required';

  @override
  String get smsRulesPermissionMessage =>
      'Grant access so incoming messages can be matched against your rules.';

  @override
  String get smsRulesNone => 'No rules yet';

  @override
  String get smsRulesNoneMessage =>
      'Add a rule to automatically create transactions when you receive bank SMS messages.';

  @override
  String get smsRulesAddFirst => 'Add first rule';

  @override
  String get smsRulesDeleteTitle => 'Delete rule?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'The rule for \"$keyword\" will be deleted. Existing transactions it created will not be affected.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return 'Created $count transactions on $date — go back to the home screen to see them.';
  }

  @override
  String get smsRulesNoImports => 'No transactions imported.';

  @override
  String get smsRuleFormTitleEdit => 'Edit Rule';

  @override
  String get smsRuleFormTitleNew => 'New Rule';

  @override
  String get smsRuleFormKeyword => 'Keyword';

  @override
  String get smsRuleFormKeywordHint => 'e.g. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Case-insensitive match anywhere in the SMS body.';

  @override
  String get smsRuleFormLabel => 'Transaction Label';

  @override
  String get smsRuleFormLabelHint =>
      'e.g. Gas, Coffee, Groceries (leave blank to use keyword)';

  @override
  String get smsRuleFormLabelHelper =>
      'Shown as the transaction description. Defaults to the keyword.';

  @override
  String get smsRuleFormType => 'Transaction Type';

  @override
  String get smsRuleFormCategory => 'Category';

  @override
  String get smsRuleFormSelectCategory => 'Select a category';

  @override
  String get smsRuleFormWallet => 'Wallet';

  @override
  String get smsRuleFormAdvanced => 'Advanced';

  @override
  String get smsRuleFormCustomRegex => 'Custom amount regex';

  @override
  String get smsRuleFormRegexHint => 'Amount regex (optional)';

  @override
  String get smsRuleFormRegexHelper =>
      'Use capture group 1 to extract the amount. Leave empty to use built-in detection.';

  @override
  String get smsRuleFormSaveChanges => 'Save Changes';

  @override
  String get smsRuleFormSaveNew => 'Save Rule';

  @override
  String get smsRuleFormDeleteRule => 'Delete Rule';

  @override
  String get smsRuleFormEnterKeyword => 'Please enter a keyword.';

  @override
  String get smsRuleFormSelectCategoryError => 'Please select a category.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'The rule for \"$keyword\" will be permanently deleted.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Select Category';

  @override
  String get smsScanTitle => 'Scan existing SMS';

  @override
  String get smsScanDesc =>
      'Apply your active rules to messages already in your inbox.';

  @override
  String get smsScanDateRange => 'Date range';

  @override
  String get smsScan3Days => '3 days';

  @override
  String get smsScanCustom => 'Custom…';

  @override
  String get smsScanSelectRange => 'Select date range';

  @override
  String get smsScanPermissionRequired =>
      'SMS permission is required to scan messages.';

  @override
  String get smsScanScanning => 'Scanning messages…';

  @override
  String get smsScanNoMatches => 'No matches found';

  @override
  String get smsScanNoMatchesMessage =>
      'No messages in this range matched your active rules.\nTry a wider range or check your rule keywords.';

  @override
  String get smsScanTryDifferent => 'Try different range';

  @override
  String smsScanMatchesFound(int count) {
    return '$count matches found';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count already exist today — unchecked by default';
  }

  @override
  String smsScanImportButton(int count) {
    return 'Import $count transactions';
  }

  @override
  String get smsScanNothingSelected => 'Nothing selected';

  @override
  String get smsScanEditLabel => 'Edit label';

  @override
  String get smsScanTransactionDesc => 'Transaction description';

  @override
  String get smsScanExists => 'exists';

  @override
  String get smsScanDupWarning =>
      'Transaction for this amount and category already exists on this day';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'Everything unlocked, once. No subscriptions.';

  @override
  String paywallUnlock(String price) {
    return 'Unlock Forever — $price';
  }

  @override
  String get paywallRestore => 'Restore Purchase';

  @override
  String get paywallRestoreNote => 'One-time purchase · No recurring fees';

  @override
  String get paywallTrialEnded => 'Your 14-day free trial has ended';

  @override
  String get paywallProUnlocked => 'Pro Unlocked';

  @override
  String get paywallFeatureWallets => 'Unlimited wallets';

  @override
  String get paywallFeatureTransactions => 'Unlimited transactions';

  @override
  String get paywallFeatureHistory => 'Full transaction history';

  @override
  String get paywallFeatureBackup => 'Google Drive backup';

  @override
  String get paywallFeatureExport => 'Export your data';

  @override
  String get paywallFeatureCategories => 'Custom categories';

  @override
  String get paywallFeatureSms => 'SMS auto-parsing (Android)';

  @override
  String get paywallNoRestoreFound =>
      'No previous purchase found for this account.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get tutorialGetStarted => 'Get Started';

  @override
  String get tutorialWelcomeTitle => 'Welcome to FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'Your personal budget, beautifully simple.\nLet\'s take a quick tour of the key features.';

  @override
  String get tutorialBudgetTitle => 'Monthly Budget';

  @override
  String get tutorialBudgetMessage =>
      'This card shows your budget vs. spending for the month. Tap \"Set Budget\" to define your monthly limit.';

  @override
  String get tutorialCarryoverTitle => 'Carry Over Surplus';

  @override
  String get tutorialCarryoverMessage =>
      'Enable carry-over in Settings → Manage Wallets for any wallet. Unused budget from last month rolls into this month automatically.';

  @override
  String get tutorialAddTitle => 'Add a Transaction';

  @override
  String get tutorialAddMessage =>
      'Tap the + button to record a purchase, bill, or income. Pick a category to see where your money goes.';

  @override
  String get tutorialBrowseTitle => 'Browse Past Months';

  @override
  String get tutorialBrowseMessage =>
      'Tap the arrows or swipe left/right on the home screen to review any previous month.';

  @override
  String get tutorialSettingsTitle => 'Settings & More';

  @override
  String get tutorialSettingsMessage =>
      'Change currency, manage accounts, customise categories, and back up your data from here.';

  @override
  String get tutorialDoneTitle => 'You\'re all set!';

  @override
  String get tutorialDoneMessage =>
      'Start by adding your first transaction. FELOOSY will track the rest.';

  @override
  String get consentTitle => 'Before you begin';

  @override
  String get consentDataTitle => 'Your data stays on your device';

  @override
  String get consentDataBody =>
      'Transactions and budgets are stored locally in SQLite. We have no servers and cannot access your financial data.';

  @override
  String get consentBackupTitle => 'Optional cloud backup';

  @override
  String get consentBackupBody =>
      'You can connect Google Drive to back up your data. It goes to your own Drive folder — we never see it.';

  @override
  String get consentReadPolicy => 'Read full policy';

  @override
  String get consentAccept => 'Accept & Continue';

  @override
  String get smsOptInTitle => 'SMS Auto-Import';

  @override
  String get smsOptInBody =>
      'FELOOSY can read bank SMS messages and create transactions automatically. Messages are matched locally — never stored as text or shared.';

  @override
  String get smsOptInEnable => 'Enable SMS';

  @override
  String get smsOptInSkip => 'Skip for now';

  @override
  String get smsToggleLabel => 'SMS Auto-Import';

  @override
  String get smsToggleSubtitle => 'Auto-create transactions from bank messages';

  @override
  String get smsTermsTitle => 'Enable SMS Auto-Import?';

  @override
  String get smsTermsBody =>
      'FELOOSY will read incoming bank SMS messages and match them against your rules to create transactions automatically. Message text is never stored or shared. You can disable this anytime.';

  @override
  String get smsTermsEnable => 'Enable';
}
