# Codebase Task Proposals (April 28, 2026)

## 1) Typo fix task
**Issue:** A comment references `_kUuids`, but the actual constant name is `kDefaultCategoryUuids`.

**Why it matters:** This creates confusion when maintaining parallel category arrays.

**Proposed task:**
- Update the comment above `kDefaultCategoryData` to reference `kDefaultCategoryUuids`.

**Acceptance criteria:**
- No comment references `_kUuids`.
- The comment clearly points to `kDefaultCategoryUuids` as the source of index alignment.

---

## 2) Bug fix task
**Issue:** `getDescriptionSuggestions` claims to return each description with the *most recently used* category, but the query selects `category_uuid` while grouping by description. In SQLite, this can return a non-deterministic category for each group.

**Why it matters:** Autocomplete can suggest the wrong category for repeated descriptions, causing incorrect preselection.

**Proposed task:**
- Rewrite the query to deterministically pick the latest row per normalized description (for example using a subquery or window function based on `created_at` and a stable tie-breaker).

**Acceptance criteria:**
- For a description used with multiple categories over time, the suggestion returns the category from the latest transaction.
- Behavior is deterministic across runs.

---

## 3) Code comment / documentation discrepancy task
**Issue:** The method documentation says suggestions are paired with the most recently used category, but the current SQL implementation does not guarantee that behavior.

**Why it matters:** The docs and implementation are out of sync, which misleads maintainers and reviewers.

**Proposed task:**
- After fixing the query, update the doc comment to describe the exact selection rule (including tie-break behavior when timestamps are equal).

**Acceptance criteria:**
- Method comment matches the implemented SQL behavior exactly.
- The tie-break behavior is documented.

---

## 4) Test improvement task
**Issue:** `test/widget_test.dart` is a placeholder (`expect(true, isTrue)`) and does not validate app behavior.

**Why it matters:** The widget test suite does not catch UI regressions.

**Proposed task:**
- Replace the placeholder with at least one meaningful widget test (for example: rendering the settings screen with provider overrides and asserting key tiles are present).
- Add a regression test for description suggestion behavior from Task #2.

**Acceptance criteria:**
- Placeholder test removed.
- New widget test verifies at least one real UI contract.
- New repository-level/unit test covers latest-category selection for suggestions.
