---
name: planrunner
description: Orchestrator-driven execution of an approved plan. Use right after a plan is approved / when the user says "execute the plan", "run the plan", "build this", "start working", "planrunner", or invokes this skill in plan mode. The main loop stays on the user's chosen model (typically Opus) and acts as ORCHESTRATOR + REVIEWER — it does not write the bulk of the code itself. It decomposes the plan into small slices, delegates each to a Sonnet `implementer` subagent (or a light agent such as Haiku, GPT-5.4 Mini/Nano, or Gemini 3.5 Flash for trivial/mechanical slices), verifies every returned slice against intent, then runs up to 3 adversarial review rounds, fixing real blockers via the same slice→subagent→verify procedure. Skip for trivial one-line changes or pure Q&A.
---

# planrunner — orchestrate, delegate, verify, review

When executing an approved plan, **you are the orchestrator and reviewer.** You stay on whatever model the user selected (they typically plan and orchestrate on Opus). You do **not** change the main-loop model — you can't, and you shouldn't want to: the point is that the high-judgment work (decomposing, verifying, adversarial review) runs at top quality while the **bulk token volume** (reading files, writing code) is pushed to cheaper subagents.

**Token efficiency is a primary goal.** The orchestrator's context is the expensive, scarce resource — protect it. Your job is decisions (decomposing, accepting/rejecting slices, adversarial review) not typing out diffs or reading whole files yourself. Push the reading and writing down to the smallest model capable of doing it well, and judge what comes back. Using a large model for grunt work wastes context; using a small model for a judgment call costs rework — match the model to the job.

Keep your own (orchestrator) turns lean: delegate the heavy reading and writing, demand structured or diff-only returns, and only open files yourself when you need to verify a specific claim or design a slice spec.

## How the user runs it

They enter plan mode on their chosen model (e.g. Opus), build the plan, and approve it. On approval you execute per this skill. The main model stays as they set it for the whole run — orchestration and adversarial review want Opus-level judgment.

## The subagents — match the model to the job

| Agent | Model | Role |
|---|---|---|
| `implementer` | **sonnet** | Code ONE slice from a precise, standalone spec. Use a light model only for genuinely trivial or mechanical slices. Good light choices: Haiku when available, **GPT-5.4 Mini**, **GPT-5.4 Nano**, or **Gemini 3.5 Flash**. |
| `runner` | **light agent** | Run tests/lint/typecheck/build, git status/diff/commit, file audits — **report only, never edits.** Mechanical work belongs on Haiku when available, **GPT-5.4 Nano**, **GPT-5.4 Mini**, or **Gemini 3.5 Flash**. |
| `reviewer` | **opus** | Independent adversarial review passes, fanned out by concern for breadth on large/risky changes. Judgment-heavy; needs the top model. |

Spawn via the `Agent` tool with `subagent_type`. Models are usually pinned in their definitions; pass an explicit light-model override only for trivial/mechanical work where the task is fully specified. If the tool requires a slug, use an available light slug such as `gpt-5.4-mini-medium`, `gpt-5.4-nano-medium`, or `gemini-3.5-flash`. Never send a judgment call to a light model; never burn Opus on a file listing.

**The orchestrator verifies; it doesn't trust blindly.** A returned slice or review finding is a claim. For anything that touches security, correctness, or a contract boundary, read the actual diff and confirm it before accepting — that is the quality gate the orchestrator exists to provide.

## The loop

1. **Decompose.** Break the approved plan into small, independently-implementable slices. Each slice = one focused, verifiable unit of work.

2. **Delegate each slice → `implementer`** (Sonnet; light-model override if trivial/mechanical). Give a standalone spec: files, the exact change, utilities to reuse, constraints, and the relevant slice of the plan. Subagents can't see this conversation — the prompt must stand alone. Run independent slices in parallel (multiple `Agent` calls in one message); keep tightly-coupled edits in one call.

3. **Verify each returned slice (you, the orchestrator).** Read the actual diff. Does it match the intent and the plan? Is it in scope, correct, consistent with conventions?
   - **Accept** if it's right.
   - Otherwise **return it** to a fresh `implementer` with specific correction instructions (what's wrong, what to change). Repeat until accepted. You own the gate — a slice isn't done until you've checked it.

4. **When ALL slices are accepted → adversarial review.** Scrutinize the whole change for correctness, security, edge cases, race conditions, regressions, and reuse/simplification. For large or risky changes, fan out `reviewer` (Opus) subagents by concern (correctness / security / regressions) in parallel and synthesize their findings; for small changes, review inline. Verify findings against the real code — don't accept hand-waving.

5. **Classify findings: real blockers vs. nitpicks.** Only **real blockers** (correctness, security, broken contracts/regressions, data loss) gate. Note nitpicks but don't loop on them.

6. **Fix blockers via the SAME slice procedure** — decompose the fixes, delegate to `implementer`, verify each returned fix. Then **re-review.**

7. **Repeat review→fix up to 3 adversarial rounds total.** Stop as soon as a round finds no real blockers. If blockers remain after 3 rounds, stop looping and report them honestly with what's left — don't spin forever.

8. **Verify (delegate → `runner`).** Run the project's tests/lint/typecheck/build and report. Commit via `runner` only if the user asked to commit.

9. **Report (you).** Summarize what changed, what each review round caught and fixed, verification results, and any residual risk or unresolved blockers. Relay subagent results faithfully.

## When NOT to delegate

Delegation has real overhead (spawn + context transfer). Handle inline when overhead exceeds savings:
- A single trivial command or a one-/two-line edit you can do correctly in seconds.
- Work that needs this conversation's full context and would be expensive to transfer.

Delegation pays off for the slice work and parallel review — which is most of a real plan.

## Guardrails

- **You never downgrade your own model or call `/model`.** The user controls the main model.
- The orchestrator makes every accept/reject and blocker/nitpick decision — subagents propose, you dispose.
- `runner` never fixes failures; if it reports red, route the fix through `implementer`.
- Keep tiers honest: don't ask `implementer` to make design judgments, and don't burn an `implementer`/`reviewer` on mechanical work a `runner` should do.
- Every delegated prompt stands alone (paths + plan slice + context to act cold).
