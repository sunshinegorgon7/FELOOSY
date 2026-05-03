---
name: FELOOSY
description: Radically simple personal budgeting — one wallet, one balance, one month at a time
colors:
  # Grove palette — light theme
  fern: "#639922"
  washed-sage: "#7A9A7A"
  forest-deep: "#5A8A40"
  mint-mist: "#F4F7F1"
  pale-grove: "#E4EBDE"
  pale-grove-high: "#C4D4C4"
  ink-deep: "#2C2C2C"
  grove-shadow: "#4A5E40"
  grove-outline: "#7A9A5A"
  grove-outline-variant: "#BED4A4"
  # Nimbus palette — dark theme
  ice-glow: "#4D7FA8"
  deep-nimbus: "#111922"
  nimbus-surface: "#1E2E3D"
  nimbus-mid: "#243547"
  nimbus-high: "#2A3D52"
  nimbus-highest: "#30455C"
  mist-text: "#C4D0DC"
  mist-variant: "#9AB0C4"
  # Semantic — theme-independent
  ledger-red: "#D64545"
  ledger-green: "#4A9955"
  amber-mark: "#CC8830"
typography:
  wordmark:
    fontFamily: "Rajdhani, sans-serif"
    fontSize: "26sp"
    fontWeight: 700
    letterSpacing: "3"
  headline:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "34sp"
    fontWeight: 700
    lineHeight: 1.1
  title:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "16sp"
    fontWeight: 500
    lineHeight: 1.4
  body:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "11sp"
    fontWeight: 500
    letterSpacing: "0.5"
rounded:
  sm: "8dp"
  md: "16dp"
  pill: "24dp"
  full: "9999dp"
spacing:
  xs: "4dp"
  sm: "8dp"
  md: "16dp"
  lg: "20dp"
  xl: "24dp"
components:
  button-filled:
    backgroundColor: "{colors.fern}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "12dp 24dp"
  button-filled-hover:
    backgroundColor: "{colors.forest-deep}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "12dp 24dp"
  button-text:
    backgroundColor: "transparent"
    textColor: "{colors.fern}"
    rounded: "{rounded.md}"
    padding: "10dp 16dp"
  fab-expense:
    backgroundColor: "{colors.ledger-red}"
    textColor: "#FFFFFF"
    rounded: "{rounded.full}"
    size: "56dp"
  fab-income:
    backgroundColor: "{colors.ledger-green}"
    textColor: "#FFFFFF"
    rounded: "{rounded.full}"
    size: "56dp"
  card:
    backgroundColor: "{colors.pale-grove-high}"
    textColor: "{colors.ink-deep}"
    rounded: "{rounded.md}"
    padding: "20dp"
  chip-type-expense:
    backgroundColor: "#F6E5E5"
    textColor: "{colors.ledger-red}"
    rounded: "{rounded.pill}"
    padding: "8dp 16dp"
  chip-type-income:
    backgroundColor: "#E5F2E7"
    textColor: "{colors.ledger-green}"
    rounded: "{rounded.pill}"
    padding: "8dp 16dp"
---

# Design System: FELOOSY

## 1. Overview: The Still Ledger

**Creative North Star: "The Still Ledger"**

FELOOSY is a personal budgeting app that earns its simplicity. The design philosophy is not minimalism as an aesthetic — it is restraint in service of a single user task: knowing where you stand, instantly. Every screen should feel like opening a well-kept paper ledger: each entry in its place, confident spacing, nothing decorative, nothing performing. The user is never meant to admire the interface. They should barely notice it.

The palette is nature-anchored in light mode (Fern green over Mint Mist) and shifts to a cool deep-water darkness for night use. Both themes feel deliberate, not fashionable — chosen for readability and calm, not for trend. The two FABs (Ledger Green for income, Ledger Red for expense) are the only saturated color on the home screen at rest. Their rarity is the signal.

The system explicitly rejects the analysis-heavy dashboard, the corporate bank app's cold authority, and the gamified cartoon warmth of apps like Monefy. If it looks like it is trying to teach the user something, it is wrong. If it looks like a financial product, it is too formal. If it looks like a game, it is too loose.

**Key Characteristics:**
- Flat surfaces with tonal layering — no shadows, no elevation drama
- Numbers are the visual hero — balance and amounts are always the largest element on screen
- Deliberate and spacious — comfortable margins, generous touch targets, never cramped
- Two named color families: Grove (light) and Nimbus (dark), with three shared semantic colors
- Semantic coloring: Ledger Red and Ledger Green are locked to expense/income meaning across every screen

## 2. Colors: The Grove and Nimbus Palettes

Two named families cover the full system. The Grove palette governs light mode; the Nimbus palette governs dark mode. Three semantic colors (Ledger Red, Ledger Green, Amber Mark) are theme-independent and appear identically in both.

### Primary
- **Fern (#639922):** The primary action color in light mode. Used on FilledButtons, FAB highlights, selected states, progress bar fill, and active navigation indicators. The only saturated green on screen at rest in light mode. Its rarity is its authority.
- **Ice Glow (#4D7FA8):** The primary action color in dark mode. Same role as Fern, in a cooler blue-steel to suit the Nimbus surface. Never warm; always composed.

### Secondary
- **Washed Sage (#7A9A7A):** Secondary chips, filter pills, and supporting badges in light mode. Never competes with Fern.
- **Steel Water (#5A8FAA):** Secondary role in dark mode — same function as Washed Sage.

### Tertiary
- **Forest Deep (#5A8A40):** Tertiary actions in light mode. Used in warning-adjacent states and the progress bar warning range.

### Neutral
- **Mint Mist (#F4F7F1):** Main scaffold background in light mode. The ground everything sits on. Tinted slightly toward green — never pure white.
- **Pale Grove (#E4EBDE):** Elevated surfaces, section backgrounds, input fills. One tonal step above Mint Mist.
- **Pale Grove High (#C4D4C4):** Card background color in light mode. The highest tonal step before ink — clear card-on-surface distinction without shadows.
- **Ink Deep (#2C2C2C):** Primary text in light mode. Near-black with a green tint. Never pure black.
- **Grove Shadow (#4A5E40):** Secondary text, captions, placeholder text, section labels.
- **Grove Outline (#7A9A5A):** Border for focused inputs and active containers.
- **Grove Outline Variant (#BED4A4):** Default card borders and dividers. Subtle, not decorative.
- **Deep Nimbus (#111922):** Main scaffold background in dark mode. Deep blue-black; tinted toward steel, not brown.
- **Nimbus Surface (#1E2E3D):** Card background in dark mode. The Nimbus equivalent of Pale Grove High.
- **Nimbus High (#2A3D52):** Elevated containers in dark mode. Stat chips, input fills.
- **Mist Text (#C4D0DC):** Primary text in dark mode. Cool blue-gray, never pure white.
- **Mist Variant (#9AB0C4):** Secondary text in dark mode. Same role as Grove Shadow.

### Semantic (theme-independent)
- **Ledger Red (#D64545):** Expense amounts, expense FAB, expense type chip, over-budget indicators, delete-action backgrounds. Used exclusively for "money out" and destructive contexts adjacent to financial data.
- **Ledger Green (#4A9955):** Income amounts, income FAB, income type chip, available-budget indicators. Used exclusively for "money in" contexts.
- **Amber Mark (#CC8830):** Budget approaching limit (>80% spent). Warning only. Never decorative.

### Named Rules
**The Semantic Parity Rule.** Ledger Red and Ledger Green are the only colors with locked meaning. They must never appear in non-semantic contexts — no decorative borders, no illustration fills, no category colors that happen to be red or green. Every appearance is a data point.

**The Rarity Rule.** Fern (light) and Ice Glow (dark) appear on no more than 15% of any given screen surface. Their scarcity is their authority. Never use them as background fills on large surfaces.

**The No-Gray Rule.** Every neutral in this system carries a tint toward the brand hue. Pure `#808080` gray is forbidden. Placeholder text uses Grove Shadow; disabled states use onSurface at 38% opacity over the correct surface color.

## 3. Typography

**Display / Wordmark Font:** Rajdhani (condensed geometric sans-serif, via Google Fonts)
**UI Font:** Roboto (system fallback: SF Pro on iOS, system-ui)
**No mono or serif** — this is not an analytical tool and does not need the connotations of either.

**Character:** Rajdhani is deployed precisely once — the "FELOOSY" wordmark in the top bar, weight 700, letter-spacing +3, all-caps. Its condensed geometry signals identity without decoration. The entire UI is Roboto or system: legible, neutral, invisible. The pairing keeps brand identity contained to one mark so it never competes with the numbers on screen.

### Hierarchy
- **Wordmark** (Rajdhani w700, 26sp, letter-spacing +3): App name in the AppBar only. Never used elsewhere in the UI. Not a display typeface — an identity mark.
- **Balance Display** (Roboto w700, 34sp, line-height 1.1): The remaining budget or wallet balance — the largest visible number on any screen. The first thing the eye lands on. Used for `headlineLarge` in the budget summary.
- **Headline** (Roboto w700, 24sp, line-height 1.2): Screen-level amounts, featured numbers in detail views.
- **Title** (Roboto w500, 16sp, line-height 1.4): Card headers, section labels, dialog titles, AppBar titles.
- **Body** (Roboto w400, 14sp, line-height 1.5): Transaction descriptions, category names, supporting body text. This is the most-read type in the app; it should never be smaller than 14sp.
- **Label** (Roboto w500, 11sp, letter-spacing +0.5): Stat chip labels, date section headers, percentage labels, all secondary captions.

### Named Rules
**The Number-First Rule.** On any screen that displays a balance or transaction amount, that number uses the largest size and highest weight on screen. Labels, dates, and category names are always visually secondary. If a label is competing with a number, the label is winning incorrectly.

**The Wordmark Boundary.** Rajdhani is used for the FELOOSY logotype only — not for section headings, category titles, or any decorative text. It is an identity mark. Using it as a display typeface would be like writing notes in your company's logo font.

## 4. Elevation

FELOOSY is flat by default. All cards and containers carry zero Material elevation — no box shadows, no drop shadows, no blur effects applied decoratively. Depth is conveyed entirely through tonal surface layering: the scaffold is lightest, elevated containers are one step darker, cards are one step darker still. In dark mode the sequence runs: Deep Nimbus → Nimbus Surface → Nimbus High.

**The Flat Register Rule.** Shadows are prohibited on cards, containers, and inputs. If a shadow feels necessary for visual separation, the problem is inadequate tonal contrast — step the container color one level darker in the tonal scale. A shadow in this system would be like someone adding decoration to a balance sheet: technically possible, categorically wrong.

### Shadow Vocabulary
FELOOSY has no shadow vocabulary for containers. The only partial exception is FABs: a very faint directional shadow (`0 3dp 8dp rgba(0,0,0,0.18)`) may be applied to lift FABs off the content behind them, as they float over a scrolling list. This is structural, not decorative.

## 5. Components

### Buttons
Deliberate and spacious. Comfortable touch targets, clear semantic color assignment, no decoration beyond shape.
- **Shape:** Gently rounded (16dp radius)
- **FilledButton (Primary):** Fern (#639922) background in light mode; Ice Glow (#4D7FA8) in dark mode. White text, w500 14sp. Minimum 48dp height, 12dp × 24dp padding. Used for primary irreversible actions: Set Budget, Save, Confirm.
- **TextButton:** No background, Fern / Ice Glow text, same padding. Used for Cancel, See All, navigation links.
- **Hover/Focus:** Filled button darkens toward Forest Deep on press. Focus ring uses primary color at 30% opacity, 2dp offset.
- **Disabled:** surfaceContainer background, onSurface text at 38% opacity. No outline.
- **Destructive FilledButton:** `cs.error` background with `cs.onError` text. Used only for irreversible delete actions in confirmation dialogs and slide-to-delete actions. Never use Ledger Red for destructive buttons — `cs.error` is the delete color; Ledger Red is the expense color.

### FABs (Floating Action Buttons)
The two FABs are the primary interaction surface of the app — the most-used elements and the most color-saturated. They carry the semantic colors.
- **Expense FAB (bottom-right):** Ledger Red (#D64545), white minus icon, circular (full radius), 56dp. The presence of this FAB is the primary affordance for adding an expense.
- **Income FAB (bottom-left):** Ledger Green (#4A9955), white plus icon, circular (full radius), 56dp.
- Both FABs use white foreground icons, not `onPrimary` — the semantic colors are dark-mode-safe at white contrast.
- Hidden during search mode and when the keyboard is open.
- 16dp bottom + side margin.

### Type Toggle (Expense / Income)
The transaction type selector on the add-transaction screen. Two chips, always side-by-side.
- **Selected — Expense:** Tinted background (#F6E5E5), Ledger Red border (1.5dp) and text, 24dp pill.
- **Selected — Income:** Tinted background (#E5F2E7), Ledger Green border and text, 24dp pill.
- **Unselected:** No background, no border, Grove Shadow text.
- Animated 180ms ease-out on selection change (background, border, text color). No scale or elevation change — the color is enough.

### Cards / Containers
Flat surfaces. Zero elevation throughout.
- **Corner Style:** Gently rounded (16dp radius) — consistent across all card-like containers.
- **Background:** Pale Grove High (#C4D4C4) in light mode; Nimbus Surface (#1E2E3D) in dark mode.
- **Border:** 1dp in Grove Outline Variant (#BED4A4) in light mode; Nimbus Surface (#2A3D52) in dark mode.
- **Shadow:** None.
- **Internal Padding:** 20dp standard; 24dp for the primary budget summary card.
- **Nested cards are prohibited.** A container with its own background color inside a card is information architecture failure — flatten or promote the content.

### Inputs / Fields
Quiet. Inputs do not shout.
- **Style:** Filled style with surfaceContainerHigh background, no stroke at rest. Radius matches cards (16dp).
- **Focus:** Primary-color border appears (1dp at rest → 2dp on focus). No glow, no blur.
- **Placeholder / hint text:** Grove Shadow (#4A5E40) in light mode, Mist Variant (#9AB0C4) in dark. Never pure gray.
- **Error:** cs.error border + errorContainer background tint. Error message in cs.onErrorContainer at label scale.
- **Disabled:** surfaceContainerLow background, 38% opacity text.

### Transaction Tile (Signature Component)
The most-repeated element in the app. The design is settled: every tile the same height, same icon treatment, same trailing amount. Variety comes from content, not layout.
- **Normal tile (full detail):** 28dp left padding, 16dp right padding. Category icon in a 40dp CircleAvatar with category color at 15% opacity tint. Description in body weight; category name in label weight below.
- **Compact tile:** 32dp left padding. CircleAvatar 28dp, 14dp icon. Description only, no subtitle.
- **Background tint:** Expense tiles carry Ledger Red at 4% opacity (7% dark mode); income tiles carry Ledger Green at 4% opacity (7% dark mode). The tint is a whisper, not a flag.
- **Amount:** Right-aligned, w600 14sp, Ledger Red or Ledger Green. This is semantic color — its appearance in this specific context is required, not optional.
- **Truncation:** Description clips at 1 line with ellipsis. The amount never truncates.

### Balance Pill (Signature Component)
A floating pill centered above the two FABs, showing remaining budget in context of the home screen.
- **Shape:** Full pill (24dp radius), stretches edge-to-edge minus 10dp side margin.
- **Background:** Active semantic color at 12% opacity; border at 30% opacity of the same color.
- **States:** Available = Ledger Green palette; over-budget = Ledger Red palette.
- **Content:** Formatted amount in w700 16sp; "available" or "over budget" label at 11sp below. Two lines, centered.

## 6. Do's and Don'ts

### Do:
- **Do** use Ledger Red and Ledger Green exclusively for semantic expense/income contexts. Every appearance of these colors is a data point, not decoration.
- **Do** make the balance or remaining amount the largest, heaviest type on any screen that shows a number. The Number-First Rule is absolute.
- **Do** use tonal surface steps (Pale Grove → Pale Grove High → Card) for depth. No shadows on containers.
- **Do** keep touch targets a minimum of 48dp tall. The app is opened with one hand, quickly.
- **Do** use `cs.error` for destructive actions (delete buttons, slide-to-delete) — not Ledger Red. These are different semantic roles.
- **Do** use generous whitespace to communicate grouping. Compression suggests urgency; this app should feel calm.
- **Do** apply 16dp radius uniformly to all card-like containers — budget cards, stat chips, inputs, dialogs.
- **Do** keep FAB visibility logic strict: hide both FABs when the keyboard is open or search is active. They must never overlap content the user is interacting with.

### Don't:
- **Don't** add charts, graphs, pie charts, or trend visualizations as primary UI elements. This app records; it does not analyze. If a screen looks like a dashboard, it is wrong.
- **Don't** replicate the Monefy aesthetic: no bright cartoon color palette, no icon-grid as the primary home screen layout, no pie chart as a hero element. The app takes inspiration from Monefy's simplicity of concept, not its visual language.
- **Don't** use a corporate bank app style: no navy blue header bars, no gold accents, no cold formal typography, no excessive security-theater UI patterns.
- **Don't** add shadows to cards, containers, or inputs. The Flat Register Rule is not a preference — it defines the register. A shadow here would be a category error.
- **Don't** use Ledger Red or Ledger Green in non-semantic contexts: not as category icon colors, not as decorative borders, not as illustration fills.
- **Don't** use Rajdhani outside the FELOOSY wordmark in the AppBar. It is an identity mark, not a display typeface.
- **Don't** use pure `#000000` or `#FFFFFF` for text or surfaces. Every neutral in this system carries a tint toward the brand hue. The No-Gray Rule applies.
- **Don't** nest cards. No container with its own distinct background color inside a card.
- **Don't** add complexity as a feature. If a screen shows more than the user needs for their immediate task, remove elements until it does not.
- **Don't** use Amber Mark (#CC8830) decoratively. It exists only as a warning signal when budget utilization exceeds 80%. One warning color, one meaning.
