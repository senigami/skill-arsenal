# Design Critique — Reference Library

This directory holds the itemized checklists the critique runs against. Each file is one **evaluation lane** — a self-contained reviewer specialty with its own principles, testable criteria, common violations, and good/bad examples. The lanes are designed to be **fanned out to parallel sub-agents** (see SKILL.md Step 4): hand each sub-agent one lane file plus the evidence in scope, and it returns findings in that lane only.

## The six lanes

| Lane | File | Covers | Primary sources |
|------|------|--------|-----------------|
| **A — Accessibility** | [wcag-accessibility.md](wcag-accessibility.md) | WCAG 2.2 contrast, color-use, focus, target size, reflow, text spacing | W3C WCAG 2.2 (normative) |
| **B — Usability heuristics** | [nielsen-heuristics.md](nielsen-heuristics.md) | Nielsen's 10 heuristics; error-message guidelines; slips vs. mistakes | Nielsen Norman Group |
| **C — Cognitive load & attention** | [cognitive-load.md](cognitive-load.md) | Hick's Law, Von Restorff effect, Prägnanz, Miller's Law | Laws of UX |
| **D — Affordances & conventions** | [affordances-conventions.md](affordances-conventions.md) | Norman (signifiers/affordances/mapping/slips), Jakob's Law, Apple HIG platform conventions | Norman; Apple HIG |
| **E — Visual hierarchy** | [visual-hierarchy.md](visual-hierarchy.md) | Refactoring UI (weight over color, spacing, depth), Gestalt principles, HIG depth/elevation | Refactoring UI; Gestalt |
| **F — Color semantics & systems** | [color-and-systems.md](color-and-systems.md) | Semantic color restraint, Material Design 3 color roles, design tokens, product precedent | MD3; Atlassian; GitHub Primer; Stripe |

## How to use

- **Inline (small scope):** the orchestrator reads the lanes relevant to the scope and runs the checklists itself.
- **Fanned out (full audit / thoroughness):** dispatch one sub-agent per lane, each with its file + the evidence (code paths, tokens, screenshots). Sub-agents are blind to each other — that independence is the point. The orchestrator dedupes and cross-promotes (an issue caught in two lanes escalates one severity level).
- **Contested findings:** when a recommendation is genuinely debatable for the product's context, hand that specific finding to `/fusion-reasoning` for a multi-perspective verdict rather than deciding alone.

## Evidence grading — read this before citing

Not every item below carries the same authority. The critique earns trust by being honest about which rules are normative and which are guidance.

- **[VERIFIED]** — Adversarially fact-checked against primary sources (W3C, NN/g). State these as authoritative. Includes the exact numeric thresholds in Lane A and the H4/H5 structure in Lane B.
- **[GUIDELINE]** — From a published design system or named law (Apple HIG, Material Design 3, Laws of UX, Refactoring UI). Real and citable, but principle-level — do **not** invent precise numeric thresholds these sources don't actually specify. Frame as "HIG recommends," not "HIG requires."
- **[PRECEDENT]** — Industry convention shown by what major products do (GitHub, Stripe, Atlassian). Persuasive, not normative. Frame as "common practice," and respect that a brand may deviate intentionally.

When a finding's severity depends on the rule being hard (P1/P2), it must rest on a **[VERIFIED]** item. **[GUIDELINE]** and **[PRECEDENT]** items justify P3/P4 unless they coincide with a verified accessibility failure.

## Corrections baked into these files (common web misconceptions)

These errors appear frequently in scraped/secondary sources. The lane files state the corrected version:

1. **SC 1.4.1 Use of Color is Level A**, not AA. (It's still in scope — Level A is the most foundational tier.)
2. **SC 2.4.11 is "Focus Not Obscured (Minimum)"** (Level AA). The measurable focus-appearance rule (3:1 contrast, minimum area) is **SC 2.4.13 Focus Appearance at Level AAA** — aspirational, not an AA requirement.
3. **Focus contrast is measured same-pixel** (focused vs. unfocused state of the same pixels), **not** against the adjacent background.
4. **No verified minimum-focus-area formula.** The "2px perimeter / 480px²" rule circulating online was refuted — do not cite it.
5. **Nielsen H9 does not mandate red or bold** error text. It requires plain language that names the problem and suggests a fix; color treatment is not specified (and color alone would violate SC 1.4.1).
