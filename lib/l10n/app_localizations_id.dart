// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Selesai';

  @override
  String get next => 'Berikutnya';

  @override
  String get skip => 'Lewati';

  @override
  String get grant => 'Izinkan';

  @override
  String get change => 'Ubah';

  @override
  String get clear => 'Hapus';

  @override
  String get import => 'Impor';

  @override
  String get today => 'Hari ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get income => 'Pemasukan';

  @override
  String get both => 'Keduanya';

  @override
  String get recurring => 'Berulang';

  @override
  String get daily => 'Harian';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get annually => 'Tahunan';

  @override
  String get search => 'Cari';

  @override
  String get settings => 'Pengaturan';

  @override
  String get history => 'Riwayat';

  @override
  String get budget => 'Anggaran';

  @override
  String get currency => 'Mata Uang';

  @override
  String get categories => 'Kategori';

  @override
  String get version => 'Versi';

  @override
  String get auto => 'Otomatis';

  @override
  String get noCategory => 'Tanpa kategori';

  @override
  String get selectCategory => 'Pilih kategori';

  @override
  String get setBudget => 'Atur Anggaran';

  @override
  String get homeSearchHint => 'Cari transaksi…';

  @override
  String get homeAllWallets => 'Semua dompet';

  @override
  String get homeSwitchWallet => 'Ganti dompet';

  @override
  String get homeWallet => 'Dompet';

  @override
  String get homePreviousMonth => 'Bulan sebelumnya';

  @override
  String get homeNextMonth => 'Bulan berikutnya';

  @override
  String get homeTapReturnCurrentMonth => 'Ketuk untuk kembali ke bulan ini';

  @override
  String get homeNoBudget => 'Anggaran belum diatur.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'sisa bulan ini · $percent% terpakai';
  }

  @override
  String homeOverBudget(int percent) {
    return 'melebihi anggaran · $percent% terpakai';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount dilanjutkan dari bulan lalu';
  }

  @override
  String get homeNoTransactions =>
      'Belum ada transaksi.\nKetuk + untuk menambahkan.';

  @override
  String get homeNoTransactionsDay => 'Tidak ada transaksi pada hari ini.';

  @override
  String get homeNoTransactionsCategory =>
      'Tidak ada transaksi dalam\nkategori ini untuk periode ini.';

  @override
  String get homeByDay => 'Per Hari';

  @override
  String get homeByCategory => 'Per Kategori';

  @override
  String get homeDeleteTitle => 'Hapus transaksi?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" akan dihapus secara permanen.';
  }

  @override
  String get homeSeeAll => 'Lihat semua';

  @override
  String get homeRecentTransactions => 'Transaksi Terbaru';

  @override
  String get budgetRemaining => 'sisa';

  @override
  String get budgetSpent => 'Terpakai';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% terpakai';
  }

  @override
  String get budgetNoSet => 'Anggaran belum diatur untuk bulan ini.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Atur anggaran untuk $period';
  }

  @override
  String get setBudgetHint =>
      'Ini adalah total jumlah yang ingin Anda lacak bulan ini.';

  @override
  String get setBudgetAmount => 'Jumlah anggaran';

  @override
  String get setBudgetEnterAmount => 'Masukkan jumlah';

  @override
  String get setBudgetValidAmount => 'Masukkan jumlah yang valid';

  @override
  String get setBudgetSave => 'Simpan Anggaran';

  @override
  String get historyMonth => 'Bulan';

  @override
  String get historyYear => 'Tahun';

  @override
  String get transactionTitleEdit => 'Edit Transaksi';

  @override
  String get transactionTitleNew => 'Transaksi Baru';

  @override
  String get transactionValidAmount => 'Masukkan jumlah yang valid.';

  @override
  String get transactionAddDescription => 'Tambahkan deskripsi.';

  @override
  String get transactionSelectCategory => 'Pilih kategori.';

  @override
  String get transactionRepeats => 'Berulang';

  @override
  String get transactionDescription => 'Deskripsi';

  @override
  String get transactionFrequent => 'SERING DIGUNAKAN';

  @override
  String get transactionNewCategory => 'Baru';

  @override
  String get transactionEnterCategoryName => 'Masukkan nama kategori';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Tambahkan $fields untuk melanjutkan';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Aturan: $keyword  •  ketuk untuk mengedit';
  }

  @override
  String get transactionDeleteTitle => 'Hapus transaksi?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" akan dihapus secara permanen.';
  }

  @override
  String get transactionDeleteRecurringTitle => 'Hapus transaksi berulang';

  @override
  String get transactionDeleteRecurringQuestion =>
      'Bagaimana Anda ingin menghapus ini?';

  @override
  String get transactionDeleteOnlyThis => 'Hanya ini';

  @override
  String get transactionDeleteThisAndFuture => 'Ini & berikutnya';

  @override
  String get categoriesNoExpense => 'Belum ada kategori pengeluaran.';

  @override
  String get categoriesNoIncome => 'Belum ada kategori pemasukan.';

  @override
  String categoriesActiveCount(int count) {
    return '$count aktif';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'TIDAK DIGUNAKAN BULAN INI · $count';
  }

  @override
  String get categoriesUnused => 'tidak digunakan';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% dari pengeluaran';
  }

  @override
  String get editCategoryTitleEdit => 'Edit Kategori';

  @override
  String get editCategoryTitleAdd => 'Tambah Kategori';

  @override
  String get editCategoryName => 'Nama';

  @override
  String get editCategoryUsedFor => 'Digunakan untuk';

  @override
  String get editCategoryColour => 'Warna';

  @override
  String get editCategoryIcon => 'Ikon';

  @override
  String get editCategoryChartNote =>
      'Warna batang grafik dikelola tema untuk kategori bawaan.';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsMonthStartsOn => 'Bulan dimulai pada';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Hari $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Hari 29–31 tidak tersedia untuk memastikan kompatibilitas Februari.';

  @override
  String get settingsDefaultMonthlyBudget => 'Anggaran bulanan default';

  @override
  String get settingsNotSet => 'Belum diatur';

  @override
  String get settingsManageCategories => 'Kelola kategori';

  @override
  String get settingsWallets => 'Dompet';

  @override
  String get settingsManageWallets => 'Kelola dompet';

  @override
  String get settingsAutomations => 'Otomasi';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get settingsDeveloperTools => 'Alat Pengembang';

  @override
  String get settingsDangerZone => 'Zona Berbahaya';

  @override
  String get settingsResetApp => 'Reset aplikasi';

  @override
  String get settingsResetAppDesc =>
      'Hapus semua transaksi dan anggaran, kembalikan default';

  @override
  String get settingsSelectCurrency => 'Pilih Mata Uang';

  @override
  String get settingsMonthStartOnDay => 'Bulan dimulai pada hari…';

  @override
  String get settingsResetTitle => 'Reset aplikasi?';

  @override
  String get settingsResetMessage =>
      'Ini akan menghapus secara permanen:\n  • Semua transaksi\n  • Semua anggaran\n  • Semua kategori kustom\n\nPengaturan akan dikembalikan ke default dan Anda akan keluar dari Google. Masuk kembali setelahnya untuk memulihkan dari cadangan.\n\nIni tidak dapat dibatalkan.';

  @override
  String get settingsResetConfirm => 'Reset Semua';

  @override
  String get settingsChangeStartDayTitle => 'Ubah hari mulai?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Mengubah dari hari $from ke hari $to akan menggeser batas periode untuk semua bulan. Transaksi yang ada tetap tidak berubah.';
  }

  @override
  String get settingsBackupToDrive => 'Cadangkan ke Google Drive';

  @override
  String get settingsSignInForBackup => 'Masuk untuk mengaktifkan cadangan';

  @override
  String settingsLastBackup(String time) {
    return 'Cadangan terakhir: $time';
  }

  @override
  String get settingsNoBackupYet => 'Belum ada cadangan';

  @override
  String get settingsBackupNow => 'Cadangkan sekarang';

  @override
  String get settingsRestoreFromDrive => 'Pulihkan dari Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Ganti data lokal dengan cadangan Drive';

  @override
  String get settingsSignOut => 'Keluar';

  @override
  String get settingsBackupSaved => 'Cadangan disimpan ke Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'Tidak ada perubahan sejak cadangan terakhir — dilewati.';

  @override
  String settingsBackupFailed(String error) {
    return 'Cadangan gagal: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Tidak dapat mencantumkan cadangan: $error';
  }

  @override
  String get settingsNoBackupFound =>
      'Tidak ada cadangan ditemukan di Google Drive.';

  @override
  String get settingsReplaceLocalTitle => 'Ganti semua data lokal?';

  @override
  String get settingsReplaceLocalMessage =>
      'Memulihkan dari Google Drive akan menghapus secara permanen semua yang ada di perangkat ini — semua transaksi, anggaran, dan kategori — dan menggantinya dengan cadangan.\n\nIni tidak dapat dibatalkan.';

  @override
  String get settingsReplaceMyData => 'Ganti data saya';

  @override
  String get settingsDataRestored => 'Data dipulihkan dari Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String get settingsSelectBackup => 'Pilih cadangan untuk dipulihkan';

  @override
  String get settingsExportBackup => 'Ekspor cadangan';

  @override
  String get settingsExportBackupDesc => 'Simpan semua data sebagai file JSON';

  @override
  String get settingsRestoreFromFile => 'Pulihkan dari file';

  @override
  String get settingsRestoreFromFileDesc =>
      'Ganti data lokal dengan cadangan yang diekspor';

  @override
  String settingsExportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Tidak dapat membaca file: $error';
  }

  @override
  String get settingsImportTitle => 'Impor cadangan?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Ditemukan:\n  • $transactions transaksi\n  • $budgets anggaran\n  • $categories kategori\n\nIni akan mengganti semua data lokal. Ini tidak dapat dibatalkan.';
  }

  @override
  String get settingsImportConfirm => 'Impor';

  @override
  String settingsImportDone(int count) {
    return 'Berhasil mengimpor $count transaksi.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Impor gagal: $error';
  }

  @override
  String get settingsSmsRules => 'Aturan SMS';

  @override
  String get settingsSmsRulesDesc => 'Buat transaksi otomatis dari pesan masuk';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsThemeAuto => 'Otomatis';

  @override
  String get settingsCarryOver => 'Lanjutkan anggaran yang tidak terpakai';

  @override
  String get settingsCarryOverDesc => 'Surplus dilanjutkan ke bulan berikutnya';

  @override
  String get settingsDefaultBudgetApplied =>
      'Diterapkan secara otomatis jika anggaran belum diatur untuk bulan ini.';

  @override
  String get settingsJustNow => 'Baru saja';

  @override
  String settingsMinutesAgo(int minutes) {
    return '$minutes menit lalu';
  }

  @override
  String settingsHoursAgo(int hours) {
    return '$hours jam lalu';
  }

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsSelectLanguage => 'Pilih Bahasa';

  @override
  String get manageWalletsTitle => 'Kelola Dompet';

  @override
  String get manageWalletsNone => 'Belum ada dompet.';

  @override
  String get manageWalletsAdd => 'Tambah dompet';

  @override
  String get manageWalletsEditTitle => 'Edit dompet';

  @override
  String get manageWalletsName => 'Nama dompet';

  @override
  String get manageWalletsDefaultBudget =>
      'Anggaran bulanan default (opsional)';

  @override
  String get manageWalletsLeaveEmpty => 'Biarkan kosong untuk menonaktifkan';

  @override
  String get manageWalletsMonthStart => 'Bulan dimulai pada (opsional)';

  @override
  String get manageWalletsAppDefault => 'Default aplikasi';

  @override
  String manageWalletsDay(int day) {
    return 'Hari $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Biarkan sebagai default aplikasi jika tidak diatur';

  @override
  String get manageWalletsDefaultLabel => 'Dompet default';

  @override
  String get manageWalletsSetAsDefault => 'Jadikan default';

  @override
  String get manageWalletsNoBudget => 'Tidak ada anggaran default';

  @override
  String get manageWalletsAlreadyExists => 'Dompet dengan nama ini sudah ada';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Lanjutkan aktif';
  }

  @override
  String get smsRulesTitle => 'Aturan SMS';

  @override
  String get smsRulesScanPast => 'Pindai SMS lama';

  @override
  String get smsRulesPermissionTitle => 'Izin SMS diperlukan';

  @override
  String get smsRulesPermissionMessage =>
      'Berikan akses agar pesan masuk dapat dicocokkan dengan aturan Anda.';

  @override
  String get smsRulesNone => 'Belum ada aturan';

  @override
  String get smsRulesNoneMessage =>
      'Tambahkan aturan untuk membuat transaksi otomatis saat menerima SMS bank.';

  @override
  String get smsRulesAddFirst => 'Tambah aturan pertama';

  @override
  String get smsRulesDeleteTitle => 'Hapus aturan?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'Aturan untuk \"$keyword\" akan dihapus. Transaksi yang sudah dibuat tidak akan terpengaruh.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return 'Membuat $count transaksi pada $date — kembali ke layar utama untuk melihatnya.';
  }

  @override
  String get smsRulesNoImports => 'Tidak ada transaksi yang diimpor.';

  @override
  String get smsRuleFormTitleEdit => 'Edit Aturan';

  @override
  String get smsRuleFormTitleNew => 'Aturan Baru';

  @override
  String get smsRuleFormKeyword => 'Kata Kunci';

  @override
  String get smsRuleFormKeywordHint => 'cth. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Pencocokan tidak sensitif huruf di mana saja dalam isi SMS.';

  @override
  String get smsRuleFormLabel => 'Label Transaksi';

  @override
  String get smsRuleFormLabelHint =>
      'cth. Bensin, Kopi, Belanja (biarkan kosong untuk menggunakan kata kunci)';

  @override
  String get smsRuleFormLabelHelper =>
      'Ditampilkan sebagai deskripsi transaksi. Default ke kata kunci.';

  @override
  String get smsRuleFormType => 'Jenis Transaksi';

  @override
  String get smsRuleFormCategory => 'Kategori';

  @override
  String get smsRuleFormSelectCategory => 'Pilih kategori';

  @override
  String get smsRuleFormWallet => 'Dompet';

  @override
  String get smsRuleFormAdvanced => 'Lanjutan';

  @override
  String get smsRuleFormCustomRegex => 'Regex jumlah kustom';

  @override
  String get smsRuleFormRegexHint => 'Regex jumlah (opsional)';

  @override
  String get smsRuleFormRegexHelper =>
      'Gunakan grup tangkapan 1 untuk mengekstrak jumlah. Biarkan kosong untuk menggunakan deteksi bawaan.';

  @override
  String get smsRuleFormSaveChanges => 'Simpan Perubahan';

  @override
  String get smsRuleFormSaveNew => 'Simpan Aturan';

  @override
  String get smsRuleFormDeleteRule => 'Hapus Aturan';

  @override
  String get smsRuleFormEnterKeyword => 'Silakan masukkan kata kunci.';

  @override
  String get smsRuleFormSelectCategoryError => 'Silakan pilih kategori.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'Aturan untuk \"$keyword\" akan dihapus secara permanen.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Pilih Kategori';

  @override
  String get smsScanTitle => 'Pindai SMS yang ada';

  @override
  String get smsScanDesc =>
      'Terapkan aturan aktif Anda ke pesan yang sudah ada di kotak masuk.';

  @override
  String get smsScanDateRange => 'Rentang tanggal';

  @override
  String get smsScan3Days => '3 hari';

  @override
  String get smsScan7Days => '7 hari';

  @override
  String get smsScan30Days => '30 hari';

  @override
  String get smsScanCustom => 'Kustom…';

  @override
  String get smsScanSelectRange => 'Pilih rentang tanggal';

  @override
  String get smsScanPermissionRequired =>
      'Izin SMS diperlukan untuk memindai pesan.';

  @override
  String get smsScanScanning => 'Memindai pesan…';

  @override
  String get smsScanNoMatches => 'Tidak ada kecocokan';

  @override
  String get smsScanNoMatchesMessage =>
      'Tidak ada pesan dalam rentang ini yang cocok dengan aturan aktif Anda.\nCoba rentang yang lebih luas atau periksa kata kunci aturan Anda.';

  @override
  String get smsScanTryDifferent => 'Coba rentang berbeda';

  @override
  String smsScanMatchesFound(int count) {
    return '$count kecocokan ditemukan';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count sudah ada hari ini — tidak dicentang secara default';
  }

  @override
  String smsScanImportButton(int count) {
    return 'Impor $count transaksi';
  }

  @override
  String get smsScanNothingSelected => 'Tidak ada yang dipilih';

  @override
  String get smsScanEditLabel => 'Edit label';

  @override
  String get smsScanTransactionDesc => 'Deskripsi transaksi';

  @override
  String get smsScanExists => 'sudah ada';

  @override
  String get smsScanDupWarning =>
      'Transaksi untuk jumlah dan kategori ini sudah ada pada hari ini';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'Semua terbuka, sekali. Tanpa langganan.';

  @override
  String paywallUnlock(String price) {
    return 'Buka Selamanya — $price';
  }

  @override
  String get paywallRestore => 'Pulihkan Pembelian';

  @override
  String get paywallRestoreNote => 'Pembelian satu kali · Tanpa biaya berulang';

  @override
  String get paywallTrialEnded => 'Uji coba gratis 14 hari Anda telah berakhir';

  @override
  String get paywallProUnlocked => 'Pro Terbuka';

  @override
  String get paywallFeatureWallets => 'Dompet tak terbatas';

  @override
  String get paywallFeatureTransactions => 'Transaksi tak terbatas';

  @override
  String get paywallFeatureHistory => 'Riwayat transaksi lengkap';

  @override
  String get paywallFeatureBackup => 'Cadangan Google Drive';

  @override
  String get paywallFeatureExport => 'Ekspor data Anda';

  @override
  String get paywallFeatureCategories => 'Kategori kustom';

  @override
  String get paywallFeatureSms => 'Parsing SMS otomatis (Android)';

  @override
  String get paywallNoRestoreFound =>
      'Tidak ada pembelian sebelumnya yang ditemukan untuk akun ini.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get tutorialGetStarted => 'Mulai';

  @override
  String get tutorialWelcomeTitle => 'Selamat datang di FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'Anggaran pribadi Anda, sederhana dan indah.\nMari kami tunjukkan fitur-fitur utamanya.';

  @override
  String get tutorialBudgetTitle => 'Anggaran Bulanan';

  @override
  String get tutorialBudgetMessage =>
      'Kartu ini menampilkan anggaran vs. pengeluaran Anda untuk bulan ini. Ketuk \"Atur Anggaran\" untuk menentukan batas bulanan Anda.';

  @override
  String get tutorialCarryoverTitle => 'Lanjutkan Surplus';

  @override
  String get tutorialCarryoverMessage =>
      'Aktifkan lanjutkan di Pengaturan → Kelola Dompet untuk dompet apa pun. Anggaran yang tidak terpakai dari bulan lalu otomatis dilanjutkan.';

  @override
  String get tutorialAddTitle => 'Tambah Transaksi';

  @override
  String get tutorialAddMessage =>
      'Ketuk tombol + untuk mencatat pembelian, tagihan, atau pemasukan. Pilih kategori untuk melihat ke mana uang Anda pergi.';

  @override
  String get tutorialBrowseTitle => 'Jelajahi Bulan Lalu';

  @override
  String get tutorialBrowseMessage =>
      'Ketuk panah atau geser kiri/kanan di layar utama untuk meninjau bulan sebelumnya.';

  @override
  String get tutorialSettingsTitle => 'Pengaturan & Lainnya';

  @override
  String get tutorialSettingsMessage =>
      'Ubah mata uang, kelola akun, sesuaikan kategori, dan cadangkan data Anda dari sini.';

  @override
  String get tutorialDoneTitle => 'Anda siap!';

  @override
  String get tutorialDoneMessage =>
      'Mulailah dengan menambahkan transaksi pertama Anda. FELOOSY akan melacak sisanya.';

  @override
  String get privacyTitle => 'Sebelum memulai';

  @override
  String get privacySmsTitle => 'Deteksi SMS otomatis';

  @override
  String get privacySmsMessage =>
      'Jika Anda memberikan izin SMS, pesan bank masuk dicocokkan dengan aturan Anda di memori. Teks pesan tidak pernah disimpan atau dibagikan.';

  @override
  String get privacyDataTitle => 'Data Anda tetap di perangkat Anda';

  @override
  String get privacyDataMessage =>
      'Transaksi dan anggaran disimpan secara lokal. Kami tidak memiliki server dan tidak dapat melihat data keuangan Anda.';

  @override
  String get privacyAiTitle => 'Analisis AI (opsional)';

  @override
  String get privacyAiMessage =>
      'Jika Anda menggunakan fitur AI, ringkasan pengeluaran yang dianonimkan (total kategori, tanpa SMS mentah) dikirim ke Google Gemini.';

  @override
  String get privacyReadPolicy => 'Baca kebijakan lengkap';

  @override
  String get privacyAccept => 'Terima & Lanjutkan';
}
