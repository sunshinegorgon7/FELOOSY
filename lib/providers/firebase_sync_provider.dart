import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../domain/services/firebase_sync_service.dart';
import 'auth_provider.dart';
import 'budget_provider.dart';
import 'categories_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';

// Nullable — returns null when user is not signed in
final firebaseSyncProvider = Provider<FirebaseSyncService?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return FirebaseSyncService(uid: user.uid, localDb: DatabaseHelper.instance);
});

// Orchestrates the first-time sync when the user signs in
final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  return SyncOrchestrator(ref);
});

class SyncOrchestrator {
  final Ref _ref;
  SyncOrchestrator(this._ref);

  Future<void> onSignIn(String uid) async {
    final sync = FirebaseSyncService(
      uid: uid,
      localDb: DatabaseHelper.instance,
    );
    final hasRemote = await sync.hasRemoteData();
    if (hasRemote) {
      // Cloud has data (returning user / new device) → pull to local
      await sync.pullAll();
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(transactionPeriodOffsetsProvider);
      _ref.invalidate(currentBudgetProvider);
      _ref.invalidate(settingsProvider);
      _ref.invalidate(categoriesProvider);
    } else {
      // First sign-in → push local data to cloud
      await sync.pushAll();
    }
    await sync.flushPendingTransactionOps();
  }
}
