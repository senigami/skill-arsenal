---
name: planrunner
description: Orchestrator-driven execution of an approved plan. Use right after a plan is approved / when the user says "execute the plan", "run the plan", "build this", "start working", "planrunner", or invokes this skill in plan mode. The main loop stays on the user's chosen model and acts as ORCHESTRATOR + REVIEWER — it does not write the bulk of the code itself. It decomposes the plan into small slices, delegates each to a mid-tier `implementer` subagent (or a light-tier agent for trivial/mechanical slices), verifies every returned slice against intent, then runs up to 3 adversarial review rounds, fixing real blockers via the same slice→subagent→verify procedure. Model-agnostic: it discovers the available models at runtime and assigns work by capability tier rather than by model name. Skip for trivial one-line changes or pure Q&A.
---

# planrunner — orchestrate, delegate, verify, review

When executing an approved plan, **you are the orchestrator and reviewer.** You stay on whatever model the user selected — they typically orchestrate on a top-tier model. You do **not** change the main-loop model — you can't, and you shouldn't want to: the point is that the high-judgment work (decomposing, verifying, adversarial review) runs at top quality while the **bulk token volume** (reading files, writing code) is pushed to cheaper subagents.

**Token efficiency is a primary goal.** The orchestrator's context is the expensive, scarce resource — protect it. Your job is decisions (decomposing, accepting/rejecting slices, adversarial review) not typing out diffs or reading whole files yourself. Push the reading and writing down to the smallest model capable of doing it well, and judge what comes back. Using a large model for grunt work wastes context; using a small model for a judgment call costs rework — match the model to the job.

Keep your own (orchestrator) turns lean: delegate the heavy reading and writing, demand structured or diff-only returns, and only open files yourself when you need to verify a specific claim or design a slice spec.

## Model tiers — discover, don't hardcode

This skill is **model-agnostic**. Don't assume a specific provider or model name. At the start of a run, determine what models are actually available to the `Agent` tool (inspect the `model` parameter's allowed values / the agent definitions) and sort them into three capability tiers:

- **light** — fastest, cheapest models (e.g. Haiku-class, Flash-class, Mini/Nano-class). For mechanical work: reading, running commands, audits.
- **mid** — balanced models (e.g. Sonnet-class). For implementing slices from a precise spec.
- **top** — highest-judgment models (e.g. Opus-class). For adversarial review.

Map by *capability*, not by name — whatever the environment offers. If only one tier is available, use it for everything. If two, collapse light→mid or mid→top sensibly. The principle is constant even when the model lineup changes: **never spend a bigger model than the work needs, and never send a judgment call to a model too small for it.**

## The subagents — match the tier to the job

| Agent | Tier | Role |
|---|---|---|
| `implementer` | **mid** | Code ONE slice from a precise, standalone spec. Drop to **light** for genuinely trivial or mechanical slices. |
| `runner` | **light** | Run tests/lint/typecheck/build, git status/diff/commit, file audits — **report only, never edits.** |
| `reviewer` | **top** | Independent adversarial review passes, fanned out by concern for breadth on large/risky changes. Judgment-heavy. |

Spawn via the `Agent` tool with `subagent_type`. Models are usually pinned in their definitions; pass an explicit model override (the slug for the tier you chose) only when you need to move a task off its default — e.g. dropping a trivial slice to the light tier. Never send a judgment call to a light model; never burn a top-tier model on a file listing.

**The orchestrator verifies; it doesn't trust blindly.** A returned slice or review finding is a claim. For anything that touches security, correctness, or a contract boundary, read the actual diff and confirm it before accepting — that is the quality gate the orchestrator exists to provide.

## The loop

1. **Decompose.** Break the approved plan into small, independently-implementable slices. Each slice = one focused, verifiable unit of work. **If the plan came from `task-plan-architect`** (a plan folder with `01-map.md`, `02-roadmap.md`, and `tasks/NNN-*.md`), don't re-derive the structure — the slices are already written: use the roadmap's workload order and dependency graph, treat each task file as a slice spec, and keep `01-map.md` open as the source of contracts and invariants every slice must honor. Only decompose from scratch when the plan has no such structure.

2. **Delegate each slice → `implementer`** (mid tier; drop to light tier if trivial/mechanical). Give a standalone spec: files, the exact change, utilities to reuse, constraints, and the relevant slice of the plan (for architect plans, include the task file plus the map links it points to). Subagents can't see this conversation — the prompt must stand alone. Run independent slices in parallel (multiple `Agent` calls in one message); keep tightly-coupled edits in one call. **Never parallelize two slices that touch the same file** — concurrent implementers will clobber each other's edits. Serialize them, or merge them into one slice.

3. **Verify each returned slice (you, the orchestrator).** Read the actual diff. Does it match the intent and the plan? Is it in scope, correct, consistent with conventions?
   - **Accept** if it's right.
   - Otherwise **return it** to a fresh `implementer` with specific correction instructions (what's wrong, what to change). Repeat until accepted. You own the gate — a slice isn't done until you've checked it.

4. **When ALL slices are accepted → get to green FIRST (delegate → `runner`).** Run the project's tests/lint/typecheck/build. Route any failure's fix through `implementer` (the `runner` never edits), then re-run until green. Do this *before* adversarial review — it's the cheapest tier catching the cheapest class of bugs, and it means the expensive review in step 5 only ever runs on code that actually compiles and passes. Reviewing red code wastes your most expensive resource on findings tests would have caught for free.

5. **On green → adversarial review.** Scrutinize the whole change for correctness, security, edge cases, race conditions, regressions, and reuse/simplification. For large or risky changes, fan out `reviewer` (top tier) subagents by concern (correctness / security / regressions) in parallel and synthesize their findings; for small changes, review inline. Verify findings against the real code — don't accept hand-waving.

6. **Classify findings: real blockers vs. nitpicks.** Only **real blockers** (correctness, security, broken contracts/regressions, data loss) gate. Note nitpicks but don't loop on them.

7. **Fix blockers via the SAME slice procedure** — decompose the fixes, delegate to `implementer`, verify each returned fix, then **re-run the green gate (step 4)** so a fix can't silently break a test. **Re-review** focuses on the fixed areas and their blast radius, not a full from-scratch pass.

8. **Repeat review→fix up to 3 adversarial rounds total.** Stop as soon as a round finds no real blockers. If blockers remain after 3 rounds, stop looping and report them honestly with what's left — don't spin forever.

9. **Report (you).** Summarize what changed, what each review round caught and fixed, verification results, and any residual risk or unresolved blockers. Commit via `runner` only if the user asked to commit. Relay subagent results faithfully.

## When NOT to delegate

Delegation has real overhead (spawn + context transfer). Handle inline when overhead exceeds savings:
- A single trivial command or a one-/two-line edit you can do correctly in seconds.
- Work that needs this conversation's full context and would be expensive to transfer.

Delegation pays off for the slice work and parallel review — which is most of a real plan.

## Guardrails

- **You never downgrade your own model or call `/model`.** The user controls the main model.
- The orchestrator makes every accept/reject and blocker/nitpick decision — subagents propose, you dispose.
- `runner` never fixes failures; if it reports red, route the fix through `implementer`.
- Keep tiers honest: don't ask `implementer` to make design judgments, and don't burn an `implementer`/`reviewer` on mechanical work a `runner` should do. Assign by the capability tier you discovered, never by a hardcoded model name.
- Every delegated prompt stands alone (paths + plan slice + context to act cold).
