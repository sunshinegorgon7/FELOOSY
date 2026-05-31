// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get done => 'Tamam';

  @override
  String get next => 'İleri';

  @override
  String get skip => 'Atla';

  @override
  String get grant => 'İzin Ver';

  @override
  String get change => 'Değiştir';

  @override
  String get clear => 'Temizle';

  @override
  String get import => 'İçe Aktar';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get expense => 'Gider';

  @override
  String get income => 'Gelir';

  @override
  String get both => 'Her ikisi';

  @override
  String get recurring => 'Tekrarlayan';

  @override
  String get daily => 'Günlük';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get annually => 'Yıllık';

  @override
  String get search => 'Ara';

  @override
  String get settings => 'Ayarlar';

  @override
  String get history => 'Geçmiş';

  @override
  String get budget => 'Bütçe';

  @override
  String get currency => 'Para birimi';

  @override
  String get categories => 'Kategoriler';

  @override
  String get version => 'Sürüm';

  @override
  String get auto => 'Otomatik';

  @override
  String get noCategory => 'Kategori yok';

  @override
  String get selectCategory => 'Kategori seç';

  @override
  String get setBudget => 'Bütçe Belirle';

  @override
  String get homeSearchHint => 'İşlem ara…';

  @override
  String get homeAllWallets => 'Tüm cüzdanlar';

  @override
  String get homeSwitchWallet => 'Cüzdan değiştir';

  @override
  String get homeWallet => 'Cüzdan';

  @override
  String get homePreviousMonth => 'Önceki ay';

  @override
  String get homeNextMonth => 'Sonraki ay';

  @override
  String get homeTapReturnCurrentMonth => 'Mevcut aya dönmek için dokunun';

  @override
  String get homeNoBudget => 'Bütçe belirlenmemiş.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'bu ay kalan · $percent% harcandı';
  }

  @override
  String homeOverBudget(int percent) {
    return 'bütçeyi aştı · $percent% harcandı';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount geçen aydan aktarıldı';
  }

  @override
  String get homeNoTransactions =>
      'Henüz işlem yok.\nEklemek için + düğmesine dokunun.';

  @override
  String get homeNoTransactionsDay => 'Bu günde işlem yok.';

  @override
  String get homeNoTransactionsCategory =>
      'Bu dönemde bu\nkategoride işlem yok.';

  @override
  String get homeByDay => 'Güne Göre';

  @override
  String get homeByCategory => 'Kategoriye Göre';

  @override
  String get homeDeleteTitle => 'İşlem silinsin mi?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" kalıcı olarak silinecek.';
  }

  @override
  String get homeSeeAll => 'Tümünü gör';

  @override
  String get homeRecentTransactions => 'Son İşlemler';

  @override
  String get budgetRemaining => 'kalan';

  @override
  String get budgetSpent => 'Harcanan';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% kullanıldı';
  }

  @override
  String get budgetNoSet => 'Bu ay için henüz bütçe belirlenmemiş.';

  @override
  String setBudgetForPeriod(String period) {
    return '$period için bütçe belirle';
  }

  @override
  String get setBudgetHint => 'Bu ay takip etmek istediğiniz toplam tutardır.';

  @override
  String get setBudgetAmount => 'Bütçe tutarı';

  @override
  String get setBudgetEnterAmount => 'Tutar girin';

  @override
  String get setBudgetValidAmount => 'Geçerli bir tutar girin';

  @override
  String get setBudgetSave => 'Bütçeyi Kaydet';

  @override
  String get historyMonth => 'Ay';

  @override
  String get historyYear => 'Yıl';

  @override
  String get transactionTitleEdit => 'İşlemi Düzenle';

  @override
  String get transactionTitleNew => 'Yeni İşlem';

  @override
  String get transactionValidAmount => 'Geçerli bir tutar girin.';

  @override
  String get transactionAddDescription => 'Açıklama ekleyin.';

  @override
  String get transactionSelectCategory => 'Kategori seçin.';

  @override
  String get transactionRepeats => 'Tekrarlar';

  @override
  String get transactionDescription => 'Açıklama';

  @override
  String get transactionFrequent => 'SIK KULLANILAN';

  @override
  String get transactionNewCategory => 'Yeni';

  @override
  String get transactionEnterCategoryName => 'Kategori adı girin';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Devam etmek için $fields ekleyin';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Kural: $keyword  •  düzenlemek için dokunun';
  }

  @override
  String get transactionDeleteTitle => 'İşlem silinsin mi?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" kalıcı olarak silinecek.';
  }

  @override
  String get transactionDeleteRecurringTitle => 'Tekrarlayan işlemi sil';

  @override
  String get transactionDeleteRecurringQuestion => 'Nasıl silmek istiyorsunuz?';

  @override
  String get transactionDeleteOnlyThis => 'Yalnızca bu';

  @override
  String get transactionDeleteThisAndFuture => 'Bu ve gelecektekiler';

  @override
  String get categoriesNoExpense => 'Henüz gider kategorisi yok.';

  @override
  String get categoriesNoIncome => 'Henüz gelir kategorisi yok.';

  @override
  String categoriesActiveCount(int count) {
    return '$count aktif';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'BU AY KULLANILMAYAN · $count';
  }

  @override
  String get categoriesUnused => 'kullanılmayan';

  @override
  String categoriesPercentSpend(String percent) {
    return 'harcamanın $percent%\'i';
  }

  @override
  String get editCategoryTitleEdit => 'Kategoriyi Düzenle';

  @override
  String get editCategoryTitleAdd => 'Kategori Ekle';

  @override
  String get editCategoryName => 'Ad';

  @override
  String get editCategoryUsedFor => 'Kullanım amacı';

  @override
  String get editCategoryColour => 'Renk';

  @override
  String get editCategoryIcon => 'Simge';

  @override
  String get editCategoryChartNote =>
      'Grafik çubuğu rengi yerleşik kategoriler için tema tarafından yönetilir.';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsMonthStartsOn => 'Ay başlangıcı';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return '$day$ordinal. Gün';
  }

  @override
  String get settingsDaysFebNote =>
      'Şubat uyumluluğunu sağlamak için 29-31. günler kullanılamaz.';

  @override
  String get settingsDefaultMonthlyBudget => 'Varsayılan aylık bütçe';

  @override
  String get settingsNotSet => 'Belirlenmemiş';

  @override
  String get settingsManageCategories => 'Kategorileri yönet';

  @override
  String get settingsWallets => 'Cüzdanlar';

  @override
  String get settingsManageWallets => 'Cüzdanları yönet';

  @override
  String get settingsAutomations => 'Otomasyonlar';

  @override
  String get settingsData => 'Veri';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsDeveloperTools => 'Geliştirici Araçları';

  @override
  String get settingsDangerZone => 'Tehlike Bölgesi';

  @override
  String get settingsResetApp => 'Uygulamayı sıfırla';

  @override
  String get settingsResetAppDesc =>
      'Tüm işlemleri ve bütçeleri sil, varsayılanları geri yükle';

  @override
  String get settingsSelectCurrency => 'Para Birimi Seç';

  @override
  String get settingsMonthStartOnDay => 'Ay hangi günde başlasın…';

  @override
  String get settingsResetTitle => 'Uygulama sıfırlansın mı?';

  @override
  String get settingsResetMessage =>
      'Bu işlem kalıcı olarak silecek:\n  • Tüm işlemler\n  • Tüm bütçeler\n  • Tüm özel kategoriler\n\nAyarlar varsayılana döndürülecek ve Google hesabından çıkış yapılacak. Yedekten geri yüklemek için tekrar giriş yapın.\n\nBu işlem geri alınamaz.';

  @override
  String get settingsResetConfirm => 'Her Şeyi Sıfırla';

  @override
  String get settingsChangeStartDayTitle => 'Başlangıç günü değiştirilsin mi?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return '$from. günden $to. güne geçiş tüm ayların dönem sınırlarını kaydıracak. Mevcut işlemler değişmeden kalır.';
  }

  @override
  String get settingsBackupToDrive => 'Google Drive\'a yedekle';

  @override
  String get settingsSignInForBackup =>
      'Yedeklemeyi etkinleştirmek için giriş yapın';

  @override
  String settingsLastBackup(String time) {
    return 'Son yedek: $time';
  }

  @override
  String get settingsNoBackupYet => 'Henüz yedek yok';

  @override
  String get settingsBackupNow => 'Şimdi yedekle';

  @override
  String get settingsRestoreFromDrive => 'Drive\'dan geri yükle';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Yerel verileri Drive yedeğiyle değiştir';

  @override
  String get settingsSignOut => 'Çıkış yap';

  @override
  String get settingsBackupSaved => 'Yedek Google Drive\'a kaydedildi.';

  @override
  String get settingsBackupNoChanges =>
      'Son yedekten bu yana değişiklik yok — atlandı.';

  @override
  String settingsBackupFailed(String error) {
    return 'Yedekleme başarısız: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Yedekler listelenemedi: $error';
  }

  @override
  String get settingsNoBackupFound => 'Google Drive\'da yedek bulunamadı.';

  @override
  String get settingsReplaceLocalTitle => 'Tüm yerel veriler değiştirilsin mi?';

  @override
  String get settingsReplaceLocalMessage =>
      'Google Drive\'dan geri yükleme bu cihazdaki her şeyi — tüm işlemler, bütçeler ve kategoriler — kalıcı olarak silecek ve yedeğiyle değiştirecek.\n\nBu işlem geri alınamaz.';

  @override
  String get settingsReplaceMyData => 'Verilerimi değiştir';

  @override
  String get settingsDataRestored => 'Veriler Google Drive\'dan geri yüklendi.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Geri yükleme başarısız: $error';
  }

  @override
  String get settingsSelectBackup => 'Geri yüklenecek yedeği seçin';

  @override
  String get settingsExportBackup => 'Yedeği dışa aktar';

  @override
  String get settingsExportBackupDesc =>
      'Tüm verileri JSON dosyası olarak kaydet';

  @override
  String get settingsRestoreFromFile => 'Dosyadan geri yükle';

  @override
  String get settingsRestoreFromFileDesc =>
      'Yerel verileri dışa aktarılan yedekle değiştir';

  @override
  String settingsExportFailed(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Dosya okunamıyor: $error';
  }

  @override
  String get settingsImportTitle => 'Yedek içe aktarılsın mı?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Bulundu:\n  • $transactions işlem\n  • $budgets bütçe\n  • $categories kategori\n\nBu tüm yerel verilerin yerini alacak. Geri alınamaz.';
  }

  @override
  String get settingsImportConfirm => 'İçe Aktar';

  @override
  String settingsImportDone(int count) {
    return '$count işlem başarıyla içe aktarıldı.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get settingsSmsRules => 'SMS Kuralları';

  @override
  String get settingsSmsRulesDesc => 'Gelen mesajlardan otomatik işlem oluştur';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeAuto => 'Otomatik';

  @override
  String get settingsCarryOver => 'Kullanılmayan bütçeyi aktar';

  @override
  String get settingsCarryOverDesc => 'Fazla miktar sonraki aya aktarılır';

  @override
  String get settingsDefaultBudgetApplied =>
      'Mevcut ay için bütçe belirlenmediğinde otomatik olarak uygulanır.';

  @override
  String get settingsJustNow => 'Az önce';

  @override
  String settingsMinutesAgo(int minutes) {
    return '$minutes dk önce';
  }

  @override
  String settingsHoursAgo(int hours) {
    return '$hours sa önce';
  }

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsSelectLanguage => 'Dil Seç';

  @override
  String get manageWalletsTitle => 'Cüzdanları Yönet';

  @override
  String get manageWalletsNone => 'Henüz cüzdan yok.';

  @override
  String get manageWalletsAdd => 'Cüzdan ekle';

  @override
  String get manageWalletsEditTitle => 'Cüzdanı düzenle';

  @override
  String get manageWalletsName => 'Cüzdan adı';

  @override
  String get manageWalletsDefaultBudget =>
      'Varsayılan aylık bütçe (isteğe bağlı)';

  @override
  String get manageWalletsLeaveEmpty => 'Devre dışı bırakmak için boş bırakın';

  @override
  String get manageWalletsMonthStart => 'Ay başlangıcı (isteğe bağlı)';

  @override
  String get manageWalletsAppDefault => 'Uygulama varsayılanı';

  @override
  String manageWalletsDay(int day) {
    return '$day. Gün';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Belirlenmemişse uygulama varsayılanı olarak bırak';

  @override
  String get manageWalletsDefaultLabel => 'Varsayılan cüzdan';

  @override
  String get manageWalletsSetAsDefault => 'Varsayılan olarak ayarla';

  @override
  String get manageWalletsNoBudget => 'Varsayılan bütçe yok';

  @override
  String get manageWalletsAlreadyExists => 'Bu adda bir cüzdan zaten var';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Aktarım açık';
  }

  @override
  String get smsRulesTitle => 'SMS Kuralları';

  @override
  String get smsRulesScanPast => 'Geçmiş SMS\'leri tara';

  @override
  String get smsRulesPermissionTitle => 'SMS izni gerekli';

  @override
  String get smsRulesPermissionMessage =>
      'Gelen mesajların kurallarınızla eşleştirilebilmesi için erişim izni verin.';

  @override
  String get smsRulesNone => 'Henüz kural yok';

  @override
  String get smsRulesNoneMessage =>
      'Banka SMS\'i alındığında otomatik işlem oluşturmak için kural ekleyin.';

  @override
  String get smsRulesAddFirst => 'İlk kuralı ekle';

  @override
  String get smsRulesDeleteTitle => 'Kural silinsin mi?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return '\"$keyword\" kuralı silinecek. Oluşturulan işlemler etkilenmeyecek.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$date tarihinde $count işlem oluşturuldu — görmek için ana ekrana gidin.';
  }

  @override
  String get smsRulesNoImports => 'Hiç işlem içe aktarılmadı.';

  @override
  String get smsRuleFormTitleEdit => 'Kuralı Düzenle';

  @override
  String get smsRuleFormTitleNew => 'Yeni Kural';

  @override
  String get smsRuleFormKeyword => 'Anahtar kelime';

  @override
  String get smsRuleFormKeywordHint => 'örn. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'SMS metninin herhangi bir yerinde büyük/küçük harf duyarsız eşleşme.';

  @override
  String get smsRuleFormLabel => 'İşlem Etiketi';

  @override
  String get smsRuleFormLabelHint =>
      'örn. Yakıt, Kahve, Market (anahtar kelimeyi kullanmak için boş bırakın)';

  @override
  String get smsRuleFormLabelHelper =>
      'İşlem açıklaması olarak gösterilir. Varsayılan anahtar kelimedir.';

  @override
  String get smsRuleFormType => 'İşlem Türü';

  @override
  String get smsRuleFormCategory => 'Kategori';

  @override
  String get smsRuleFormSelectCategory => 'Kategori seçin';

  @override
  String get smsRuleFormWallet => 'Cüzdan';

  @override
  String get smsRuleFormAdvanced => 'Gelişmiş';

  @override
  String get smsRuleFormCustomRegex => 'Özel tutar regex\'i';

  @override
  String get smsRuleFormRegexHint => 'Tutar regex\'i (isteğe bağlı)';

  @override
  String get smsRuleFormRegexHelper =>
      'Tutarı çıkarmak için 1. yakalama grubunu kullanın. Yerleşik algılama için boş bırakın.';

  @override
  String get smsRuleFormSaveChanges => 'Değişiklikleri Kaydet';

  @override
  String get smsRuleFormSaveNew => 'Kuralı Kaydet';

  @override
  String get smsRuleFormDeleteRule => 'Kuralı Sil';

  @override
  String get smsRuleFormEnterKeyword => 'Lütfen bir anahtar kelime girin.';

  @override
  String get smsRuleFormSelectCategoryError => 'Lütfen bir kategori seçin.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return '\"$keyword\" kuralı kalıcı olarak silinecek.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Kategori Seç';

  @override
  String get smsScanTitle => 'Mevcut SMS\'leri Tara';

  @override
  String get smsScanDesc =>
      'Aktif kurallarınızı gelen kutunuzdaki mesajlara uygulayın.';

  @override
  String get smsScanDateRange => 'Tarih aralığı';

  @override
  String get smsScan3Days => '3 gün';

  @override
  String get smsScan7Days => '7 gün';

  @override
  String get smsScan30Days => '30 gün';

  @override
  String get smsScanCustom => 'Özel…';

  @override
  String get smsScanSelectRange => 'Tarih aralığı seç';

  @override
  String get smsScanPermissionRequired =>
      'Mesajları taramak için SMS izni gereklidir.';

  @override
  String get smsScanScanning => 'Mesajlar taranıyor…';

  @override
  String get smsScanNoMatches => 'Eşleşme bulunamadı';

  @override
  String get smsScanNoMatchesMessage =>
      'Bu aralıkta hiçbir mesaj aktif kurallarınızla eşleşmedi.\nDaha geniş bir aralık deneyin veya kural anahtar kelimelerinizi kontrol edin.';

  @override
  String get smsScanTryDifferent => 'Farklı aralık dene';

  @override
  String smsScanMatchesFound(int count) {
    return '$count eşleşme bulundu';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count bugün zaten mevcut — varsayılan olarak işaretsiz';
  }

  @override
  String smsScanImportButton(int count) {
    return '$count işlemi içe aktar';
  }

  @override
  String get smsScanNothingSelected => 'Hiçbir şey seçilmedi';

  @override
  String get smsScanEditLabel => 'Etiketi düzenle';

  @override
  String get smsScanTransactionDesc => 'İşlem açıklaması';

  @override
  String get smsScanExists => 'mevcut';

  @override
  String get smsScanDupWarning =>
      'Bu tutara ve kategoriye ait işlem bu günde zaten mevcut';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'Her şey açık, bir kez. Abonelik yok.';

  @override
  String paywallUnlock(String price) {
    return 'Sonsuza Kadar Aç — $price';
  }

  @override
  String get paywallRestore => 'Satın Almayı Geri Yükle';

  @override
  String get paywallRestoreNote =>
      'Tek seferlik satın alma · Tekrarlayan ücret yok';

  @override
  String get paywallTrialEnded => '14 günlük ücretsiz deneme süreniz sona erdi';

  @override
  String get paywallProUnlocked => 'Pro Açık';

  @override
  String get paywallFeatureWallets => 'Sınırsız cüzdan';

  @override
  String get paywallFeatureTransactions => 'Sınırsız işlem';

  @override
  String get paywallFeatureHistory => 'Tam işlem geçmişi';

  @override
  String get paywallFeatureBackup => 'Google Drive yedekleme';

  @override
  String get paywallFeatureExport => 'Verilerinizi dışa aktarın';

  @override
  String get paywallFeatureCategories => 'Özel kategoriler';

  @override
  String get paywallFeatureSms => 'SMS otomatik ayrıştırma (Android)';

  @override
  String get paywallNoRestoreFound =>
      'Bu hesap için önceki satın alma bulunamadı.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Geri yükleme başarısız: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$total içinde $current';
  }

  @override
  String get tutorialGetStarted => 'Başla';

  @override
  String get tutorialWelcomeTitle => 'FELOOSY\'ye Hoş Geldiniz';

  @override
  String get tutorialWelcomeMessage =>
      'Kişisel bütçeniz, güzel bir şekilde sade.\nTemel özelliklerin hızlı turunu yapalım.';

  @override
  String get tutorialBudgetTitle => 'Aylık Bütçe';

  @override
  String get tutorialBudgetMessage =>
      'Bu kart, ay için bütçenize karşı harcamanızı gösterir. Aylık limitinizi belirlemek için \"Bütçe Belirle\"ye dokunun.';

  @override
  String get tutorialCarryoverTitle => 'Fazlayı Aktar';

  @override
  String get tutorialCarryoverMessage =>
      'Herhangi bir cüzdan için Ayarlar → Cüzdanları Yönet\'ten aktarmayı etkinleştirin. Geçen aydaki kullanılmayan bütçe otomatik olarak bu aya aktarılır.';

  @override
  String get tutorialAddTitle => 'İşlem Ekle';

  @override
  String get tutorialAddMessage =>
      'Bir alışveriş, fatura veya gelir kaydetmek için + düğmesine dokunun. Paranızın nereye gittiğini görmek için kategori seçin.';

  @override
  String get tutorialBrowseTitle => 'Geçmiş Aylara Göz At';

  @override
  String get tutorialBrowseMessage =>
      'Önceki ayları incelemek için ana ekranda oklara dokunun veya sola/sağa kaydırın.';

  @override
  String get tutorialSettingsTitle => 'Ayarlar ve Daha Fazlası';

  @override
  String get tutorialSettingsMessage =>
      'Para birimini değiştirin, hesapları yönetin, kategorileri özelleştirin ve verilerinizi buradan yedekleyin.';

  @override
  String get tutorialDoneTitle => 'Hazırsınız!';

  @override
  String get tutorialDoneMessage =>
      'İlk işleminizi ekleyerek başlayın. FELOOSY gerisini takip eder.';

  @override
  String get privacyTitle => 'Başlamadan önce';

  @override
  String get privacySmsTitle => 'SMS otomatik algılama';

  @override
  String get privacySmsMessage =>
      'SMS izni verirseniz, gelen banka mesajları bellekte kurallarınızla eşleştirilir. Mesaj metni hiçbir zaman kaydedilmez veya paylaşılmaz.';

  @override
  String get privacyDataTitle => 'Verileriniz cihazınızda kalır';

  @override
  String get privacyDataMessage =>
      'İşlemler ve bütçeler yerel olarak saklanır. Sunucumuz yok ve finansal verilerinizi göremeyiz.';

  @override
  String get privacyAiTitle => 'AI analizi (isteğe bağlı)';

  @override
  String get privacyAiMessage =>
      'AI özelliğini kullanırsanız, anonimleştirilmiş harcama özetleri (kategori toplamları, ham SMS yok) Google Gemini\'ye gönderilir.';

  @override
  String get privacyReadPolicy => 'Tam politikayı oku';

  @override
  String get privacyAccept => 'Kabul Et ve Devam Et';
}
