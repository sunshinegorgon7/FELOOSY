# Feature Shipping Checklist

Blast-radius playbook for shipping a new feature. Run this top-to-bottom before starting implementation. The checklist **learns** — when something bites us, add a lesson at the bottom so the next feature doesn't repeat it.

---

## Phase 1 — Design

- [ ] Read this entire checklist first.
- [ ] Write a spec in `docs/superpowers/specs/<feature-name>.md` for non-trivial features.
- [ ] If the feature involves a financial calculation (carry-over, recurring amounts, period math, rounding): read `docs/algorithm-decisions.md` and confirm the approach before writing code.
- [ ] If the feature introduces a new calculation or non-obvious logic: add an entry to `docs/algorithm-decisions.md` before or during implementation.
- [ ] Identify the access tier dimension: does this feature differ between Free / Pro / SMS? If yes, mark the row in `docs/feature-gating.md` before coding.
- [ ] Identify all UX surfaces that will be affected: screens, modals, bottom sheets, home widget.
- [ ] Check if the feature is Android-only (SMS, home widget, SMS receiver) — confirm iOS fallback behavior.

---

## Phase 2 — Schema & Data

- [ ] If new table: write the `CREATE TABLE` SQL and add a migration in `DatabaseHelper._onUpgrade()`. Increment `_kDbVersion`.
- [ ] If new column: add an `ALTER TABLE ADD COLUMN` migration. Confirm default value for existing rows.
- [ ] Update the schema table in `CLAUDE.md` (Section 2) and the schema version noted in `README.md`'s Tech Stack table.
- [ ] New model: add `toMap()`, `fromMap()`, `copyWith()` — no Freezed annotations needed.
- [ ] New repository: add to `data/repositories/` and expose via `providers/database_provider.dart`.
- [ ] If the new table holds user data: add export/import in `GoogleDriveBackupService` (backup JSON + restore transaction).
- [ ] If user-facing: add to `LocalExportService` CSV output.

---

## Phase 3 — State & Logic

- [ ] New provider follows `AsyncNotifier` pattern with `ref.invalidateSelf()` on mutations.
- [ ] Provider reads repos via `ref.read(xRepositoryProvider)` — never constructs repos inline.
- [ ] Async reads use `.asData?.value ?? safeDefault` — never `.value!`.
- [ ] Service logic (side effects, background work) lives in `services/` or `domain/services/`, not in providers or widgets.
- [ ] Recurring/background work: confirm it hooks into app resume in `app.dart` if needed.

---

## Phase 4 — UI

- [ ] Colors via `cs = Theme.of(context).colorScheme`. No hardcoded hex.
- [ ] Semantic text: `AppTheme.expenseText(cs)`, `incomeText(cs)`, `warningText(cs)`.
- [ ] Spacing via `gap` package or `SizedBox` — no magic pixel literals without justification.
- [ ] New screen added to `router.dart` with a named route constant.
- [ ] Complex objects passed via `extra`, not path params.
- [ ] If new screen needs a paywall gate: gate fires on `build`, pops modal context first if needed, passes correct `focus` param.
- [ ] Tutorial: does the new feature need a tutorial step? If yes, add to `TutorialOverlay`.
- [ ] Date display: format via `DateFormat` from `intl`, never raw `toString()`.
- [ ] Currency display: format via `CurrencyFormatter` — respects symbol position and decimal rules.

---

## Phase 5 — Feature Gating

- [ ] Gate wired in `access_tier_provider.dart` if tier-dependent.
- [ ] `docs/feature-gating.md` matrix updated with new row or limit change.
- [ ] Paywall screen tested for both `focus=pro` and `focus=sms` if applicable.
- [ ] Dev flavor verified: feature should be fully accessible (tier = subscription).

---

## Phase 6 — Backup, Export & Restore

- [ ] New user-data table: added to `GoogleDriveBackupService` backup JSON (`data` map key = table name).
- [ ] New user-data table: restore transaction in `GoogleDriveBackupService.restore()` clears and re-inserts.
- [ ] New user-facing data: included in `LocalExportService` CSV.
- [ ] Backup `version` key in JSON: increment if structure changed incompatibly.
- [ ] Restore tested with an existing backup that does NOT have the new table/column (backward compat).

---

## Phase 7 — Home Screen Widget

- [ ] Confirm with user whether the widget needs to reflect this change (data, colors, formatting).
- [ ] If yes: update `FeloosyWidgetProvider.kt` (Android) and `FeloosyWidget.swift` (iOS).
- [ ] Widget palette mirrors `AppTheme` — if any `AppTheme` color constant changed, update both native files.
- [ ] `HomeWidgetSyncService` debounce (400ms) is sufficient — no manual flush needed.

---

## Phase 8 — Version & Release

- [ ] Version bumped in `pubspec.yaml` (`version: X.Y.Z+BUILD`) and `lib/core/constants/app_info.dart` (`kAppVersionLabel`).
- [ ] Build number = `git rev-list --count HEAD`.
- [ ] Minor bump for new screen/integration; patch bump for fix or small improvement. Do NOT bump major without repo owner instruction.
- [ ] Both version files updated in the same commit.

---

## Phase 9 — Quality

- [ ] `dart analyze` passes with no new warnings.
- [ ] Manually test the golden path: create, edit, delete the new entity.
- [ ] Test with Free tier account to verify gate fires correctly.
- [ ] Test with Pro tier to verify feature is accessible.
- [ ] Test backup + restore round-trip if new data table added.
- [ ] Test on Android (SMS features) and verify iOS fallback.
- [ ] If any UI string added: confirm it's not hardcoded in a way that would break if i18n is added later (use variable names that describe the content, not the position).

---

## Phase 10 — Docs & Lessons

- [ ] Update `docs/algorithm-decisions.md` if a non-obvious calculation or logic was introduced.
- [ ] Update `docs/feature-gating.md` if a new gate or limit was added.
- [ ] Update `CLAUDE.md` Section 2 database table and `README.md`'s schema version if schema changed.
- [ ] Add any new lesson to the **Lessons Learned** section below.

---

## Lessons Learned

*Add a row here whenever something bites during shipping so the next feature doesn't repeat it.*

| Date | Lesson |
|---|---|
| — | When storing purchase state, use `flutter_secure_storage` only — not SQLite. Storing it in SQLite allows tampering via DB replacement. |
| — | Default category UUIDs are foreign keys in user databases. Never regenerate or reorder them; use `kDefaultCategoryUuids` for all positional alignment. |
| — | Paywall navigation from inside a modal bottom sheet requires `Navigator.pop()` before `context.push('/paywall')` — skipping this leaves a ghost route on the stack. |
| — | Monthly recurring rules must anchor to `start_date`'s day-of-month, not roll 30 days from last run. 30-day rolling causes visible drift within a few months. |
| — | `getDescriptionSuggestions` in `TransactionRepository` uses a non-deterministic GROUP BY for `category_uuid` in SQLite — known bug, tracked in `docs/task_proposals.md`. Fix before relying on suggestion accuracy. |
