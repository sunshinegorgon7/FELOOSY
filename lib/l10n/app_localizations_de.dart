// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get done => 'Fertig';

  @override
  String get next => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get grant => 'Gewähren';

  @override
  String get change => 'Ändern';

  @override
  String get clear => 'Löschen';

  @override
  String get import => 'Importieren';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get expense => 'Ausgabe';

  @override
  String get income => 'Einnahme';

  @override
  String get both => 'Beides';

  @override
  String get recurring => 'Wiederkehrend';

  @override
  String get daily => 'Täglich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get annually => 'Jährlich';

  @override
  String get search => 'Suchen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get history => 'Verlauf';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Währung';

  @override
  String get categories => 'Kategorien';

  @override
  String get version => 'Version';

  @override
  String get auto => 'Auto';

  @override
  String get noCategory => 'Keine Kategorie';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get setBudget => 'Budget festlegen';

  @override
  String get homeSearchHint => 'Transaktionen suchen…';

  @override
  String get homeAllWallets => 'Alle Wallets';

  @override
  String get homeSwitchWallet => 'Wallet wechseln';

  @override
  String get homeWallet => 'Wallet';

  @override
  String get homePreviousMonth => 'Vorheriger Monat';

  @override
  String get homeNextMonth => 'Nächster Monat';

  @override
  String get homeTapReturnCurrentMonth =>
      'Tippen, um zum aktuellen Monat zurückzukehren';

  @override
  String get homeNoBudget => 'Kein Budget festgelegt.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'verbleibend diesen Monat · $percent% ausgegeben';
  }

  @override
  String homeOverBudget(int percent) {
    return 'über Budget · $percent% ausgegeben';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount vom letzten Monat übertragen';
  }

  @override
  String get homeNoTransactions =>
      'Noch keine Transaktionen.\nTippe auf + um eine hinzuzufügen.';

  @override
  String get homeNoTransactionsDay => 'Keine Transaktionen an diesem Tag.';

  @override
  String get homeNoTransactionsCategory =>
      'Keine Transaktionen in dieser\nKategorie für diesen Zeitraum.';

  @override
  String get homeByDay => 'Nach Tag';

  @override
  String get homeByCategory => 'Nach Kategorie';

  @override
  String get homeDeleteTitle => 'Transaktion löschen?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" wird dauerhaft gelöscht.';
  }

  @override
  String get homeSeeAll => 'Alle anzeigen';

  @override
  String get homeRecentTransactions => 'Letzte Transaktionen';

  @override
  String get budgetRemaining => 'verbleibend';

  @override
  String get budgetSpent => 'Ausgegeben';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% verwendet';
  }

  @override
  String get budgetNoSet => 'Noch kein Budget für diesen Monat festgelegt.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Budget für $period festlegen';
  }

  @override
  String get setBudgetHint =>
      'Dies ist der Gesamtbetrag, den Sie diesen Monat verfolgen möchten.';

  @override
  String get setBudgetAmount => 'Budgetbetrag';

  @override
  String get setBudgetEnterAmount => 'Betrag eingeben';

  @override
  String get setBudgetValidAmount => 'Gültigen Betrag eingeben';

  @override
  String get setBudgetSave => 'Budget speichern';

  @override
  String get historyMonth => 'Monat';

  @override
  String get historyYear => 'Jahr';

  @override
  String get transactionTitleEdit => 'Transaktion bearbeiten';

  @override
  String get transactionTitleNew => 'Neue Transaktion';

  @override
  String get transactionValidAmount => 'Gültigen Betrag eingeben.';

  @override
  String get transactionAddDescription => 'Beschreibung hinzufügen.';

  @override
  String get transactionSelectCategory => 'Kategorie auswählen.';

  @override
  String get transactionRepeats => 'Wiederholt sich';

  @override
  String get transactionDescription => 'Beschreibung';

  @override
  String get transactionFrequent => 'HÄUFIG';

  @override
  String get transactionNewCategory => 'Neu';

  @override
  String get transactionEnterCategoryName => 'Kategorienamen eingeben';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return '$fields hinzufügen um fortzufahren';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Regel: $keyword  •  Tippen zum Bearbeiten';
  }

  @override
  String get transactionDeleteTitle => 'Transaktion löschen?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" wird dauerhaft gelöscht.';
  }

  @override
  String get transactionDeleteRecurringTitle =>
      'Wiederkehrende Transaktion löschen';

  @override
  String get transactionDeleteRecurringQuestion => 'Wie möchten Sie löschen?';

  @override
  String get transactionDeleteOnlyThis => 'Nur diese';

  @override
  String get transactionDeleteThisAndFuture => 'Diese und zukünftige';

  @override
  String get categoriesNoExpense => 'Noch keine Ausgabenkategorien.';

  @override
  String get categoriesNoIncome => 'Noch keine Einnahmenkategorien.';

  @override
  String categoriesActiveCount(int count) {
    return '$count aktiv';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'DIESEN MONAT UNBENUTZT · $count';
  }

  @override
  String get categoriesUnused => 'unbenutzt';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% der Ausgaben';
  }

  @override
  String get editCategoryTitleEdit => 'Kategorie bearbeiten';

  @override
  String get editCategoryTitleAdd => 'Kategorie hinzufügen';

  @override
  String get editCategoryName => 'Name';

  @override
  String get editCategoryUsedFor => 'Verwendet für';

  @override
  String get editCategoryColour => 'Farbe';

  @override
  String get editCategoryIcon => 'Symbol';

  @override
  String get editCategoryChartNote =>
      'Balkenfarbe im Diagramm wird durch das Design für integrierte Kategorien verwaltet.';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsMonthStartsOn => 'Monat beginnt am';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Tag $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Tage 29–31 nicht verfügbar um Februar-Kompatibilität sicherzustellen.';

  @override
  String get settingsDefaultMonthlyBudget => 'Standard-Monatsbudget';

  @override
  String get settingsNotSet => 'Nicht festgelegt';

  @override
  String get settingsManageCategories => 'Kategorien verwalten';

  @override
  String get settingsWallets => 'Wallets';

  @override
  String get settingsManageWallets => 'Wallets verwalten';

  @override
  String get settingsAutomations => 'Automatisierungen';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get settingsDeveloperTools => 'Entwicklertools';

  @override
  String get settingsDangerZone => 'Gefahrenzone';

  @override
  String get settingsResetApp => 'App zurücksetzen';

  @override
  String get settingsResetAppDesc =>
      'Alle Transaktionen und Budgets löschen, Standardeinstellungen wiederherstellen';

  @override
  String get settingsSelectCurrency => 'Währung auswählen';

  @override
  String get settingsMonthStartOnDay => 'Monat beginnt an Tag…';

  @override
  String get settingsResetTitle => 'App zurücksetzen?';

  @override
  String get settingsResetMessage =>
      'Dies wird dauerhaft löschen:\n  • Alle Transaktionen\n  • Alle Budgets\n  • Alle benutzerdefinierten Kategorien\n\nEinstellungen werden auf Standard zurückgesetzt und Sie werden von Google abgemeldet. Melden Sie sich danach erneut an, um aus einer Sicherung wiederherzustellen.\n\nDies kann nicht rückgängig gemacht werden.';

  @override
  String get settingsResetConfirm => 'Alles zurücksetzen';

  @override
  String get settingsChangeStartDayTitle => 'Starttag ändern?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Das Ändern von Tag $from auf Tag $to verschiebt die Zeitraumgrenzen für alle Monate. Bestehende Transaktionen bleiben unverändert.';
  }

  @override
  String get settingsBackupToDrive => 'Auf Google Drive sichern';

  @override
  String get settingsSignInForBackup => 'Anmelden um Sicherung zu aktivieren';

  @override
  String settingsLastBackup(String time) {
    return 'Letzte Sicherung: $time';
  }

  @override
  String get settingsNoBackupYet => 'Noch keine Sicherung';

  @override
  String get settingsBackupNow => 'Jetzt sichern';

  @override
  String get settingsRestoreFromDrive => 'Von Drive wiederherstellen';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Lokale Daten durch Drive-Sicherung ersetzen';

  @override
  String get settingsSignOut => 'Abmelden';

  @override
  String get settingsBackupSaved => 'Sicherung auf Google Drive gespeichert.';

  @override
  String get settingsBackupNoChanges =>
      'Keine Änderungen seit letzter Sicherung — übersprungen.';

  @override
  String settingsBackupFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Sicherungen konnten nicht aufgelistet werden: $error';
  }

  @override
  String get settingsNoBackupFound =>
      'Keine Sicherung auf Google Drive gefunden.';

  @override
  String get settingsReplaceLocalTitle => 'Alle lokalen Daten ersetzen?';

  @override
  String get settingsReplaceLocalMessage =>
      'Die Wiederherstellung von Google Drive löscht dauerhaft alles auf diesem Gerät — alle Transaktionen, Budgets und Kategorien — und ersetzt sie durch die Sicherung.\n\nDies kann nicht rückgängig gemacht werden.';

  @override
  String get settingsReplaceMyData => 'Meine Daten ersetzen';

  @override
  String get settingsDataRestored =>
      'Daten von Google Drive wiederhergestellt.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get settingsSelectBackup =>
      'Sicherung zur Wiederherstellung auswählen';

  @override
  String get settingsExportBackup => 'Sicherung exportieren';

  @override
  String get settingsExportBackupDesc => 'Alle Daten als JSON-Datei speichern';

  @override
  String get settingsRestoreFromFile => 'Aus Datei wiederherstellen';

  @override
  String get settingsRestoreFromFileDesc =>
      'Lokale Daten durch exportierte Sicherung ersetzen';

  @override
  String settingsExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Datei kann nicht gelesen werden: $error';
  }

  @override
  String get settingsImportTitle => 'Sicherung importieren?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Gefunden:\n  • $transactions Transaktionen\n  • $budgets Budgets\n  • $categories Kategorien\n\nDies ersetzt alle lokalen Daten. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get settingsImportConfirm => 'Importieren';

  @override
  String settingsImportDone(int count) {
    return '$count Transaktionen erfolgreich importiert.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get settingsSmsRules => 'SMS-Regeln';

  @override
  String get settingsSmsRulesDesc =>
      'Automatisch Transaktionen aus eingehenden Nachrichten erstellen';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsCarryOver => 'Ungenutztes Budget übertragen';

  @override
  String get settingsCarryOverDesc =>
      'Überschuss wird auf den nächsten Monat übertragen';

  @override
  String get settingsDefaultBudgetApplied =>
      'Wird automatisch angewendet, wenn kein Budget für den aktuellen Monat festgelegt wurde.';

  @override
  String get settingsJustNow => 'Gerade eben';

  @override
  String settingsMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String settingsHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSelectLanguage => 'Sprache auswählen';

  @override
  String get manageWalletsTitle => 'Wallets verwalten';

  @override
  String get manageWalletsNone => 'Noch keine Wallets.';

  @override
  String get manageWalletsAdd => 'Wallet hinzufügen';

  @override
  String get manageWalletsEditTitle => 'Wallet bearbeiten';

  @override
  String get manageWalletsName => 'Wallet-Name';

  @override
  String get manageWalletsDefaultBudget => 'Standard-Monatsbudget (optional)';

  @override
  String get manageWalletsLeaveEmpty => 'Leer lassen zum Deaktivieren';

  @override
  String get manageWalletsMonthStart => 'Monat beginnt am (optional)';

  @override
  String get manageWalletsAppDefault => 'App-Standard';

  @override
  String manageWalletsDay(int day) {
    return 'Tag $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Als App-Standard belassen wenn nicht gesetzt';

  @override
  String get manageWalletsDefaultLabel => 'Standard-Wallet';

  @override
  String get manageWalletsSetAsDefault => 'Als Standard festlegen';

  @override
  String get manageWalletsNoBudget => 'Kein Standardbudget';

  @override
  String get manageWalletsAlreadyExists =>
      'Ein Wallet mit diesem Namen existiert bereits';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Übertrag aktiv';
  }

  @override
  String get smsRulesTitle => 'SMS-Regeln';

  @override
  String get smsRulesScanPast => 'Vergangene SMS scannen';

  @override
  String get smsRulesPermissionTitle => 'SMS-Berechtigung erforderlich';

  @override
  String get smsRulesPermissionMessage =>
      'Gewähren Sie Zugriff damit eingehende Nachrichten mit Ihren Regeln abgeglichen werden können.';

  @override
  String get smsRulesNone => 'Noch keine Regeln';

  @override
  String get smsRulesNoneMessage =>
      'Fügen Sie eine Regel hinzu, um automatisch Transaktionen beim Empfang von Bank-SMS zu erstellen.';

  @override
  String get smsRulesAddFirst => 'Erste Regel hinzufügen';

  @override
  String get smsRulesDeleteTitle => 'Regel löschen?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'Die Regel für \"$keyword\" wird gelöscht. Erstellte Transaktionen werden nicht beeinflusst.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$count Transaktionen am $date erstellt — gehen Sie zum Startbildschirm um sie zu sehen.';
  }

  @override
  String get smsRulesNoImports => 'Keine Transaktionen importiert.';

  @override
  String get smsRuleFormTitleEdit => 'Regel bearbeiten';

  @override
  String get smsRuleFormTitleNew => 'Neue Regel';

  @override
  String get smsRuleFormKeyword => 'Schlüsselwort';

  @override
  String get smsRuleFormKeywordHint => 'z.B. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Groß-/Kleinschreibung-unabhängige Übereinstimmung überall im SMS-Text.';

  @override
  String get smsRuleFormLabel => 'Transaktionsbezeichnung';

  @override
  String get smsRuleFormLabelHint =>
      'z.B. Tankstelle, Kaffee, Lebensmittel (leer lassen für Schlüsselwort)';

  @override
  String get smsRuleFormLabelHelper =>
      'Wird als Transaktionsbeschreibung angezeigt. Standard ist das Schlüsselwort.';

  @override
  String get smsRuleFormType => 'Transaktionstyp';

  @override
  String get smsRuleFormCategory => 'Kategorie';

  @override
  String get smsRuleFormSelectCategory => 'Kategorie auswählen';

  @override
  String get smsRuleFormWallet => 'Wallet';

  @override
  String get smsRuleFormAdvanced => 'Erweitert';

  @override
  String get smsRuleFormCustomRegex => 'Benutzerdefinierter Betrag-Regex';

  @override
  String get smsRuleFormRegexHint => 'Betrag-Regex (optional)';

  @override
  String get smsRuleFormRegexHelper =>
      'Verwenden Sie Erfassungsgruppe 1 um den Betrag zu extrahieren. Leer lassen für integrierte Erkennung.';

  @override
  String get smsRuleFormSaveChanges => 'Änderungen speichern';

  @override
  String get smsRuleFormSaveNew => 'Regel speichern';

  @override
  String get smsRuleFormDeleteRule => 'Regel löschen';

  @override
  String get smsRuleFormEnterKeyword => 'Bitte Schlüsselwort eingeben.';

  @override
  String get smsRuleFormSelectCategoryError => 'Bitte Kategorie auswählen.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'Die Regel für \"$keyword\" wird dauerhaft gelöscht.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Kategorie auswählen';

  @override
  String get smsScanTitle => 'Vorhandene SMS scannen';

  @override
  String get smsScanDesc =>
      'Ihre aktiven Regeln auf Nachrichten in Ihrem Posteingang anwenden.';

  @override
  String get smsScanDateRange => 'Datumsbereich';

  @override
  String get smsScan3Days => '3 Tage';

  @override
  String get smsScan7Days => '7 Tage';

  @override
  String get smsScan30Days => '30 Tage';

  @override
  String get smsScanCustom => 'Benutzerdefiniert…';

  @override
  String get smsScanSelectRange => 'Datumsbereich auswählen';

  @override
  String get smsScanPermissionRequired =>
      'SMS-Berechtigung ist erforderlich um Nachrichten zu scannen.';

  @override
  String get smsScanScanning => 'Nachrichten werden gescannt…';

  @override
  String get smsScanNoMatches => 'Keine Treffer gefunden';

  @override
  String get smsScanNoMatchesMessage =>
      'Keine Nachrichten in diesem Bereich entsprechen Ihren aktiven Regeln.\nVersuchen Sie einen größeren Bereich oder überprüfen Sie Ihre Schlüsselwörter.';

  @override
  String get smsScanTryDifferent => 'Anderen Bereich versuchen';

  @override
  String smsScanMatchesFound(int count) {
    return '$count Treffer gefunden';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count existieren heute bereits — standardmäßig nicht ausgewählt';
  }

  @override
  String smsScanImportButton(int count) {
    return '$count Transaktionen importieren';
  }

  @override
  String get smsScanNothingSelected => 'Nichts ausgewählt';

  @override
  String get smsScanEditLabel => 'Bezeichnung bearbeiten';

  @override
  String get smsScanTransactionDesc => 'Transaktionsbeschreibung';

  @override
  String get smsScanExists => 'vorhanden';

  @override
  String get smsScanDupWarning =>
      'Eine Transaktion für diesen Betrag und diese Kategorie existiert bereits an diesem Tag';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle =>
      'Alles freigeschaltet, einmalig. Keine Abonnements.';

  @override
  String paywallUnlock(String price) {
    return 'Für immer freischalten — $price';
  }

  @override
  String get paywallRestore => 'Kauf wiederherstellen';

  @override
  String get paywallRestoreNote => 'Einmalige Zahlung · Keine laufenden Kosten';

  @override
  String get paywallTrialEnded =>
      'Ihre 14-tägige kostenlose Testphase ist abgelaufen';

  @override
  String get paywallProUnlocked => 'Pro freigeschaltet';

  @override
  String get paywallFeatureWallets => 'Unbegrenzte Wallets';

  @override
  String get paywallFeatureTransactions => 'Unbegrenzte Transaktionen';

  @override
  String get paywallFeatureHistory => 'Vollständiger Transaktionsverlauf';

  @override
  String get paywallFeatureBackup => 'Google Drive-Sicherung';

  @override
  String get paywallFeatureExport => 'Daten exportieren';

  @override
  String get paywallFeatureCategories => 'Benutzerdefinierte Kategorien';

  @override
  String get paywallFeatureSms => 'Automatische SMS-Auswertung (Android)';

  @override
  String get paywallNoRestoreFound =>
      'Kein früherer Kauf für dieses Konto gefunden.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current von $total';
  }

  @override
  String get tutorialGetStarted => 'Loslegen';

  @override
  String get tutorialWelcomeTitle => 'Willkommen bei FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'Ihr persönliches Budget, wunderschön einfach.\nLassen Sie uns die wichtigsten Funktionen kurz vorstellen.';

  @override
  String get tutorialBudgetTitle => 'Monatsbudget';

  @override
  String get tutorialBudgetMessage =>
      'Diese Karte zeigt Ihr Budget gegenüber den Ausgaben des Monats. Tippen Sie auf \"Budget festlegen\" um Ihr monatliches Limit zu definieren.';

  @override
  String get tutorialCarryoverTitle => 'Überschuss übertragen';

  @override
  String get tutorialCarryoverMessage =>
      'Aktivieren Sie den Übertrag in Einstellungen → Wallets verwalten für jedes Wallet. Ungenutztes Budget vom letzten Monat wird automatisch auf diesen Monat übertragen.';

  @override
  String get tutorialAddTitle => 'Transaktion hinzufügen';

  @override
  String get tutorialAddMessage =>
      'Tippen Sie auf + um einen Kauf, eine Rechnung oder Einnahme zu erfassen. Wählen Sie eine Kategorie um zu sehen wohin Ihr Geld fließt.';

  @override
  String get tutorialBrowseTitle => 'Vergangene Monate durchsuchen';

  @override
  String get tutorialBrowseMessage =>
      'Tippen Sie auf die Pfeile oder wischen Sie links/rechts auf dem Startbildschirm um beliebige vergangene Monate anzuzeigen.';

  @override
  String get tutorialSettingsTitle => 'Einstellungen und mehr';

  @override
  String get tutorialSettingsMessage =>
      'Währung ändern, Konten verwalten, Kategorien anpassen und Daten sichern — alles hier.';

  @override
  String get tutorialDoneTitle => 'Alles bereit!';

  @override
  String get tutorialDoneMessage =>
      'Beginnen Sie mit Ihrer ersten Transaktion. FELOOSY erledigt den Rest.';

  @override
  String get privacyTitle => 'Bevor Sie beginnen';

  @override
  String get privacySmsTitle => 'Automatische SMS-Erkennung';

  @override
  String get privacySmsMessage =>
      'Wenn Sie SMS-Berechtigung gewähren, werden eingehende Banknachrichten im Speicher mit Ihren Regeln abgeglichen. Der Nachrichtentext wird niemals gespeichert oder geteilt.';

  @override
  String get privacyDataTitle => 'Ihre Daten bleiben auf Ihrem Gerät';

  @override
  String get privacyDataMessage =>
      'Transaktionen und Budgets werden lokal gespeichert. Wir haben keine Server und können Ihre Finanzdaten nicht einsehen.';

  @override
  String get privacyAiTitle => 'KI-Analyse (optional)';

  @override
  String get privacyAiMessage =>
      'Wenn Sie die KI-Funktion nutzen, werden anonymisierte Ausgabenzusammenfassungen (Kategorietotale, keine rohen SMS) an Google Gemini gesendet.';

  @override
  String get privacyReadPolicy => 'Vollständige Richtlinie lesen';

  @override
  String get privacyAccept => 'Akzeptieren und fortfahren';
}
