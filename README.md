# FELOOSY

A personal budgeting app for iOS and Android. Dead simple: a wallet has a balance, money goes in or out, and the month resets.

---

## Features

- **Expense & income tracking** — log a transaction in under five seconds
- **Multiple wallets** — manage separate accounts, each with its own currency and monthly budget
- **Budget periods** — swipe between months to review past spending
- **Top spending chart** — glanceable bar chart of where money went this period
- **Categories** — 16 built-in categories with custom colors and icons; add your own
- **Category filtering** — tap a category in the chart to filter the transaction list inline
- **Home screen widget** — monthly spending summary on iOS and Android home screens
- **Google Drive backup** — one-tap backup and restore via your personal Drive (`appDataFolder`; not visible in Drive UI); retains up to 5 backups
- **Light / Dark / System theme** — full design-token–based theme switching
- **Local export & import** — share or import a full JSON dump without needing a Google account

---

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Dart / Flutter |
| State management | Riverpod (code-gen) |
| Local database | SQLite via `sqflite` (schema v9) |
| Navigation | GoRouter |
| Charts | fl_chart |
| Cloud backup | Google Drive (`appDataFolder`) |
| Home widget | home_widget |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run (pick a flavor)
flutter run -t lib/main_dev.dart    # dev  →  feloosy_dev.db
flutter run -t lib/main_prod.dart   # prod →  feloosy.db

# Regenerate code (Riverpod, Freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Lint
dart analyze

# Build
flutter build apk
flutter build ios
```

---

## Architecture

```
lib/
├── app/           # Theme, router, app shell, flavors
├── core/          # Constants (default categories, currencies) and utilities
├── data/          # SQLite DatabaseHelper, models, repositories
├── domain/        # Business entities (BudgetPeriod, BudgetSummary) and services
├── presentation/  # Screens and widgets (ConsumerWidget / ConsumerStatefulWidget)
├── providers/     # Riverpod AsyncNotifierProviders + dependency injection
└── services/      # HomeWidgetSyncService
```

Data flows one way: UI watches a provider → provider calls a repository → repository queries `DatabaseHelper`. Cloud sync is on-demand only; the source of truth is always local.

---

## Version

**1.4.0** (build 69)
