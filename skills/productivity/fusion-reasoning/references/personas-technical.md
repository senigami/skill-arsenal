# Technical personas (architecture, bugs, security, UX)

Panel personas for technical reasoning — architecture, correctness, security, and UI/UX. Each has a **mindset**, **priorities**, and **best used when**. Routed from [personas.md](personas.md). Pick personas that would genuinely disagree.

---

## Architecture & Technical Design

### The Skeptic
**Mindset:** "Why is this the right shape? Prove it."
**Priorities:** Over-engineering, hidden coupling, abstractions that don't earn their complexity, alternatives that weren't seriously considered, places where simpler is obviously sufficient.
**Best used when:** Architecture proposals, new system designs, API design.

---

### The Operator
**Mindset:** "I run this at 3am when something breaks. Is it survivable?"
**Priorities:** Observability (can I tell what's wrong?), failure recovery (does it degrade gracefully?), operational burden (how much manual intervention?), deployment complexity, rollback difficulty.
**Best used when:** System design, infrastructure decisions, service architecture.

---

### The Evolver
**Mindset:** "How does this age? What does it cost to change in 18 months?"
**Priorities:** Change surface (what breaks when requirements shift?), migration cost, how much the design bakes in current assumptions, whether the abstractions will survive new use cases.
**Best used when:** Core architecture decisions, data model design, public API design.

---

### The Performance Pessimist
**Mindset:** "This works at 100 users. I want to know what happens at 100,000."
**Priorities:** Algorithmic complexity, I/O on the hot path, unbounded data fetching, cache invalidation correctness, lock contention under concurrent load.
**Best used when:** Performance-sensitive design, database-heavy systems, high-throughput services.

---

## Bug Hunting & Correctness

### The Saboteur
**Mindset:** "I will break this in production with the most plausible bad input."
**Priorities:** Unvalidated input reaching dangerous operations, race conditions and concurrent state, error paths that swallow failures, off-by-ones and boundary conditions, resource leaks.
**Best used when:** Code correctness reviews, logic analysis, pre-merge checks.

---

### The Edge-Case Hunter
**Mindset:** "The happy path works. I live in the boundary conditions."
**Priorities:** Empty collections, null/zero/negative values, maximum-scale inputs, first-run vs. subsequent-run behavior, the case where two things happen simultaneously.
**Best used when:** Algorithm analysis, data processing code, anything with branching logic.

---

### The Integration Skeptic
**Mindset:** "Everything this code depends on will behave unexpectedly."
**Priorities:** External call failure modes (timeout, wrong schema, partial failure), implicit assumptions about ordering, contracts with other systems that aren't enforced, what breaks when the dependency changes.
**Best used when:** Code that calls external services, glue code between systems, integration logic.

---

### The Concurrency Specialist
**Mindset:** "Two of these run at the same time. Now what?"
**Priorities:** Race conditions on shared state, check-then-act gaps, lock granularity and deadlock ordering, non-atomic read-modify-write, assumptions that something runs once or in order, async cleanup racing new work.
**Best used when:** Reasoning about concurrent or distributed designs, correctness of parallel logic, anything with shared state, locks, or transactions. *(Also in the adversarial-review library.)*

---

## Security & Trust

### The Attacker
**Mindset:** "How do I exploit this? I have unlimited time and the source code."
**Priorities:** Injection paths, auth gaps, data exposure, trust-boundary violations, privilege escalation, secrets in unexpected places.
**Best used when:** Security-sensitive features, auth systems, data access changes.

---

### The Insider Threat
**Mindset:** "If a malicious employee used this system, what could they do?"
**Priorities:** Privilege escalation, audit log gaps, data exfiltration paths, actions that bypass normal approval flows, admin capabilities with no oversight.
**Best used when:** Admin tooling, internal systems, multi-tenant applications.

---

### The Compliance Auditor
**Mindset:** "What regulation does this touch, and does this change respect it?"
**Priorities:** PII handling and retention, consent and opt-out flows, audit trail completeness, data residency assumptions, logging of sensitive operations.
**Best used when:** User data handling, payment flows, regulated industries.

---

### The Threat Modeler
**Mindset:** "You drew six doors and bolted five — I only need the one category you forgot to think about."
**Priorities:** Systematic STRIDE coverage of each component (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege); which values are trusted on faith vs. re-derived server-side; the trust boundaries the design crosses; the threat category nobody considered.
**Best used when:** Security design reasoning, threat-modeling a new system or feature, auth and multi-tenant architecture. *(Also in the adversarial-review library.)*

---

## UI / UX / Design

### The Confused User
**Mindset:** "I don't know how this works. I will click the wrong thing."
**Priorities:** Missing feedback, unclear affordances, unexpected navigation, broken edge states (empty, error, loading), mobile/touch gaps, cognitive load.
**Best used when:** UI design review, flow analysis, UX decisions.

---

### The HIG Auditor
**Mindset:** "Platform conventions exist for a reason. Deviation has a cost."
**Priorities:** Non-standard control usage, custom implementations of native patterns, interactions that conflict with platform norms, visual hierarchy consistency.
**Best used when:** Native/mobile UI, platform-specific design decisions.

---

### The Accessibility Critic
**Mindset:** "I use a screen reader, keyboard only, or high-contrast mode."
**Priorities:** Focus order, ARIA correctness, color as sole signal, contrast ratios, interactive elements without accessible names, dynamic content announcements.
**Best used when:** Any UI change.
