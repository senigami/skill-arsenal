# The reviewer panel

Each reviewer is a Sonnet agent (judgment + vision needed) dispatched in parallel with the round's screenshot paths and its lens. Where a reviewer has a backing skill, its prompt tells it to load that skill first so guidance stays current and isn't duplicated here. All reviewers are **read-only** — they critique and score; they never edit.

## Roster

This is a **menu, not a checklist.** Pick the 3–5 most relevant reviewers for the screen under review — more than five produces redundant findings the orchestrator just has to dedupe back together. Choose by what the design needs: craft reviewers catch what looks wrong; the follow/flow reviewers catch what's confusing; the human reviewers catch what trips real people up.

### Craft — does each screen look right (pick 2–3)

| Reviewer | Lens | Loads | Skip when |
|----------|------|-------|-----------|
| **UX & visual** | Clarity, hierarchy, information density, the primary-action-is-obvious test | `design:design-critique` if present | core — rarely skip |
| **UI craft & polish** | Spacing rhythm, alignment, type scale, color harmony, component consistency — plus the *squint test*: does this read as premium/considered, or generic? | — | core — rarely skip |
| **Apple HIG** | Clarity/deference/depth, platform conventions, restraint, 2026 Liquid Glass aesthetics | `apple-hig-expert` | non-Apple-styled product |
| **Design-system compliance** | Token-driven color, semantic classes, no hardcoded hex, component vocabulary | repo's design-compliance skill (e.g. `greenlight-design-compliance`) | no design system exists |
| **Responsive & theming** | Layout holds 390→1280px, no overflow/clipping, dark mode complete and contrast-correct | — | non-responsive surface |
| **Accessibility** | Contrast in both themes, focus order, touch targets (~44px), color-isn't-the-only-signal, labels | `a11y-audit` if present | rarely skip — it's also a people lens |

### Easy to follow — can someone understand it (pick 1–2)

| Reviewer | Lens | Loads | Skip when |
|----------|------|-------|-----------|
| **Content & UX writing** | Labels, button text, empty-state and error copy, headings, tone — is every word pulling weight and does it sound human, not system-generated? | `design:ux-copy` if present | text-light surface (e.g. a pure canvas) |
| **Flow & information architecture** | Can a first-timer complete the core task without a guide? Nav clarity, cognitive load, step count, what's shown vs. progressively disclosed, sensible defaults | — | single static screen with no task |

### Made for people — does it work for a real user (pick 0–1)

| Reviewer | Lens | Loads | Skip when |
|----------|------|-------|-----------|
| **Persona walkthrough** | Role-plays the actual target user attempting the core task *cold* from the screenshots, narrating where it hesitates, misreads, or gets stuck. The closest thing to watching a real user. | — | give it a concrete persona + task, or skip |
| **Motion & interaction** | Transitions, feedback on every action, loading/skeleton behavior, the fluid responsive feel Apple is known for — and nothing janky, abrupt, or missing. Needs a short screen recording or before/after states, not just stills. | — | static surface with no meaningful motion |

**For a "looks great, easy to follow, Apple-quality, human" goal**, a strong default panel is: UI craft & polish + Apple HIG + Content & UX writing + Flow & IA + Persona walkthrough — swapping in Accessibility/Responsive when the screen's risk is there. That covers craft, clarity, and the real-person test without redundancy.

## Pass 2a — Independent review prompt (template)

> Read-only design review. You are the **<lens>** reviewer. <If a backing skill applies:> First load the `<skill-name>` skill and apply its rubric.
>
> Screenshots for this round are at: `<paths>`. <On round 2+:> The prior round scored `<scores>` and made these changes: `<change list>` — confirm they landed and don't re-raise settled points.
>
> Critique only through your lens. Score each of your dimensions 1–5 (5 = ship-quality, 4 = good with nits, 3 = noticeable problems, ≤2 = blocking). For every score below 5, give a concrete, located finding and a specific fix — not "improve hierarchy" but "the page title and the section headers are the same size (desktop screenshot); drop section headers to text-lg/medium so the H1 leads."
>
> Return only this JSON:
> ```json
> {
>   "reviewer": "<lens>",
>   "scores": [{"dimension": "hierarchy", "score": 3, "reason": "one line"}],
>   "findings": [
>     {"severity": "blocker|major|minor", "dimension": "hierarchy",
>      "screen": "<screen>", "viewport": "desktop",
>      "problem": "what's wrong, concretely", "fix": "the specific change", "location": "component/file if known or null"}
>   ],
>   "overall": "one-sentence verdict"
> }
> ```

## Pass 2b — Deliberation prompt (template)

After compiling the independent verdicts into one combined report (every finding + score, tagged with the reviewer who raised it), send it back to each reviewer. Include only the **contested or cross-cutting** items — drop findings the whole panel already agrees on.

> Read-only. You are the **<lens>** reviewer from the panel. Here is the combined report from this round's independent reviews, with each item tagged by who raised it: `<combined report>`.
>
> React as a board member, not by re-reviewing from scratch. For items that touch your lens or that you have a view on:
> - State **agree** or **disagree** with a one-line reason. Disagreement is valuable — if another reviewer's fix would hurt your dimension, say so concretely.
> - Note any **cross-finding**: something another reviewer's point made you newly notice that you missed in your first pass.
> - If the discussion changes your mind, give **revised scores** for your dimensions with the reason.
>
> Stay in your lane — don't grade dimensions that aren't yours. Return only this JSON:
> ```json
> {
>   "reviewer": "<lens>",
>   "positions": [
>     {"finding_ref": "<id or short quote>", "stance": "agree|disagree|neutral", "reason": "one line"}
>   ],
>   "cross_findings": [
>     {"severity": "blocker|major|minor", "problem": "...", "fix": "...", "prompted_by": "<which reviewer's point>"}
>   ],
>   "revised_scores": [{"dimension": "hierarchy", "from": 3, "to": 4, "reason": "one line"}],
>   "overall": "one-sentence updated verdict"
> }
> ```

If a reviewer disagrees with a fix that another reviewer proposed, that tension is exactly what you (the orchestrator) arbitrate in Step 3 — the deliberation surfaces it cleanly instead of leaving you to guess the panel would have disagreed.

## How scores drive the loop

- A **dimension** is converged when every reviewer scoring it gives ≥ threshold (default 4). Use **post-deliberation** scores (a reviewer's `revised_scores` override its 2a scores) — those reflect the panel's settled view.
- The loop continues while any dimension is below threshold and rounds remain.
- The orchestrator carries scores across rounds so the trend is visible. Flat or falling scores round-over-round mean the changes aren't working — stop and rethink the direction rather than spending the cap.
- **blocker** findings (broken layout, failed contrast, unreadable text) force another round regardless of the numeric scores — a 4/5 average doesn't excuse a broken mobile view.
