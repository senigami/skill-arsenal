# Test Quality Bar (Universal)

Read this when adding/updating tests or when triaging test failures during Stage 3.3.

For **project-specific commands** (which test runner, where coverage reports land, coverage thresholds), see `project-rules.md`.

## The Primary Requirement

When you modify code, you must add or update tests for the behavior you changed. This isn't optional — it's how the team protects against regressions.

**Test file location:** Co-located with the module (the universal convention is `foo.ts` → `foo.test.ts` alongside it). If your project uses a different convention, follow that — see `project-rules.md`.

If no test file exists for the code you changed, create one.

## TDD Cycle (for new behavior)

Follow red → green → refactor:

1. **Write the failing test first** — express the desired contract before writing implementation
2. **Run it and watch it fail** — confirm the failure is meaningful (not a setup error)
3. **Write the minimum code to pass** — don't over-engineer
4. **Run it and watch it pass** — confirm the new code fixes the failure
5. **Refactor** — clean up duplication, naming, structure without breaking the green test

## What a Useful Test Asserts

Tests should protect **intent and behavior**, not implementation trivia.

### UI / Components
**Assert:** user interactions (clicks, keyboard, form submit), visible state changes, accessibility roles/labels, loading and error UI.
**Don't just assert:** that static copy exists in the document.

### Server / Domain Logic
**Assert:** validation, error codes, auth/permission boundaries, transforms, parsing, external client args, side effects (DB/cache/queue writes) where meaningful.
**Don't just assert:** that a mock returned its canned value unchanged.

### API Layer (Routers, Controllers)
**Assert:** invalid inputs rejected **before** services are called when validation applies; error propagation from downstream; user/tenant context forwarding where relevant.

## Low-Value Patterns to Avoid

These don't count as meaningful coverage:

- ❌ "Is in the document" checks for static copy
- ❌ Constant smoke tests (`expect(MAX_RETRIES).toBe(3)`)
- ❌ `toBeDefined` / `toBeTruthy` without a concrete expected value
- ❌ Loose `length > 0` checks
- ❌ Tests that only assert a mock returned its input unchanged
- ❌ Long prompt/template strings tested for containing a phrase (unless that phrase is a documented contract)
- ❌ Duplicated smoke tests that mirror mocked return values

If you find these in nearby tests while adding/updating yours, **rewrite or remove them** as part of the same change. Don't add high-quality tests next to obviously weak ones.

## DAMP Over DRY in Tests

Test code should **read like a specification**, even at the cost of duplication. This is the opposite of production code.

- **Repeat setup inline** when it makes test intent obvious
- **Extract helpers only** when the abstraction makes the test *clearer*, not just shorter
- **Name tests as contracts:** `"returns 401 when user is not authenticated"`, not `"works correctly"`
- **Avoid factory abstractions** that hide what values matter

Over-abstracted tests are a known anti-pattern — they make failures hard to diagnose and intent hard to read. When in doubt, duplicate.

## Probe the Edges

Use tests to find ways to break the code:

- Empty inputs (string, array, object)
- Null / undefined / missing fields
- Boundary values (0, 1, max, max+1)
- First / last item in iterations
- Permission / auth boundaries
- API errors, network failures, missing data

This makes the code more robust and documents intended behavior at the edges.

## Coverage Growth (when configured)

If `project-rules.md` defines a coverage growth rule (e.g., "raise modified file's coverage by 5% when below 80%"), apply it. Generally:

- **Primary:** add tests for the behavior you changed in the modified file (this comes first)
- **Secondary:** if a coverage threshold rule applies, raise the modified file's coverage by the required amount using meaningful tests

**Coverage is not a score to game.** Any growth must come from meaningful tests for the file you changed (or closely related edge/error paths in the same file). Don't add unrelated tests just to raise the number.

## When Tests Fail: Triage Before Changing Them

A failing test is **signal**, not noise. Treat it like a real bug report.

### The Triage Process

1. **Read the failure** — message, stack, diff. What behavior is the test protecting?
2. **Classify:**

| Category | Action |
|---|---|
| Production bug or regression | Fix the code (or types/schema) to match the intended contract |
| Intentional behavior change (feature, UX, API) | Update the test to match the new contract; prefer tightening, not vague matchers |
| Obsolete or wrong test | Rewrite or remove with a clear reason — not silent deletion |
| Brittle test (timing, DOM structure, over-mocked) | Stabilize (better selectors, fewer mocks, fake timers) rather than deleting the scenario |

### Never Do This

- ❌ Loosen assertions just to make CI green
- ❌ `expect(true).toBe(true)` placeholder hacks
- ❌ Skip tests without a ticket and context
- ❌ Delete cases only to silence the build without understanding why they failed
- ❌ Mock so heavily that the code under test never actually runs
- ❌ Hit coverage % with meaningless assertions

**If intent is unclear** (bug vs. intentional change): infer from the task, PR description, surrounding code, or **ask** — don't guess by weakening tests.

## Audit Nearby Tests

When you add or modify tests, **also look at the same file and closely related test files** for weak tests you can clean up. Don't leave obviously low-value assertions sitting beside your high-quality additions.

This isn't scope creep — touching the test file is in-scope, and cleaning up the part you're editing is appropriate. (Don't go further into adjacent unrelated files.)
