# CLAUDE.md

FELOOSY is a Flutter personal budgeting app for iOS and Android. Local-first SQLite, no backend. Riverpod state layer, GoRouter navigation, Gemini AI analysis, Google Drive backup, Android SMS auto-parsing. This file is the index — detail lives in [docs/](docs/).

---

## 1. Project Overview & Stack

| Layer | Technology | Version |
|---|---|---|
| **Language / SDK** | Dart | `^3.11.5` |
| **Framework** | Flutter | current stable |
| **App version** | — | `1.4.1+70` (pubspec + app_info.dart must stay in sync) |
| **State management** | flutter_riverpod | `^3.3.1` |
| **Codegen** | riverpod_annotation + build_runner + riverpod_generator | `^4.0.2` |
| **Database** | sqflite (SQLite v18, 18 migrations) | `^2.3.3` |
| **Navigation** | go_router (12 named routes) | `^17.2.2` |
| **AI analysis** | google_generative_ai (Gemini 1.5 Flash, JSON mode) | `^0.4.0` |
| **Authentication** | google_sign_in | `^7.2.0` |
| **Cloud backup** | googleapis (Drive appDataFolder) | `^16.0.0` |
| **Monetization** | in_app_purchase | `^3.2.2` |
| **Secure storage** | flutter_secure_storage | `^10.2.0` |
| **Charts** | fl_chart | `^1.2.0` |
| **Icons** | lucide_icons | `^0.257.0` |
| **Font** | google_fonts (Geist) | `^8.0.2` |
| **Export/share** | share_plus + file_picker | `^12.0.2` / `^11.0.2` |
| **Home widget** | home_widget | `^0.9.1` |
| **SMS (Android only)** | EventChannel + SmsReceiver.kt | native |
| **Spacing** | gap | `^3.0.1` |
| **IDs** | uuid | `^4.5.1` |
| **Crypto** | crypto (SHA-256 for AI cache) | `^3.0.0` |

**What is NOT here:** Firebase, Firestore, REST APIs, Freezed/json_serializable in use (deps exist but annotations unused), i18n/l10n (English-only, intl used only for date + number formatting), IAP receipt validation server.

**Flavors:** Two only — `dev` and `prod`. No UAT.
- `lib/main_dev.dart` → `Flavor.dev` → `feloosy_dev.db`
- `lib/main.dart` → `Flavor.prod` → `feloosy.db`
- Dev always resolves to `AccessTier.subscription` — paywall never appears.

**Common commands:**
```bash
flutter run -t lib/main_dev.dart          # dev run
flutter run -t lib/main.dart              # prod run
flutter build apk
flutter build ios
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
dart analyze
git rev-list --count HEAD                 # build number for pubspec
```

---

## 2. Architecture & Import Rules

**Layer order (data flows down, never up):**
```
UI (presentation/) → Providers (providers/) → Repositories (data/repositories/) → DatabaseHelper (data/database/)
                                            → Services (domain/services/ + services/)
```

**Import rules — read before touching any of these:**

| Need | Import from | Never duplicate in |
|---|---|---|
| DB access | `data/database/database_helper.dart` | Any other file — it's a singleton |
| Repository instances | `providers/database_provider.dart` | Construct repos inline in notifiers |
| Theme colors | `app/app_theme.dart` via `Theme.of(context).colorScheme` | Hard-coded hex in widgets |
| Semantic text colors | `AppTheme.expenseText(cs)` / `incomeText(cs)` / `warningText(cs)` | Custom `TextStyle(color: ...)` for semantic roles |
| Budget period math | `core/utils/month_calculator.dart` | Inline `DateTime` arithmetic for period boundaries |
| Currency formatting | `core/utils/currency_formatter.dart` | `NumberFormat` or `intl` directly in widgets |
| Default category UUIDs | `core/constants/default_categories.dart` → `kDefaultCategoryUuids` | Any hardcoded UUID string in code |
| Access tier | `providers/access_tier_provider.dart` | Re-reading secure storage directly |
| Navigation | `app/router.dart` named route constants | Inline string paths in `context.go()` calls |

**Key files to read before touching load-bearing code:**
- Budget period / month-start: [core/utils/month_calculator.dart](lib/core/utils/month_calculator.dart)
- Feature gating logic: [providers/access_tier_provider.dart](lib/providers/access_tier_provider.dart) → deeper in [docs/feature-gating.md](docs/feature-gating.md)
- Carry-over + budget summary: [providers/budget_summary_provider.dart](lib/providers/budget_summary_provider.dart) → see [docs/algorithm-decisions.md](docs/algorithm-decisions.md)
- All routes: [app/router.dart](lib/app/router.dart)
- DB migrations: [data/database/database_helper.dart](lib/data/database/database_helper.dart) — currently v18

**Database Schema (SQLite v18):**

| Table | Key columns |
|---|---|
| `accounts` | id, name, currency_code, currency_symbol, currency_symbol_leading, default_monthly_budget, is_favorite, month_start_day, carry_over_enabled |
| `transactions` | id, uuid, account_id, amount, type (expense/income), description, category_uuid, transaction_date, source (manual/sms_rule:id/recurring:uuid) |
| `budgets` | id, account_id, year, month, amount, currency_code — unique (account_id, year, month) |
| `categories` | id, uuid, name, color_value, icon_code_point, icon_font_family, is_custom, is_active, sort_order, transaction_type |
| `app_settings` | singleton (id=1): theme_mode, color_theme, currency_code, month_start_day, google_backup_enabled, last_backup_at, tutorial_completed, favorite_account_id |
| `sms_rules` | id, keyword, description, category_uuid, transaction_type, account_id, amount_regex, is_active |
| `recurring_rules` | uuid (PK), account_id, amount, type, description, category_uuid, frequency (daily/weekly/monthly/annually), start_date, last_generated_date, is_active |
| `ai_analysis_cache` | hash (PK), group_label, summary, insights (JSON), advice, source, created_at, retry_after |

All timestamps: milliseconds-since-epoch integers. Never store datetimes as ISO strings.

**Provider pattern:**
```dart
@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<List<Transaction>> build() =>
      ref.read(transactionRepositoryProvider).getAll();

  Future<void> add(Transaction t) async {
    await ref.read(transactionRepositoryProvider).insert(t);
    ref.invalidateSelf();   // always invalidate, never patch state manually
  }
}
```
Read providers synchronously with `ref.read(xProvider)`. Watch with `ref.watch(xProvider)`. Use `.asData?.value ?? safeDefault` for async values in build methods — do not throw or crash on loading state.

**Access tier resolution (read before writing any gate):**
```dart
enum AccessTier { free, pro, subscription }
// Resolved in access_tier_provider.dart from: purchaseProvider + smsSubscriptionProvider + trialProvider
// Dev flavor always returns subscription.
```

**Monetization products:**
- `feloosy_pro_lifetime` — $4.99 one-time Pro tier
- `feloosy_sms_monthly` — recurring SMS tier subscription
- Trial: 14-day trial for SMS features, stored as first-launch timestamp in `flutter_secure_storage`
- Purchase state: `flutter_secure_storage` ONLY. Never SQLite — it resists tampering.

**Android-only features:**
- SMS auto-parsing: `SmsReceiver.kt` → `SmsSink.kt` → `EventChannel("com.feloosy/sms")` → `SmsTransactionService`
- SMS inbox scan: `MethodChannel("com.feloosy/sms_inbox")`
- Home screen widget: `FeloosyWidgetProvider.kt`
- iOS has none of the above.

---

## 3. Conventions That Bite If Ignored

**Colors — always use the theme, never hardcode:**
```dart
final cs = Theme.of(context).colorScheme;   // cs is the established shorthand
// Use semantic helpers for text on colored backgrounds:
AppTheme.expenseText(cs)    // ledger red, contrast-safe
AppTheme.incomeText(cs)     // ledger green, contrast-safe
AppTheme.warningText(cs)    // amber, contrast-safe
AppTheme.primaryText(cs)    // primary-colored text
// Category bar colors:
AppTheme.categoryBarColor(colorValue, isDark)
```
Never call `AppTheme.ledgerRed` or `AppTheme.forestGreen` directly in a widget — always go through `cs` so dark mode works.

**Date handling — always use MonthCalculator for period boundaries:**
- Budget periods respect per-account `month_start_day` (1–28). Month boundaries are NOT always the 1st.
- Use `MonthCalculator.periodFor(date, monthStartDay)` to get period start/end.
- Store dates as `millisecondsSinceEpoch`. Convert on read: `DateTime.fromMillisecondsSinceEpoch(ms)`.
- For date-only comparisons use `DateUtils.dateOnly(dt)` (Flutter built-in), not `DateTime(y, m, d)`.
- Never assume "this month" means the calendar month — always query `monthStartDay` from the account.

**Default category UUIDs — never change, never regenerate:**
- 18 default categories have stable UUIDs in `kDefaultCategoryUuids` (default_categories.dart).
- These are used as foreign keys in existing user databases. Changing them breaks all existing data.
- DB migrations v11–14 relied on positional alignment between `kDefaultCategoryData` and `kDefaultCategoryUuids`. Keep them in sync.

**Feature gates — always default to the restrictive side on loading:**
```dart
// Safe pattern: .asData?.value ?? false
final isPro = ref.watch(purchaseProvider).asData?.value ?? false;
// Never: ref.watch(purchaseProvider).value! — throws on loading state
```

**Provider dependencies — use database_provider.dart:**
- Repos are provided as `Provider<XRepository>` in `database_provider.dart`.
- Read them in notifiers with `ref.read(xRepositoryProvider)`.
- Never instantiate `XRepository(DatabaseHelper.instance)` inline in a notifier.

**Navigation — use named routes:**
- All route constants are in `router.dart`. Use `context.goNamed(...)` not `context.go('/raw-path')`.
- Pass complex objects via `extra`. Never serialize them into the path.
- Paywall: pop any modal context before pushing `/paywall` to avoid navigation stack corruption.

**Home widget parity:**
- If you change app colors, data fields shown, or formatting on the home screen, **ask the user** whether the widget should match before touching `FeloosyWidgetProvider.kt` or `FeloosyWidget.swift`.
- Widget palette is separate from app theme (widget runs outside app process, adapts to system dark/light).

**Version bumping:**
- Always update BOTH `pubspec.yaml` (`version: X.Y.Z+BUILD`) AND `lib/core/constants/app_info.dart` (`kAppVersionLabel`).
- Do not bump major version without explicit instruction from the repo owner.
- Build number = `git rev-list --count HEAD`.

**Recurring rules — monthly anchor:**
- Monthly/annual recurrences anchor to the rule's `start_date` day-of-month, not "30 days from last run". See [docs/algorithm-decisions.md](docs/algorithm-decisions.md) for why.

**AI cache hashing:**
- The cache hash is SHA-256 of sorted transaction UUIDs + amounts + budget. Sorted because insertion order is arbitrary. See [docs/algorithm-decisions.md](docs/algorithm-decisions.md).

---

## 4. Push Back When I'm Wrong

If a proposed implementation conflicts with an established pattern, a financial correctness principle, a data-integrity rule (especially category UUIDs or purchase storage), or would create a worse UX — **say so once, clearly, before implementing**. State what the problem is and propose an alternative. If I still want the original approach after hearing the objection, implement what I pick without re-arguing.

This applies especially to:
- Storing purchase state anywhere other than `flutter_secure_storage`
- Changing default category UUIDs
- Bypassing `MonthCalculator` for period date math
- Hardcoding colors instead of using the theme
- Implementing financial calculations (carry-over, rounding, recurring amounts) without verifying the logic

---

## 5. Financial Accuracy — Research Before Coding

Budgeting and personal finance rules have non-obvious edge cases. Before implementing any new financial calculation or rule:

1. **Verify the math** — carry-over, period boundaries, rounding, currency symbol placement. Don't assume; check against how mainstream personal finance apps handle the case.
2. **Log non-obvious decisions** in [docs/algorithm-decisions.md](docs/algorithm-decisions.md) with the reasoning and rejected alternatives.
3. **Flag disagreements** before picking a threshold or formula — e.g., "should carry-over include income surplus or only unused budget?" — ask before assuming.
4. **Never invent plausible numbers** — e.g., default budget amounts, trial lengths, backup retention counts. Use values explicitly decided by the product owner.
5. **Cite the decision** in code comments when the choice is non-obvious (e.g., why recurring monthly rules anchor to start_date day rather than calculating from last_generated_date).

Currently decided values (do not change without explicit instruction):
- Trial length: 14 days
- Max backups retained: 5
- Pro product: `feloosy_pro_lifetime` / $4.99
- SMS product: `feloosy_sms_monthly`
- DB name (dev): `feloosy_dev.db` / (prod): `feloosy.db`

---

## 6. Deeper Docs

| File | Read before… |
|---|---|
| [docs/algorithm-decisions.md](docs/algorithm-decisions.md) | Touching budget period math, carry-over, recurring rule generation, AI cache, SMS parsing |
| [docs/feature-gating.md](docs/feature-gating.md) | Adding any screen, feature, or limit that differs between tiers |
| [docs/feature-shipping-checklist.md](docs/feature-shipping-checklist.md) | Starting any new feature — run this checklist top to bottom |

---

## 7. Adding a New Feature

**Workflow (in order):**

1. Read [docs/feature-shipping-checklist.md](docs/feature-shipping-checklist.md) — identify all touch points.
2. If the feature involves financial logic or a new calculation, log the design decision in [docs/algorithm-decisions.md](docs/algorithm-decisions.md) before writing code.
3. If the feature has a gating dimension (Free vs Pro vs SMS), update [docs/feature-gating.md](docs/feature-gating.md) and wire the gate in `access_tier_provider.dart`.
4. Write a spec in `docs/superpowers/specs/` if the feature is non-trivial.
5. Implement — schema migration first, then repository, then provider, then UI.
6. Update version in both `pubspec.yaml` and `app_info.dart`.
7. Check widget parity — does the home screen widget need a matching update?
8. Add any new lesson to the shipping checklist so the next feature doesn't repeat a mistake.

**Quick checklist:**
- [ ] Schema migration added and version incremented in `database_helper.dart`
- [ ] New model has `toMap()` / `fromMap()` and `copyWith()`
- [ ] Repository added to `database_provider.dart`
- [ ] Provider follows `AsyncNotifier` pattern with `ref.invalidateSelf()` on mutations
- [ ] Feature gate added/updated in `access_tier_provider.dart` + `docs/feature-gating.md`
- [ ] Route added to `router.dart` if new screen
- [ ] Colors via `cs = Theme.of(context).colorScheme` — no hardcoded hex
- [ ] Dates stored as millisecondsSinceEpoch, period math via `MonthCalculator`
- [ ] Backup: new table included in `GoogleDriveBackupService` export/restore
- [ ] Export: new table/fields included in `LocalExportService` if user-facing data
- [ ] Version bumped in both `pubspec.yaml` and `app_info.dart`
- [ ] Widget parity confirmed with user (if home data or colors changed)
- [ ] Algorithm decision logged in `docs/algorithm-decisions.md` if non-obvious logic
- [ ] Shipping checklist updated with any new lessons learned
