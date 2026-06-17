# Self-Review Checklist (Universal)

Read this when doing the Stage 3.2 self-review. The point isn't to mechanically tick every box — it's to prompt yourself with each dimension so issues don't slip through. A thoughtful PR reviewer would scan for all of these; you should too.

For **stack-specific conventions** (logging patterns, state management choices, error handling idioms), see `project-rules.md`.

## How to Apply

1. Run `git diff <base>...HEAD` (or open the changed files)
2. Walk through each dimension below, asking "did I look?"
3. If you find an issue, **fix it** before handoff — don't just list findings
4. Re-run verification (`scripts/verify.sh`) after fixes; cap the loop at 1-2 re-runs and ship when substantive issues are addressed

---

## Correctness & Edge Cases

The single most common source of bugs in agent-written code is silent failure paths. Probe these:

- **Null / undefined / empty strings** — does the code crash or do something useful?
- **Empty arrays, missing data** — graceful fallback or assumption that data exists?
- **First / last item** — off-by-one or boundary issues?
- **Invalid params, missing query strings** — validated at boundaries or assumed present?
- **Permission / auth boundaries** — does the operation respect the right user/tenant scope?
- **Failure paths** — API errors, network failures, missing dependencies handled?
- **Control flow clarity** — no "lucky" fall-through where a branch happens to be correct but is hard to follow?

## Resource Cleanup

Subscriptions, listeners, timers, intervals — anything that allocates needs cleanup:

- Effect/teardown hooks defined where needed?
- Long-lived connections (WebSockets, DB, file handles) closed on all code paths including errors?
- Event listeners removed when no longer needed?
- Timers and intervals cleared on unmount/disposal?

## Type Safety

- Unnecessary escape hatches (`any`, type assertions, `// @ts-ignore`) that could be expressed properly?
- Type guards used where they'd remove casts?
- Discriminated unions where they'd improve safety?
- Immutable properties marked as such where the language supports it?
- Generic constraints used to express invariants?

## Consistency

The most subtle reviewer feedback is "this doesn't match how we do it elsewhere." Check:

- Does this follow the same patterns as adjacent code (URL building, error handling, naming, file structure)?
- Are you using the project's standard libraries/utilities rather than reinventing them?
- Does your structure match the project's conventions for this kind of code? (See `project-rules.md` for project-specific patterns.)

## Prefer Boring Solutions

Did you reach for a clever pattern when a dull one would do?

- A complex chain of operations that could be a simple loop?
- A custom abstraction for something used in one place?
- A pattern added "in case we need it later"?

Cleverness costs review, maintenance, and debug time. If the boring approach matches existing patterns, choose it.

## Chesterton's Fence

If you removed or substantially changed existing code, you must understand *why* it was there. Code that looks dead often handles an edge case, a historical workaround, or an extension point.

- Removed something? Can you explain why it was originally written?
- If not, restore it or add a comment justifying the change
- "It looked unused" is not a sufficient reason

## Accessibility

UI changes need:

- Loading/status UI surfaces state to assistive tech (live regions, status roles)?
- Interactive elements: focus management, keyboard navigation, semantic HTML
- Form inputs properly labeled and associated
- Color contrast adequate
- Screen reader behavior verified where it matters

## Security & Data

- No secrets logged (client or server) — check log calls
- User/tenant context correct for the operation
- Input validated at boundaries (entry points to your code from users, APIs, webhooks)
- Sensitive data redacted in production logs
- Injection vectors closed (no unsafe HTML insertion, no string-built SQL/shell commands)
- File / blob operations check ownership and permissions

## Observability & Logging

- Logs include enough context (entity IDs, user/tenant scope, operation name) to debug production issues
- Log levels appropriate (debug for noise, info for milestones, warn for recoverable issues, error for failures)
- Key events emit metrics/tracing where it matters for production monitoring
- No noisy debug logs left behind in committed code

(See `project-rules.md` for this project's specific logger pattern and conventions.)

## Performance

- N+1 query patterns: any loop that hits the database/API per iteration?
- Unnecessary recomputation or re-rendering on hot paths?
- Heavy work on the main thread / request path that could be deferred?
- Buffering where streaming would be more efficient (large files, big result sets)?
- Caching configuration appropriate (TTLs, invalidation)?

## Documentation

- TODO comments have linked issue/ticket references?
- Public APIs or complex algorithms documented with the *why*, not the *what*?
- No auto-generated markdown summary files (`*_FIX.md`, `*_SUMMARY.md`, etc.) in the diff?

---

## Calibrating the Review

Use this as a **prompt list, not a yes/no checklist**. For each dimension, ask "did I look?" before calling the review done. Dimensions that don't apply to your change can be skipped quickly; those that do warrant a careful pass.

**When you find issues, fix them and re-run verification.** Typically 1-2 re-runs is enough. Stop when substantive issues are addressed and anything left is minor polish you'd defer to a follow-up.
