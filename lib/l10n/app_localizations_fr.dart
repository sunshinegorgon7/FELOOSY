// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get done => 'Terminé';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Ignorer';

  @override
  String get grant => 'Accorder';

  @override
  String get change => 'Modifier';

  @override
  String get clear => 'Effacer';

  @override
  String get import => 'Importer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get expense => 'Dépense';

  @override
  String get income => 'Revenu';

  @override
  String get both => 'Les deux';

  @override
  String get recurring => 'Récurrent';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get annually => 'Annuel';

  @override
  String get search => 'Rechercher';

  @override
  String get settings => 'Paramètres';

  @override
  String get history => 'Historique';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Devise';

  @override
  String get categories => 'Catégories';

  @override
  String get version => 'Version';

  @override
  String get auto => 'Auto';

  @override
  String get noCategory => 'Sans catégorie';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get setBudget => 'Définir le budget';

  @override
  String get homeSearchHint => 'Rechercher des transactions…';

  @override
  String get homeAllWallets => 'Tous les portefeuilles';

  @override
  String get homeSwitchWallet => 'Changer de portefeuille';

  @override
  String get homeWallet => 'Portefeuille';

  @override
  String get homePreviousMonth => 'Mois précédent';

  @override
  String get homeNextMonth => 'Mois suivant';

  @override
  String get homeTapReturnCurrentMonth => 'Appuyez pour revenir au mois actuel';

  @override
  String get homeNoBudget => 'Aucun budget défini.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'restant ce mois · $percent% dépensé';
  }

  @override
  String homeOverBudget(int percent) {
    return 'au-dessus du budget · $percent% dépensé';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount reporté du mois dernier';
  }

  @override
  String get homeNoTransactions =>
      'Aucune transaction pour l\'instant.\nAppuyez sur + pour en ajouter une.';

  @override
  String get homeNoTransactionsDay => 'Aucune transaction ce jour.';

  @override
  String get homeNoTransactionsCategory =>
      'Aucune transaction dans cette\ncatégorie pour cette période.';

  @override
  String get homeByDay => 'Par jour';

  @override
  String get homeByCategory => 'Par catégorie';

  @override
  String get homeDeleteTitle => 'Supprimer la transaction ?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" sera définitivement supprimé.';
  }

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeRecentTransactions => 'Transactions récentes';

  @override
  String get budgetRemaining => 'restant';

  @override
  String get budgetSpent => 'Dépensé';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% utilisé';
  }

  @override
  String get budgetNoSet => 'Aucun budget défini pour ce mois.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Définir le budget pour $period';
  }

  @override
  String get setBudgetHint =>
      'C\'est le montant total que vous souhaitez suivre ce mois.';

  @override
  String get setBudgetAmount => 'Montant du budget';

  @override
  String get setBudgetEnterAmount => 'Entrez un montant';

  @override
  String get setBudgetValidAmount => 'Entrez un montant valide';

  @override
  String get setBudgetSave => 'Enregistrer le budget';

  @override
  String get historyMonth => 'Mois';

  @override
  String get historyYear => 'Année';

  @override
  String get transactionTitleEdit => 'Modifier la transaction';

  @override
  String get transactionTitleNew => 'Nouvelle transaction';

  @override
  String get transactionValidAmount => 'Entrez un montant valide.';

  @override
  String get transactionAddDescription => 'Ajoutez une description.';

  @override
  String get transactionSelectCategory => 'Sélectionnez une catégorie.';

  @override
  String get transactionRepeats => 'Se répète';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionFrequent => 'FRÉQUENT';

  @override
  String get transactionNewCategory => 'Nouveau';

  @override
  String get transactionEnterCategoryName => 'Entrez un nom de catégorie';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Ajoutez $fields pour continuer';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Règle : $keyword  •  appuyez pour modifier';
  }

  @override
  String get transactionDeleteTitle => 'Supprimer la transaction ?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" sera définitivement supprimé.';
  }

  @override
  String get transactionDeleteRecurringTitle =>
      'Supprimer la transaction récurrente';

  @override
  String get transactionDeleteRecurringQuestion =>
      'Comment souhaitez-vous supprimer ?';

  @override
  String get transactionDeleteOnlyThis => 'Seulement celle-ci';

  @override
  String get transactionDeleteThisAndFuture => 'Celle-ci et les suivantes';

  @override
  String get categoriesNoExpense =>
      'Aucune catégorie de dépense pour l\'instant.';

  @override
  String get categoriesNoIncome =>
      'Aucune catégorie de revenu pour l\'instant.';

  @override
  String categoriesActiveCount(int count) {
    return '$count active(s)';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'INUTILISÉES CE MOIS · $count';
  }

  @override
  String get categoriesUnused => 'inutilisée';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% des dépenses';
  }

  @override
  String get editCategoryTitleEdit => 'Modifier la catégorie';

  @override
  String get editCategoryTitleAdd => 'Ajouter une catégorie';

  @override
  String get editCategoryName => 'Nom';

  @override
  String get editCategoryUsedFor => 'Utilisée pour';

  @override
  String get editCategoryColour => 'Couleur';

  @override
  String get editCategoryIcon => 'Icône';

  @override
  String get editCategoryChartNote =>
      'La couleur de la barre du graphique est gérée par le thème pour les catégories intégrées.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsMonthStartsOn => 'Le mois commence le';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Jour $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Les jours 29-31 sont indisponibles pour assurer la compatibilité avec février.';

  @override
  String get settingsDefaultMonthlyBudget => 'Budget mensuel par défaut';

  @override
  String get settingsNotSet => 'Non défini';

  @override
  String get settingsManageCategories => 'Gérer les catégories';

  @override
  String get settingsWallets => 'Portefeuilles';

  @override
  String get settingsManageWallets => 'Gérer les portefeuilles';

  @override
  String get settingsAutomations => 'Automatisations';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsDeveloperTools => 'Outils développeur';

  @override
  String get settingsDangerZone => 'Zone de danger';

  @override
  String get settingsResetApp => 'Réinitialiser l\'application';

  @override
  String get settingsResetAppDesc =>
      'Effacer toutes les transactions et budgets, restaurer les valeurs par défaut';

  @override
  String get settingsSelectCurrency => 'Sélectionner la devise';

  @override
  String get settingsMonthStartOnDay => 'Le mois commence le jour…';

  @override
  String get settingsResetTitle => 'Réinitialiser l\'application ?';

  @override
  String get settingsResetMessage =>
      'Cela supprimera définitivement :\n  • Toutes les transactions\n  • Tous les budgets\n  • Toutes les catégories personnalisées\n\nLes paramètres seront restaurés par défaut et vous serez déconnecté de Google. Reconnectez-vous ensuite pour restaurer depuis une sauvegarde.\n\nCette action est irréversible.';

  @override
  String get settingsResetConfirm => 'Tout réinitialiser';

  @override
  String get settingsChangeStartDayTitle => 'Changer le jour de début ?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Passer du jour $from au jour $to décalera les limites de période pour tous les mois. Les transactions existantes restent inchangées.';
  }

  @override
  String get settingsBackupToDrive => 'Sauvegarder sur Google Drive';

  @override
  String get settingsSignInForBackup =>
      'Connectez-vous pour activer la sauvegarde';

  @override
  String settingsLastBackup(String time) {
    return 'Dernière sauvegarde : $time';
  }

  @override
  String get settingsNoBackupYet => 'Aucune sauvegarde pour l\'instant';

  @override
  String get settingsBackupNow => 'Sauvegarder maintenant';

  @override
  String get settingsRestoreFromDrive => 'Restaurer depuis Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Remplacer les données locales par la sauvegarde Drive';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsBackupSaved => 'Sauvegarde enregistrée sur Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'Aucun changement depuis la dernière sauvegarde — ignoré.';

  @override
  String settingsBackupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Impossible de lister les sauvegardes : $error';
  }

  @override
  String get settingsNoBackupFound =>
      'Aucune sauvegarde trouvée sur Google Drive.';

  @override
  String get settingsReplaceLocalTitle =>
      'Remplacer toutes les données locales ?';

  @override
  String get settingsReplaceLocalMessage =>
      'La restauration depuis Google Drive supprimera définitivement tout sur cet appareil — toutes les transactions, budgets et catégories — et les remplacera par la sauvegarde.\n\nCette action est irréversible.';

  @override
  String get settingsReplaceMyData => 'Remplacer mes données';

  @override
  String get settingsDataRestored => 'Données restaurées depuis Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get settingsSelectBackup => 'Sélectionner la sauvegarde à restaurer';

  @override
  String get settingsExportBackup => 'Exporter la sauvegarde';

  @override
  String get settingsExportBackupDesc =>
      'Enregistrer toutes les données en fichier JSON';

  @override
  String get settingsRestoreFromFile => 'Restaurer depuis un fichier';

  @override
  String get settingsRestoreFromFileDesc =>
      'Remplacer les données locales par une sauvegarde exportée';

  @override
  String settingsExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Impossible de lire le fichier : $error';
  }

  @override
  String get settingsImportTitle => 'Importer la sauvegarde ?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Trouvé :\n  • $transactions transactions\n  • $budgets budgets\n  • $categories catégories\n\nCela remplacera toutes les données locales. Cette action est irréversible.';
  }

  @override
  String get settingsImportConfirm => 'Importer';

  @override
  String settingsImportDone(int count) {
    return '$count transactions importées avec succès.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get settingsSmsRules => 'Règles SMS';

  @override
  String get settingsSmsRulesDesc =>
      'Créer automatiquement des transactions depuis les messages entrants';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsCarryOver => 'Reporter le budget inutilisé';

  @override
  String get settingsCarryOverDesc => 'Le surplus est reporté au mois suivant';

  @override
  String get settingsDefaultBudgetApplied =>
      'Appliqué automatiquement quand aucun budget n\'est défini pour le mois en cours.';

  @override
  String get settingsJustNow => 'À l\'instant';

  @override
  String settingsMinutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String settingsHoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSelectLanguage => 'Sélectionner la langue';

  @override
  String get manageWalletsTitle => 'Gérer les portefeuilles';

  @override
  String get manageWalletsNone => 'Aucun portefeuille pour l\'instant.';

  @override
  String get manageWalletsAdd => 'Ajouter un portefeuille';

  @override
  String get manageWalletsEditTitle => 'Modifier le portefeuille';

  @override
  String get manageWalletsName => 'Nom du portefeuille';

  @override
  String get manageWalletsDefaultBudget =>
      'Budget mensuel par défaut (optionnel)';

  @override
  String get manageWalletsLeaveEmpty => 'Laisser vide pour désactiver';

  @override
  String get manageWalletsMonthStart => 'Le mois commence le (optionnel)';

  @override
  String get manageWalletsAppDefault => 'Défaut de l\'application';

  @override
  String manageWalletsDay(int day) {
    return 'Jour $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Laisser comme défaut de l\'app si non défini';

  @override
  String get manageWalletsDefaultLabel => 'Portefeuille par défaut';

  @override
  String get manageWalletsSetAsDefault => 'Définir par défaut';

  @override
  String get manageWalletsNoBudget => 'Pas de budget par défaut';

  @override
  String get manageWalletsAlreadyExists =>
      'Un portefeuille avec ce nom existe déjà';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Report activé';
  }

  @override
  String get smsRulesTitle => 'Règles SMS';

  @override
  String get smsRulesScanPast => 'Analyser les SMS passés';

  @override
  String get smsRulesPermissionTitle => 'Permission SMS requise';

  @override
  String get smsRulesPermissionMessage =>
      'Accordez l\'accès pour que les messages entrants puissent être comparés à vos règles.';

  @override
  String get smsRulesNone => 'Aucune règle pour l\'instant';

  @override
  String get smsRulesNoneMessage =>
      'Ajoutez une règle pour créer automatiquement des transactions lors de la réception de SMS bancaires.';

  @override
  String get smsRulesAddFirst => 'Ajouter la première règle';

  @override
  String get smsRulesDeleteTitle => 'Supprimer la règle ?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'La règle pour \"$keyword\" sera supprimée. Les transactions créées ne seront pas affectées.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$count transactions créées le $date — retournez à l\'écran d\'accueil pour les voir.';
  }

  @override
  String get smsRulesNoImports => 'Aucune transaction importée.';

  @override
  String get smsRuleFormTitleEdit => 'Modifier la règle';

  @override
  String get smsRuleFormTitleNew => 'Nouvelle règle';

  @override
  String get smsRuleFormKeyword => 'Mot-clé';

  @override
  String get smsRuleFormKeywordHint => 'ex. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Correspondance insensible à la casse n\'importe où dans le corps du SMS.';

  @override
  String get smsRuleFormLabel => 'Libellé de transaction';

  @override
  String get smsRuleFormLabelHint =>
      'ex. Essence, Café, Courses (laisser vide pour utiliser le mot-clé)';

  @override
  String get smsRuleFormLabelHelper =>
      'Affiché comme description de la transaction. Par défaut le mot-clé.';

  @override
  String get smsRuleFormType => 'Type de transaction';

  @override
  String get smsRuleFormCategory => 'Catégorie';

  @override
  String get smsRuleFormSelectCategory => 'Sélectionner une catégorie';

  @override
  String get smsRuleFormWallet => 'Portefeuille';

  @override
  String get smsRuleFormAdvanced => 'Avancé';

  @override
  String get smsRuleFormCustomRegex =>
      'Expression régulière personnalisée pour le montant';

  @override
  String get smsRuleFormRegexHint => 'Regex du montant (optionnel)';

  @override
  String get smsRuleFormRegexHelper =>
      'Utilisez le groupe de capture 1 pour extraire le montant. Laisser vide pour utiliser la détection intégrée.';

  @override
  String get smsRuleFormSaveChanges => 'Enregistrer les modifications';

  @override
  String get smsRuleFormSaveNew => 'Enregistrer la règle';

  @override
  String get smsRuleFormDeleteRule => 'Supprimer la règle';

  @override
  String get smsRuleFormEnterKeyword => 'Veuillez entrer un mot-clé.';

  @override
  String get smsRuleFormSelectCategoryError =>
      'Veuillez sélectionner une catégorie.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'La règle pour \"$keyword\" sera définitivement supprimée.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Sélectionner la catégorie';

  @override
  String get smsScanTitle => 'Analyser les SMS existants';

  @override
  String get smsScanDesc =>
      'Appliquer vos règles actives aux messages déjà dans votre boîte de réception.';

  @override
  String get smsScanDateRange => 'Plage de dates';

  @override
  String get smsScan3Days => '3 jours';

  @override
  String get smsScan7Days => '7 jours';

  @override
  String get smsScan30Days => '30 jours';

  @override
  String get smsScanCustom => 'Personnalisé…';

  @override
  String get smsScanSelectRange => 'Sélectionner la plage de dates';

  @override
  String get smsScanPermissionRequired =>
      'La permission SMS est requise pour analyser les messages.';

  @override
  String get smsScanScanning => 'Analyse des messages…';

  @override
  String get smsScanNoMatches => 'Aucune correspondance';

  @override
  String get smsScanNoMatchesMessage =>
      'Aucun message dans cette plage ne correspond à vos règles actives.\nEssayez une plage plus large ou vérifiez vos mots-clés.';

  @override
  String get smsScanTryDifferent => 'Essayer une plage différente';

  @override
  String smsScanMatchesFound(int count) {
    return '$count correspondances trouvées';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count existent déjà aujourd\'hui — décochées par défaut';
  }

  @override
  String smsScanImportButton(int count) {
    return 'Importer $count transactions';
  }

  @override
  String get smsScanNothingSelected => 'Rien sélectionné';

  @override
  String get smsScanEditLabel => 'Modifier le libellé';

  @override
  String get smsScanTransactionDesc => 'Description de la transaction';

  @override
  String get smsScanExists => 'existe';

  @override
  String get smsScanDupWarning =>
      'Une transaction pour ce montant et cette catégorie existe déjà ce jour';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle =>
      'Tout débloqué, une fois pour toutes. Aucun abonnement.';

  @override
  String paywallUnlock(String price) {
    return 'Débloquer à vie — $price';
  }

  @override
  String get paywallRestore => 'Restaurer l\'achat';

  @override
  String get paywallRestoreNote => 'Achat unique · Aucun frais récurrent';

  @override
  String get paywallTrialEnded => 'Votre essai gratuit de 14 jours est terminé';

  @override
  String get paywallProUnlocked => 'Pro débloqué';

  @override
  String get paywallFeatureWallets => 'Portefeuilles illimités';

  @override
  String get paywallFeatureTransactions => 'Transactions illimitées';

  @override
  String get paywallFeatureHistory => 'Historique complet des transactions';

  @override
  String get paywallFeatureBackup => 'Sauvegarde Google Drive';

  @override
  String get paywallFeatureExport => 'Exporter vos données';

  @override
  String get paywallFeatureCategories => 'Catégories personnalisées';

  @override
  String get paywallFeatureSms => 'Analyse automatique SMS (Android)';

  @override
  String get paywallNoRestoreFound =>
      'Aucun achat précédent trouvé pour ce compte.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get tutorialGetStarted => 'Commencer';

  @override
  String get tutorialWelcomeTitle => 'Bienvenue dans FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'Votre budget personnel, d\'une simplicité élégante.\nFaisons un tour rapide des fonctionnalités clés.';

  @override
  String get tutorialBudgetTitle => 'Budget mensuel';

  @override
  String get tutorialBudgetMessage =>
      'Cette carte affiche votre budget par rapport à vos dépenses du mois. Appuyez sur \"Définir le budget\" pour fixer votre limite mensuelle.';

  @override
  String get tutorialCarryoverTitle => 'Reporter le surplus';

  @override
  String get tutorialCarryoverMessage =>
      'Activez le report dans Paramètres → Gérer les portefeuilles pour chaque portefeuille. Le budget inutilisé du mois dernier est automatiquement ajouté à ce mois.';

  @override
  String get tutorialAddTitle => 'Ajouter une transaction';

  @override
  String get tutorialAddMessage =>
      'Appuyez sur le bouton + pour enregistrer un achat, une facture ou un revenu. Choisissez une catégorie pour voir où va votre argent.';

  @override
  String get tutorialBrowseTitle => 'Parcourir les mois précédents';

  @override
  String get tutorialBrowseMessage =>
      'Appuyez sur les flèches ou glissez gauche/droite sur l\'écran d\'accueil pour consulter n\'importe quel mois précédent.';

  @override
  String get tutorialSettingsTitle => 'Paramètres et plus';

  @override
  String get tutorialSettingsMessage =>
      'Changez la devise, gérez les comptes, personnalisez les catégories et sauvegardez vos données depuis ici.';

  @override
  String get tutorialDoneTitle => 'Vous êtes prêt !';

  @override
  String get tutorialDoneMessage =>
      'Commencez par ajouter votre première transaction. FELOOSY s\'occupera du reste.';

  @override
  String get privacyTitle => 'Avant de commencer';

  @override
  String get privacySmsTitle => 'Détection automatique des SMS';

  @override
  String get privacySmsMessage =>
      'Si vous accordez la permission SMS, les messages bancaires entrants sont comparés à vos règles en mémoire. Le texte du message n\'est jamais enregistré ni partagé.';

  @override
  String get privacyDataTitle => 'Vos données restent sur votre appareil';

  @override
  String get privacyDataMessage =>
      'Les transactions et les budgets sont stockés localement. Nous n\'avons pas de serveurs et ne pouvons pas voir vos données financières.';

  @override
  String get privacyAiTitle => 'Analyse par IA (optionnel)';

  @override
  String get privacyAiMessage =>
      'Si vous utilisez la fonctionnalité IA, des résumés de dépenses anonymisés (totaux par catégorie, sans SMS bruts) sont envoyés à Google Gemini.';

  @override
  String get privacyReadPolicy => 'Lire la politique complète';

  @override
  String get privacyAccept => 'Accepter et continuer';
}
