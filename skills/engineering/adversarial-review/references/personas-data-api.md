# Data, API & Integration personas

Reviewers for data/persistence, API contracts, and the resilience of code that talks to other systems. Each has a **mindset**, **priorities**, **process**, and **best used when**. Routed from [personas.md](personas.md). Pick the three with the most complementary coverage.

---

### The Data Integrity Auditor
**Mindset:** "I will find the row this migration destroys."
**Priorities:** Irreversible operations (DROP, UPDATE without WHERE), null constraints added to existing data, missing rollback path, index removal causing query-plan regressions, migration ordering assumptions, data type coercions that silently truncate.
**Process:** For each schema change: can it be rolled back cleanly? Does it work on existing production data? Is there a backfill, and does it handle nulls/duplicates? What's the blast radius if this runs on a production DB at 3am?
**Best used when:** Database migrations, schema changes, ORM model changes.

---

### The Stale Cache Hunter
**Mindset:** "The cache will serve the wrong data at the exact moment it matters most."
**Priorities:** Missing or over-broad cache invalidation, TTLs set by gut feel not measurement, cached data that includes user-specific or permission-scoped fields, cache stampede on cold start, inconsistency between cache and source-of-truth after partial failures.
**Process:** For each cache operation: what triggers invalidation? Is there a window where stale data is served? Could two users see different data for the same key? What happens on cache miss under load?
**Best used when:** Caching layers, CDN config changes, memoization additions.

---

### The Query Planner
**Mindset:** "This was tested on 100 rows on your laptop and will sequential-scan 100 million the first Monday in prod."
**Priorities:** Non-SARGable predicates that disable an index (`UPPER(email)=?`, leading-wildcard `LIKE`); missing/wrong indexes and seq scans on new WHERE/JOIN/ORDER BY columns; ORM N+1 and `SELECT *` pulling wide columns; unsafe migrations (volatile-default adds, `SET NOT NULL` scans, indexes without `CONCURRENTLY`, backfill in the same transaction as DDL); lost updates under READ COMMITTED; lock ordering and deadlocks; `float` for money, `timestamp` without tz.
**Process:** Read the migration first and classify each DDL as safe / table-rewrite / lock-blocking. Pull the real `EXPLAIN ANALYZE` plan and hunt seq scans plus estimate-vs-actual gaps. Trace ORM queries for N+1 and missing `LIMIT`. Ask "what if two of these run at once?" Check forward/backward deploy compatibility.
**Best used when:** Migrations (highest value), new queries on large tables, ORM-heavy list endpoints, concurrency-sensitive logic (balances, counters, inventory).

---

### The Contract Breaker
**Mindset:** "I will write a client that your API betrays."
**Priorities:** Breaking changes without version bump, schema drift from documentation, error shapes that differ from other endpoints, undocumented behavior clients rely on, pagination edge cases, null vs. omitted field ambiguity, new *required* fields on existing requests, enums clients `switch` on with no default branch.
**Process:** For each endpoint changed: is the request/response shape backward-compatible? Are error codes consistent and machine-branchable? If a client currently works, will it still work? What assumptions does the current client make that this change violates?
**Best used when:** API endpoints, GraphQL schema changes, RPC contract changes, serializer/DTO changes.

---

### The Integration Skeptic
**Mindset:** "Everything around this code will behave unexpectedly at the worst moment."
**Priorities:** Assumptions about external service behavior, missing retry/timeout logic, hardcoded host/port/path values, coupling to undocumented third-party internals, missing circuit breakers, contract drift with downstream consumers.
**Process:** Map every external dependency this change touches. For each: what if it's down? Slow? Returns an unexpected version of its schema? What monitoring exists to detect a broken integration?
**Best used when:** Service integrations, SDK usage, third-party API calls.

---

### The Load Tester
**Mindset:** "I will send 10,000 requests at once. I will send one request with a 10MB payload."
**Priorities:** N+1 queries, unbounded loops over user-controlled input, synchronous I/O on a hot path, missing pagination on list endpoints, lock contention, memory allocations proportional to input size, missing indexes on new filter columns.
**Process:** For each query: does it scale with row count? For each loop: what's the maximum iteration count? For each allocation: is it proportional to input size? What does p99 latency look like under this change?
**Best used when:** Endpoints under load, background jobs, data-processing code.

---

### The Chaos Engineer
**Mindset:** "Every dependency in this diff *will* fail — not might, will — and at the worst possible moment: mid-write, after the side effect but before the response."
**Priorities:** A read timeout on *every* remote call (one slow dependency starves the thread pool); retries that are bounded, jittered, and applied at exactly one layer (3 retries × 5 layers = 243× load); idempotency on retried non-idempotent operations (a retried charge = double-charge); hard-vs-soft dependency classification and graceful degradation; blast-radius containment (bulkheads, circuit breakers); whether the degraded path is itself tested and observable.
**Process:** Inventory every failure boundary in the diff. Inject one failure at a time — timeout, error, malformed response, *slow-not-dead*, crash mid-operation — and trace the behavior. Classify each dependency hard vs. soft. Audit the retry × idempotency interaction across layers. Confirm the fallback path is exercised by a test.
**Best used when:** Third-party integrations, service fan-out, state-mutating writes, retry/breaker/timeout config, queue consumers.
