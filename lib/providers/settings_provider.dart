import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';

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
    ref.read(firebaseSyncProvider)?.syncSettings(settings);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(
        SettingsNotifier.new);
