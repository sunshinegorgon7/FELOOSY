# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FELOOSY is a Flutter personal budgeting app targeting iOS and Android. It uses SQLite for local-first persistence with optional Google Drive backup (Google Sign-In required). Firebase/Firestore has been removed.

## Common Commands

```bash
# Run by flavor
flutter run -t lib/main_dev.dart
flutter run -t lib/main_uat.dart
flutter run -t lib/main_prod.dart

# Build
flutter build apk
flutter build ios

# Code generation (Freezed, json_serializable, Riverpod generator)
flutter pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test
flutter test test/widget_test.dart   # single file

# Lint
dart analyze
```

## Architecture

The app follows a three-layer architecture:

**`data/`** — SQLite repositories and model serialization. All models use `toMap()`/`fromMap()` (not Freezed/json_serializable, despite those deps being in pubspec). `DatabaseHelper` is a singleton managing schema migrations up to v9.

**`domain/`** — Business logic entities (`BudgetSummary`, `BudgetPeriod`) and services (`GoogleDriveBackupService`, `LocalExportService`, `BudgetService`). Services are stateless and called directly from providers.

**`presentation/`** — Screens and widgets. All screens are `ConsumerWidget` or `ConsumerStatefulWidget`.

**`providers/`** — Riverpod state layer. Each feature has an `AsyncNotifierProvider` wrapping the repository. Mutations call `ref.invalidateSelf()` to force reload. `database_provider.dart` handles dependency injection of repositories via `Provider`.

## Key Patterns

**Data flow**: UI watches a provider → provider calls repository → repository queries `DatabaseHelper`. There is no automatic cloud sync on writes; data lives locally and is backed up to Google Drive on demand.

**Google Drive backup**: `GoogleDriveBackupService` exports all SQLite tables as JSON to the Drive `appDataFolder` scope. It retains up to 5 backups (auto-prunes oldest). Restore replaces all local tables in a single SQLite transaction. The `last_backup_at` timestamp is stored in `app_settings`. Triggered from the Settings screen.

**Google sign-in**: Handled by `GoogleAccountNotifier` in `google_auth_provider.dart` using `GoogleSignIn.instance` directly (no Firebase Auth dependency). Scopes: `email`, `profile`, and `drive.appdata`.

**Navigation**: GoRouter with named routes. Complex objects (e.g., a `Transaction` being edited) are passed via the `extra` parameter. See [app/router.dart](lib/app/router.dart) for all routes.

**Multi-account**: Every `Transaction` and `Budget` is linked to an `account_id`. The home view can filter by account or aggregate across all. The `is_favorite` flag marks the default wallet.

**Categories**: The 16 default categories have stable hardcoded UUIDs in [core/constants/default_categories.dart](lib/core/constants/default_categories.dart). Never change these UUIDs — they're used as foreign keys in existing user databases.

**Flavors**: `AppFlavor` (set at startup) controls the SQLite database filename and debug banner. Dev uses `feloosy_dev.db`, prod uses `feloosy.db`.

**Home widget**: `HomeWidgetSyncService` bridges Flutter data to the native home screen widget. `FeloosyApp` listens to provider changes via `ref.listenManual()` to keep the widget in sync.

**Period navigation**: The home screen supports swiping between budget periods (months). Available offsets are cached in `_cachedPeriodOffsets` (a `Set<int>`) when the data loads, so swipe buttons don't disable mid-gesture during account switches. `selectedPeriodOffsetProvider` tracks the current offset.

**Top spending chart**: `_TopCategoriesChart` is an inline widget at the bottom of `home_screen.dart` (also referenced from the budget screen). It renders a vertical bar chart of top expense categories for the current period, using each category's own `colorValue`. Not a separate file.

## Database Schema (v9)

| Table | Key columns |
|---|---|
| `accounts` | id, name, currency_code, currency_symbol, default_monthly_budget, is_favorite, month_start_day |
| `transactions` | uuid, account_id, amount, type (expense/income), category_uuid, transaction_date |
| `budgets` | id, account_id, year, month, amount — unique on (account_id, year, month) |
| `categories` | uuid, name, color_value, icon_code_point, icon_font_family, is_custom, is_active, sort_order |
| `app_settings` | singleton row: theme_mode, color_theme, currency, month_start_day, google_backup_enabled, last_backup_at |

Migration notes: v8 added `month_start_day` to `accounts`. v9 dropped `pending_sync_ops` (Firestore offline queue — no longer used).

All timestamps are stored as milliseconds-since-epoch integers.

## State Management

Providers live in [providers/](lib/providers/). The pattern is:

```dart
@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<List<Transaction>> build() => ref.read(transactionRepositoryProvider).getAll();

  Future<void> add(Transaction t) async {
    await ref.read(transactionRepositoryProvider).insert(t);
    ref.invalidateSelf();
  }
}
```

`database_provider.dart` exposes repository instances as simple `Provider`s so they can be read synchronously by notifiers.

Additional providers:
- `google_auth_provider.dart` — `googleAccountProvider` (`NotifierProvider<GoogleAccountNotifier, GoogleSignInAccount?>`) for Google sign-in state. Attempts a lightweight session restore on first build.
- `drive_backup_provider.dart` — `googleDriveBackupProvider` (simple `Provider`) exposing a `GoogleDriveBackupService` instance.

## Google Drive Backup

Firebase and Firestore have been fully removed from the project. Cloud backup is now handled exclusively via Google Drive.

- Google sign-in uses `GoogleSignIn.instance` directly (no Firebase Auth). See `google_auth_provider.dart`.
- `GoogleDriveBackupService` in `domain/services/` handles backup, restore, and listing. It stores files in the Drive `appDataFolder` (private, app-only scope — not visible in the user's Drive).
- Backup format: JSON with a `version` key and a `data` map containing all five tables. Timestamped filename `feloosy_backup_{ms}.json`.
- Up to 5 backups retained; oldest are pruned automatically after each backup.
- `restore(fileId)` — atomically replaces all local data in a single SQLite transaction. Irreversible; UI should confirm before calling.
- `listBackups()` returns `List<BackupEntry>` (id + modifiedTime), sorted newest-first.
- `firebase_options.dart` may still exist in the repo but Firebase is no longer initialised or used.
