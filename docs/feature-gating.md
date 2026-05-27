# Feature Gating — Free vs Pro vs SMS Subscription

Living matrix. Update this file every time a feature ships or a limit changes. The code gate (`access_tier_provider.dart`) and this doc must stay aligned.

**Tier resolution order (access_tier_provider.dart):**
1. Dev flavor → always `subscription` (no paywall ever in dev)
2. `smsSubscriptionProvider` purchased → `subscription`
3. `purchaseProvider` purchased → `pro`
4. `trialProvider` trial active → `subscription` (14-day SMS trial only; Pro features NOT unlocked by trial)
5. Otherwise → `free`

**Product IDs:**
- Pro: `feloosy_pro_lifetime` (one-time $4.99)
- SMS: `feloosy_sms_monthly` (recurring)

---

## Feature Matrix

| Feature | Free | Pro | SMS Subscription |
|---|---|---|---|
| **Wallets** | 1 | 2 | Unlimited |
| **Transactions / wallet / month** | 10 | 50 | Unlimited |
| **Budget history** | Current month only | Full history | Full history |
| **Custom categories** | ✗ | ✓ | ✓ |
| **Google Drive backup** | ✗ | ✓ | ✓ |
| **Local CSV export** | ✗ | ✓ | ✓ |
| **AI spending analysis** | ✗ | ✓ | ✓ |
| **Recurring transactions** | ✗ | ✓ | ✓ |
| **SMS auto-parsing** | ✗ | Trial (14 days) | ✓ |
| **SMS inbox scan** | ✗ | Trial (14 days) | ✓ |
| **Carry-over budgeting** | ✗ | ✓ | ✓ |
| **Default categories** | ✓ | ✓ | ✓ |
| **Manual transactions** | ✓ (limit applies) | ✓ (limit applies) | ✓ |
| **Dark/light theme** | ✓ | ✓ | ✓ |
| **Home screen widget** | ✓ | ✓ | ✓ |
| **Tutorial** | ✓ | ✓ | ✓ |

---

## Gate Implementation Notes

**Where gates fire:**
- Wallet count: `ManageAccountsScreen` — checks wallet count before allowing add
- Transaction limit: `AddTransactionScreen` — checks count for current period before save
- Feature screens (backup, export, AI, recurring, SMS): each screen checks tier on build and redirects to `/paywall?focus=pro` or `/paywall?focus=sms`
- Custom categories: `CategoriesScreen` — edit/add gate
- Budget history: `HistoryScreen` — period navigation gate

**Paywall entry:**
- Modal contexts (e.g., settings bottom sheets): `Navigator.pop()` first, then `context.push('/paywall')`
- Non-modal contexts: `context.push('/paywall')`
- Pass `focus` query param: `pro` or `sms` to show the relevant product on the paywall

**Safe read pattern (never crash on loading state):**
```dart
final tier = ref.watch(accessTierProvider).asData?.value ?? AccessTier.free;
final isPro = tier == AccessTier.pro || tier == AccessTier.subscription;
```

---

## Updating This Doc

When a feature ships:
1. Add the row to the matrix above.
2. Update the gate in `access_tier_provider.dart`.
3. Update the feature checklist in `docs/feature-shipping-checklist.md` if a new surface was discovered.
4. Commit both files in the same commit as the feature.
