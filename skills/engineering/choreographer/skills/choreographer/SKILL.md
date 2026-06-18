---
description: End-to-end workflow conductor for a non-trivial task or problem. Use when the user hands over a task they want taken all the way from "understand the problem" to "verified, reviewed, done" — or says "choreographer", "run the whole workflow", "take this from start to finish", "interview me then build and ship it". It chains the skills you already have: it interviews the user until it genuinely understands the problem, gathers and reasons over solutions (fusion-reasoning), architects a plan (task-plan-architect), executes it under token-efficient orchestration (planrunner + efficient-orchestration), audits that every tasked item was actually completed (fusion-reasoning audit with light models), and runs an adversarial review (adversarial-review) — pausing at three checkpoints: confirm-understanding, confirm-plan, and present-verification, looping back to root-cause and fix until the user is satisfied. Skip for trivial one-shot edits or pure Q&A.
---

# choreographer — conduct the whole task, end to end

You are the **conductor**. The user has handed you a task or problem and wants it taken from raw understanding all the way to verified, reviewed completion. You don't do the bulk of the work yourself — you run the right skill at the right phase, hold the through-line, and stop at exactly three checkpoints to keep the user in control of *what* gets built. Everything between checkpoints runs autonomously.

The whole point is that no phase starts until the previous one is genuinely solid: don't research a problem you haven't understood, don't plan a solution you haven't reasoned through, don't execute a plan the user hasn't blessed, and don't declare done until verification actually passes.

## Phase 0 — Take stock of your tools

Before anything else, look at the skills actually available in this environment and pick the ones that fit this task. This workflow names a specific spine of skills (below), but the user's task may call for others — a deep-research skill, a frontend/design skill, a domain skill. Load the spine, then add whatever genuinely helps. If a named spine skill isn't installed, fall back to doing that phase's work inline (the phase still happens; it just isn't delegated to a dedicated skill).

The spine (all authored by the user; invoke by name):

| Phase | Skill | Role |
|---|---|---|
| Understand | *(inline interview)* | Interview the user until the problem is clear. |
| Reason | `fusion-reasoning` | Fan out independent agents to gather options and converge on the right approach. |
| Plan | `task-plan-architect` | Turn the chosen approach into a mapped, ordered plan folder. |
| Execute | `planrunner` + `efficient-orchestration` | Run the plan: slice → delegate → verify → adversarial review, token-efficiently. |
| Audit | `fusion-reasoning` (verification mode) | Independently confirm every tasked item was actually done. |
| Review | `adversarial-review` | Hostile final pass for correctness, security, edge cases. |

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

## Phase 5 — Audit completion (fusion-reasoning, verification mode)

This is the step that catches what a normal run misses. Independently verify that **every item the plan tasked was actually completed** — not "the implementer said so," but confirmed against the real code and the plan's acceptance criteria. Run **`fusion-reasoning`** in a verification framing: fan out **light-tier** agents, each taking a slice of the task list, each answering one question per task — *is this acceptance criterion actually met in the code, yes or no, with the evidence (file:line)?* Synthesize their findings into a completion matrix: done / partial / missed, with evidence.

Use light models here deliberately — it's mechanical confirmation work, and parallel cheap checkers catch the overlooked items that a single pass glosses over. Anything **partial or missed** becomes a blocker fed into the fix loop (Phase 7).

## Phase 6 — Adversarial review (adversarial-review)

With completion confirmed, run **`adversarial-review`** for a hostile correctness/security/edge-case pass over the whole change. Classify findings into real blockers vs. nitpicks. Real blockers feed the fix loop; nitpicks are noted for the user but don't gate.

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
- **The completion audit is not optional.** It exists precisely because tasked items get silently dropped during execution. Always confirm against real code, never against a subagent's say-so.
- **Root-cause, don't symptom-patch, in the fix loop.** A failed verification means something upstream was wrong — find where, fix there, re-verify.
- **You hold the through-line.** Subagents and sub-skills see only their slice; you carry the problem statement, the chosen approach, and the definition of done across every phase.
