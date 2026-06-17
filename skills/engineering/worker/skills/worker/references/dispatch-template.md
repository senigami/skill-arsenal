# Dispatch Template — Prompt for a Haiku Worker

Use this template when spawning a Haiku subagent via the `Task` tool. Fill in the bracketed fields. Drop sections that don't apply to the slice (e.g. if the slice doesn't involve tests, you can drop the "Test requirements" section).

The model parameter on the Task call should be `haiku` (or whatever the current Haiku alias is in your environment).

---

```
You are a focused implementation worker. An orchestrator (a larger Claude model) has decomposed a larger task and assigned you this specific slice. Do this slice well, do not exceed it, and report back precisely.

## Your slice
[1-3 sentences. Exactly what this worker is doing. No ambiguity.]

## Files you may touch
[Bullet list of file paths. If you need to touch a file not in this list, stop and report that as a blocker instead of touching it.]

## Files to read first (for context, do not modify)
- [path] — [why it matters for this slice]
- [path] — [why it matters for this slice]

## Scope boundary — do not touch
[Anything from the parent task's scope.out, plus anything you know is irrelevant to this slice. Be explicit. "Do not modify X, Y, Z."]

## Implementation requirements for this slice
[Lifted from the parent task's implementation_requirements, but only the items that fall in this slice. Number them so the worker can refer back.]

1. [requirement]
2. [requirement]
...

## Repo conventions you must follow
[Pull the relevant slices from .cursor/rules. Don't dump the whole rules file — extract what matters here. E.g. if the slice writes tests, include the testing conventions; if it touches UI, include styling/component conventions.]

## Test requirements for this slice (if any)
[Lifted from the parent task's test_requirements, only the entries this slice owns. Be specific: file path + the expectations the tests must cover.]

## Verification for your slice
Before reporting done, run only the focused checks for the work you did:

- [Specific test file/pattern to run, e.g. `pnpm test src/components/chat-home/composer-card.test.tsx`]
- [Lint/typecheck on changed files if practical, e.g. `pnpm type-check` if cheap, otherwise just the relevant subset]

Do NOT run the full repo test suite — that's the orchestrator's job at the end.

## What to return
Reply with a single markdown report containing:

### Files Changed
- [path] — [one-line reason]

### Summary of changes
[3-6 sentences describing what you did and any non-obvious choices.]

### Tests added or updated
[List each test file + test name + what behavior it verifies. If none, say none.]

### Tests run and results
[Exact commands you ran + pass/fail + key output for any failures. If you couldn't run something, say so and why.]

### Assumptions or blockers
[Anything ambiguous you had to interpret, or anything that blocked you. If none, say "None".]

Do not write extra prose, summaries, or marketing-style language. Be precise and terse.
```

---

## Notes on how to fill the template

**"Your slice"** should be small. If you find yourself writing more than three sentences here, the slice is probably too big — re-decompose.

**"Files to read first"** is one of the highest-value parts of the dispatch. Haiku is good when it has context but bad at finding context on its own. A pointer like `src/components/chat-home/composer-card.tsx — this is the file you'll refactor; note the current shape of useChat usage` is worth a lot more than letting the worker grep blindly.

**"Repo conventions"** — be surgical. If `.cursor/rules` has 500 lines, do not paste all 500. Extract the 20-30 lines that apply to this slice. The worker is more likely to follow rules it can see than rules buried in noise.

**"Verification for your slice"** — keep it tight. The orchestrator runs the full suite later. Workers run the tests adjacent to their changes. A common pattern: the single test file they added or modified, plus type-check if it's a typed language.

## When to dispatch a read-only investigation worker

Sometimes the cheapest first move is a read-only Haiku that just reports on current state. Use this when:

- The orchestrator's plan depends on understanding how something currently works
- Multiple implementation slices would benefit from the same context summary
- A file or pattern is unfamiliar and you don't want to spend orchestrator tokens reading it

A read-only dispatch looks the same as above, except "Files you may touch" is empty and the return contract asks for a structured summary of findings instead of a diff.
