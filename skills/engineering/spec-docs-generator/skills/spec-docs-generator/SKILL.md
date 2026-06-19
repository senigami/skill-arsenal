---
name: spec-docs-generator
description: >-
  Generate OR update a numbered spec-document set (docs/00-index.md,
  docs/NN-topic.md, docs/decisions/ ADRs) that becomes the source of truth an
  agent obeys when writing code. Use whenever the user wants to "create specs",
  "document the architecture", "set up a docs/ folder", "make a source of
  truth", "spec out this app", or "reverse-engineer documentation". Also use on
  projects that ALREADY have spec docs — "update the specs", "audit the docs",
  "reconcile specs with the code", "are the specs still current?", or fix spec
  drift: it detects the existing set, diffs each spec against the code, updates
  what's drifted, adds what's missing, retires what's gone, supersedes (never
  rewrites) ADRs, and leaves a changelog. Works for existing codebases,
  greenfield apps (interviews the user), or a mix. Best paired with
  `code-quality-checklist`, which uses the generated docs/00-index.md as the
  authoritative source of conventions for future implementation work.
---

# Spec Docs Generator

Generate a set of numbered specification documents for an application, modeled on a proven layout: numbered specs under `docs/`, a `00-index.md` map, and Architecture Decision Records under `docs/decisions/`. The output is the application's **source of truth** — written so that a coding agent can find the right spec from the index, read it, and follow it, and so a human can navigate it just as easily.

## Why this shape

- **Numbered specs** (`docs/05-system-architecture.md`) give stable, citable names. Code reviews, tickets, and agent instructions can say "per docs/09" and the reference never rots.
- **The index** (`docs/00-index.md`) is the router. An agent with limited context reads ~100 lines and knows exactly which one or two files to open for the task at hand. Without it, agents grep blindly or read everything.
- **ADRs** capture *why* decisions were made, separately from *what* the system does. Specs stay clean statements of current behavior; the history and rejected alternatives live in `docs/decisions/`. When an agent is tempted to "improve" something, the ADR explains why it's shaped that way.
- **Specs and code are jointly authoritative.** Specs carry intent and constraints; code proves what ships. Drift gets resolved explicitly — never silently.
- **This skill writes docs, never code.** Its only outputs are specs, ADRs, and a compliance plan. When the code is internally inconsistent it picks a canonical rule by *convergence* (the most common implementation wins) and records every out-of-line occurrence on a to-do plan for a **separate** fix pass — it does not edit application code to make it conform. Bringing code into compliance is a follow-up task, gated by the plan this run leaves behind.

## Workflow

### Step 1 — Determine the mode

Check **two** things independently: does code exist, and do spec docs already exist? They combine into the working mode.

First, **do spec docs already exist?** Look for a `docs/` (or `documentation/`, `spec/`, etc.) directory with numbered specs, a `00-index.md`, an ADR/`decisions/` folder, or anything serving as a source-of-truth doc set. If so, this is an **update/reconcile run, not a from-scratch generation** — your job is to bring the existing set current and fill its gaps, *not* to regenerate it and overwrite the authors' work. Jump to [Step 1b](#step-1b--updatereconcile-mode-existing-specs) and run the rest of the workflow in its "update" framing.

If there are no specs yet, it's a **generation run** — pick the source of evidence by what's in the directory:

- **Code exists** → reverse-engineering mode. The code is the primary evidence; the user fills gaps about intent.
- **No code (or skeleton only)** → greenfield mode. Interview the user; their answers are the evidence.
- **Partial** → mix: document what the code proves, interview for what's planned.

In greenfield or partial mode, ask the user about: what the app does and for whom, the intended stack, the major components/boundaries, what's explicitly out of scope for v1, and any decisions they've already made (these become ADRs). Batch questions; don't drip them one at a time.

### Step 1b — Update/reconcile mode (existing specs)

When a spec set already exists, the goal is **continuity**: keep what's right, fix what's drifted, add what's missing, retire what's gone — and never silently throw away intent the authors captured. Respect the existing numbering, structure, and voice; you're editing a living document set, not replacing it.

1. **Inventory what's there.** List every existing spec and ADR with its topic and last-meaningful-state. This is the baseline you reconcile against. (Delegate the reading to light agents per the token-efficiency note in Step 2.)
2. **Survey the current code** (Step 2) so you have ground truth to measure the specs against.
3. **Diff specs against reality — this is the core of the mode.** For each spec, classify every normative claim:
   - **Current** — still true of the code. Leave it (don't churn prose for its own sake).
   - **Drifted** — the code has moved on (the spec says error shape A, the code now returns B; an endpoint was renamed; a convention changed). Update the spec to match reality, or — if the code looks like the mistake — flag it as a code-vs-spec discrepancy for the user rather than rewriting silently.
   - **Missing** — real surface the code has but no spec covers (a new subsystem, a new integration). Add a spec, or a section, for it.
   - **Orphaned** — the spec describes something the code no longer has. Don't delete blindly: confirm it's genuinely gone (not just moved), then mark it removed/retired with a note, so the history is visible.
4. **Treat ADRs as append-only history.** Never rewrite or delete an existing ADR to reflect a new decision — that erases the record. If a decision changed, write a **new** ADR that supersedes the old one (and mark the old one `Superseded by ADR-NNNN`). New significant, contestable decisions found in the code since the last update each get their own ADR.
5. **Run conflict resolution (Step 3) on anything ambiguous** — including disagreements between an existing spec and the current code where it's unclear which is canon. Don't guess; ask, with evidence for both sides.
6. **Reconcile the index and cross-links (Steps 7–8)** so new/renamed/retired specs are reflected in `00-index.md`, the Key Decisions table, and every cross-reference still resolves.
7. **Leave a changelog.** End with a short summary (in your reply, and optionally a dated note in the index or a `CHANGELOG`): which specs were updated and why, what was added, what was retired, which ADRs were superseded, and any discrepancies you surfaced for the user. This is what makes the run *auditable* and lets the user trust nothing was lost.

The mental model: a generation run writes the specs; an update run **audits and reconciles** them. The steps below (survey, conflicts, writing, ADRs, index, self-review) all still apply — read each in its "update what exists" sense rather than "create from nothing." Where this file says "write the spec," in update mode it means "update the spec in place, preserving what's still accurate."

### Step 2 — Survey the codebase (reverse-engineering mode)

Read enough to understand the system before writing anything. **Token efficiency matters here:** fan this work out to the smallest capable agents rather than reading everything yourself. Use parallel subagents — one per area — dispatched in one batch; otherwise survey inline. Match the model to the job: file listing, lockfile reading, and grep work → **Haiku** (mechanical, no judgment needed); interpreting auth flows, inferring component boundaries, analyzing test quality → **Sonnet** (bounded judgment). Keep your own (orchestrator) context free for conflict resolution and writing. Cover:

- **Layout & stack**: package manifests, lockfiles, build config, monorepo structure
- **Entry points & runtime**: servers, CLIs, workers, jobs; how the app starts and deploys
- **Data**: schema files, migrations, ORM models, external stores
- **API surface**: routes, contracts, RPC/GraphQL schemas, public interfaces
- **Auth & security**: authentication, authorization, secrets handling, input validation
- **Configuration**: env vars, feature flags, per-environment differences
- **Testing & CI**: test layout, frameworks, pipelines
- **Existing docs**: README, wikis, comments — mine them, but treat code as stronger evidence

**Collect conflicts as you go — with a tally.** When the codebase contains clashing rules — two error-response shapes, mixed naming conventions (snake_case and camelCase in the same API), two state-management approaches, duplicated logic that disagrees, config defaults that contradict the README — do **not** silently pick a winner. Record each conflict with `file:line` evidence for **every** variant, and **count how many occurrences follow each one**. That ratio is what lets Step 3 pick a canon by convergence and put the rest on the compliance plan. You don't need to find every instance, but the counts must be honest and representative — note when a count is a sample (`~30 sites, all snake_case`) versus exhaustive.

### Step 3 — Resolve conflicts: converge on a canon

A spec that documents both patterns endorses both; a spec that picks one gives agents a rule to enforce. So every conflict from Step 2 must resolve to exactly **one** canonical rule — and the default resolution method is **convergence**.

**Pick the canon by convergence.** For each conflict, read the tally. If one variant clearly dominates — most occurrences, most modules, or it's the newer actively-maintained form — treat **the most popular implementation as canon**. Record it as the rule in the spec, with a one-line *why* that states the convergence ("error shape A is canon — used by 11 of 14 endpoints; the 3 on shape B predate the rewrite"). The minority occurrences don't move the canon; they become **drift**, and every one of them goes on the compliance plan (Step 6b) as code to bring into line. This is how the specs become a *source of truth* rather than a mirror of the mess — without editing any code to get there.

**Escalate to the user only when convergence doesn't settle it** — batched into one round, each shown with your tally and a recommendation:
- **No clear majority** — the split is roughly even, or there are two well-entrenched camps of comparable size.
- **The majority looks like the mistake** — the dominant pattern is legacy code the newer code is deliberately moving away from, so raw count points the wrong way.
- **High-stakes surface** — auth, money, data shape, security, or a public contract, where guessing is dangerous regardless of counts.

Don't ask about conflicts a clear majority already answers; record the canon and list the deviations. Reserve the user's attention for the genuinely undecidable ones.

**Non-interactive run:** convergence decides everything. Record each assumed canon in a clearly-marked **"Assumed conventions — confirm these"** section of the index, and every deviation on the compliance plan, so both are reviewable later.

### Step 4 — Propose the spec inventory

Adapt the document set to the application — don't stamp out a fixed list with empty stubs. Propose the inventory to the user (a one-line-per-doc table) before writing, unless running non-interactively.

**In update mode**, the "inventory" is a diff, not a fresh list: show the existing specs alongside their reconcile verdict (current / drifted→update / missing→add / orphaned→retire) so the user sees what will change and what won't be touched. Keep existing numbers stable; new specs take the next free numbers rather than renumbering the set.

Core set that nearly every app needs:

| # | Spec | Covers |
|---|------|--------|
| 00 | index | Doc map, product summary, key-decisions table |
| 01 | scope | What the product is, v1 boundary, explicit out-of-scope |
| 02 | system-architecture | Components, how they connect, deployment shape, stack |
| 03 | data-model | Schema, entities, relationships, migration strategy |
| 04 | api-conventions | Error shape, naming, pagination, identifiers, timestamps, validation |
| 05 | code-organization | Repo layout, module boundaries, where new code goes, naming, file-size norms |
| 06 | test-strategy | Test pyramid, frameworks, what gets mocked vs real, placement |

Add domain specs only when the app has the surface: security/auth, observability, background jobs, UI design system, third-party integrations, deployment/infrastructure, environment config, CLI interface, AI/LLM usage, etc. A focused 150-line spec on a real area beats a 40-line stub on a hypothetical one.

Sizing guidance: most specs land between 100–400 lines. Reference-heavy specs (full schema, full API catalog) can run long; orientation specs (personas, scope) stay short. Never pad.

### Step 5 — Write the specs

Read [references/spec-template.md](references/spec-template.md) for the exact document anatomy, formatting conventions, and a worked example. Key rules:

- H1 title, then a `> **TL;DR:**` blockquote — the punchline before any prose.
- Standard H2 flow: Overview → Scope/Boundary → topic sections → cross-references.
- Tables for reference data (endpoints, error codes, env vars, stack choices); prose for reasoning.
- Cross-reference with relative links: `[docs/03-data-model.md](03-data-model.md)`, `[ADR-0002](decisions/0002-slug.md)`.
- Mark deferred work inline as `**post-v1**` rather than omitting it — agents need to know a gap is intentional.
- **Write rules in the imperative, with the why.** "API fields are `snake_case` because the public contract predates the TypeScript rewrite" is enforceable; "fields are usually snake_case" is not.
- In reverse-engineering mode, every normative claim should be true of the code or flagged as aspiration. Don't invent behavior the code doesn't have.

Write specs in dependency order (architecture before API conventions, etc.) and write `00-index.md` **last**, when the inventory is final.

### Step 6 — Seed ADRs

Read [references/adr-template.md](references/adr-template.md) for the template and conventions. Create `docs/decisions/README.md` (template + when-to-write guidance, included in that reference) plus an ADR for each *significant, contestable* decision discovered — the choices a future agent or engineer might be tempted to reverse: database choice, framework, auth approach, monorepo vs polyrepo, the winner of each conflict resolved in Step 3.

Don't ADR the obvious ("we use git"). 3–8 seeded ADRs is typical. Date them today and note in Context when the decision predates the ADR ("retro-documented; decision originally made earlier").

### Step 6b — Write the spec-compliance plan (when code is out of line)

Whenever Step 3 picked a canon that some code doesn't follow — or update mode found code that contradicts a spec — collect **every** out-of-line occurrence into a single to-do plan at `docs/spec-compliance-plan.md`. This is the bridge between "the specs now say X" and "the code actually does X everywhere," and it's what keeps the run honest about what isn't aligned yet **without touching code to fix it**. The plan is the deliverable; the fixing is a later, separate task.

Structure it as a checklist grouped by the canonical rule each item serves. For every item:

- **Rule it violates** — link the spec (`per docs/04-api-conventions.md`).
- **Where** — `file:line` for each occurrence, or a representative list plus a count when there are many.
- **Now vs. canon** — what the code does today and what the rule requires.
- **Blast radius** — rough effort and what depends on it, so a human can sequence the fixes safely.

Order it by risk or by how much hangs on each fix. Headline the file and name it so no agent mistakes it for a spec of current behavior — it is an **action backlog**, not canon. Use `- [ ]` checkboxes so progress is trackable. If everything converges and nothing deviates, don't create the file — just note "code is internally consistent; no compliance plan needed" in your summary.

This step never edits application code. It only writes the plan that a future fix pass (or `code-quality-checklist` / a planning skill) will execute.

### Step 7 — Write the index and wire it up

`00-index.md` contains, in order:

1. One paragraph: what this directory is and the authority rule ("specs and code are jointly authoritative; resolve drift explicitly, in the same change").
2. **Document Index** — table of every spec: filename, one-line contents. This is the router; write each line so an agent can pick the right doc from it alone.
3. **Product Summary** — 3–6 sentences: what the app is, who uses it, deployment shape.
4. **Key Decisions** — table of cross-cutting choices (Decision / Choice / Rationale), linking to ADRs where one exists.
5. **Assumed conventions — confirm these** (only if Step 3 ran non-interactively).
6. **Open compliance items** — a link to `spec-compliance-plan.md` when one was written, with a one-line note that it's the backlog of code that doesn't yet match canon (and that this skill left the code untouched).

Finally, make the specs discoverable by agents: add (or append to) the repo's agent-instructions file — `CLAUDE.md`, `AGENTS.md`, or equivalent — a short block: read `docs/00-index.md` first, specs are the source of truth, follow the conventions specs, and update specs in the same PR as behavior changes. If no such file exists, create `AGENTS.md` with just that block. Don't overwrite existing content — append.

### Step 8 — Self-review

Before handing off, re-read the set as if you were a cold agent assigned a task ("add an endpoint", "add a table"): can you get from the index to the rule you'd need in two hops? Check that cross-reference links resolve, numbering has no gaps or duplicates, every conflict from Step 3 has exactly one canonical answer, and no spec contradicts another. Confirm every deviation from a chosen canon is captured on the compliance plan — nothing silently dropped — and that no application code was modified anywhere in this run (docs, ADRs, and the plan are the only changes). Fix what you find, then summarize for the user: docs created, how each conflict converged (canon chosen + why), what was logged to the compliance plan, and what they should verify.

---

## What to run next

**If a compliance plan was generated (`docs/spec-compliance-plan.md`):**
The plan is a prioritized backlog of code that doesn't match the spec canon. To turn it into executable fix tasks, run `/task-plan-architect` pointed at the compliance plan. It will decompose each checklist item into a self-contained, map-linked task with acceptance criteria. Then run `/planrunner` to execute. Don't try to fix compliance violations by hand — the plan exists so an agent can do it systematically.

**To enforce the specs on every future implementation task:**
`/code-quality-checklist` reads `docs/00-index.md` and the spec files automatically when they exist. Once the specs are generated, the checklist enforces them without any additional configuration. If the team isn't using it yet, now is a good time to install it.

**To pressure-test the specs themselves:**
The spec docs are authoritative but not infallible — they represent the convergence of existing code, which may have inherited bad patterns. Running `/adversarial-review` on the spec files (especially any API contracts, data models, or auth conventions) will surface gaps, contradictions, and rules that sound right but will cause problems at the edges.
