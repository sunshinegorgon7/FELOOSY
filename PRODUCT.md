# Product

## Business Model

**Free tier** — fully functional for a single wallet. No transaction limits. The free experience is intentionally complete so users can build a habit before being asked to pay.

**Pro — $4.99 one-time** — unlocks everything, forever. No subscription, no recurring charge.

| Feature | Free | Pro |
|---|---|---|
| Wallets | 1 | Unlimited |
| Google Drive backup | No | Yes |
| Local export (JSON) | No | Yes |
| Custom categories | No | Yes |
| All future features | — | Yes |

The paywall appears only when a user reaches a gated feature. It never interrupts the core flow (logging transactions, checking balance). The upgrade pitch is "more power", not "you've run out."

Product ID: `feloosy_pro_lifetime` (non-consumable, configured in App Store Connect and Google Play Console).

## Users

Anyone who wants to track their money without learning a system — a person managing household spending, a couple splitting costs, a freelancer watching cash flow. The mental model is dead simple: a wallet has a number, money goes in or comes out, and the month resets. Users open the app to log a transaction or check their balance, not to study their finances.

## Product Purpose

Budgeting made radically simple. One wallet, one balance, one month at a time. Success looks like: the user logs a transaction in under five seconds and never feels confused about where they stand.

The home screen shows a top spending categories chart at the bottom of the transaction list. This is the only analytical element in the app — a glanceable breakdown of where money went this period, not a dashboard. It should never be the primary focus of the screen; the balance and transaction list come first.

## Brand Personality

No-nonsense, clean, straight to the point. The app should feel like a well-designed notebook — quiet confidence, nothing decorative, everything purposeful. Not playful, not corporate, not clever. Just clear.

## Anti-references

- **Monefy** — all of it: the pie chart dominance, the bright cartoon palette, the icon-grid layout, the visual busyness
- **Corporate bank apps** — cold, over-engineered, full of features nobody asked for
- **Investment / trading apps** — charts, tickers, complexity as a feature
- **Any app that does analysis** — dashboards, spending trends, projections. If it looks like it's trying to teach you something, it's wrong

## Design Principles

1. **Numbers are the hero** — the balance and transaction amounts must be impossible to miss at any screen size
2. **One thing at a time** — never show more than the user needs right now; reveal complexity only when requested
3. **Action over information** — logging a transaction is the primary act; everything else is secondary
4. **Calm and decided** — the UI should feel settled, not trying to impress; no decoration that doesn't do work
5. **Restraint is the feature** — if an element can be removed without losing meaning, remove it

## Accessibility & Inclusion

No specific WCAG requirements at this stage. Aim for legible contrast and readable type sizes as a baseline.
