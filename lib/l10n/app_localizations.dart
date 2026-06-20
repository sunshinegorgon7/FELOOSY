import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @carryOver.
  ///
  /// In en, this message translates to:
  /// **'Carry-over'**
  String get carryOver;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @annually.
  ///
  /// In en, this message translates to:
  /// **'Annually'**
  String get annually;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions…'**
  String get homeSearchHint;

  /// No description provided for @discreetModeShow.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get discreetModeShow;

  /// No description provided for @discreetModeHide.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get discreetModeHide;

  /// No description provided for @homeAllWallets.
  ///
  /// In en, this message translates to:
  /// **'All wallets'**
  String get homeAllWallets;

  /// No description provided for @homeSwitchWallet.
  ///
  /// In en, this message translates to:
  /// **'Switch wallet'**
  String get homeSwitchWallet;

  /// No description provided for @homeWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get homeWallet;

  /// No description provided for @homePreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get homePreviousMonth;

  /// No description provided for @homeNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get homeNextMonth;

  /// No description provided for @homeTapReturnCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to current month'**
  String get homeTapReturnCurrentMonth;

  /// No description provided for @homeNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget set.'**
  String get homeNoBudget;

  /// No description provided for @homeRemainingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'remaining this month · {percent}% spent'**
  String homeRemainingThisMonth(int percent);

  /// No description provided for @homeOverBudget.
  ///
  /// In en, this message translates to:
  /// **'over budget · {percent}% spent'**
  String homeOverBudget(int percent);

  /// No description provided for @homeCarryOver.
  ///
  /// In en, this message translates to:
  /// **'+ {amount} carried from last month'**
  String homeCarryOver(String amount);

  /// No description provided for @homeNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.\nTap + to add one.'**
  String get homeNoTransactions;

  /// No description provided for @homeNoTransactionsDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions on this day.'**
  String get homeNoTransactionsDay;

  /// No description provided for @homeNoTransactionsCategory.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this\ncategory for this period.'**
  String get homeNoTransactionsCategory;

  /// No description provided for @homeByDay.
  ///
  /// In en, this message translates to:
  /// **'By Day'**
  String get homeByDay;

  /// No description provided for @homeByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get homeByCategory;

  /// No description provided for @homeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get homeDeleteTitle;

  /// No description provided for @homeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{description}\" will be permanently removed.'**
  String homeDeleteMessage(String description);

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get homeRecentTransactions;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get budgetRemaining;

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpent;

  /// No description provided for @budgetPercentUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String budgetPercentUsed(String percent);

  /// No description provided for @budgetNoSet.
  ///
  /// In en, this message translates to:
  /// **'No budget set for this month yet.'**
  String get budgetNoSet;

  /// No description provided for @setBudgetForPeriod.
  ///
  /// In en, this message translates to:
  /// **'Set budget for {period}'**
  String setBudgetForPeriod(String period);

  /// No description provided for @setBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'This is the total amount you want to track this month.'**
  String get setBudgetHint;

  /// No description provided for @setBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get setBudgetAmount;

  /// No description provided for @setBudgetEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get setBudgetEnterAmount;

  /// No description provided for @setBudgetValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get setBudgetValidAmount;

  /// No description provided for @setBudgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get setBudgetSave;

  /// No description provided for @historyMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get historyMonth;

  /// No description provided for @historyYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get historyYear;

  /// No description provided for @transactionTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get transactionTitleEdit;

  /// No description provided for @transactionTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get transactionTitleNew;

  /// No description provided for @transactionValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get transactionValidAmount;

  /// No description provided for @transactionAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a description.'**
  String get transactionAddDescription;

  /// No description provided for @transactionSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get transactionSelectCategory;

  /// No description provided for @transactionRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get transactionRepeats;

  /// No description provided for @transactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDescription;

  /// No description provided for @transactionFrequent.
  ///
  /// In en, this message translates to:
  /// **'FREQUENT'**
  String get transactionFrequent;

  /// No description provided for @transactionNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get transactionNewCategory;

  /// No description provided for @transactionEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get transactionEnterCategoryName;

  /// No description provided for @transactionAddFieldsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add {fields} to continue'**
  String transactionAddFieldsTooltip(String fields);

  /// No description provided for @transactionRuleInfo.
  ///
  /// In en, this message translates to:
  /// **'Rule: {keyword}  •  tap to edit'**
  String transactionRuleInfo(String keyword);

  /// No description provided for @transactionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get transactionDeleteTitle;

  /// No description provided for @transactionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{description}\" will be permanently removed.'**
  String transactionDeleteMessage(String description);

  /// No description provided for @transactionDeleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring transaction'**
  String get transactionDeleteRecurringTitle;

  /// No description provided for @transactionDeleteRecurringQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to delete this?'**
  String get transactionDeleteRecurringQuestion;

  /// No description provided for @transactionDeleteOnlyThis.
  ///
  /// In en, this message translates to:
  /// **'Only this'**
  String get transactionDeleteOnlyThis;

  /// No description provided for @transactionDeleteThisAndFuture.
  ///
  /// In en, this message translates to:
  /// **'This & future'**
  String get transactionDeleteThisAndFuture;

  /// No description provided for @categoriesNoExpense.
  ///
  /// In en, this message translates to:
  /// **'No expense categories yet.'**
  String get categoriesNoExpense;

  /// No description provided for @categoriesNoIncome.
  ///
  /// In en, this message translates to:
  /// **'No income categories yet.'**
  String get categoriesNoIncome;

  /// No description provided for @categoriesActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String categoriesActiveCount(int count);

  /// No description provided for @categoriesUnusedHeader.
  ///
  /// In en, this message translates to:
  /// **'UNUSED THIS MONTH · {count}'**
  String categoriesUnusedHeader(int count);

  /// No description provided for @categoriesUnused.
  ///
  /// In en, this message translates to:
  /// **'unused'**
  String get categoriesUnused;

  /// No description provided for @categoriesPercentSpend.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of spend'**
  String categoriesPercentSpend(String percent);

  /// No description provided for @editCategoryTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitleEdit;

  /// No description provided for @editCategoryTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get editCategoryTitleAdd;

  /// No description provided for @editCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editCategoryName;

  /// No description provided for @editCategoryUsedFor.
  ///
  /// In en, this message translates to:
  /// **'Used for'**
  String get editCategoryUsedFor;

  /// No description provided for @editCategoryColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get editCategoryColour;

  /// No description provided for @editCategoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get editCategoryIcon;

  /// No description provided for @editCategoryChartNote.
  ///
  /// In en, this message translates to:
  /// **'Chart bar colour is theme-managed for built-in categories.'**
  String get editCategoryChartNote;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsMonthStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Month Starts On'**
  String get settingsMonthStartsOn;

  /// No description provided for @settingsMonthStartDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}{ordinal}'**
  String settingsMonthStartDay(int day, String ordinal);

  /// No description provided for @settingsDaysFebNote.
  ///
  /// In en, this message translates to:
  /// **'Days 29–31 unavailable to ensure February compatibility.'**
  String get settingsDaysFebNote;

  /// No description provided for @settingsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get settingsNotSet;

  /// No description provided for @settingsManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get settingsManageCategories;

  /// No description provided for @settingsWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get settingsWallets;

  /// No description provided for @settingsManageWallets.
  ///
  /// In en, this message translates to:
  /// **'Manage Wallets'**
  String get settingsManageWallets;

  /// No description provided for @settingsAutomations.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get settingsAutomations;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsDeveloperTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get settingsDeveloperTools;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsResetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get settingsResetApp;

  /// No description provided for @settingsResetAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Erase all transactions and budgets, restore defaults'**
  String get settingsResetAppDesc;

  /// No description provided for @settingsSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get settingsSelectCurrency;

  /// No description provided for @settingsMonthStartOnDay.
  ///
  /// In en, this message translates to:
  /// **'Month Starts On Day…'**
  String get settingsMonthStartOnDay;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app?'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:\n  • All transactions\n  • All budgets\n  • All custom categories\n\nSettings will be restored to defaults and you will be signed out of Google. Sign in again afterwards to restore from a backup.\n\nThis cannot be undone.'**
  String get settingsResetMessage;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get settingsResetConfirm;

  /// No description provided for @settingsChangeStartDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Change start day?'**
  String get settingsChangeStartDayTitle;

  /// No description provided for @settingsChangeStartDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing from day {from} to day {to} will shift the period boundaries for all months. Existing transactions stay as-is.'**
  String settingsChangeStartDayMessage(int from, int to);

  /// No description provided for @settingsGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In'**
  String get settingsGoogleSignIn;

  /// No description provided for @settingsBackupToDrive.
  ///
  /// In en, this message translates to:
  /// **'Backup to Google Drive'**
  String get settingsBackupToDrive;

  /// No description provided for @settingsSignInForBackup.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up to the cloud'**
  String get settingsSignInForBackup;

  /// No description provided for @settingsLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time}'**
  String settingsLastBackup(String time);

  /// No description provided for @settingsNoBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No Backup Yet'**
  String get settingsNoBackupYet;

  /// No description provided for @settingsRestoreFromDrive.
  ///
  /// In en, this message translates to:
  /// **'Restore From Drive'**
  String get settingsRestoreFromDrive;

  /// No description provided for @settingsRestoreFromDriveDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace local data with Drive backup'**
  String get settingsRestoreFromDriveDesc;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to Google Drive.'**
  String get settingsBackupSaved;

  /// No description provided for @settingsBackupNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes since last backup — skipped.'**
  String get settingsBackupNoChanges;

  /// No description provided for @settingsBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String settingsBackupFailed(String error);

  /// No description provided for @settingsListBackupsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not list backups: {error}'**
  String settingsListBackupsFailed(String error);

  /// No description provided for @settingsNoBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup found in Google Drive.'**
  String get settingsNoBackupFound;

  /// No description provided for @settingsReplaceLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all local data?'**
  String get settingsReplaceLocalTitle;

  /// No description provided for @settingsReplaceLocalMessage.
  ///
  /// In en, this message translates to:
  /// **'Restoring from Google Drive will permanently delete everything currently on this device — all transactions, budgets, and categories — and replace it with the backup.\n\nThis cannot be undone.'**
  String get settingsReplaceLocalMessage;

  /// No description provided for @settingsReplaceMyData.
  ///
  /// In en, this message translates to:
  /// **'Replace my data'**
  String get settingsReplaceMyData;

  /// No description provided for @settingsDataRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored from Google Drive.'**
  String get settingsDataRestored;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String settingsRestoreFailed(String error);

  /// No description provided for @settingsSelectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select Backup to Restore'**
  String get settingsSelectBackup;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Save all data as a JSON file'**
  String get settingsExportBackupDesc;

  /// No description provided for @settingsRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore From File'**
  String get settingsRestoreFromFile;

  /// No description provided for @settingsRestoreFromFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace local data with an exported backup'**
  String get settingsRestoreFromFileDesc;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved {fileName}'**
  String settingsExportSuccess(String fileName);

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @settingsCannotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot read file: {error}'**
  String settingsCannotReadFile(String error);

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup?'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportFound.
  ///
  /// In en, this message translates to:
  /// **'Found:\n  • {transactions} transactions\n  • {budgets} budgets\n  • {categories} categories\n\nThis will replace all local data. This cannot be undone.'**
  String settingsImportFound(int transactions, int budgets, int categories);

  /// No description provided for @settingsImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImportConfirm;

  /// No description provided for @settingsImportDone.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} transactions successfully.'**
  String settingsImportDone(int count);

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailed(String error);

  /// No description provided for @settingsSmsRules.
  ///
  /// In en, this message translates to:
  /// **'SMS Rules'**
  String get settingsSmsRules;

  /// No description provided for @settingsSmsRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-create transactions from incoming messages'**
  String get settingsSmsRulesDesc;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsThemeAuto;

  /// No description provided for @settingsCarryOver.
  ///
  /// In en, this message translates to:
  /// **'Carry Over Unused Budget'**
  String get settingsCarryOver;

  /// No description provided for @settingsCarryOverDesc.
  ///
  /// In en, this message translates to:
  /// **'Surplus rolls into the next month'**
  String get settingsCarryOverDesc;

  /// No description provided for @settingsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get settingsJustNow;

  /// No description provided for @settingsMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String settingsMinutesAgo(int minutes);

  /// No description provided for @settingsHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String settingsHoursAgo(int hours);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// No description provided for @manageWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Wallets'**
  String get manageWalletsTitle;

  /// No description provided for @manageWalletsNone.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet.'**
  String get manageWalletsNone;

  /// No description provided for @manageWalletsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get manageWalletsAdd;

  /// No description provided for @manageWalletsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get manageWalletsEditTitle;

  /// No description provided for @manageWalletsName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get manageWalletsName;

  /// No description provided for @manageWalletsDefaultBudget.
  ///
  /// In en, this message translates to:
  /// **'Default monthly budget (optional)'**
  String get manageWalletsDefaultBudget;

  /// No description provided for @manageWalletsLeaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to disable'**
  String get manageWalletsLeaveEmpty;

  /// No description provided for @manageWalletsMonthStart.
  ///
  /// In en, this message translates to:
  /// **'Month starts on (optional)'**
  String get manageWalletsMonthStart;

  /// No description provided for @manageWalletsAppDefault.
  ///
  /// In en, this message translates to:
  /// **'App default'**
  String get manageWalletsAppDefault;

  /// No description provided for @manageWalletsDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String manageWalletsDay(int day);

  /// No description provided for @manageWalletsLeaveAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Leave as app default if not set'**
  String get manageWalletsLeaveAsDefault;

  /// No description provided for @manageWalletsDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default wallet'**
  String get manageWalletsDefaultLabel;

  /// No description provided for @manageWalletsSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get manageWalletsSetAsDefault;

  /// No description provided for @manageWalletsNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No default budget'**
  String get manageWalletsNoBudget;

  /// No description provided for @manageWalletsAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A wallet with this name already exists'**
  String get manageWalletsAlreadyExists;

  /// No description provided for @manageWalletsBudgetCarryOver.
  ///
  /// In en, this message translates to:
  /// **'{budget} · Carry-over on'**
  String manageWalletsBudgetCarryOver(String budget);

  /// No description provided for @manageWalletsCarryOverSuffix.
  ///
  /// In en, this message translates to:
  /// **'· Carry-over on'**
  String get manageWalletsCarryOverSuffix;

  /// No description provided for @smsRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Rules'**
  String get smsRulesTitle;

  /// No description provided for @smsRulesScanPast.
  ///
  /// In en, this message translates to:
  /// **'Scan past SMS'**
  String get smsRulesScanPast;

  /// No description provided for @smsRulesPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS permission required'**
  String get smsRulesPermissionTitle;

  /// No description provided for @smsRulesPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Grant access so incoming messages can be matched against your rules.'**
  String get smsRulesPermissionMessage;

  /// No description provided for @smsRulesNone.
  ///
  /// In en, this message translates to:
  /// **'No rules yet'**
  String get smsRulesNone;

  /// No description provided for @smsRulesNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a rule to automatically create transactions when you receive bank SMS messages.'**
  String get smsRulesNoneMessage;

  /// No description provided for @smsRulesAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first rule'**
  String get smsRulesAddFirst;

  /// No description provided for @smsRulesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete rule?'**
  String get smsRulesDeleteTitle;

  /// No description provided for @smsRulesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The rule for \"{keyword}\" will be deleted. Existing transactions it created will not be affected.'**
  String smsRulesDeleteMessage(String keyword);

  /// No description provided for @smsRulesImported.
  ///
  /// In en, this message translates to:
  /// **'Created {count} transactions on {date} — go back to the home screen to see them.'**
  String smsRulesImported(int count, String date);

  /// No description provided for @smsRulesNoImports.
  ///
  /// In en, this message translates to:
  /// **'No transactions imported.'**
  String get smsRulesNoImports;

  /// No description provided for @smsRuleFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get smsRuleFormTitleEdit;

  /// No description provided for @smsRuleFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Rule'**
  String get smsRuleFormTitleNew;

  /// No description provided for @smsRuleFormKeyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get smsRuleFormKeyword;

  /// No description provided for @smsRuleFormKeywordHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Carrefour, VODAFONE, Uber'**
  String get smsRuleFormKeywordHint;

  /// No description provided for @smsRuleFormKeywordHelper.
  ///
  /// In en, this message translates to:
  /// **'Case-insensitive match anywhere in the SMS body.'**
  String get smsRuleFormKeywordHelper;

  /// No description provided for @smsRuleFormLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Label'**
  String get smsRuleFormLabel;

  /// No description provided for @smsRuleFormLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gas, Coffee, Groceries (leave blank to use keyword)'**
  String get smsRuleFormLabelHint;

  /// No description provided for @smsRuleFormLabelHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown as the transaction description. Defaults to the keyword.'**
  String get smsRuleFormLabelHelper;

  /// No description provided for @smsRuleFormType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get smsRuleFormType;

  /// No description provided for @smsRuleFormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get smsRuleFormCategory;

  /// No description provided for @smsRuleFormSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get smsRuleFormSelectCategory;

  /// No description provided for @smsRuleFormWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get smsRuleFormWallet;

  /// No description provided for @smsRuleFormAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get smsRuleFormAdvanced;

  /// No description provided for @smsRuleFormCustomRegex.
  ///
  /// In en, this message translates to:
  /// **'Custom amount regex'**
  String get smsRuleFormCustomRegex;

  /// No description provided for @smsRuleFormRegexHint.
  ///
  /// In en, this message translates to:
  /// **'Amount regex (optional)'**
  String get smsRuleFormRegexHint;

  /// No description provided for @smsRuleFormRegexHelper.
  ///
  /// In en, this message translates to:
  /// **'Use capture group 1 to extract the amount. Leave empty to use built-in detection.'**
  String get smsRuleFormRegexHelper;

  /// No description provided for @smsRuleFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get smsRuleFormSaveChanges;

  /// No description provided for @smsRuleFormSaveNew.
  ///
  /// In en, this message translates to:
  /// **'Save Rule'**
  String get smsRuleFormSaveNew;

  /// No description provided for @smsRuleFormDeleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule'**
  String get smsRuleFormDeleteRule;

  /// No description provided for @smsRuleFormEnterKeyword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a keyword.'**
  String get smsRuleFormEnterKeyword;

  /// No description provided for @smsRuleFormSelectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get smsRuleFormSelectCategoryError;

  /// No description provided for @smsRuleFormDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The rule for \"{keyword}\" will be permanently deleted.'**
  String smsRuleFormDeleteMessage(String keyword);

  /// No description provided for @smsRuleFormSelectCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get smsRuleFormSelectCategoryTitle;

  /// No description provided for @smsScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan existing SMS'**
  String get smsScanTitle;

  /// No description provided for @smsScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply your active rules to messages already in your inbox.'**
  String get smsScanDesc;

  /// No description provided for @smsScanDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get smsScanDateRange;

  /// No description provided for @smsScan3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get smsScan3Days;

  /// No description provided for @smsScanCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get smsScanCustom;

  /// No description provided for @smsScanSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get smsScanSelectRange;

  /// No description provided for @smsScanPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'SMS permission is required to scan messages.'**
  String get smsScanPermissionRequired;

  /// No description provided for @smsScanScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning messages…'**
  String get smsScanScanning;

  /// No description provided for @smsScanNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get smsScanNoMatches;

  /// No description provided for @smsScanNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'No messages in this range matched your active rules.\nTry a wider range or check your rule keywords.'**
  String get smsScanNoMatchesMessage;

  /// No description provided for @smsScanTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try different range'**
  String get smsScanTryDifferent;

  /// No description provided for @smsScanMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} matches found'**
  String smsScanMatchesFound(int count);

  /// No description provided for @smsScanDupNote.
  ///
  /// In en, this message translates to:
  /// **'{count} already exist today — unchecked by default'**
  String smsScanDupNote(int count);

  /// No description provided for @smsScanImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import {count} transactions'**
  String smsScanImportButton(int count);

  /// No description provided for @smsScanNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected'**
  String get smsScanNothingSelected;

  /// No description provided for @smsScanEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get smsScanEditLabel;

  /// No description provided for @smsScanTransactionDesc.
  ///
  /// In en, this message translates to:
  /// **'Transaction description'**
  String get smsScanTransactionDesc;

  /// No description provided for @smsScanExists.
  ///
  /// In en, this message translates to:
  /// **'exists'**
  String get smsScanExists;

  /// No description provided for @smsScanDupWarning.
  ///
  /// In en, this message translates to:
  /// **'Transaction for this amount and category already exists on this day'**
  String get smsScanDupWarning;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'FELOOSY PRO'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything unlocked, once. No subscriptions.'**
  String get paywallSubtitle;

  /// No description provided for @paywallUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Forever — {price}'**
  String paywallUnlock(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get paywallRestore;

  /// No description provided for @paywallRestoreNote.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase · No recurring fees'**
  String get paywallRestoreNote;

  /// No description provided for @paywallTrialEnded.
  ///
  /// In en, this message translates to:
  /// **'Your 14-day free trial has ended'**
  String get paywallTrialEnded;

  /// No description provided for @paywallProUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Pro Unlocked'**
  String get paywallProUnlocked;

  /// No description provided for @paywallFeatureWallets.
  ///
  /// In en, this message translates to:
  /// **'Unlimited wallets'**
  String get paywallFeatureWallets;

  /// No description provided for @paywallFeatureTransactions.
  ///
  /// In en, this message translates to:
  /// **'Unlimited transactions'**
  String get paywallFeatureTransactions;

  /// No description provided for @paywallFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'Full transaction history'**
  String get paywallFeatureHistory;

  /// No description provided for @paywallFeatureBackup.
  ///
  /// In en, this message translates to:
  /// **'Google Drive backup'**
  String get paywallFeatureBackup;

  /// No description provided for @paywallFeatureExport.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get paywallFeatureExport;

  /// No description provided for @paywallFeatureCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom categories'**
  String get paywallFeatureCategories;

  /// No description provided for @paywallFeatureSms.
  ///
  /// In en, this message translates to:
  /// **'SMS auto-parsing (Android)'**
  String get paywallFeatureSms;

  /// No description provided for @paywallNoRestoreFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found for this account.'**
  String get paywallNoRestoreFound;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String paywallRestoreFailed(String error);

  /// No description provided for @tutorialStepOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String tutorialStepOf(int current, int total);

  /// No description provided for @tutorialGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get tutorialGetStarted;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FELOOSY'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your personal budget, beautifully simple.\nLet\'s take a quick tour of the key features.'**
  String get tutorialWelcomeMessage;

  /// No description provided for @tutorialBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get tutorialBudgetTitle;

  /// No description provided for @tutorialBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'This card shows your budget vs. spending for the month. Tap \"Set Budget\" to define your monthly limit.'**
  String get tutorialBudgetMessage;

  /// No description provided for @tutorialCarryoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Carry Over Surplus'**
  String get tutorialCarryoverTitle;

  /// No description provided for @tutorialCarryoverMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable carry-over in Settings → Manage Wallets for any wallet. Unused budget from last month rolls into this month automatically.'**
  String get tutorialCarryoverMessage;

  /// No description provided for @tutorialAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Transaction'**
  String get tutorialAddTitle;

  /// No description provided for @tutorialAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to record a purchase, bill, or income. Pick a category to see where your money goes.'**
  String get tutorialAddMessage;

  /// No description provided for @tutorialBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Past Months'**
  String get tutorialBrowseTitle;

  /// No description provided for @tutorialBrowseMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the arrows or swipe left/right on the home screen to review any previous month.'**
  String get tutorialBrowseMessage;

  /// No description provided for @tutorialSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & More'**
  String get tutorialSettingsTitle;

  /// No description provided for @tutorialSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Change currency, manage accounts, customise categories, and back up your data from here.'**
  String get tutorialSettingsMessage;

  /// No description provided for @tutorialDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get tutorialDoneTitle;

  /// No description provided for @tutorialDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first transaction. FELOOSY will track the rest.'**
  String get tutorialDoneMessage;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you begin'**
  String get consentTitle;

  /// No description provided for @consentDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get consentDataTitle;

  /// No description provided for @consentDataBody.
  ///
  /// In en, this message translates to:
  /// **'Transactions and budgets are stored locally in SQLite. We have no servers and cannot access your financial data.'**
  String get consentDataBody;

  /// No description provided for @consentBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional cloud backup'**
  String get consentBackupTitle;

  /// No description provided for @consentBackupBody.
  ///
  /// In en, this message translates to:
  /// **'You can connect Google Drive to back up your data. It goes to your own Drive folder — we never see it.'**
  String get consentBackupBody;

  /// No description provided for @consentReadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read Policy'**
  String get consentReadPolicy;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get consentAccept;

  /// No description provided for @smsOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS Auto Import'**
  String get smsOptInTitle;

  /// No description provided for @smsOptInBody.
  ///
  /// In en, this message translates to:
  /// **'FELOOSY can read bank SMS messages and create transactions automatically. Messages are matched locally — never stored as text or shared.'**
  String get smsOptInBody;

  /// No description provided for @smsOptInEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable SMS'**
  String get smsOptInEnable;

  /// No description provided for @smsOptInSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get smsOptInSkip;

  /// No description provided for @smsToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS Auto-Import'**
  String get smsToggleLabel;

  /// No description provided for @smsToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-create transactions from bank messages'**
  String get smsToggleSubtitle;

  /// No description provided for @smsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable SMS Auto-Import?'**
  String get smsTermsTitle;

  /// No description provided for @smsTermsBody.
  ///
  /// In en, this message translates to:
  /// **'FELOOSY will read incoming bank SMS messages and match them against your rules to create transactions automatically. Message text is never stored or shared. You can disable this anytime.'**
  String get smsTermsBody;

  /// No description provided for @smsTermsEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get smsTermsEnable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
