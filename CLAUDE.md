# CLAUDE.md

FELOOSY is a Flutter personal budgeting app for iOS and Android. Local-first SQLite, no backend. Riverpod state layer, GoRouter navigation, local AI insights + on-device Gemma model, Google Drive backup, Android SMS auto-parsing. This file is the index — detail lives in [docs/](docs/).

---

## 1. Project Overview & Stack

| Layer | Technology | Version |
|---|---|---|
| **Language / SDK** | Dart | `^3.11.5` |
| **Framework** | Flutter | current stable |
| **App version** | — | `1.4.5+284` (pubspec + app_info.dart must stay in sync) |
| **State management** | flutter_riverpod | `^3.3.1` |
| **Codegen** | riverpod_annotation + build_runner + riverpod_generator | `^4.0.2` |
| **Database** | sqflite (SQLite v31, 29 migration steps) | `^2.3.3` |
| **Navigation** | go_router (path-based, 14 routes) | `^17.2.2` |
| **AI analysis** | local rule-based insights (InsightsService) + on-device Gemma 2 2B GGUF (ModelDownloadService) | — |
| **Authentication** | google_sign_in | `^7.2.0` |
| **Cloud backup** | googleapis (Drive appDataFolder, AES-256-GCM encrypted) | `^16.0.0` |
| **Monetization** | in_app_purchase + Ed25519 license keys | `^3.2.2` |
| **Secure storage** | flutter_secure_storage | `^10.2.0` |
| **Cryptography** | cryptography (Ed25519 license, AES-256-GCM backup) | `^2.7.0` |
| **Charts** | fl_chart | `^1.2.0` |
| **Icons** | lucide_icons | `^0.257.0` |
| **Font** | google_fonts (Geist) | `^8.0.2` |
| **Export/share** | share_plus + file_picker | `^12.0.2` / `^11.0.2` |
| **Home widget** | home_widget | `^0.9.1` |
| **SMS (Android only)** | EventChannel + SmsReceiver.kt | native |
| **Spacing** | gap | `^3.0.1` |
| **IDs** | uuid | `^4.5.1` |
| **Crypto (hash)** | crypto (SHA-256 for AI cache) | `^3.0.0` |
| **HTTP** | http | `^1.2.2` |
| **Permissions** | permission_handler | `^11.3.1` |
| **URL launch** | url_launcher | `^6.3.1` |
| **i18n** | flutter_localizations + intl (English + Arabic) | `^0.20.1` |

**What is NOT here:** Firebase, Firestore, REST APIs, Freezed/json_serializable in use (deps exist but annotations unused), IAP receipt validation server, Gemini cloud API (removed — replaced by local analysis).

**Flavors:** Two only — `dev` and `prod`. No UAT.
- `lib/main_dev.dart` → `Flavor.dev` → `feloosy_dev.db`
- `lib/main.dart` → `Flavor.prod` → `feloosy.db`
- Dev always resolves to `AccessTier.pro` — paywall never appears.

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
| Brand category UUIDs | `core/constants/brand_categories.dart` → `kBrandCategoryUuids` | Any hardcoded UUID string in code |
| Access tier | `providers/access_tier_provider.dart` | Re-reading secure storage directly |
| Navigation | `app/router.dart` path constants | Named-route calls (`context.goNamed(...)` — not used) |
| Blurred amounts | `core/widgets/discreet_amount.dart` → `DiscreetAmount` | Custom blur logic in widgets |

**Key files to read before touching load-bearing code:**
- Budget period / month-start: [core/utils/month_calculator.dart](lib/core/utils/month_calculator.dart)
- Feature gating logic: [providers/access_tier_provider.dart](lib/providers/access_tier_provider.dart) → deeper in [docs/feature-gating.md](docs/feature-gating.md)
- Carry-over + budget summary: [providers/budget_summary_provider.dart](lib/providers/budget_summary_provider.dart) → see [docs/algorithm-decisions.md](docs/algorithm-decisions.md)
- All routes: [app/router.dart](lib/app/router.dart)
- DB migrations: [data/database/database_helper.dart](lib/data/database/database_helper.dart) — currently v31
- License system: [services/license_service.dart](lib/services/license_service.dart)
- Remote config / version gate: [services/remote_config_service.dart](lib/services/remote_config_service.dart)
- Backup encryption: [core/utils/backup_encryption.dart](lib/core/utils/backup_encryption.dart)

**Database Schema (SQLite v31):**

| Table | Key columns |
|---|---|
| `accounts` | id, name, currency_code, currency_symbol, currency_symbol_leading, default_monthly_budget, is_favorite, month_start_day, carry_over_enabled, created_at, updated_at |
| `transactions` | id, uuid, account_id, amount, type (expense/income), description, category_uuid, transaction_date, source (manual/sms_rule:id/recurring:uuid/carryover), created_at, updated_at |
| `budgets` | id, account_id, year, month, amount, currency_code — unique (account_id, year, month) |
| `categories` | id, uuid, name, color_value, icon_code_point, icon_font_family, is_custom, is_active, sort_order, transaction_type, logo_url (always NULL — feature removed v30), currency_hint |
| `app_settings` | singleton (id=1): theme_mode, color_theme, currency_code, currency_symbol, currency_symbol_leading, month_start_day, google_backup_enabled, last_backup_at, default_monthly_budget, tutorial_completed, favorite_account_id, privacy_accepted_at, language_code, sms_opt_in, discreet_mode |
| `sms_rules` | id, keyword, description, category_uuid, transaction_type, amount_regex, is_active, created_at |
| `sms_rule_accounts` | id, sms_rule_id → sms_rules(id), account_id — UNIQUE(sms_rule_id, account_id) — many-to-many junction |
| `sms_suggestion_feedback` | id, keyword, action, created_at |
| `recurring_rules` | uuid (PK), account_id, amount, type, description, category_uuid, frequency (daily/weekly/monthly/annually), start_date, last_generated_date, is_active, created_at, updated_at |
| `ai_analysis_cache` | hash (PK), group_label, summary, insights (JSON), advice, source, created_at, retry_after |

All timestamps: milliseconds-since-epoch integers. Never store datetimes as ISO strings.

**Category UUIDs — three pools, all stable:**
- Default categories: `kDefaultCategoryUuids` in `default_categories.dart` — 34 user-facing categories (UUIDs `...000001` – `...000018` original 18, `...000069` – `...000084` newer batch)
- Brand categories: `kBrandCategoryUuids` in `brand_categories.dart` — region-specific brands (UUIDs `...000019` – `...000068`); sort_order starts at 1000
- Carry-over system category: `kCarryOverCategoryUuid = '...000099'` — hidden from all pickers/charts

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
enum AccessTier { free, pro }
// Resolution order: dev flavor > valid license key > purchase > active trial > free
// Resolved in access_tier_provider.dart — synchronous; loading async providers → free (conservative)
// Dev flavor always returns pro.

enum ProSource { none, trial, purchase, license }
// proSourceProvider tells you HOW the user got Pro (for UI/analytics)
```

**Monetization products:**
- `feloosy_pro_lifetime` — $9.99 one-time, unlocks everything (unlimited wallets + transactions, full history, backup, export, custom categories, SMS auto-parsing)
- Trial: 14-day trial of Pro features, stored as first-launch timestamp in `flutter_secure_storage`
- License keys: Ed25519-signed, issued offline by dev app, verified against embedded public key + remote revocation list via Gist config
- Purchase state + license keys: `flutter_secure_storage` ONLY. Never SQLite — it resists tampering.

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
- 34 default categories + brand categories have stable UUIDs in `kDefaultCategoryUuids` / `kBrandCategoryUuids`.
- These are used as foreign keys in existing user databases. Changing them breaks all existing data.
- The carry-over system category (`kCarryOverCategoryUuid = '...000099'`) is NOT in `kDefaultCategoryUuids` — it is hidden from all pickers and charts.

**Feature gates — always default to the restrictive side on loading:**
```dart
// Safe pattern: .asData?.value ?? false
final isPro = ref.watch(purchaseProvider).asData?.value ?? false;
// Never: ref.watch(purchaseProvider).value! — throws on loading state
// For the resolved tier:
final tier = ref.watch(accessTierProvider);  // synchronous, safe
```

**Provider dependencies — use database_provider.dart:**
- Repos are provided as `Provider<XRepository>` in `database_provider.dart`.
- Read them in notifiers with `ref.read(xRepositoryProvider)`.
- Never instantiate `XRepository(DatabaseHelper.instance)` inline in a notifier.

**Navigation — use path-based routes:**
- The router uses raw path strings, not named routes. Use `context.go('/path')`, not `context.goNamed(...)`.
- Pass complex objects via `extra`. Never serialize them into the path.
- Paywall: pop any modal context before pushing `/paywall` to avoid navigation stack corruption.
- All 14 routes are in `app/router.dart`.

**Discreet mode — wrap monetary amounts with `DiscreetAmount`:**
- When `discreetMode` is on in settings, monetary values should be blurred.
- Wrap the widget displaying the amount with `DiscreetAmount(child: ...)` from `core/widgets/discreet_amount.dart`.
- Do not re-implement the blur logic inline.

**Home widget parity:**
- If you change app colors, data fields shown, or formatting on the home screen, **ask the user** whether the widget should match before touching `FeloosyWidgetProvider.kt` or `FeloosyWidget.swift`.
- Widget palette is separate from app theme (widget runs outside app process, adapts to system dark/light).

**Version bumping:**
- Always update BOTH `pubspec.yaml` (`version: X.Y.Z+BUILD`) AND `lib/core/constants/app_info.dart` (`kAppVersionLabel` + `kAppBuildNumber`).
- Build number = `git rev-list --count HEAD`.
- **Version rollover rule:** No octet (X, Y, or Z in X.Y.Z) may ever display as 10 or higher — each octet caps at 9, odometer-style. When a bump would take an octet to 10, reset it to 0 and increment the octet to its left instead:
  - Patch rolls at Z: **9 → 10** becomes minor+1, patch 0 (e.g. `1.4.9` → `1.5.0`, not `1.4.10`).
  - This cascades: if that same bump also takes minor (Y) from **9 → 10**, minor resets to 0 and major increments (e.g. `1.9.9` → `2.0.0`, not `1.10.0`).
- Do not bump major version without explicit instruction from the repo owner — this still applies even when a patch/minor rollover would cascade into one. If a version bump would cascade into the major octet, stop and confirm with the repo owner before applying it; do not auto-bump major.

**Recurring rules — monthly anchor:**
- Monthly/annual recurrences anchor to the rule's `start_date` day-of-month, not "30 days from last run". See [docs/algorithm-decisions.md](docs/algorithm-decisions.md) for why.

**AI cache hashing:**
- The cache hash is SHA-256 of sorted transaction UUIDs + amounts + budget. Sorted because insertion order is arbitrary. See [docs/algorithm-decisions.md](docs/algorithm-decisions.md).

**Remote config / version gate:**
- `RemoteConfigService` fetches a JSON config from a GitHub Gist URL stored in `kRemoteConfigUrl` (app_info.dart).
- If `min_build` in the config exceeds `kAppBuildNumber`, `UpdateRequiredScreen` is shown and the app is locked.
- The config also carries a `revoked_identifiers` list checked by `licenseProvider`.
- Fails open: any network error returns `RemoteConfig.passthrough()` (no block, no revocations).
- Dev builds skip the fetch entirely.

**Backup encryption:**
- Backup files are AES-256-GCM encrypted. The key is hardcoded in `BackupEncryption`.
- Old plain-JSON backups are detected by the absence of the magic header and handled transparently.
- Never write a plain-JSON backup for new users.

**License keys:**
- Ed25519-signed keys. Format: `"identifier:base64url_signature"`.
- Verification uses the public key embedded in `LicenseService._publicKeyBytes`.
- After rotating the keypair, move the old public key to `_legacyPublicKeyBytesList` so old keys still verify.
- To revoke a single key: add its identifier to the Gist config (`revoked_identifiers`). To revoke permanently: add full key string to `_blocklist` and ship an update.

---

## 4. Push Back When I'm Wrong

If a proposed implementation conflicts with an established pattern, a financial correctness principle, a data-integrity rule (especially category UUIDs or purchase storage), or would create a worse UX — **say so once, clearly, before implementing**. State what the problem is and propose an alternative. If I still want the original approach after hearing the objection, implement what I pick without re-arguing.

This applies especially to:
- Storing purchase state or license keys anywhere other than `flutter_secure_storage`
- Changing or regenerating default/brand category UUIDs
- Bypassing `MonthCalculator` for period date math
- Hardcoding colors instead of using the theme
- Implementing financial calculations (carry-over, rounding, recurring amounts) without verifying the logic
- Using `context.goNamed(...)` — this project uses path-based routing

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
- Pro product: `feloosy_pro_lifetime` / $9.99 (update price in App Store / Play Console)
- DB name (dev): `feloosy_dev.db` / (prod): `feloosy.db`
- Version octet cap: 9 for both minor and patch (X.Y.Z — each rolls to the octet on its left at 10, cascading; see Version bumping above)

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
- [ ] Route added to `router.dart` if new screen (path-based, not named)
- [ ] Colors via `cs = Theme.of(context).colorScheme` — no hardcoded hex
- [ ] Dates stored as millisecondsSinceEpoch, period math via `MonthCalculator`
- [ ] Monetary amounts displayed via `DiscreetAmount` wrapper
- [ ] Backup: new table included in `GoogleDriveBackupService` export/restore
- [ ] Export: new table/fields included in `LocalExportService` if user-facing data
- [ ] Version bumped in both `pubspec.yaml` and `app_info.dart` (respect patch rollover rule)
- [ ] Widget parity confirmed with user (if home data or colors changed)
- [ ] Algorithm decision logged in `docs/algorithm-decisions.md` if non-obvious logic
- [ ] Shipping checklist updated with any new lessons learned
