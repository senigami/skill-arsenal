---
name: code-quality-checklist
description: |
  Use this skill to ensure code adheres to the team's development protocols. Trigger at three moments: (1) BEFORE starting a non-trivial task — to surface assumptions and align on approach; (2) DURING work — when modifying schemas, generated configs, or UI; (3) BEFORE marking a task complete — to run verification and self-review. The skill bundles project-specific rules in `references/project-rules.md` and a `scripts/verify.sh` runner so it adapts to any codebase. Use proactively whenever you're about to declare work done, hand off, or start a feature/fix — even if the user doesn't explicitly ask for a "review" or "checklist." Best paired with `spec-docs-generator`: when specs exist at `docs/00-index.md`, read the relevant spec files as the authoritative source of conventions and contracts — not just that tests pass, but that the implementation matches what the project's source of truth documents.
compatibility: "Requires bash, git, and whatever tools scripts/verify.sh invokes (test runner, linter, type checker)"
---

# Code Quality Checklist

A guardrail against the most common ways agents violate team conventions: silent scope creep, weakened tests, missed verification gates, ignored project-specific workflows.

## How to Use This Skill

**First step, every session you invoke this skill:** read `references/project-rules.md`. It defines the verification commands, triggered workflows, anti-patterns, and stack conventions specific to *this* codebase. Without it, you're applying generic advice that may not match the team's actual standards.

**Then:**
1. **Identify which stage you're in** using the decision tree below
2. **Apply the stage's guidance** — don't read every reference upfront
3. **Read the matching reference file** only when you hit a trigger that needs deeper guidance
4. **Run `scripts/verify.sh`** before marking a task complete

You don't need to recite checklists to the user. Internalize the rules and act on what applies. If you find an issue, **fix it** before handoff — don't list findings.

### Token Efficiency

This skill is designed to be lean:
- **Silent by default:** Don't explain the checklist to the user unless they ask. Just do the work and act on what you find.
- **Minimal chatter:** If verify.sh passes and self-review finds no issues, say nothing — the task is done.
- **Only speak when:** (a) you find an issue and fix it, or (b) you surface an assumption/recommendation in Stage 1, or (c) you encounter something blocking.
- **No running commentary:** Don't narrate "now I'm checking X... now I'm checking Y..." Just check and act.
- **Reference files are on-demand:** Load them only when needed, not upfront.

## Decision Tree

| If you are... | Apply | Read if relevant |
|---|---|---|
| **Starting a non-trivial task** | Stage 1 below | `references/project-rules.md` (stack conventions) |
| **Modifying code that triggers a workflow** (schemas, generated configs, UI, APIs) | Stage 2 below | `references/project-rules.md` (triggered workflows) |
| **About to mark a task complete** | Stage 3 below | `references/self-review-checklist.md`, `references/test-quality-bar.md` |
| **Asked to skip checks** (e.g., hotfix) | Honor the request, but state what you're skipping | — |

---

## Stage 1: Pre-Implementation (5 Questions Before Writing Code)

Misaligned assumptions are the most expensive bug. Before writing a non-trivial change, ask:

1. **Is the request ambiguous or relying on unstated context?** → Ask one clarifying question. Don't guess.
2. **Does it conflict with existing behavior?** → Flag the conflict before implementing.
3. **Is there a boring, obvious solution that matches existing patterns?** → Prefer it. Cleverness is expensive to review, maintain, and debug.
4. **Are there trade-offs** (performance, accessibility, maintainability)? → Mention them with alternatives.
5. **Would a different approach be better than what was asked?** → Recommend it: *"We could do X as asked, but Y is simpler and matches our existing pattern — I recommend Y."*

**Take ownership.** Don't just agree with the user. Treat the codebase as if you own the outcome. Push back constructively when something feels off, and propose better approaches even when the literal request could be fulfilled as stated.

---

## Stage 2: Triggered Workflows

Some changes require follow-up steps that are easy to forget. The set of triggers is project-specific — see `references/project-rules.md` for this project's full list.

Common categories (each project defines its own):

- **Schema changes** → generate and apply migrations; never hand-edit generated SQL
- **Generated config changes** → regenerate downstream artifacts (registries, types, manifests)
- **UI / frontend changes** → manually verify the feature in a browser; type-check and tests verify code correctness, not feature correctness
- **API / webhook changes** → verify auth boundaries, idempotency for retries, no secrets in logs

If you're not sure whether a trigger applies, check `project-rules.md`. If the project has a trigger that's not documented there, surface it to the user and offer to add it.

---

## Stage 3: Verification & Self-Review (Before Declaring Done)

A task is not done until all three sub-phases pass.

### 3.1 — Run Verification

```bash
./scripts/verify.sh
```

This script runs the project's verification commands (typically: type-check, lint, unit tests) in sequence and stops on first failure. See `references/project-rules.md` for what it actually runs in this project.

**Why a full run?** Faster checks (changed-only test runs, staged-only linting) match what pre-commit/pre-push hooks do — not what CI does. The full suite catches cross-file regressions. Rely on it before handoff.

### 3.2 — Self-Review the Diff

```bash
git diff <base-branch>...HEAD
```

Review your changes adversarially — treat it like a PR you're reviewing for someone else. Focus on the lines you added.

For the full review dimensions (correctness, types, security, performance, observability, accessibility, etc.), see `references/self-review-checklist.md`.

**Top 5 questions that catch the most issues:**
1. **Edge cases:** Null/undefined, empty arrays, error paths — handled?
2. **Chesterton's Fence:** If you removed or changed existing code, do you know *why* it was there?
3. **Type safety:** Any unnecessary escape hatches (`any` casts, type assertions) that could be expressed properly?
4. **Performance footguns:** N+1 queries, unnecessary re-renders, heavy work on hot paths?
5. **Security & auth:** Secrets in logs? User/permission context correct for the operation?

If you find issues, **fix them** — don't just list findings. Then re-run Stage 3.1.

### 3.3 — Test Updates & Coverage

You modified code, so tests must reflect the new behavior. See `references/test-quality-bar.md` for the full quality bar, anti-patterns, and triage guidance.

**Key requirements:**
- Tests updated/added for the behavior you changed
- Coverage thresholds (if any) defined in `references/project-rules.md` are met
- Tests assert **behavior and contracts**, not implementation trivia or mock passthroughs
- If existing tests failed, you triaged them properly — never weakened assertions just to make CI green

---

## The 5 Critical Don'ts

These violate team conventions in ways that cause real damage. Never do these without explicit user approval:

1. **Silent scope creep** — touching files outside the task ("while I'm here..."). If you spot an adjacent issue, *mention it in chat*, don't fix it silently. Example: *"I noticed `service.ts:142` has an N+1 — outside this task's scope but worth a follow-up."*
2. **Weakening tests to pass CI** — broadening matchers, `it.skip` without reason, deleting assertions. Triage failures properly (see `references/test-quality-bar.md`).
3. **Auto-generated markdown summaries** — no `*_FIX.md`, `*_SUMMARY.md`, `*_ANALYSIS.md` files in the diff. Summarize in chat instead. Only create docs when the user explicitly asks.
4. **Skipping the full verification gate** — partial checks (changed files only, staged only) are pre-commit/push hooks, not the verification gate. Use `./scripts/verify.sh`.
5. **Bypassing project-specific workflows** — see `references/project-rules.md` for the project's protected workflows (e.g., never hand-edit generated migrations). Always run the documented follow-up steps.

---

## When You Hit a Conflict

- **User explicitly overrides a check** ("skip tests, hotfix"): honor it, but state what you're skipping so it's on the record.
- **User asks for scope expansion** ("also fix the adjacent file"): proceed — scope discipline is about *unrequested* expansion.
- **Time pressure**: communicate the trade-off explicitly. *"Skipping the coverage bump to ship; will follow up in a separate PR."*

The goal is reviewable, mergeable PRs that match the team's quality bar — not slavish checklist adherence.

---

## Minimal Output Examples

Each pair contrasts a verbose output style (Bad) with the lean style this skill expects (Good). The goal is to communicate *only what the user needs to know* — no narration, no checklist recitation, no asking permission for things you can just do.

**After verify.sh passes and self-review finds nothing:**
- ❌ "I ran verify.sh. Type-check passed. Lint passed. Tests passed. Now reviewing the diff against the self-review checklist. Checking edge cases... checking types..."
- ✅ Silent, or one line: "Verified — ready to commit."

**After fixing an issue found in self-review:**
- ❌ "I found the archive button is missing error handling. Per test-quality-bar.md, error states are important because users need feedback when..."
- ✅ "Added `onError` handler to `archive-button.tsx` — error toast was missing on mutation failure."

**Flagging an adjacent issue (out of scope):**
- ❌ "I noticed an N+1 query in `service.ts:142`. Should I fix it?"
- ✅ "Noticed an N+1 in `service.ts:142` — out of scope here, worth a follow-up."

**Surfacing assumptions in Stage 1:**
- ❌ "Before I implement, let me think through what you mean by 'news-feed.' There are a few interpretations: it could be a built-in channel, or it could be an integrated provider... [paragraph of analysis]"
- ✅ "One question: built-in channel (like Discussion) or integrated provider (like GitHub)? Architecture differs significantly."

**Triage when verify.sh fails:**
- ❌ "The test failed. Let me read the error message carefully. The test expects 'Archive' text but got undefined. This means the button isn't rendering text. Let me think about why..."
- ✅ "Test failure: button text missing. Fixing." → fix it → re-run → done.

---

## Adapting This Skill to a New Project

Two files are project-specific. Everything else is generic.

1. **`scripts/verify.sh`** — edit the commands to match your project's type-check / lint / test invocations
2. **`references/project-rules.md`** — fill in verification commands (mirroring verify.sh), triggered workflows, anti-patterns, and stack-specific conventions

The other reference files (`self-review-checklist.md`, `test-quality-bar.md`) contain universal software engineering principles and don't need editing.
