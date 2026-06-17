# Adversarial Review Checklist

When a Haiku worker reports a slice done, you (the orchestrator) review it adversarially. Assume nothing. Trust the diff, not the worker's summary.

This is not "did the worker say the right things" — it's "is the actual code correct, complete, and good." Read the files. Look at the diff. Run the tests if you're not sure.

---

## 1. Instruction adherence

For each `implementation_requirement` assigned to this slice, ask:

- Was it actually done?
- Where in the diff is it done?
- Is it done correctly, or is it half-done / done in a way that misses the point?

If you can't point to the specific change that satisfies a requirement, the requirement isn't satisfied.

## 2. Scope discipline

- Did the worker only touch files in its assigned "may touch" list?
- Did it leave `scope.out` alone?
- Did it avoid drive-by reformats, drive-by refactors, drive-by "while I was in there" changes?

Drive-by changes are a yellow flag — they expand the diff, risk regressions, and aren't what was asked for. Push back on them unless they're trivially obviously correct and improving.

## 3. Logical correctness

Read the actual code. Look for:

- **Off-by-ones, wrong indices, wrong loop bounds**
- **Inverted conditions** (`if (!foo)` where it should be `if (foo)`)
- **Wrong async/await handling** — missing await, returned promise not awaited, unhandled rejection
- **State mutation where immutability was expected** (especially in React/Redux/etc.)
- **Missing null/undefined guards** on values that can clearly be missing
- **Stale closures** in hooks (missing dependencies in useEffect/useMemo/useCallback)
- **Wrong event handler signatures** (e.g. forgetting to call preventDefault)
- **Silently swallowed errors** — caught and ignored, or caught and logged but not handled
- **Resource leaks** — listeners added without cleanup, subscriptions not unsubscribed, files opened not closed
- **Incorrect types** — `any` slipped in, type assertions hiding a real mismatch

## 4. Test quality

If the slice required tests:

- Are the tests there?
- Do they test the behavior, or do they test the implementation? (Implementation tests break on refactor and don't catch real bugs.)
- Do they cover the happy path?
- Do they cover at least one edge case (empty input, error path, boundary condition, concurrent access if relevant)?
- Are the assertions meaningful, or are they trivially true (`expect(x).toBeDefined()` on a value that's obviously defined)?
- Did the worker actually run them? If they said "tests pass" but didn't show the output, that's a flag — re-run them yourself or send back for output.

A test that doesn't actually test the thing is worse than no test — it gives false confidence and clutters the suite.

## 5. Repo convention alignment

- Does the code match the patterns in surrounding files?
- Naming conventions (camelCase vs snake_case, file naming, component naming)?
- Import ordering and grouping?
- Error handling style consistent with the rest of the codebase?
- For UI work: does it use the repo's design tokens, component library, Tailwind utilities — not raw hex colors or ad-hoc styles?
- Are comments in the same style as the rest of the file (or no comments if the file convention is no comments)?

## 6. Quality constraints

Walk through any `quality_constraints` from the task JSON that apply to this slice:

- "Do not weaken or skip tests" — were any tests deleted or made trivial?
- "Preserve existing user changes" — anything in-progress in the tree that got blown away?
- "Keep diff reviewable" — is the diff small and focused, or sprawling?
- "Do not broaden scope" — anything that crept beyond what was asked?

Constraint violations are not minor — they're explicit rules the task laid down. Bounce them back.

## 7. The smell test

Read the changes as if you were code-reviewing a teammate's PR. Would you approve it as-is? If not, what would you write in the PR comment? That comment becomes the fix-task description.

---

## Decision: pass, fix, or escalate

After review, decide:

- **Pass** — slice is good. Mark the todo complete, move on.
- **Fix** — slice has issues. Dispatch a fix task to a fresh Haiku worker with a precise list of what's wrong. (Cap: 3 fix rounds per slice.)
- **Escalate** — slice is fundamentally broken or the slice plan was wrong. Re-decompose, or do the slice yourself as the orchestrator, or surface as an open issue.

When writing fix tasks, be precise. "Tests are weak" is too vague. "The test in `composer-card.test.tsx` for the failure path only checks that the function was called — it doesn't verify that the input field still has the user's text after the failed send. Add an assertion for that" is what the fix worker needs.
