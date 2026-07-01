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
- Filterable: `source = 'carryover'` lets analysis exclude it cleanly
- Recalculated every load but self-correcting in place (see Self-healing below) rather than being purely ephemeral — still gives a stable row to point at (same `uuid` persists across corrections) while never going stale

**Running balance, not a per-period delta:** `net = prevCarryOverNet + prevBudget - prevExpenses + prevIncome`, where `prevCarryOverNet` is the signed amount of the *previous period's own* carry-over transaction — excluded from `prevExpenses`/`prevIncome` so it isn't double-counted as a regular transaction, but re-added as a level so a deficit or surplus persists across periods until it's actually paid off, instead of resetting to just that period's own delta. This matches standard rollover-budget behavior (e.g. YNAB-style rollover): an outstanding deficit should stay outstanding until spending genuinely catches up.

- `net > 0` → income transaction (net surplus rolled forward, increases available budget)
- `net < 0` → expense transaction (net deficit rolled forward, reduces available budget)
- `net == 0` → no transaction created

**Zero-activity guard:** A nonzero inherited balance must persist even through a period with no new transactions, so the early-exit only fires when *both* the previous period had no new transactions *and* its carried-in balance was zero — not on empty transactions alone.

**Bug history:** An earlier version of this formula excluded the previous period's carry-over from the sum (to avoid double-counting it as a regular transaction) but never added it back in — i.e. `net = prevBudget - prevExpenses + prevIncome` with no `prevCarryOverNet` term. This silently erased most of an outstanding deficit the moment a later period performed only slightly better than budget. Example that surfaced it: May ended at -1739.11, June ended at -1644.15 (June's own spending was actually +94.96 better than budget). The old formula carried forward only that +94.96 as an *income* transaction into July, instead of the correct -1644.15 expense — the -1739.11 debt from May just vanished. Fixed by re-adding `prevCarryOverNet` as a persistent level rather than treating it as something to prevent from "compounding." What was documented here as intentional "cascade prevention" was actually the bug.

**Self-healing:** Every call to `CarryOverService.generateIfNeeded()` recomputes `net` from scratch and calls `TransactionRepository.syncCarryOver()`, which atomically inserts the row if absent, corrects it in place if the stored amount/type has drifted from the fresh calculation, or deletes it if `net` is now zero — all in one DB transaction, so concurrent builds can't race each other. This means a stale carry-over (from a formula fix, or from editing a transaction in an already-completed period) self-corrects the next time that period's summary loads, with no manual intervention needed. The prior design only inserted once and then skipped forever if a row already existed — that's what let a formula bug's bad output persist indefinitely; it's why this was changed to always-recompute-and-sync.

**Budget math:** `budgetSummaryProvider` passes carry-over transactions as `carryOverAmount` (signed) and excludes them from `regularTxs` sent to `BudgetService.computeSummary`. This avoids double-counting: the transaction is in the DB (visible in the list) but the budget formula uses the dedicated field.

**Excluded from analysis:** `LocalAnalysisService` filters `isCarryOver` before aggregating category totals or building AI insights. Carry-over is a system adjustment, not real spending.

**Triggered in:** `budget_summary_provider.dart` — calls `CarryOverService.generateIfNeeded()` on every build. Self-healing makes repeated calls harmless and self-correcting; only visiting a period actually re-syncs it, so a stale value in a period the user hasn't opened since a formula fix won't update until they view it (and, if a later period's carry-over was computed from that stale value, that later period needs a visit too to pick up the correction).

**Implemented in:** `lib/services/carry_over_service.dart`, `lib/providers/budget_summary_provider.dart`.

**Don't break this if you…**
- Change how budget amounts are fetched — the carry-over net uses the previous period's budget, not the current one.
- Add multi-currency support — carry-over comparison only makes sense within a single currency account.
- Touch `resetAll()` in `database_helper.dart` — must also re-insert the `kCarryOverCategoryUuid` system category.

**Rejected alternative:** Global carry-over toggle in `app_settings`. Rejected because different wallets may have different preferences.

**Rejected alternative:** Display-only `carryOverAmount` field with no DB transaction. Rejected because it couldn't be excluded from analysis cleanly and gave the user no transaction-level transparency — even though both approaches now recalculate on every load, only the persistent-transaction approach is filterable and visible in the ledger.

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
