# Algorithm Decisions

Why prediction/destructive logic works the way it does. Not a changelog — this records decisions that were non-obvious, have plausible-but-wrong alternatives, or would be easy to "fix" back into a bug.

---

## Budget Period Boundaries (custom month-start day)

**Decision:** Period start/end are computed from the account's `month_start_day` field (1–28), not the calendar month boundary.

**Why:** Users in some markets get paid mid-month (e.g., the 15th). Tracking against a calendar month makes their budget straddle two pay periods, which is useless. Allowing per-account override means each wallet tracks against the user's actual financial cycle.

**How it works (`MonthCalculator`):**
- If today ≥ month_start_day: period starts this month on start_day, ends day before next occurrence.
- If today < month_start_day: period started last month on start_day.
- Year-boundary wraps (e.g., start_day=25, current date=Jan 5) are handled by decrementing the month and adjusting year.

**Don't break this if you…**
- Add any "current period" query — always pass `monthStartDay` from the account, never hardcode 1.
- Add period navigation (offset ±N) — use `MonthCalculator.offsetPeriod(base, offset, monthStartDay)`, not `DateTime(y, m+offset, d)` which breaks on 28/29/30/31 boundaries.

**Rejected alternative:** Use the app-level `month_start_day` from `app_settings` as a global override. Rejected because per-account override is already in the schema and some users have wallets on different cycles.

---

## Carry-Over Logic

**Decision:** Carry-over is per-account, opt-in (`carry_over_enabled` on the `accounts` table). When enabled, both surplus and deficit from the prior period carry into the current period as a **persistent transaction** — income if surplus, expense if deficit.

**Why persistent transaction (not a display-only number):**
- Transparent: the user sees exactly where the adjustment came from in the transaction list
- Stable: computed once per period, not recalculated on every load
- Filterable: `source = 'carryover'` lets analysis exclude it cleanly

**Cascade prevention:** When computing the previous period's net, carry-over transactions in that prior period are excluded. This prevents a chain effect where each month's carry-over compounds the previous month's carry-over.

**Signed carry-over:** `net = prevBudget - prevExpenses + prevIncome`
- `net > 0` → income transaction (surplus rolled forward, increases available budget)
- `net < 0` → expense transaction (deficit rolled forward, reduces available budget)
- `net == 0` → no transaction created

**Idempotency:** Before generating, `CarryOverService` checks whether a `source = 'carryover'` transaction already exists in the current period. Safe to call on every home screen load.

**Budget math:** `budgetSummaryProvider` passes carry-over transactions as `carryOverAmount` (signed) and excludes them from `regularTxs` sent to `BudgetService.computeSummary`. This avoids double-counting: the transaction is in the DB (visible in the list) but the budget formula uses the dedicated field.

**Excluded from analysis:** `LocalAnalysisService` filters `isCarryOver` before aggregating category totals or building AI insights. Carry-over is a system adjustment, not real spending.

**Triggered in:** `budget_summary_provider.dart` — calls `CarryOverService.generateIfNeeded()` on every build. Idempotency makes repeated calls harmless; first call for a new period triggers the insertion.

**Implemented in:** `lib/services/carry_over_service.dart`, `lib/providers/budget_summary_provider.dart`.

**Don't break this if you…**
- Change how budget amounts are fetched — the carry-over net uses the previous period's budget, not the current one.
- Add multi-currency support — carry-over comparison only makes sense within a single currency account.
- Touch `resetAll()` in `database_helper.dart` — must also re-insert the `kCarryOverCategoryUuid` system category.

**Rejected alternative:** Global carry-over toggle in `app_settings`. Rejected because different wallets may have different preferences.

**Rejected alternative:** Display-only `carryOverAmount` field with no DB transaction. Rejected because it recalculated on every load (fragile), couldn't be excluded from analysis cleanly, and gave the user no transaction-level transparency.

---

## Recurring Rule Monthly Anchoring

**Decision:** Monthly and annual rules anchor to the day-of-month from `start_date`, not "30 days from last generated date."

**Example:** Rule starts 2025-01-31. Next occurrence: 2025-02-28 (clamped to month end), then 2025-03-31, not 2025-03-02 (which would drift).

**Why:** "Every month on the 31st" is a meaningful user intent. Rolling 30-day intervals would cause the occurrence to drift through the month over time, breaking the user's mental model.

**Implemented in:** `RecurringTransactionService.generatePending()`.

**Don't break this if you…**
- Change how `last_generated_date` is updated — it records the *logical* occurrence date (even if clamped), not the generation timestamp.
- Add weekly rules — weekly does NOT anchor; it rolls 7 days from last_generated_date. Only monthly/annual anchor.

**Rejected alternative:** Always add 30/365 days. Rejected because it causes visible drift (e.g., "monthly rent" appearing on the 3rd instead of the 1st after a few months).

---

## AI Analysis Cache Hashing

**Decision:** Cache key is SHA-256 of sorted transaction UUIDs concatenated with their amounts and the period budget amount.

**Why sorted:** Transaction insertion order into SQLite is not guaranteed to match display order. If we hash in insertion order, the same logical dataset can produce different hashes, causing unnecessary re-analysis and API quota waste.

**Why include budget amount:** The same transactions with a different budget produce a meaningfully different analysis (the AI commentary on "you're over budget" changes). The budget is a legitimate cache dimension.

**Implemented in:** `AiCacheRepository` + `LocalAnalysisService`.

**Don't break this if you…**
- Add new transaction fields — only UUID + amount are hashed. Adding more fields to the hash without migrating existing cache entries will invalidate all cached results. If you must extend the hash, increment a cache version prefix.
- Change budget currency — the hash uses the raw budget amount. If currency changes, the hash should change too (currency is implicitly tied to the account, so account-scoped caching handles this correctly).

---

## SMS Amount Extraction (currency-agnostic regex)

**Decision:** Amount extraction strips currency symbols and thousands separators before parsing, using a currency-agnostic numeric extraction pass. A custom regex per rule (`amount_regex`) can override this for non-standard SMS formats.

**Why:** Egyptian/Gulf SMS bank messages embed amounts in formats like "EGP 1,234.56" or "١٬٢٣٤٫٥٦ جم" (Arabic numerals). A hard-coded currency symbol list would miss formats. Stripping non-numeric characters (except `.` and `,`) before parsing handles most cases without a symbol database.

**Implemented in:** `SmsParserService.extractAmount()`.

**Don't break this if you…**
- Add a new locale — verify the regex still extracts correctly for comma-as-decimal-separator locales (e.g., German "1.234,56"). Current logic treats the rightmost separator as decimal.
- Change the custom regex field — it is per-rule and nullable. Null means use the default extractor.

---

## Period Offset Caching (`_cachedPeriodOffsets`)

**Decision:** The set of navigable period offsets (past periods with transactions) is cached in a `Set<int>` when home screen data loads, and is NOT re-queried mid-gesture.

**Why:** Without caching, switching accounts mid-swipe could cause the available offsets to change while the user is swiping, enabling/disabling the swipe button during the gesture. This caused a visible flicker and could strand the user on an offset with no data. The cache is intentionally stale until the next full reload.

**Implemented in:** `home_screen.dart` → `_cachedPeriodOffsets`.

**Don't break this if you…**
- Add a "new transaction" shortcut from the home screen — after adding, `invalidateSelf()` on the transactions provider will trigger a rebuild that refreshes the cache.
- Add pagination or infinite scroll — the cached offsets are a bounded set of months with data; any pagination scheme must still validate offset availability from this cache.
