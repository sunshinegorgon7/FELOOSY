# FELOOSY

FELOOSY is a local-first personal budgeting app for iOS and Android. The model is intentionally simple: wallets hold balances, transactions move money in or out, and budget periods reset on the user's chosen month-start day.

## Features

- **Fast expense and income logging** - amount-first entry, description autocomplete, frequent categories, and inline category creation.
- **Multiple wallets** - per-wallet currency, default monthly budget, month-start override, carry-over toggle, and favorite wallet support.
- **Budget periods** - current and past period navigation with wallet filtering and automatic budget-row creation.
- **Budget carry-over** - per-wallet toggle that rolls any unused monthly surplus forward into the next period; disabled by default.
- **History** - monthly or yearly transaction groups with expandable category charts and filters.
- **Categories** - built-in expense and income categories, custom colors/icons, and active/inactive management.
- **Recurring transactions** - daily, weekly, monthly, and annual repeats with single-occurrence or future-occurrence edits.
- **AI/local insights** - completed periods are summarized with Gemini when available, with a local fallback cached in SQLite.
- **SMS rules** - Android/dev-facing automation for matching bank SMS messages, scanning past SMS, and importing matched transactions.
- **Backups** - Google Drive `appDataFolder` backup/restore plus local JSON export/import.
- **Home screen widgets** - native Android and iOS budget summary widgets kept in sync from Flutter.
- **Themes and settings** - light, dark, or system theme, currency selection, custom month start, reset, and developer snapshot mode.
- **Monetization** - Pro lifetime purchase unlocks gated features in production; dev flavor treats Pro gates as unlocked.

## Tech Stack

| Layer | Choice |
| --- | --- |
| App | Flutter / Dart |
| State | Riverpod manual `Provider`, `NotifierProvider`, and `AsyncNotifierProvider` |
| Database | SQLite via `sqflite` (schema v18) |
| Navigation | GoRouter |
| Charts | `fl_chart` |
| AI | `google_generative_ai` / Gemini |
| Cloud backup | Google Sign-In + Google Drive `appDataFolder` |
| Purchases | `in_app_purchase` + `flutter_secure_storage` |
| Home widget bridge | `home_widget` plus native Android/iOS widget code |
| Android native bridges | Kotlin `EventChannel` / `MethodChannel` for SMS, inbox scan, widget, and window-focus hooks |

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Create the local Gemini key file if it is not present. This file is gitignored:

```dart
// lib/core/constants/api_keys.dart
const kGeminiApiKey = 'YOUR_GEMINI_API_KEY';
```

Run the app on Android:

```bash
# Dev flavor -> feloosy_dev.db, debug banner, Pro gates unlocked
flutter run --flavor dev -t lib/main_dev.dart

# Prod flavor -> feloosy.db
flutter run --flavor prod -t lib/main.dart
```

Run the app on iOS with the Dart entry point directly:

```bash
flutter run -t lib/main_dev.dart
flutter run -t lib/main.dart
```

Useful commands:

```bash
# Tests
flutter test
flutter test test/widget_test.dart

# Static analysis
dart analyze

# Android builds
flutter build apk --flavor prod -t lib/main.dart
flutter build appbundle --flavor prod -t lib/main.dart

# iOS build
flutter build ios -t lib/main.dart
```

The current codebase does not require generated Riverpod/Freezed/json files. The generator dependencies remain in `pubspec.yaml`, but there are no `@riverpod`, Freezed models, or generated `part` files in the app code at the moment.

## Architecture

```text
lib/
|-- app/           # App shell, router, theme, and flavor setup
|-- core/          # Constants and shared utilities
|-- data/          # SQLite helper, models, and repositories
|-- domain/        # Entities and stateless business services
|-- providers/     # Riverpod state and dependency injection
|-- presentation/  # Screens and widgets
|-- services/      # Runtime integration services
`-- dev/           # Snapshot/test-data tooling
```

Data flow is one way: UI watches a provider, the provider calls a repository or service, and repositories talk to `DatabaseHelper`. SQLite is the source of truth. Google Drive backup is on-demand, with a silent backup attempt when the app pauses and a signed-in Drive account is available.

## Flavors

`AppFlavor` is initialized by the Dart entry point:

| Entry point | Flavor | Database |
| --- | --- | --- |
| `lib/main_dev.dart` | `dev` | `feloosy_dev.db` |
| `lib/main.dart` | `prod` | `feloosy.db` |

Android also defines matching Gradle product flavors, `dev` and `prod`, in `android/app/build.gradle.kts`.

## Database

The SQLite schema is currently version 17. Main tables:

| Table | Purpose |
| --- | --- |
| `accounts` | Wallets, currencies, default budgets, favorites, month-start overrides |
| `transactions` | Expenses/income, account link, category link, date, and source (`manual`, `recurring:*`, `sms_rule:*`) |
| `budgets` | Per-account monthly budget rows, unique by account/year/month |
| `categories` | Built-in and custom categories, icon/color metadata, income/expense type |
| `app_settings` | Global settings, theme, backup timestamp, tutorial completion |
| `ai_analysis_cache` | Cached Gemini/local period summaries and retry metadata |
| `sms_rules` | Keyword/regex rules for SMS transaction creation |
| `recurring_rules` | Repeat transaction definitions and generation cursor |

## Native Integrations

- **Google Drive backup** stores private JSON backups in Drive `appDataFolder`, keeps a manifest hash to skip unchanged backups, and retains the five newest backup files.
- **Local export/import** shares or restores a FELOOSY JSON backup file.
- **Android SMS automation** uses `RECEIVE_SMS`, `READ_SMS`, `SmsReceiver`, and inbox scanning through `MainActivity`. The settings tile is currently only exposed in dev flavor.
- **Home widgets** live in `android/app/src/main/kotlin/com/feloosy/app/widget/` and `ios/FeloosyWidget/`. `FeloosyApp` listens to account, transaction, budget, and settings changes and schedules widget sync.
- **Purchases** use store products plus secure storage. Pro product ID: `feloosy_pro_lifetime`. Dev flavor returns purchased by default.

## Project Notes

- Default category UUIDs in `lib/core/constants/default_categories.dart` are stable foreign keys; do not change them casually.
- `PRODUCT.md` describes product positioning and monetization intent.
- `DESIGN.md` and `DESIGN.json` describe design direction.
- `CLAUDE.md` contains implementation guidance and codebase conventions.

## Version

**1.4.1** (build 70)
