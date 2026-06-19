---
name: design-critique
description: >-
  Evaluate an existing UI against Apple HIG, Nielsen's 10 heuristics, Gestalt,
  and WCAG 2.2 AA. Use when the user wants to "critique the design", "improve
  the UI", "audit the interface", "apply HIG", "review this page", "make this
  more Apple", or "what's wrong with the design". Works from a style guide, a
  codebase, a specific page, screenshots, or any combination. If a style guide
  exists, evaluates the live UI against it. If not, surveys the codebase or
  works from what the user provides. Produces a full audit report in
  docs/design-critique/ — severity-rated findings (P1–P4), exact violation
  citations, before/after code fixes, an impact/effort improvement roadmap, and
  trade-off decisions requiring user input. Preserves the existing theme. After
  the report, suggests which complementary skills to run next: task-plan-architect
  to build an executable plan, fusion-reasoning for contested decisions,
  planrunner to execute, style-guide to codify the implicit design system.
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

## Evaluation frameworks

The skill runs four passes in order. Apple HIG is primary; the others fill gaps HIG doesn't address.

### Apple HIG (web translation)

HIG was written for native apps, but its three core principles — **Clarity**, **Deference**, and **Depth** — apply universally.

**Clarity violations to check:**
- Buttons that don't look clickable (insufficient visual weight, no affordance cue)
- Links indistinguishable from body text (same color, no underline, no icon)
- Icons used without labels where meaning isn't universal
- Error messages in technical language or error codes (SMTP authentication failed)
- Form labels so far from their inputs they could belong to either

**Deference violations to check:**
- Navigation and chrome competing visually with the content it surrounds
- Decorative elements (illustrations, textures, gradients) louder than primary actions
- Sidebar or modal with `background: #000000` flat fill — HIG specifies layered translucency, one translucent surface per z-level (`backdrop-filter: blur(20px)` + semi-transparent fill). Solid opaque backgrounds remove depth signaling.
- Tab bars used for actions rather than navigation-only

**Depth violations to check:**
- Elevation inconsistency — cards and modals at same visual depth
- Heavy `box-shadow` with multiple large blur values (reads as MD3 not HIG — HIG uses subtle shadow + layering)
- Z-axis model broken (tooltip appears below the content it references)
- Dark mode: lighter surfaces should be higher elevation (commonly inverted by mistake)

**HIG color rules:**
- Avoid pure `#000000` black → use `#1C1C1E` equivalent
- Avoid pure `#FFFFFF` white → use `#F5F5F7` equivalent
- Semantic color tokens, not raw hex in components
- Red only for destructive/error — never for non-destructive CTAs

**HIG typography:**
- Minimum 16px body on web (below this, iOS Safari auto-zooms on input focus)
- Minimum 11pt absolute floor; captions no smaller than 12px
- Use system font stack (`system-ui, -apple-system`) or explicit loaded font — never platform-default fallback by accident
- `prefers-reduced-motion`: mandatory. Transitions must fall back to instant or opacity-only. This is never optional.
- Spring physics preferred over linear easing for interactive elements

**HIG touch targets:**
- Minimum 44×44px (HIG standard). Flag anything below.
- WCAG 2.5.8 floor: 24×24px. Below this is an AA failure.

---

### Nielsen's 10 Heuristics

| H# | Heuristic | What to check |
|----|-----------|---------------|
| H1 | Visibility of system status | Loading states on every async action, success/error after form submit, no silent failures |
| H2 | Match between system and real world | User-language labels (not internal jargon), natural information order, recognizable icon meanings |
| H3 | User control and freedom | Cancel in every multi-step flow, undo for destructive actions, functional browser back button |
| H4 | Consistency and standards | Same term means the same thing everywhere; button placement follows platform convention |
| H5 | Error prevention | Inline validation (not submit-only), confirmation dialogs before irreversible deletes, date pickers not free-text |
| H6 | Recognition over recall | Options visible without memory; breadcrumbs; autocomplete; help available in context |
| H7 | Flexibility and efficiency | Keyboard shortcuts for power users; bulk actions; saved filters or presets |
| H8 | Aesthetic and minimalist design | One primary CTA per screen; every element earns its place; visual hierarchy clear at squint-test |
| H9 | Help recover from errors | Plain language error messages that name the problem and suggest the fix |
| H10 | Help and documentation | In-context help (tooltips, inline guidance), not just a remote knowledge base |

---

### Gestalt principles

| Principle | Violation pattern |
|-----------|-------------------|
| **Proximity** | Form label >8px gap from its input; CTA button not adjacent to the content it acts on; related elements scattered with equal whitespace |
| **Similarity** | Two button styles for the same action class; interactive text looks identical to static text; different icon fill-styles in the same bar |
| **Continuity** | Form fields misaligned on vertical axis; CTA button moves position between wizard steps; navigation reorders between pages |
| **Figure/ground** | Body text below 4.5:1 contrast; full-bleed hero photo with overlaid text not separated; background pattern competing with foreground content |
| **Common region** | Unrelated content inside the same card; related settings split across separate containers |
| **Prägnanz** | Dashboard with >15 simultaneous metrics; icons that require a legend; layout described as "busy" by fresh readers |
| **Common fate** | Unrelated elements animate together; related elements animate independently when they should move as a unit |

---

### WCAG 2.2 AA — measurable from code

These are the criteria testable by inspecting CSS and DOM without screenshots.

| Criterion | Threshold | What fails |
|-----------|-----------|-----------|
| **SC 1.4.3** | 4.5:1 normal text; 3:1 large (≥18px or ≥14px bold) | Any text below threshold; ratios cannot be rounded (4.47:1 fails 4.5:1) |
| **SC 1.4.11** | 3:1 for UI components — button/input borders, focus rings, active icons | Borderless inputs; focus rings below threshold |
| **SC 1.4.1** | Color not sole indicator | Links distinguished only by color (no underline, no icon); error state only via red border |
| **SC 2.4.7** | Focus visible on all keyboard-focusable elements | `outline: none` or `outline: 0` with no replacement focus style |
| **SC 2.4.11** | Focus not entirely obscured by sticky header/modal | Focused element scrolls behind a fixed header |
| **SC 2.5.8** | Touch target ≥24×24px or 24px offset between adjacent targets | Icon buttons below 24px with no padding; dense link lists |
| **SC 1.4.4** | Content functional at 200% text zoom | Text overflow clipped or overlapping at 200% browser zoom |
| **SC 1.4.10** | Reflow at 320px width without horizontal scroll | Any content triggering horizontal scroll at `max-width: 320px` |
| **SC 1.4.12** | Text spacing: line-height ≥1.5×, letter-spacing ≥0.12em, word-spacing ≥0.16em | Hard-coded pixel line-height that can't be overridden |

---

## Workflow

### Step 1 — Determine what to review

The skill adapts to whatever evidence is available. Route based on what the user provided:

**Route A — Style guide exists**
Check for `docs/style-guide/`, `STYLEGUIDE.md`, Storybook, or `tokens.json`. If found:
- The style guide is the canon. Evaluate the live UI *against it*.
- Deviations from the style guide are P2 consistency violations (the spec exists; the implementation ignored it).
- Still run all four evaluation passes against design principles — style guide conformance and principle conformance are separate concerns.
- Note the style guide version/date in the report header.

**Route B — No style guide; codebase is available**
Survey the codebase as described in Step 3. Extract the implicit design system from tokens, components, and patterns. This is the widest-scope path — the critique covers the whole product.

**Route C — Specific page, feature, or URL**
The user pointed at something particular ("review the checkout page", "look at this dashboard", "how does this form compare to best practices"). Scope the critique to that surface only. Don't expand unless the user asks. State the scope boundary explicitly at the top of the report.

**Route D — Screenshots only**
The user has no codebase access, or they want feedback purely from what's visible. Work entirely from the screenshots provided. Mark every finding as `[visual only — no code reference]`. Skip Step 3 (codebase survey). Contrast findings cite the visible colors; note that exact ratios require the actual CSS values.

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

Fan this across parallel agents for large codebases. Read systematically:

**CSS/design tokens (highest signal):**
- Global CSS: check `:root` custom properties, `globals.css`, `variables.css`
- Tailwind config (`tailwind.config.js/ts` or `@theme` blocks in CSS): extract color, font, spacing, border-radius values
- `theme.ts`, `tokens.json`, dedicated token files

**For each color value found:** calculate or estimate contrast ratios against likely backgrounds. Flag any text-on-background pair below 4.5:1. Flag any UI component (border, icon, badge) below 3:1.

**For spacing values:** check if all values are multiples of 4 (or 8 for the 8pt grid). Flag hard-coded values like `7px`, `13px`, `19px` — off-grid.

**Component files:**
- Read Button, Input, Select, Modal, Nav — note which interactive states have explicit styles (hover, focus, active, disabled) and which are missing
- `cva()`, `clsx()`, `cn()`, `variants` patterns — encode the full variant system; read these to detect inconsistent naming
- Check for `outline: none` / `outline: 0` without replacement focus style

**Typography:**
- Smallest font-size token — flag if below 12px
- Check if `font-size` below 16px is applied to inputs (iOS zoom trigger)
- Check for hard-coded `line-height` in pixels (prevents user text-spacing override)

**Motion:**
- Search for `transition`, `animation`, `@keyframes`
- Check if `@media (prefers-reduced-motion: reduce)` override exists — if not, that's a P2

**Responsive:**
- Confirm 320px-width reflow: check for `min-width` values that would break at 320px, fixed-width containers, `100vw` on content containers (scrollbar width bug)
- Check for `vh` (should be `dvh` or `svh` for mobile) on full-height layouts

---

### Step 4 — Run evaluation passes

Run all four passes. Map each finding to a unique ID (`DC-001`, `DC-002`, …).

**Pass A: Apple HIG**
Check every violation listed in the frameworks section. For web apps, translate native HIG concepts:
- "Layered translucency" → `backdrop-filter: blur()` + semi-transparent background on elevated surfaces (modals, sidebars, dropdowns). Solid dark fills on these surfaces is the violation the user described.
- "Springy animations" → `transition-timing-function: cubic-bezier(0.34, 1.56, 0.64, 1)` or equivalent; linear easing is the violation
- "Platform conventions" → compare to common web patterns (tab bar = bottom nav on mobile, top nav on desktop)

**Pass B: Nielsen**
Walk through H1–H10. For each heuristic, name at least one pass and one concern. Don't skip any — a clean pass on H7 (flexibility) is still worth noting. Flag all fails.

**Pass C: Gestalt**
The squint test: blur your mental image of the layout. What groups? What's figure vs. ground? What's the scan path? Flag proximity/similarity/figure-ground failures.

**Pass D: WCAG 2.2 AA**
Run the measurable checks from the table above. For contrast, compute precise ratios — don't estimate. Include the exact ratio in the finding (`3.1:1 — fails SC 1.4.3 by 1.4:1`).

---

### Step 5 — Triage findings

Rate every finding before writing the report.

**Severity levels:**

| Level | Label | Criteria | Examples |
|-------|-------|----------|----------|
| **P1** | Blocker | Prevents task completion, causes data loss, WCAG AA failure on critical-path element, legal risk | Keyboard trap in modal; form submit button not keyboard-operable; primary CTA text at 2.8:1 contrast |
| **P2** | Major | Core feature completable but severely degraded; significant user confusion; HIG core principle clearly violated; WCAG AA failure off critical path | Missing error states; solid black modal background (breaks depth model); body text at 3.2:1; no loading state on data fetch |
| **P3** | Polish | Design principle deviation that's noticeable but doesn't block flow; consistency issue; sub-optimal but functional | Off-grid spacing value (15px instead of 16px); hover state inconsistent between similar buttons; missing focus ring only on icon buttons |
| **P4** | Cosmetic | Team preference; pixel nudge; no functional or perceptual impact | Slight font-weight preference; logo size tweak; micro-animation timing 50ms vs. 60ms |

**Severity escalates by one level** when a finding affects the primary conversion path (checkout, signup, primary CTA).

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
| **Framework** | Apple HIG — Depth; Nielsen H8 — Aesthetic and Minimalist |
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
/* Reduced-motion fallback */
@media (prefers-reduced-transparency) {
  .sidebar { background-color: oklch(10% 0 0 / 1); }
}
```
```

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
**Frameworks:** Apple HIG (primary), Nielsen's 10 heuristics, Gestalt, WCAG 2.2 AA
**Style guide used:** [Yes — docs/style-guide/ / No — implicit system extracted from code / N/A — screenshots only]

---

> **TL;DR:** [2–3 sentence verdict. Be direct. Example: "The typography and information hierarchy are well-executed. The depth model is broken — every elevated surface uses solid black fills that collapse the spatial hierarchy Apple HIG requires. Three contrast failures on primary actions are WCAG blockers and must ship before any polish work."]

## What we reviewed
[One paragraph: what surfaces were evaluated, what was not, what evidence was used (code, screenshots, style guide), and any notable limitations (e.g., "interactive states could not be verified — screenshots of hover and focus states were not provided")]

## What's working
[3–5 specific strengths. Be genuine — good critique includes what to preserve, not just what to fix. Strengths are as important as findings for a team that needs to know what not to touch in a redesign.]
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

## Top priority findings
| ID | Finding | Severity | Effort |
|----|---------|----------|--------|
| DC-001 | [Title] | P1 | S |
| DC-002 | [Title] | P1 | M |
| DC-003 | [Title] | P2 | S |

## Decisions needed from you
[List any trade-offs from Step 6 that the user resolved, and note the decision for the record. If none: "No brand-conflicting recommendations — all improvements preserve existing visual identity."]
```

---

**`docs/design-critique/01-findings.md`** — the full finding list:

Write every P1 and P2 finding in full (per-finding format from Step 7). Group P3 and P4 at the end in a summary table:

```markdown
## P3 — Polish (grouped)
| ID | Finding | Location | Effort |
|----|---------|----------|--------|
| DC-0NN | [Title] | [File/Component] | XS |
...

## P4 — Cosmetic (grouped)
| ID | Finding | Location | Note |
|----|---------|----------|------|
| DC-0NN | [Title] | [File/Component] | Fix if time allows |
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
- Every finding cites a specific principle or criterion (no bare "this is bad")
- Every P1 includes exact contrast ratio, exact pixel measurement, or exact code that fails
- No fix removes or changes the logo, wordmark, or brand hue without explicit user approval
- All High theme-impact findings were put to the user in Step 6
- The improvement plan assigns every finding to a quadrant
- `prefers-reduced-motion` is addressed for any motion-related finding
- P3/P4 findings are summarized, not padded into full entries
- No application code was modified — this skill writes docs only
- The "What's working" section has genuine specific strengths, not filler
- The scope boundary is stated clearly in `00-summary.md`

---

### Step 10 — Skill handoffs

After delivering the report, suggest the next skills to continue the work. Present these as options, not requirements.

**To turn findings into an executable implementation plan:**
> The improvement plan in `02-improvement-plan.md` lists what to fix in priority order. To convert that into a sequenced, map-linked task set that any agent can execute independently, run `/task-plan-architect` and point it at the improvement plan document. It will decompose each finding into a verifiable task with acceptance criteria.

**To get a second opinion on contested design decisions:**
> If you're not sure whether a recommendation is right for your specific context — or you want multiple perspectives before committing — run `/fusion-reasoning` with the contested finding(s) as input. It will dispatch independent agent personas and synthesize one answer that accounts for the trade-offs.

**To execute the improvement plan once built:**
> After `/task-plan-architect` produces the implementation task files, run `/planrunner` to execute them. It orchestrates the work across subagents, runs adversarial review on each slice, and verifies against the task acceptance criteria before marking complete.

**To generate a style guide alongside this critique:**
> If no style guide was found in Step 1, the critique surfaced the implicit visual system. Run `/style-guide` to codify it — it will extract the same tokens the critique evaluated and produce a `docs/style-guide/` directory that serves as the canon going forward. Future critiques run faster with a style guide in place.

**To run the critique again after improvements are implemented:**
> Re-run `/design-critique` on the same scope. The second pass should show P1/P2 counts dropping, and the delta between runs is the measure of design quality improvement.

---

Summarize for the user: total findings by severity, the single highest-priority fix they should make today, and which skills they should reach for next based on what the audit found.
