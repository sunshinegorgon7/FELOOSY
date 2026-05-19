# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FELOOSY is a Flutter personal budgeting app targeting iOS and Android. It uses SQLite for local-first persistence with optional Google Drive backup (Google Sign-In required). Firebase/Firestore has been removed.

## Common Commands

```bash
# Run by flavor
flutter run -t lib/main_dev.dart   # dev  → feloosy_dev.db
flutter run -t lib/main.dart       # prod → feloosy.db

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

**Flavors**: `AppFlavor` (set at startup) controls the SQLite database filename and debug banner. Dev uses `feloosy_dev.db`, prod uses `feloosy.db`. Entry points: `lib/main_dev.dart` (dev) and `lib/main.dart` (prod). There is no UAT flavor.

**Theme system**: `AppTheme` in `lib/app/app_theme.dart` defines two palettes — Grove for light mode and Nimbus for dark mode, plus semantic ledger red/green/amber roles. All colors are exposed as named `static const` values on `AppTheme`. In widgets, access the active palette via `final cs = Theme.of(context).colorScheme;` (the `cs` shorthand is the established pattern throughout the codebase). Use `AppTheme.primaryText(cs)`, `expenseText(cs)`, `incomeText(cs)`, and `warningText(cs)` for small colored text so contrast stays readable. `AppTheme.resolveMode(stored)` converts the `theme_mode` string from `app_settings` to a `ThemeMode`.

**Tutorial**: A one-time first-run tutorial is implemented as `TutorialOverlay` in `lib/presentation/tutorial/tutorial_overlay.dart`. Completion is tracked by the `tutorialCompleted` flag stored in the `app_settings` singleton row.

**Monetization**: The app is free with a $4.99 one-time purchase (product ID: `feloosy_pro_lifetime`) that unlocks: multiple wallets, Google Drive backup, local export, and custom categories. Purchase state is stored in the platform keychain/keystore via `flutter_secure_storage` (key: `feloosy_pro_purchased`), not in SQLite. `purchaseProvider` in `providers/purchase_provider.dart` manages the `in_app_purchase` stream, buy, and restore flows. **Dev flavor always returns purchased = true** — no paywall appears in dev builds. The paywall screen lives at `/paywall` and is pushed from each feature gate; modal settings contexts pop before pushing. Never store the purchase flag in SQLite — it must stay in secure storage to resist tampering.

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

## Home Screen Widget

The native widget lives in two places:
- **Android**: `android/app/src/main/kotlin/com/feloosy/app/widget/FeloosyWidgetProvider.kt` + layout/drawables in `android/app/src/main/res/`
- **iOS**: `ios/FeloosyWidget/FeloosyWidget.swift`

**Widget / app parity rule**: The widget should generally match any visual or data changes made to the app where the context applies (theme colours, data fields shown, formatting). When making such a change, **always confirm** with the user whether it should also be applied to the widget before doing so.

**Theme sync**: The widget palette mirrors `AppTheme` in `lib/app/app_theme.dart`. It adapts to the device's system dark/light mode (not the app's in-app override, since widgets run outside the app process). When `AppTheme` colours change, update the widget colour constants in both the Kotlin provider and the Swift file to match.

## Version Management

The canonical version lives in two places and must be kept in sync:
- `pubspec.yaml` → `version: X.Y.Z+BUILD`
- `lib/core/constants/app_info.dart` → `kAppVersionLabel = 'X.Y.Z (BUILD)'`

The build number is the total number of git commits (`git rev-list --count HEAD`).

**Rules:**
- **Major version** (`X.0.0`) — only the repo owner decides when to increment this. Do not bump the major version without explicit instruction.
- **Minor version** (`X.Y.0`) — bump when a meaningful new feature or capability ships (e.g. a new screen, a new integration, a significant UX addition).
- **Patch version** (`X.Y.Z`) — bump when shipping a fix or small improvement with no new surface area.
- Always update both files together in the same commit whenever the version changes.
