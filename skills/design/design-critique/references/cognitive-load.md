# Lane C — Cognitive Load & Attention

**Sub-agent brief:** Evaluate how much thinking the interface demands and whether it directs attention well. These are **[GUIDELINE]** principles (named psychological effects popularized for UX) — they explain *why* something is hard to use, but they don't carry hard numeric thresholds. Frame findings as "increases decision cost / dilutes emphasis," and let Lane A/B carry any hard failures. Report cognitive-load findings only.

Sources: [Hick's Law](https://lawsofux.com/hicks-law/), [Von Restorff Effect](https://lawsofux.com/von-restorff-effect/), [Miller's Law](https://lawsofux.com/millers-law/), Gestalt Prägnanz (see also Lane E).

---

## C1 — Hick's Law: decision time grows with the number and complexity of choices **[GUIDELINE]**

**What it means:** The more options presented at once (and the less they're organized), the longer a user takes to decide — and the more likely they abandon or pick wrong. Time rises with the log of the option count, so *grouping and progressive disclosure* help more than raw deletion.

**What to check:**
- Navigation menus with many flat, ungrouped items.
- Toolbars/action bars exposing every possible action with equal weight.
- Forms presenting all fields at once when a stepped/branching flow would fit.
- Settings pages that are one long undifferentiated list.
- More than one element competing to be "the" primary action.

**Mitigations to recommend:** group related options (categories, sections); progressive disclosure (show advanced options on demand); sensible defaults so the common path needs no decision; a single clear primary action with secondaries de-emphasized.

**Good vs. bad:**
- ✗ A dashboard header with 12 equally-weighted icon buttons.
- ✓ 2–3 primary actions visible; the rest behind a clearly-labeled "More" / overflow menu.

---

## C2 — Von Restorff (isolation) effect: the distinctive item is remembered — and ubiquity destroys distinctiveness **[GUIDELINE]**

**What it means:** When items are similar, the one that differs stands out and is recalled. The corollary is the one that matters most for critique: **if everything is emphasized, nothing is.** Overusing a high-salience treatment (especially a strong color) burns out its signal value.

**What to check (the "red everywhere" anti-pattern):**
- A reserved/high-alarm color (typically **red**) used for non-urgent things — decorative accents, default icons, neutral counts, multiple unrelated badges — so that a *genuine* error or destructive action no longer stands out. (This is the attention-economics reason behind the semantic-color rule in Lane F.)
- Multiple "primary" buttons on one screen, each fighting for the eye.
- So many highlighted/badged elements that the highlight is just noise.

**Mitigations:** reserve your highest-salience treatment for the single most important element per view; demote everything else; make the emphasized element genuinely different from its neighbors (not just slightly).

**Good vs. bad:**
- ✗ Sidebar where 15 status dots span the rainbow including red for "info."
- ✓ Neutral palette for routine status; red appears *only* for true error/destructive, so it reads instantly.

---

## C3 — Miller's Law: working memory is limited (~7±2 chunks) **[GUIDELINE]**

**What it means:** People hold only a handful of items in working memory at once. Don't make users carry information across steps or hold long unbroken sequences.

**What to check:**
- Long strings shown unchunked (card numbers, phone numbers, codes) instead of grouped (`4242 4242 4242 4242`).
- Multi-step flows that require remembering a value entered three screens back.
- Comparison tasks that force the user to memorize one option's details to evaluate another (show them side by side instead).

**Caution:** Miller's "7±2" is about working memory, **not** a hard cap on menu length — don't cite it as "max 7 nav items." Use it to argue for **chunking and recognition over recall** (ties to Nielsen H6, Lane B).

---

## C4 — Prägnanz / simplicity: the eye prefers the simplest interpretation **[GUIDELINE]**

**What it means:** Users perceive complex layouts in the simplest way they can. A layout that resists a simple reading reads as "busy" and raises load. (Also a Gestalt principle — see Lane E for the visual-grouping mechanics.)

**What to check:**
- Dashboards showing a large number of simultaneous metrics with no hierarchy or grouping.
- Layouts a fresh viewer describes as "cluttered" or "I don't know where to look."
- Decoration (borders, dividers, shadows, gradients) added where whitespace would group more cleanly.

**Mitigations:** reduce simultaneous information; establish one clear scan path; group with proximity and whitespace before reaching for borders.

---

## Reporting notes for this lane

- These findings are usually **P3** (and occasionally P2 when decision cost demonstrably blocks the primary task — e.g., a checkout with no clear primary action).
- Quantify where you can: "11 equally-weighted actions in the header" is reviewable; "too cluttered" is not.
- When a cognitive-load finding coincides with a semantic-color problem, note the link to **Lane F** (Von Restorff ↔ red-reservation) and **Lane B H8** (minimalist design) so the orchestrator can cross-promote.
