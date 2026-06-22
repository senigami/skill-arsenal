---
name: design-critique
description: >-
  Evaluate an existing UI against Apple HIG, Nielsen's heuristics, Gestalt,
  WCAG 2.2, and color/cognitive-load principles. Use when the user wants to
  "critique the design", "improve the UI", "audit the interface", "apply HIG",
  "review this page", "make this more Apple", or "what's wrong with the design".
  Works from a style guide, a codebase, a specific page, screenshots, or any
  combination. Runs six evaluation lanes — accessibility, usability heuristics,
  cognitive load, affordances/conventions, visual hierarchy, and color/design
  systems — each backed by an itemized reference checklist, and can fan them out
  to parallel sub-agents (pairs with fusion-reasoning) for a full audit. Produces
  a report in docs/design-critique/ — severity-rated findings (P1–P4), exact
  violation citations, before/after code fixes, an impact/effort roadmap, and
  trade-off decisions needing user input. Preserves the existing theme.
---

# Design Critique

Evaluate an existing UI against established design principles, then produce a concrete improvement plan. This skill plays the role of an opinionated senior designer who cites sources, ranks issues, and prescribes specific changes — while preserving the product's existing visual identity.

## Why this approach

- **Citation-first findings** remove subjectivity. Every issue names the principle it violates (Apple HIG — Clarity, Nielsen H8, WCAG SC 1.4.3). Reviewers can't dismiss it as opinion.
- **Severity triage** answers "fix this sprint vs. backlog." P1 is a blocker; P4 is a preference. Don't waste sprint capacity on P4s when P1s exist.
- **Theme preservation** keeps the audit safe to share with clients. Brand hue, logos, and wordmarks are out of scope. Everything else — spacing, hierarchy, contrast, elevation — can be improved without touching identity.
- **Trade-off questions** surface before recommendations land. When an improvement would change something visible and contestable (replacing a solid hero image background with a blur overlay), the user decides.
- **Impact/effort matrix** turns a list of problems into a phased roadmap.

---

## Evaluation lanes

The critique evaluates the UI across **six lanes**. Each lane is a self-contained reviewer specialty with its own itemized checklist in [`references/`](references/) — principles, testable criteria, common CSS/DOM violations, and good/bad examples. **Read the lane files; don't critique from memory** — the checklists carry corrected thresholds and citations that ad-hoc review gets wrong.

| Lane | Reference file | Covers |
|------|----------------|--------|
| **A — Accessibility** | [references/wcag-accessibility.md](references/wcag-accessibility.md) | WCAG 2.2: contrast, use-of-color, focus, target size, reflow, text spacing |
| **B — Usability heuristics** | [references/nielsen-heuristics.md](references/nielsen-heuristics.md) | Nielsen's 10 heuristics; error messages; slips vs. mistakes |
| **C — Cognitive load** | [references/cognitive-load.md](references/cognitive-load.md) | Hick's Law, Von Restorff, Prägnanz, Miller's Law |
| **D — Affordances & conventions** | [references/affordances-conventions.md](references/affordances-conventions.md) | Norman (signifiers/affordances/slips), Jakob's Law, Apple HIG (Clarity/Deference/Depth) |
| **E — Visual hierarchy** | [references/visual-hierarchy.md](references/visual-hierarchy.md) | Refactoring UI (weight over color, spacing, states), Gestalt principles |
| **F — Color & design systems** | [references/color-and-systems.md](references/color-and-systems.md) | Semantic color restraint, Material Design 3 roles, design tokens, product precedent |

Start at [references/00-index.md](references/00-index.md) — it carries the lane map, the **evidence grading** ([VERIFIED] / [GUIDELINE] / [PRECEDENT]) that governs how hard a finding's severity can be, and a list of common WCAG/Nielsen misconceptions the lanes correct.

**Evidence discipline (load-bearing):** A finding's severity may only rest on the authority of its evidence. **P1/P2 severity requires a [VERIFIED] basis** (the WCAG numeric thresholds in Lane A; the H4/H5 structure in Lane B). [GUIDELINE] and [PRECEDENT] items justify **P3/P4** unless they coincide with a verified accessibility failure. Apple HIG, Material Design 3, the laws of UX, and product precedent are real and citable but **principle-level** — frame them as "HIG recommends," never "HIG requires," and never invent a numeric threshold a guideline doesn't actually publish.

---

## Workflow

### Step 1 — Determine what to review

The skill adapts to whatever evidence is available. Route based on what the user provided:

**Route A — Style guide exists**
Check for `docs/style-guide/`, `STYLEGUIDE.md`, Storybook, or `tokens.json`. If found:
- The style guide is the canon. Evaluate the live UI *against it*.
- Deviations from the style guide are P2 consistency violations (the spec exists; the implementation ignored it).
- Still run all lanes against design principles — style guide conformance and principle conformance are separate concerns.
- Note the style guide version/date in the report header.

**Route B — No style guide; codebase is available**
Survey the codebase as described in Step 3. Extract the implicit design system from tokens, components, and patterns. This is the widest-scope path — the critique covers the whole product.

**Route C — Specific page, feature, or URL**
The user pointed at something particular ("review the checkout page", "look at this dashboard"). Scope the critique to that surface only. Don't expand unless the user asks. State the scope boundary explicitly at the top of the report.

**Route D — Screenshots only**
The user has no codebase access, or wants feedback purely from what's visible. Work entirely from the screenshots provided. Mark every finding as `[visual only — no code reference]`. Skip Step 3 (codebase survey). Contrast findings cite visible colors; note that exact ratios require the actual CSS values.

**Route E — Combination**
Most common in practice: style guide + screenshots of a specific page, or codebase + user-submitted screenshot of one screen. Take the tightest scope the user specified.

---

**If the scope isn't clear**, ask in a single question before proceeding:
> "What should I review? Options:
> 1. The full product/site — I'll survey the codebase and ask for representative screenshots
> 2. A specific page or feature — which one?
> 3. Screenshots you've already taken — share them and I'll evaluate from those
> 4. The style guide vs. the live implementation — check whether code matches the documented spec
>
> Any answer works; 'just do the whole thing' is fine."

---

**What always stays unchanged regardless of scope:**
- Logos and wordmarks (exempt from WCAG contrast requirements per SC 1.4.3)
- The core brand hue (preserve the hue; build companion tones around it)
- Brand voice and personality

**What is always in scope regardless of route:**
- All text contrast ratios (brand color exemption covers logos only)
- Interactive state completeness (hover, focus, active, disabled, loading, error)
- Visual hierarchy and spacing
- Touch targets and focus indicators
- Information architecture and labeling

**Detect design system:** Check `package.json` for MUI, shadcn/ui, Chakra, Ant Design, Mantine, Radix. If found, customizations are in scope; base system components are not (they're already principled).

---

### Step 2 — Request screenshots (batched)

Ask for screenshots **in one request**. Never drip questions across turns. Frame each ask specifically. Adapt the request to the scope from Step 1.

**Skip this step** if Route D (screenshots already provided) or if the user explicitly says not to ask.

**For full-site / Route B:**
> "To complete the critique I need visual reference for elements the code can't fully describe. Could you share:
> 1. The main page or dashboard in its default state
> 2. A form with at least one validation error visible
> 3. Your primary CTA button and a secondary button side by side
> 4. Navigation on desktop (and mobile if it's different)
> 5. A modal or overlay, if the product has one
> 6. The mobile viewport of the main page at 375px width
> 7. Dark mode, if the product supports it
>
> Screenshots are reference only — no changes will be made from them directly."

**For a specific page / Route C:**
> "To complete the critique of [page name] I need a few screenshots. Could you share:
> 1. [The page] in its default loaded state
> 2. [The page] with any interactive elements in a non-default state (error, loading, empty, or hover if you can capture it)
> 3. [The page] at a narrow viewport (375px) if it has a responsive layout
>
> If there are specific states or elements you want critiqued, include those too."

**For style guide vs. implementation / Route A:**
> "To check whether the live UI matches the style guide, could you share a screenshot of:
> 1. [The surface most likely to have drifted — usually the newest page or component]
> 2. [Any interactive component where the state styling is important — a form, a button group, or a modal]"

Mark any finding based on unconfirmed visual state as `[visual unconfirmed — verify]`. Continue without stalling.

---

### Step 3 — Survey the codebase for measurable violations

Gather the raw evidence the lanes will judge. Fan this across parallel agents for large codebases. Read systematically:

**CSS/design tokens (highest signal):**
- Global CSS: `:root` custom properties, `globals.css`, `variables.css`
- Tailwind config (`tailwind.config.js/ts` or `@theme` blocks): extract color, font, spacing, border-radius values
- `theme.ts`, `tokens.json`, dedicated token files

**For each color value found:** calculate or estimate contrast ratios against likely backgrounds. Flag any text-on-background pair below 4.5:1; any UI component (border, icon, badge) below 3:1.

**For spacing values:** check if all values are multiples of 4 (or 8 for the 8pt grid). Flag hard-coded `7px`, `13px`, `19px` — off-grid.

**Component files:**
- Read Button, Input, Select, Modal, Nav — note which interactive states have explicit styles (hover, focus, active, disabled) and which are missing
- `cva()`, `clsx()`, `cn()`, `variants` patterns — read these to detect inconsistent naming
- Check for `outline: none` / `outline: 0` without a replacement focus style

**Typography:**
- Smallest font-size token — flag if below 12px
- `font-size` below 16px on inputs (iOS zoom trigger)
- Hard-coded `line-height` in pixels (prevents text-spacing override)

**Motion:** search `transition`, `animation`, `@keyframes`; check for a `@media (prefers-reduced-motion: reduce)` override (missing = a real issue, not just polish).

**Responsive:** confirm 320px reflow (fixed-width containers, `100vw` on content, large `min-width`); check `vh` that should be `dvh`/`svh` on full-height layouts.

Collect this into a compact **evidence pack** (token values, component-state matrix, flagged measurements, screenshots) — this is what you hand to the lanes in Step 4.

---

### Step 4 — Run the evaluation lanes

Run all six lanes (A–F). Each lane reads its reference file and the evidence pack, and returns findings tagged with the criteria it cites. Pick the execution mode by scope:

**Inline mode (small scope — one page, one component, a quick pass):**
Read the relevant lane files yourself and work through their checklists against the evidence. Faster for narrow reviews; no orchestration overhead.

**Fan-out mode (full audit, or when the user asks for thoroughness) — the fusion-style panel:**
Dispatch **one sub-agent per lane**, in parallel (multiple `Agent` calls in one message). This is the same panel-of-independent-reviewers pattern as `/fusion-reasoning`, specialized for design — each lane is a distinct lens, and their independence is the point: a sub-agent blind to the others won't rationalize away what its lane is built to catch.

Give each lane sub-agent a tight contract:
- **Its one reference file** (e.g., Lane A gets `references/wcag-accessibility.md`) and nothing from the other lanes.
- **The evidence pack** from Step 3 (token values, component-state matrix, flagged measurements) plus any screenshots and the scope boundary.
- **A return contract:** report findings *only* in this lane, each as `{title, severity, framework/criterion cited, location (file:line or component), issue, current code, proposed fix, effort, theme impact}`. Honor the evidence-grading rule — P1/P2 only on a [VERIFIED] basis. Return nothing for a clean check rather than padding.
- Use light/cheap models for the mechanical lanes (A accessibility math, F token scan) and a stronger model for judgment-heavy lanes (B, D, E) if the model menu allows — match the model to the lane.

Then the orchestrator (you) **synthesizes** — this is the judge half of the panel:
1. **Collect** all lane findings into one list.
2. **Deduplicate** — the same root issue often surfaces in several lanes (a color-only error border hits Lane A SC 1.4.1, Lane B H9, and Lane F F1). Merge into one finding that cites all the lanes/criteria it touches.
3. **Cross-promote severity** — a finding independently raised by **2+ lanes is promoted one severity level** (the multi-lens agreement is signal, exactly as fusion weighs converging perspectives).
4. **Assign IDs** — `DC-001`, `DC-002`, … in final severity order.

**Either mode** must end with every framework represented: don't let fan-out drop a lane, and don't let inline mode skip one because it "seemed fine" — record the clean pass.

**HIG web-translation reminders** (Lane D/E carry the detail): "layered translucency" → `backdrop-filter: blur()` + semi-transparent fill on elevated surfaces (with a `prefers-reduced-transparency` fallback); "platform conventions" → compare to common web patterns; depth → consistent elevation, nothing rendered behind its trigger.

---

### Step 5 — Triage findings

Rate every finding before writing the report.

**Severity levels:**

| Level | Label | Criteria | Examples |
|-------|-------|----------|----------|
| **P1** | Blocker | Prevents task completion, causes data loss, [VERIFIED] WCAG failure on a critical-path element, legal risk | Keyboard trap in modal; submit button not keyboard-operable; primary CTA text at 2.8:1 contrast |
| **P2** | Major | Core feature completable but severely degraded; significant confusion; HIG core principle clearly violated; [VERIFIED] WCAG failure off critical path | Missing error states; solid black modal background (breaks depth model); body text at 3.2:1; no loading state on data fetch |
| **P3** | Polish | Principle/guideline deviation that's noticeable but doesn't block flow; consistency issue; AAA-stretch (focus appearance, 44px target); sub-optimal but functional | Off-grid spacing (15px); hover state inconsistent between similar buttons; missing focus ring on icon buttons only |
| **P4** | Cosmetic | Team preference; pixel nudge; no functional or perceptual impact | Slight font-weight preference; logo size tweak; micro-animation timing |

**Severity escalates by one level** when a finding affects the primary conversion path (checkout, signup, primary CTA), and (per Step 4) when 2+ lanes independently raised it.

**Severity gate:** A P1 or P2 must cite a **[VERIFIED]** basis (a hard WCAG threshold, or a task-blocking/data-loss usability failure). A finding resting only on a [GUIDELINE] or [PRECEDENT] item caps at **P3** unless it coincides with a verified accessibility failure.

**Theme impact classification:**
- **None** — fix doesn't touch any brand-adjacent value
- **Low** — fix changes a token value but stays within brand hue and existing palette
- **High** — fix would change something the user/client explicitly chose (requires explicit user approval before implementing)

---

### Step 6 — Trade-off check

Before writing the report, list every finding with **High theme impact** and ask the user explicitly. Do this in a single consolidated question — not one-by-one.

**Format:**
> "Before I write the full report, I found [N] improvements that would touch brand or visual decisions you may have made intentionally. I need your call on these before recommending them:
>
> 1. **[DC-00N] [Title]**: [What the current design does] → [What HIG/WCAG recommends]. This would change [specific element]. Keep it as-is, or proceed with the improvement?
> 2. **[DC-00N] [Title]**: [Same format]
>
> Answer however you like — 'fix 1, keep 2' works fine."

If no high-impact conflicts exist, skip this step.

---

### Step 7 — Write findings

Output to `docs/design-critique/01-findings.md`.

**Per-finding format:**
```markdown
### DC-001: [Short title — 5–8 words describing the problem]

| Field | Value |
|-------|-------|
| **Severity** | P1 — Blocker |
| **Lanes / Framework** | A (WCAG SC 1.4.11) + D (Norman — signifier) |
| **Location** | Sidebar / `components/ui/sidebar.tsx` |
| **Effort** | S (half-day) |
| **Theme impact** | Low |

**Issue:** The sidebar uses `background-color: #000000` — a solid opaque black. Apple HIG specifies layered translucency for elevated surfaces: one semi-transparent layer per z-level, with backdrop blur conveying depth. Solid fills collapse the spatial model, making the sidebar feel like a wall rather than a layer above the content.

**Current:**
```css
.sidebar { background-color: #000000; }
```

**Fix:**
```css
.sidebar {
  background-color: oklch(0% 0 0 / 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}
/* Reduced-transparency fallback */
@media (prefers-reduced-transparency: reduce) {
  .sidebar { background-color: oklch(10% 0 0 / 1); }
}
```
```

When a finding was caught by 2+ lanes, list all of them in the **Lanes / Framework** row — it documents why the severity was promoted.

Write every P1 and P2 finding in full. Summarize P3 and P4 findings in a grouped table at the end of the file.

---

### Step 8 — Write the full audit report

The report lives in `docs/design-critique/`. It is a complete, standalone document — someone who wasn't in the conversation should be able to read it and understand exactly what's wrong, why it matters, and what to do about it.

---

**`docs/design-critique/00-summary.md`** — the executive layer:

```markdown
# Design Critique — [Product/Page Name]
**Date:** [today]
**Scope:** [Full site / Page: [name] / Style guide vs. implementation]
**Frameworks:** WCAG 2.2 (Lane A), Nielsen heuristics (B), cognitive load (C), affordances/HIG (D), visual hierarchy/Gestalt (E), color/design-systems (F)
**Style guide used:** [Yes — docs/style-guide/ / No — implicit system extracted from code / N/A — screenshots only]

---

> **TL;DR:** [2–3 sentence verdict. Be direct. Example: "The typography and information hierarchy are well-executed. The depth model is broken — every elevated surface uses solid black fills that collapse the spatial hierarchy Apple HIG requires. Three contrast failures on primary actions are WCAG blockers and must ship before any polish work."]

## What we reviewed
[One paragraph: what surfaces were evaluated, what was not, what evidence was used (code, screenshots, style guide), how it was run (inline or fan-out across lanes), and any limitations (e.g., "interactive states could not be verified — hover/focus screenshots were not provided").]

## What's working
[3–5 specific strengths. Be genuine — good critique includes what to preserve. Strengths matter as much as findings for a team that needs to know what not to touch in a redesign.]
- ✓ [Strength 1 — specific, not generic]
- ✓ [Strength 2]
- ✓ [Strength 3]

## Findings summary
| Severity | Count | Estimated total effort |
|----------|-------|----------------------|
| P1 — Blocker | N | [e.g., 1–2 days] |
| P2 — Major | N | [e.g., 1 sprint] |
| P3 — Polish | N | [e.g., 2–3 days] |
| P4 — Cosmetic | N | [e.g., as-available] |
| **Total** | **N** | |

## Coverage by lane
| Lane | Findings | Notable |
|------|----------|---------|
| A — Accessibility | N | [1-line] |
| B — Usability | N | [1-line] |
| C — Cognitive load | N | [1-line] |
| D — Affordances/conventions | N | [1-line] |
| E — Visual hierarchy | N | [1-line] |
| F — Color/systems | N | [1-line] |

## Top priority findings
| ID | Finding | Severity | Effort |
|----|---------|----------|--------|
| DC-001 | [Title] | P1 | S |
| DC-002 | [Title] | P1 | M |
| DC-003 | [Title] | P2 | S |

## Decisions needed from you
[List trade-offs from Step 6 the user resolved, and note the decision for the record. If none: "No brand-conflicting recommendations — all improvements preserve existing visual identity."]
```

---

**`docs/design-critique/01-findings.md`** — the full finding list:

Write every P1 and P2 finding in full (per-finding format from Step 7). Group P3 and P4 at the end in summary tables:

```markdown
## P3 — Polish (grouped)
| ID | Finding | Lane | Location | Effort |
|----|---------|------|----------|--------|
| DC-0NN | [Title] | E | [File/Component] | XS |

## P4 — Cosmetic (grouped)
| ID | Finding | Lane | Location | Note |
|----|---------|------|----------|------|
| DC-0NN | [Title] | F | [File/Component] | Fix if time allows |
```

---

**`docs/design-critique/02-improvement-plan.md`** — the roadmap:

```markdown
# Improvement Plan

## Impact/effort matrix
| Quadrant | Strategy | Finding IDs |
|----------|----------|------------|
| **Quick Wins** — High impact, Low effort | Fix this sprint | DC-001, DC-004 |
| **Big Bets** — High impact, High effort | Plan for next quarter | DC-007 |
| **Fill-ins** — Low impact, Low effort | Complete when capacity exists | DC-010, DC-011 |
| **Defer** — Low impact, High effort | Backlog, revisit later | DC-014 |

## Phased roadmap
**Phase 1 — This sprint:** [IDs] — All P1 blockers + Quick Wins. Total effort: [estimate].
**Phase 2 — Next sprint:** [IDs] — P2 majors with S/M effort. Total effort: [estimate].
**Phase 3 — This quarter:** [IDs] — Big Bets and remaining P2s. Total effort: [estimate].
**Ongoing:** [IDs] — P3/P4 as capacity allows.

## Suggested next steps
[See Step 10 — skill handoffs]
```

---

**`docs/design-critique/03-trade-offs.md`** (only if user decisions were made in Step 6):
Record each conflict, the user's decision, and the rationale for future reference. This becomes the design decision log for the session.

---

### Step 9 — Self-review

Before summarizing, verify:
- Every finding cites a specific lane criterion (no bare "this is bad")
- Every P1/P2 rests on a [VERIFIED] basis and includes the exact contrast ratio, pixel measurement, or failing code
- No P1/P2 is justified by a [GUIDELINE]/[PRECEDENT] item alone (those cap at P3 unless paired with a verified accessibility failure)
- No fix removes or changes the logo, wordmark, or brand hue without explicit user approval
- All High theme-impact findings were put to the user in Step 6
- The improvement plan assigns every finding to a quadrant
- `prefers-reduced-motion` is addressed for any motion-related finding
- All six lanes are represented in the coverage table (clean passes recorded, not silently dropped)
- P3/P4 findings are summarized, not padded into full entries
- No application code was modified — this skill writes docs only
- The "What's working" section has genuine specific strengths, not filler
- The scope boundary is stated clearly in `00-summary.md`

---

### Step 10 — Skill handoffs

After delivering the report, suggest the next skills to continue the work. Present these as options, not requirements.

**To turn findings into an executable implementation plan:**
> The improvement plan in `02-improvement-plan.md` lists what to fix in priority order. To convert that into a sequenced, map-linked task set that any agent can execute independently, run `/task-plan-architect` and point it at the improvement plan. It will decompose each finding into a verifiable task with acceptance criteria.

**To get a second opinion on contested design decisions:**
> Step 4's lane fan-out is already a fusion-style panel, but it's scoped to one finding per lane. When a *specific* recommendation is genuinely debatable for your context — a brand trade-off, an unconventional pattern you chose on purpose — run `/fusion-reasoning` with that finding as the prompt. It dispatches independent personas with different priorities and synthesizes one verdict that weighs the trade-offs.

**To execute the improvement plan once built:**
> After `/task-plan-architect` produces the task files, run `/planrunner` to execute them. It orchestrates the work across subagents, runs adversarial review on each slice, and verifies against acceptance criteria before marking complete.

**To generate a style guide alongside this critique:**
> If no style guide was found in Step 1, the critique surfaced the implicit visual system. Run `/style-guide` to codify it — it extracts the same tokens the critique evaluated and produces a `docs/style-guide/` directory that becomes the canon. Future critiques run faster with a style guide in place.

**To re-run the critique after improvements land:**
> Re-run `/design-critique` on the same scope. The second pass should show P1/P2 counts dropping; the delta between runs is the measure of design-quality improvement.

---

Summarize for the user: total findings by severity, the single highest-priority fix to make today, how it was run (inline or fanned out across lanes), and which skills to reach for next based on what the audit found.
