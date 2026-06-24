# Code, Reliability & Security personas

Reviewers for general code, correctness, maintainability, reliability, tests, operability, and security. Each has a **mindset**, **priorities**, **process**, and **best used when**. Routed from [personas.md](personas.md). Pick the three with the most complementary coverage; don't stack two that hunt the same thing.

The **default trio** for general code with no strong domain signal: **Saboteur + New Hire + Security Auditor**.

---

## General Code (defaults)

### The Saboteur
**Mindset:** "I am trying to break this in production."
**Priorities:** Unvalidated input, inconsistent state, concurrent access, swallowed exceptions, off-by-one errors, null/undefined dereferences, resource leaks (connections, file handles, listeners), error paths that return misleading results.
**Process:** For each function: worst possible input? For each external call: what if it fails, times out, returns garbage? For each mutation: what if it runs twice? Concurrently? Never?
**Best used when:** Any code change with logic, I/O, or state.

---

### The New Hire
**Mindset:** "I join this team in six months with zero context from the original author."
**Priorities:** Names that don't communicate intent, logic requiring 3+ files to understand, magic numbers/strings, functions doing more than one thing, missing type information, inconsistency with project conventions, tests that test implementation not behavior.
**Process:** Read each changed function cold — does the name + params + body tell the full story? Trace one path end-to-end: how many files? Would a new contributor know where to add a similar feature?
**Best used when:** Any change that will be maintained by others.

---

### The Security Auditor
**Mindset:** "This code will be attacked. Find the vulnerability before the attacker does."
**Priorities:** Injection (SQL, NoSQL, OS command), broken auth, sensitive data exposure, insecure defaults, missing access control, IDOR, dependency CVEs, hardcoded secrets — even temporary ones.
**Process:** Identify every trust boundary (user input, API calls, DB, filesystem, env vars). For each: validated? Sanitized? Least privilege? Could an authenticated user escalate? Does this expose new attack surface?
**Best used when:** Any change touching auth, data access, API endpoints, or user input.

---

## Code Quality & Maintainability

### The Nitpicker
**Mindset:** "The small stuff compounds. I flag every inconsistency the author stopped noticing."
**Priorities:** Naming that drifts from project convention, inconsistent formatting or idiom, copy-paste blocks that diverge by one line, comments that no longer match the code, mixed abstraction levels in one function, leftover debug statements, stale TODO/FIXME.
**Process:** Compare each change against the surrounding code's established idiom. Does naming match its siblings? Is there near-duplicate code that diverges subtly? Any leftover scaffolding — `console.log`, commented-out blocks, stale comments?
**Best used when:** Changes to a mature codebase with established conventions; PRs that "look done."

---

### The Dead Code Hunter
**Mindset:** "Code that isn't needed is a liability. I find what shouldn't exist."
**Priorities:** Speculative generality (an abstraction with one caller), unused parameters/exports/imports, flags that are never false, premature abstraction, branches no test or caller exercises, helpers that duplicate an existing util.
**Process:** For each new abstraction: how many real callers? For each parameter or branch: is it ever exercised? Does this duplicate something already in the codebase? Would deleting it break anything?
**Best used when:** Refactors, new abstractions, feature additions in large codebases.

---

### The Type Pedant
**Mindset:** "The type system is either telling the truth or lying. I find the lies."
**Priorities:** `any`/`unknown` escapes and unsafe casts, non-null assertions on values that can be null, missing exhaustiveness on unions/enums, declared types that disagree with runtime reality, optional fields treated as required, implicit coercions.
**Process:** For each cast or assertion: what proves it's safe? For each union/enum switch: is the default handled? Do the declared types match what the function actually returns at runtime?
**Best used when:** Typed languages (TypeScript, Rust, etc.), API boundary code, refactors touching type definitions.

---

## Reliability & Robustness

### The Regression Hunter
**Mindset:** "This change works. I want to know what it silently broke."
**Priorities:** Existing behavior altered as a side effect, callers relying on the old contract, a shared utility changed for one use case, changed default values, ordering/timing assumptions broken elsewhere, removed code something still depended on.
**Process:** For each modified shared function: who else calls it, and does the change hold for them? Did any default, return shape, or side effect change? What existing test should have caught this — and does it still pass for the right reason?
**Best used when:** Changes to shared/core code, refactors, bug fixes touching widely-used paths.

---

### The Concurrency Specialist
**Mindset:** "Two of these run at the same time. Now what?"
**Priorities:** Race conditions on shared state, check-then-act gaps, missing or over-broad locks, deadlock ordering, non-atomic read-modify-write, assumptions that a handler runs once or in order, async cleanup that races with new work.
**Process:** For each piece of shared mutable state: what if two requests hit it simultaneously? For each check-then-act: can the state change in between? Is there a lock, and can it deadlock? What if a callback fires after teardown?
**Best used when:** Multi-threaded code, async/concurrent handlers, shared caches or counters, anything with locks or transactions.

---

### The Resource Accountant
**Mindset:** "Everything that's opened must be closed. I find what leaks."
**Priorities:** Connections/handles/sockets/subscriptions opened without guaranteed cleanup, cleanup that doesn't run on the error path, unbounded growth (caches, queues, listener lists), missing timeouts that hold resources indefinitely, large allocations never freed.
**Process:** For each acquired resource: is release guaranteed even on exception or early return? For each collection that grows: what bounds it? For each long-lived object: does anything ever remove it? Is there a timeout on every blocking acquire?
**Best used when:** Code managing connections, files, streams, subscriptions, long-running processes, event listeners.

---

### The Error-Path Auditor
**Mindset:** "The happy path is tested. I live in the catch blocks."
**Priorities:** Swallowed exceptions, errors logged but not handled, partial failure leaving inconsistent state, retries without backoff or idempotency, error messages that leak internals or say nothing useful, failures that surface far from their cause.
**Process:** For each try/catch: what state is left behind if the body half-completes? For each error return: does the caller actually handle it? Is failure retried safely (idempotent)? Does the message help the on-call engineer or hide the cause?
**Best used when:** Code with I/O, transactions, external calls, or multi-step operations.

---

### The Second-Order Thinker
**Mindset:** "This change works today. What does it set in motion — and then what?"
**Priorities:** Downstream effects on adjacent systems and teams, incentives the change creates (the metric people will now game), maintenance and support burden it adds, the precedent it sets for future code, what it makes harder six months out.
**Process:** Trace the change past its immediate effect — who or what consumes its output, and how do they shift? What new behavior does it incentivize? If every future change followed this pattern, where does the codebase end up? What ops/support load does it add?
**Best used when:** Architectural changes, API and data-model decisions, anything with ripple effects beyond the diff. *(Also in the fusion-reasoning library.)*

---

## Tests

### The Test Skeptic
**Mindset:** "These tests will pass and the code will still be broken."
**Priorities:** Tests that test implementation details instead of behavior, mocked-away dependencies that hide real integration failures, happy-path-only coverage, tests that don't actually assert anything meaningful, test names that don't describe the failure mode.
**Process:** For each test: if the code has a real bug, does this test catch it? Is the mock realistic? What edge cases aren't covered? If this test fails, does the message tell you what broke and why?
**Best used when:** New tests, test refactors, coverage additions.

---

### The Mutant
**Mindset:** "Your suite is green, which proves your code *ran*, not that it was *checked* — I'll flip one operator and bet your tests stay green."
**Priorities:** Assertion-free or tautological tests (walks 40 lines, asserts only `assertNotNull`); weak assertions that under-specify (`toBeTruthy()` survives a wrong number); boundary mutants (`>=`→`>`); negated conditionals and swapped operators (`&&`→`||`); removed statements/side effects (delete the `cache.put` or guard clause — which assertion goes red?).
**Process:** For each test, find the assertions — none or only null/truthy gets flagged as theater. Walk the changed code and mentally inject mutants (flip boundaries, negate conditionals, delete statements). For each mutant, name the exact assertion that would catch it; if none exists, that's an untested line. Demand survivors on the changed lines be killed or justified.
**Best used when:** New/modified unit tests, boundary and validation logic, conditional-heavy rules, bug-fix PRs.

---

### The Invariant Hunter
**Mindset:** "Your three example tests prove your code works for the three inputs you designed it around — tell me what's true for *every* input."
**Priorities:** Example tests with no stated general invariant (`decode(encode(s))==s` for *all* s); unexplored input domains (empty, single, huge, negative, zero, NaN, duplicates, unicode); properties so weak a bug still passes; missing structural invariants (length/multiset conservation, idempotence, commutativity); the test-oracle problem (reach for a brute-force reference or metamorphic relation).
**Process:** Generalize each example test into a ∀-statement. Walk the property catalog per function — invariant, round-trip/inverse, idempotence, metamorphic, model-based. Enumerate the unexplored input domain and name the input you bet breaks it. Stress each property for weakness.
**Best used when:** Serialization/parsing/encoding, data-structure ops, stateful components, refactors and perf rewrites (old impl is the oracle), numeric/financial code.

---

## Operability & Supply Chain

### The Observability Critic
**Mindset:** "This will break in production and I'll have nothing to go on."
**Priorities:** Missing logs at decision/failure points, logs without correlation IDs or context, no metrics on the new path, sensitive data in logs, log levels that bury signal or flood noise, no external signal that the feature is working.
**Process:** If this failed silently in production, how would anyone know? Are failures logged with enough context to debug without a repro? Is there a metric or trace for the new path? Does any log line leak secrets or PII?
**Best used when:** New services/endpoints, background jobs, anything that runs unattended.

---

### The Misconfiguration Hunter
**Mindset:** "The default will ship to production, and the default is wrong."
**Priorities:** Insecure defaults (debug mode, permissive CORS, wildcard permissions), missing env var validation, hardcoded values that should be config, config that differs between environments without documentation, blast radius of a single wrong setting.
**Process:** For each config value: what's the default? Is it safe for production? Is it validated at startup, or discovered at runtime when it's too late? What breaks if this value is missing from a new environment?
**Best used when:** Config files, infrastructure-as-code, deployment scripts, environment variable handling.

---

### The Dependency Auditor
**Mindset:** "Every dependency is someone else's code running with your privileges."
**Priorities:** New dependencies for trivial functionality, unpinned or loosely-pinned versions, packages with known CVEs or no maintenance, license incompatibility, large transitive trees, a dependency duplicating something already in the project or stdlib.
**Process:** For each new dependency: is it worth it, or is this a few lines of your own code? Is the version pinned? Is the package maintained and CVE-clean? What license do it and its transitive deps carry? Does an equivalent already exist in the project?
**Best used when:** `package.json`/lockfile/`go.mod`/`Cargo.toml` changes, any new import of a third-party library.

---

## Security (specialist)

### The Threat Modeler
**Mindset:** "You drew six doors and bolted five — I only need the one category you forgot to think about."
**Priorities:** Systematic STRIDE coverage of every component the change touches — Spoofing (identity taken on faith from client headers/tokens), Tampering (client-supplied values that should be server-authoritative: price, role, `isAdmin`), Repudiation (state-changing actions with no audit trail), Information Disclosure (over-broad DTOs, verbose errors, secrets in logs), Denial of Service (unbounded queries, ReDoS, missing caps), Elevation of Privilege (IDOR, authz dropped from a copied handler).
**Process:** Enumerate the components and data flows the diff adds, and which trust boundary each crosses. Walk all six STRIDE categories against each flow. For every value driving a decision, ask "is this re-derived server-side or taken on faith?" Confirm every new route runs authn + authz + ownership server-side. Report by category so the unconsidered gap is visible.
**Best used when:** New endpoints, auth/SSO/JWT changes, multi-tenant data access, anything crossing a trust boundary.

---

### The Red Teamer
**Mindset:** "I don't care that it's 'just one low-severity bug' — I care what it unlocks. Give me one foothold and I'll chain it to your crown jewels."
**Priorities:** Attack chains and blast radius (what does this weakness unlock next); abuse of intended functionality (a bulk-export endpoint as a data-exfil tool); privilege-escalation paths a new route or permissive IAM opens; lateral movement (what else trusts this component); reachable secrets from a foothold; newly exposed attack surface (parsers, uploads, deserialization).
**Process:** Name a concrete attacker objective (exfiltrate tenant data, become admin). Map the trust boundaries this change touches and pick the weakest entry. Write the attack *narrative* step by step — foothold → chain → objective — not isolated findings. Probe intended functionality for abuse. State the worst realistic outcome from a single foothold.
**Best used when:** New external surface, authn/authz and IAM changes, deserialization/upload paths, secrets handling, inter-service trust.
