import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import 'database_provider.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.get();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.save(settings);
    state = AsyncData(settings);
  }

  Future<void> markTutorialComplete() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(tutorialCompleted: true);
    await saveSettings(updated);
  }

  Future<void> acceptPrivacy() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(privacyAcceptedAt: DateTime.now());
    await saveSettings(updated);
  }

  Future<void> updateLanguage(String languageCode) async {
    final current = state.value;
    if (current == null) return;
    await saveSettings(current.copyWith(languageCode: languageCode));
  }

  Future<void> resetTutorial() async {
    final current = state.value;
    if (current == null) return;
    await saveSettings(current.copyWith(tutorialCompleted: false));
  }

  Future<void> setSmsOptIn(bool value) async {
    final current = state.value;
    if (current == null) return;
    await saveSettings(current.copyWith(smsOptIn: value));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(
        SettingsNotifier.new);
