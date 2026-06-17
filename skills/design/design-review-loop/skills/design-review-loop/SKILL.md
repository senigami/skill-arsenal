---
name: design-review-loop
description: Iterative multi-agent design review-and-build loop for UI work. Use this whenever the user wants to "review the design", "make this look better", "get a design critique", "polish the UI", "have experts review my site", "iterate on the look", run a "design review", or wants a panel of design specialists to critique a rendered page and then drive it to a better state. It captures live screenshots of the running app, fans out specialist reviewer agents (general UX, UI craft, Apple HIG, design-system compliance, accessibility) who each score and critique, the orchestrator reconciles their findings into one agreed direction, builder agents implement it, and the loop repeats until scores clear a threshold or a round cap is hit. Spawns Sonnet reviewers/builders and light agents for capture; the orchestrator stays the brains.
---

# Design Review Loop

A panel of specialist reviewers critiques the *rendered* UI, the orchestrator reconciles their critiques into a single agreed direction, builder agents implement it, and the loop repeats until the design clears a quality bar. You (the large model) are the orchestrator throughout — you synthesize, decide, and verify; the reviewing and building fan out to cheaper specialist agents.

This skill runs as an orchestration: keep your own (large-model) context for synthesis and convergence calls; push capture to light, cheap agents and review/build to mid-tier agents. Never spend a bigger model than the job needs.

## The loop at a glance

```
0. Setup        → ensure app running, identify target screens, set the bar
1. Capture      → light agent drives the browser, saves screenshots to disk (per viewport)
2a. Independent review → Sonnet specialists critique in parallel, blind to each other, each scores + lists findings
2b. Deliberation       → YOU share the combined report back to the panel; each reviewer agrees/disagrees, revises, replies
3.  Synthesize         → YOU take consensus straight to the change list; escalate only unresolved splits to the user
4.  Converged?         → all dimension scores ≥ threshold, OR round cap hit → stop & report
5.  Build              → Sonnet builders implement the direction from precise specs
6.  Re-capture & re-review → back to step 1 with the new build
```

## Step 0 — Setup

- **Get the app rendering.** Use the preview tools (`preview_start`, then `preview_screenshot`) or a headless browser. If you can't render the UI, you can't run this skill — say so and stop.
- **Identify the target screens/routes.** Ask the user if it's not obvious which pages/components are in scope. A focused review of 1–3 screens beats a shallow sweep of twenty.
- **Set the bar.** Default: every dimension must reach **4/5**, hard cap of **4 rounds**. Let the user raise/lower either. The cap matters — design critique can always find *something*, so the cap is what guarantees the loop terminates.
- **Pick the panel.** Default roster is in [references/reviewers.md](references/reviewers.md). Drop reviewers that don't apply (no design system → skip the compliance reviewer) and add ones the work demands.

## Step 1 — Capture (light agent)

Delegate to a light agent (`runner` / Haiku): drive the running app and save screenshots to disk so the reviewer agents can `Read` them. Capture each target screen at **mobile (~390px), tablet (~768px), and desktop (~1280px)**, plus dark mode if the app themes. Save to a working dir, e.g. `.design-review/round-N/<screen>-<viewport>.png`. Capture details and the durable-PNG fallback (playwright) are in [references/capturing.md](references/capturing.md).

Screenshots must live on disk — reviewer subagents can't see this conversation's inline images. The capture agent returns the list of saved paths.

## Step 2 — Review panel (Sonnet, two passes)

The panel works like a real review board: everyone forms an opinion alone first, then the opinions are put on the table and the board reacts to each other before you decide. Two passes.

### 2a — Independent review (blind, parallel)

Dispatch all reviewers in **one batch** (parallel `Agent` calls). Each reviewer:
- Receives the screenshot paths for this round and its specific lens — **not** the other reviewers' findings. Independence here is the point: blind first passes give you genuinely diverse opinions instead of everyone anchoring on whoever spoke first.
- Loads its backing skill where one exists (the Apple HIG reviewer invokes `apple-hig-expert`; the design-system reviewer invokes the repo's design-compliance skill) — reuse beats re-deriving.
- Returns the **structured verdict** (per-dimension scores 1–5 + located findings), never a prose essay.

### 2b — Deliberation (shared report, parallel)

Compile the independent verdicts into one **combined report** — every finding and score, tagged with who raised it — and send it back to each reviewer for a single reaction pass. This is the agree/disagree round you want: each reviewer reads what the others saw and replies with:
- **Agree / disagree** on findings that touch its lens or that it has a view on — with a one-line reason.
- **Cross-finding** — anything a *different* reviewer's point made it newly notice (this is where the panel catches what solo passes miss).
- **Revised scores** — it may move its own scores up or down given the discussion, stating why.

Run this only on **contested or cross-cutting items**, not unanimous ones — there's no value in re-litigating a finding every reviewer already agrees on, and skipping the agreed ones keeps the pass cheap. Keep deliberation to **one** pass: the panel converges its own disagreements, and you make the final call in Step 3. If the panel is small and already in clear agreement after 2a, you can skip 2b for that round and say so.

The roster, each lens, the skill it loads, and the exact return + deliberation schemas are in [references/reviewers.md](references/reviewers.md). Reviewers are read-only throughout — they critique, they don't edit.

## Step 3 — Synthesize the agreed direction (you)

This is the high-judgment core — don't delegate it. Pull the **deliberated** panel together (post-2b positions, not the raw first pass) and split it into two buckets:

- **Consensus → proceed.** Anything the panel agrees on (unanimous in 2a, or converged during 2b) goes straight into the change list. The user does **not** need to weigh in on what the experts already agree about — that's the whole point of the panel. Dedupe these: the same problem from several lenses (weak hierarchy flagged by both UX and HIG) merges into one change.
- **Unresolved disagreement → escalate to the user.** Where the panel stayed genuinely split after deliberation (the UI-craft reviewer wants more density; HIG wants more breathing room, and neither budged), don't silently arbitrate — bring it to the user as a crisp decision. Present each open disagreement as: what's contested, each side with the reviewer(s) and their reasoning, the visual/UX trade-off, and your recommendation. Use `AskUserQuestion` so they pick. Their call (and any others in the same batch) then joins the change list. Batch all open disagreements into one round of questions, not a drip.

Then **prioritize** the combined list by impact — correctness/clarity/accessibility blockers before polish — carrying each item's score and the reviewer(s) who raised it, and **write it down** as a short ordered change list: each item is what to change, where (file/component), why, and which score it lifts. This is the builder spec.

If there are no open disagreements, there's nothing to escalate — proceed to build without interrupting the user. Only genuine, deliberation-surviving splits earn a question; don't manufacture decisions to seem thorough.

## Step 4 — Convergence check

Stop when **every dimension scores ≥ threshold** across reviewers, or the **round cap** is hit. On stop, report (Step 7). Otherwise continue to build. Track scores per round so the user sees the trend — if scores aren't improving round over round, say so rather than burning the remaining rounds.

## Step 5 — Build (Sonnet builders)

Delegate the change list to builder agents (`implementer`, Sonnet). Each gets a stand-alone spec: the files, the exact change, the design tokens/conventions to use, and the target shape. Run independent changes in parallel; keep coupled edits in one agent. Builders implement only the agreed direction — no scope creep.

Then **verify** the build landed before re-reviewing: read the diffs, confirm each change list item was addressed. A builder's "done" is a claim until you've checked it.

## Step 6 — Loop

Re-capture (Step 1) and re-review (Step 2) the new build. The reviewers should see the *prior round's scores and the change list* so they can confirm fixes landed and avoid re-litigating settled points. Continue until Step 4 says stop.

## Step 7 — Report

Summarize for the user: starting vs. final scores per dimension, the rounds it took, the headline changes each round made, before/after screenshots (paths on disk), any conflict you arbitrated, and anything still below bar at the cap with why. Note the agent split (light capture / Sonnet review + build / your synthesis) so the cost is visible.

## Guardrails

- **You never lower your own model.** You orchestrate; reviewers and builders run on their pinned models.
- **The cap is non-negotiable for termination.** "Everyone satisfied" can be asymptotic; the round cap is what makes the loop finish. Hitting the cap with residual findings is a valid, honest outcome — report them.
- **Reviewers critique rendered pixels, not just code.** The whole point of live screenshots is catching what code-reading misses (real contrast, real spacing rhythm, real overflow). Don't shortcut to source-only review.
- **Don't manufacture work.** If round 1 clears the bar, stop at round 1. A skill that always finds three rounds of changes is overfit to looking busy.
