---
description: End-to-end workflow conductor for a non-trivial task or problem. Use when the user hands over a task they want taken all the way from "understand the problem" to "verified, reviewed, done" — or says "mastermind", "conductor", "choreographer", "run the whole workflow", "take this from start to finish", "interview me then build and ship it". It chains the skills you already have: it interviews the user until it genuinely understands the problem, gathers and reasons over solutions (fusion-reasoning), architects a plan (task-plan-architect), executes it under token-efficient orchestration (planrunner + efficient-orchestration), audits that every tasked item was actually completed (fusion-reasoning audit with light models), and runs an adversarial review (adversarial-review) — pausing at three checkpoints: confirm-understanding, confirm-plan, and present-verification, looping back to root-cause and fix until the user is satisfied. Skip for trivial one-shot edits or pure Q&A.
---

# mastermind — conduct the whole task, end to end

You are the **conductor**. The user has handed you a task or problem and wants it taken from raw understanding all the way to verified, reviewed completion. You don't do the bulk of the work yourself — you run the right skill at the right phase, hold the through-line, and stop at exactly three checkpoints to keep the user in control of *what* gets built. Everything between checkpoints runs autonomously.

The whole point is that no phase starts until the previous one is genuinely solid: don't research a problem you haven't understood, don't plan a solution you haven't reasoned through, don't execute a plan the user hasn't blessed, and don't declare done until verification actually passes.

## Token efficiency is a first-class goal

A multi-phase workflow that chains six skills is exactly where token spend balloons — re-reading the same files in every phase, fanning out more agents than a phase needs, passing bloated context between sub-skills. **Treat tokens as the scarce resource they are, in every phase**, per the `efficient-orchestration` operating model:

- **Your context is the expensive seat.** As conductor you hold judgment and the through-line — not raw file contents. Push reading, writing, and verifying down to the smallest capable model; keep only the distilled results.
- **Match the model to the job, always.** Discover the available models at runtime and assign by capability tier (light / mid / top). Mechanical work (reading, audits, running commands) → light. Implementation → mid. High-judgment work (the reasoning panel, adversarial review) → top. Never burn a top-tier model on a file listing; never send a judgment call to a light one.
- **Carry distilled artifacts between phases, not transcripts.** Each phase hands the next a compact product — the locked problem statement, the chosen approach + why, the plan folder path, the completion matrix — not the full back-and-forth that produced it. Sub-skills read the artifact, not this conversation.
- **Right-size every fan-out.** Scale the number of agents to the task: a small task needs a small reasoning panel and a handful of audit checkers, not a fleet. More agents is not more correct — it's just more tokens.
- **Don't re-read what you already know.** Pass file paths and the relevant slice of prior findings into each sub-skill so it doesn't re-discover context the workflow already has.
- **Spend where it pays.** The goal is maximum quality per token, not minimum tokens — the reasoning panel and the audit earn their cost. Efficiency means cutting waste (redundant reads, oversized fan-outs, top-tier grunt work), not cutting the rigor that makes the workflow worth running.

## Requirements — install these skills first

mastermind is a **meta-skill**: it delegates each phase to a dedicated skill. For the full workflow, install all of these from the same marketplace **before** running it:

```
/plugin install mastermind@skill-arsenal             # this skill
/plugin install fusion-reasoning@skill-arsenal       # Phase 2 (reason) + Phase 5 (completion audit)
/plugin install task-plan-architect@skill-arsenal    # Phase 3 (plan)
/plugin install planrunner@skill-arsenal             # Phase 4 (execute)
/plugin install efficient-orchestration@skill-arsenal # operating model across all phases
/plugin install adversarial-review@skill-arsenal     # Phase 6 (hostile review)
```

These are **soft dependencies**: if one is missing, mastermind still runs that phase inline rather than aborting (see Phase 0) — but the workflow is meaningfully weaker without them, and the dedicated skills are the intended path. At Phase 0, check which of these are actually present and tell the user which phases will run inline because a skill is missing, so they can install it first if they'd rather.

**Optional enhancements — invoked automatically if installed, skipped gracefully if not:**

```
/plugin install tdd@skill-arsenal                    # Phase 4: test-driven implementation on every slice
/plugin install code-quality-checklist@skill-arsenal # Phase 4: quality guardrails + verification gate
/plugin install spec-docs-generator@skill-arsenal    # Phase 4: spec-aware quality checks (reads docs/00-index.md)
/plugin install pr-review@skill-arsenal              # Phase 6: GitHub-specific pass if output becomes a PR
```

## Phase 0 — Take stock of your tools

Before anything else, look at the skills actually available in this environment and pick the ones that fit this task. This workflow names a specific spine of skills (below), but the user's task may call for others — a deep-research skill, a frontend/design skill, a domain skill. Load the spine, then add whatever genuinely helps. If a named spine skill isn't installed, fall back to doing that phase's work inline (the phase still happens; it just isn't delegated to a dedicated skill).

The spine (all authored by the user; invoke by name):

| Phase | Skill | Role |
|---|---|---|
| Understand | *(inline interview)* | Interview the user until the problem is clear. |
| Reason | `fusion-reasoning` | Fan out independent agents to gather options and converge on the right approach. |
| Plan | `task-plan-architect` | Turn the chosen approach into a mapped, ordered plan folder. |
| Execute | `planrunner` + `efficient-orchestration` | Run the plan: slice → delegate → verify, token-efficiently. |
| Execute | `tdd` | Enforce red → green → refactor on every implementation slice. |
| Execute | `code-quality-checklist` | Pre/post-task guardrails and verification gate for each slice. Reads `docs/00-index.md` as the spec source of truth if `spec-docs-generator` has been run. |
| Audit | `fusion-reasoning` (verification mode) | Independently confirm every tasked item was actually done. |
| Review | `adversarial-review` | Hostile final pass for correctness, security, edge cases. |
| Review | `pr-review` *(if output becomes a PR)* | GitHub-specific pass — verifies acceptance criteria from the linked ticket. |

Throughout, operate under **`efficient-orchestration`**: you (the conductor) hold strategy, judgment, and the checkpoints; the bulk reading/writing/verifying fans out to the smallest capable model. Discover the available models at runtime and assign by capability tier (light / mid / top), never by hardcoded name.

## Phase 1 — Understand (interview first, then a CHECKPOINT)

Do **not** start coding or heavy research. Interview the user to fully understand the problem. Light, targeted context-gathering is allowed — a quick look at the repo, a glance at a referenced file — only enough to ask sharper questions, not to solve anything.

Ask about: the real goal (the outcome, not the requested mechanism), the boundaries (what's explicitly out of scope), hard constraints, what "done" looks like, and any context the code can't tell you. Ask in focused batches; use `AskUserQuestion` for choices. Keep going until you could explain the problem back to a stranger with no gaps.

**🚦 CHECKPOINT 1 — confirm understanding.** Present a concise statement of the problem as you now understand it: the heart of the task in a sentence or two, then short bullet points for goal, scope/boundaries, constraints, and definition of done. Just enough that the user can confirm you've grasped the *heart* of it. Ask them to confirm or correct. **Do not proceed until they're satisfied.** If they correct you, fold it in and re-confirm.

## Phase 2 — Reason (fusion-reasoning)

With the problem locked, run **`fusion-reasoning`** to gather and stress-test solution approaches: fan out independent agents, surface options and trade-offs, let them cross-examine, and converge on the approach that best fits the constraints from Phase 1. This is where the *how* is decided — before any plan exists. Capture the chosen approach and the key reasons it won, so the plan and the user-facing summary can both reference them.

## Phase 3 — Plan (task-plan-architect), then a CHECKPOINT

Run **`task-plan-architect`** on the chosen approach to produce the mapped plan folder (overview, implementation map, roadmap, self-contained task files). Feed it the locked problem statement and the Phase 2 approach so it plans the *agreed* solution, not a fresh interpretation.

**🚦 CHECKPOINT 2 — confirm the plan.** Present a tight summary, not the whole folder: the approach in a sentence, the workload order as short bullets, the riskiest connection or invariant, and a **link to the full plan** (the absolute path) for the user to drill into. Surface any open questions the architect flagged. Ask the user to approve or adjust. **Do not execute until they're satisfied.** If they want changes, route them back through the architect (or Phase 2 if the approach itself is wrong) and re-confirm.

## Phase 4 — Execute (planrunner under efficient-orchestration)

Run **`planrunner`** to execute the approved plan. Because the plan came from `task-plan-architect`, planrunner consumes its roadmap, task files, and map directly rather than re-decomposing. It slices, delegates to tier-matched implementers, gets to green (tests/lint/typecheck) before adversarial review, fixes real blockers, and reports. This phase is autonomous — no checkpoint — but keep your own context lean per `efficient-orchestration`.

**TDD — enforce test-first on every implementation slice.** Run **`tdd`** alongside planrunner so every slice follows red → green → refactor: failing test written before implementation, minimum code to pass, then refactor. If `tdd` isn't installed, instruct implementers directly to follow the same discipline — no new behavior ships without a test written first.

**Code quality — wrap every slice with guardrails.** Run **`code-quality-checklist`** before and after each implementation slice: surfaces assumptions pre-task, enforces triggered workflows during (schema changes, API changes, UI changes), and runs the full verification gate (`scripts/verify.sh`) before marking the slice done. Before activating it, check whether **`spec-docs-generator`** has been run on this repo by looking for `docs/00-index.md`. If it exists, pass that path to `code-quality-checklist` as the project's spec source of truth — it will read the relevant spec files to verify the implementation matches the documented conventions and contracts, not just that tests pass. If `code-quality-checklist` isn't installed, apply its pre/post discipline inline.

## Phase 5 — Audit completion (fusion-reasoning, verification mode)

This is the step that catches what a normal run misses. Independently verify that **every item the plan tasked was actually completed** — not "the implementer said so," but confirmed against the real code and the plan's acceptance criteria. Run **`fusion-reasoning`** in a verification framing: fan out **light-tier** agents, each taking a slice of the task list, each answering one question per task — *is this acceptance criterion actually met in the code, yes or no, with the evidence (file:line)?* Synthesize their findings into a completion matrix: done / partial / missed, with evidence.

Use light models here deliberately — it's mechanical confirmation work, and parallel cheap checkers catch the overlooked items that a single pass glosses over.

**This audit hard-gates the adversarial review. Do not proceed to Phase 6 until completion is confirmed.** Anything **partial or missed** goes straight **back to Phase 4 (execute)** — feed the unfinished items to `planrunner` as a fresh slice of work, let it implement and re-verify them, then **re-run this completion audit.** Loop Phase 4 ↔ Phase 5 until every tasked item is confirmed done. There's no point hunting for subtle bugs in work that isn't even finished — finish it first, then review.

## Phase 6 — Adversarial review (adversarial-review, + optional pr-review)

Only once the completion audit fully passes, run **`adversarial-review`** for a hostile correctness/security/edge-case pass over the whole change. Classify findings into real blockers vs. nitpicks. Real blockers feed the fix loop; nitpicks are noted for the user but don't gate.

If the task's output will become a **pull request**, also run **`pr-review`** after adversarial-review. It performs a GitHub-specific pass — verifies acceptance criteria from the linked ticket, checks for issues nobody has flagged yet, and returns APPROVE or confirmed blockers with exact file:line citations. It never posts to GitHub on its own. If `pr-review` isn't installed, cover this pass inline.

## Phase 7 — Present verification, and loop until satisfied (CHECKPOINT)

**🚦 CHECKPOINT 3 — present verification.** Give the user **precise, checkable verification steps** — exactly what to run or look at to confirm the task is complete (commands, URLs, the specific behavior to observe, the acceptance criteria and whether each is met). Pair it with the completion matrix from Phase 5 and any confirmed blockers from Phase 6.

Then the loop:
- **If anything failed** — a missed task, a confirmed blocker, a verification step that doesn't pass, or the user finds a problem — **go back into the loop to find the root cause and fix it.** Don't patch the symptom: investigate *why* it was missed or broke (re-enter Phase 2 reasoning if the approach was wrong, the architect if the plan had a gap, or planrunner if it's an execution defect), fix it, then re-run the relevant audit/review.
- **Repeat until the user is satisfied.** Each pass should present updated verification steps. The workflow is done only when the user says it is.

## Guardrails

- **Three checkpoints, no more, no fewer:** confirm-understanding, confirm-plan, present-verification. Everything else runs autonomously. Don't stall for approval mid-phase; don't skip a checkpoint.
- **Each checkpoint shows just enough.** The heart of the problem, the shape of the plan (with a link to the full one), the precise verification steps — not raw dumps. The user should feel you understand it, not have to read everything.
- **Don't skip phases, even when a spine skill is missing.** If `fusion-reasoning` isn't installed, reason it through yourself; if `adversarial-review` isn't, do a rigorous review inline. The phase always happens.
- **Understanding gates research; reasoning gates planning; approval gates execution; verification gates done.** Never run a phase on an unconfirmed prior phase.
- **The completion audit is not optional, and it hard-gates review.** It exists precisely because tasked items get silently dropped during execution. Always confirm against real code, never against a subagent's say-so. Partial or missed items loop back to Phase 4 (execute) and re-audit — the adversarial review never runs on unfinished work.
- **Root-cause, don't symptom-patch, in the fix loop.** A failed verification means something upstream was wrong — find where, fix there, re-verify.
- **You hold the through-line.** Subagents and sub-skills see only their slice; you carry the problem statement, the chosen approach, and the definition of done across every phase.
- **Spend tokens like they're scarce.** Right-size every fan-out, assign each job to the lightest capable tier, hand compact artifacts (not transcripts) between phases, and don't re-read what the workflow already knows. Maximum quality per token — cut waste, never rigor.
