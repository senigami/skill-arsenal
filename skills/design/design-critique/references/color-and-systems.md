# Lane F — Color Semantics & Design Systems

**Sub-agent brief:** Evaluate whether color is used *semantically and systematically* — each color earning a defined role, the alarm color reserved for alarm, and values delivered through named tokens rather than scattered hex. **[GUIDELINE]** and **[PRECEDENT]**: these are conventions and design-system practices, persuasive but not normative. A brand may deviate deliberately — flag, explain the cost, let the team decide. Report color-system findings only.

> **Verification note:** Specific Material Design 3 wording (e.g., "every role has a paired on-color," "error role is exclusive") did **not** survive adversarial fact-checking in this skill's research pass. The principles below are framed conservatively and sourced to the live design systems; verify exact MD3 rules at [m3.material.io](https://m3.material.io/styles/color/roles) before quoting them verbatim.

Sources: [Material Design 3 — Color roles](https://m3.material.io/styles/color/roles), [Atlassian — Color](https://atlassian.design/foundations/color), [Atlassian — Design tokens](https://atlassian.design/foundations/tokens/design-tokens), [GitHub Primer — Color](https://primer.style/foundations/color/overview/), [Stripe — Accessible color systems](https://stripe.com/blog/accessible-color-systems), [W3C Design Tokens Community Group](https://www.w3.org/community/design-tokens/).

---

## F1 — Reserve the alarm color for alarm (semantic color) **[GUIDELINE + PRECEDENT]**

**What it means:** Red (and other high-alarm colors) should map to a single meaning — **error / destructive / stop**. When the alarm color also decorates neutral UI, users can no longer trust it to mean danger, and genuine warnings lose their punch. (This is the design-system statement of the Von Restorff effect, Lane C C2, and Jakob's Law color convention, Lane D D4.)

**What to check:**
- Red used for non-destructive things: default icons, neutral counts/badges, decorative accents, a non-destructive primary CTA.
- Destructive actions *not* visually distinguished from safe ones.
- The same hue serving as both "brand/primary" and "error," so the user can't tell an alarm from a button.
- More than one "semantic" meaning competing for the same color.

**Good vs. bad:**
- ✗ Brand is red; the primary "Save" button, the notification dots, *and* the delete button are all red.
- ✓ Neutral/brand-tinted primary actions; red appears only on destructive/error, so "delete" and "error" read instantly.

**Brand-red caveat:** Some brands *are* red (see F4). When red is the brand, the fix isn't to abandon it — it's to ensure destructive/error states are still distinguishable (a darker/desaturated destructive red, plus non-color cues per Lane A SC 1.4.1) and that routine UI doesn't lean on the alarm shade.

---

## F2 — Color roles over raw values (design-system thinking) **[GUIDELINE]**

**What it means:** Mature systems assign color by **role** — `primary`, `on-primary`, `surface`, `error`, `outline` — rather than by raw hue. Roles make intent explicit and theming/contrast manageable. (Material Design 3 and Atlassian both organize color this way.)

**What to check:**
- Components hard-coding hex (`color:#2563EB`) instead of referencing a role/token.
- No distinct **error** role — error states borrow the brand color.
- Text-on-color pairs without a defined "on-" counterpart, leading to contrast failures (verify against Lane A A1).
- Button emphasis levels (primary / secondary / tertiary or filled / tonal / outline / text) not clearly differentiated, so users can't tell the main action.

---

## F3 — Named, machine-readable design tokens **[GUIDELINE]**

**What it means:** Design values (color, spacing, type, radius) should live as **named tokens** in a single source of truth, ideally in a portable format. The [W3C Design Tokens Community Group](https://www.w3.org/community/design-tokens/) defines a standard JSON format (`$value`, `$type`, `$description`) so tokens move between design tools and code. Tokens make global changes one-line and keep code consistent.

**Three-tier model to look for** (per Atlassian and common practice):
1. **Global/primitive** — raw values (`blue-500: #2563EB`).
2. **Alias/semantic** — role mapped to a primitive (`color.action: {blue-500}`).
3. **Component** — component-scoped reference (`button.bg: {color.action}`).

**What to check:**
- Scattered raw hex/px across components instead of token references.
- A flat token set with no semantic layer (only `blue-500`, no `action`/`error` aliases) — renaming or rebranding then touches every call site.
- Same conceptual value defined multiple times with drift (`#2563EB` here, `#2462EA` there).
- No dark-mode token mapping where dark mode exists.

**Note:** absence of a formal token system is **P3/P4** on its own (a maintainability/consistency concern), not a user-facing failure — unless it has produced visible inconsistency or contrast failures, which are scored in their own lanes.

---

## F4 — Product precedent (named examples) **[PRECEDENT]**

Use these as *illustrations* of the conventions above — persuasive comparisons, not rules. Cite when explaining why a recommendation reflects industry practice.

**Disciplined / semantic color (good examples to cite):**
- **GitHub Primer** — neutral and green-leaning primary actions; **red reserved for destructive** operations; an accessibility-driven color system. ([Primer color](https://primer.style/foundations/color/overview/), [GitHub inclusive color](https://github.blog/engineering/user-experience/unlocking-inclusive-design-how-primers-color-system-is-making-github-com-more-inclusive/))
- **Atlassian Design System** — explicit color *roles* and a tokenized three-tier model. ([Atlassian color](https://atlassian.design/foundations/color))
- **Stripe** — publicly documented an accessible, systematic color approach. ([Stripe](https://stripe.com/blog/accessible-color-systems))

**Strong brand red used deliberately (the nuance):**
- **Netflix, Target, YouTube** — red *is* the brand identity, applied to prominent surfaces. The lesson isn't "never use red prominently" — it's that these brands still keep **destructive/error states distinguishable** and don't rely on red to mean two different things at once. When critiquing a red-brand product, hold it to *that* bar, not to "remove the red."

**How to apply:** when recommending the alarm-color reservation (F1), cite GitHub as the precedent. When a product's brand *is* red, switch to the Netflix/Target framing and focus on keeping destructive/error distinguishable rather than de-branding.

---

## Reporting notes for this lane

- Color-*semantic* findings (red overloaded so danger is ambiguous) can reach **P2**, especially when they collide with Lane A SC 1.4.1 (color-only signaling) or a destructive action that isn't distinguishable. Pure token/architecture findings are **P3/P4**.
- Always separate **brand identity** (preserve — hue, logo, wordmark are out of scope) from **functional color use** (in scope — can the user tell an error from a button?). Never recommend changing the brand hue; recommend changing how *functional* states are colored around it.
- Where a recommendation is industry convention, cite a named precedent (F4) so the team sees it isn't just opinion — and acknowledge when a deliberate brand deviation is legitimate.
