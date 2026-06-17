---
name: spec-docs-generator
description: Generate OR update a numbered spec-document set (docs/00-index.md, docs/NN-topic.md, docs/decisions/ ADRs) that becomes the source of truth an agent obeys when writing code. Use whenever the user wants to "create specs", "document the architecture", "set up a docs/ folder", "make a source of truth", "spec out this app", or "reverse-engineer documentation". Also use on projects that ALREADY have spec docs — "update the specs", "audit the docs", "reconcile specs with the code", "are the specs still current?", or fix spec drift: it detects the existing set, diffs each spec against the code, updates what's drifted, adds what's missing, retires what's gone, supersedes (never rewrites) ADRs, and leaves a changelog. Works for existing codebases, greenfield apps (interviews the user), a mix, or an existing spec set that needs refreshing.
---

# Spec Docs Generator

Generate a set of numbered specification documents for an application, modeled on a proven layout: numbered specs under `docs/`, a `00-index.md` map, and Architecture Decision Records under `docs/decisions/`. The output is the application's **source of truth** — written so that a coding agent can find the right spec from the index, read it, and follow it, and so a human can navigate it just as easily.

## Why this shape

- **Numbered specs** (`docs/05-system-architecture.md`) give stable, citable names. Code reviews, tickets, and agent instructions can say "per docs/09" and the reference never rots.
- **The index** (`docs/00-index.md`) is the router. An agent with limited context reads ~100 lines and knows exactly which one or two files to open for the task at hand. Without it, agents grep blindly or read everything.
- **ADRs** capture *why* decisions were made, separately from *what* the system does. Specs stay clean statements of current behavior; the history and rejected alternatives live in `docs/decisions/`. When an agent is tempted to "improve" something, the ADR explains why it's shaped that way.
- **Specs and code are jointly authoritative.** Specs carry intent and constraints; code proves what ships. Drift gets resolved explicitly — never silently.

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

**Collect conflicts as you go.** When the codebase contains clashing rules — two error-response shapes, mixed naming conventions (snake_case and camelCase in the same API), two state-management approaches, duplicated logic that disagrees, config defaults that contradict the README — do **not** silently pick a winner. Record each conflict with file:line evidence for both sides.

### Step 3 — Resolve conflicts with the user

Present every conflict found in Step 2 **before writing the specs**, batched into one round of questions. For each: show both patterns with evidence, note which appears dominant or newer, and ask which one is canon. The spec then records the chosen rule, and may note the known deviation as migration debt.

This step is the heart of making specs a *source of truth* rather than a mirror of the mess: a spec that documents both patterns endorses both; a spec that picks one gives agents a rule to enforce.

If the user is unavailable (non-interactive run), choose the pattern that is dominant and/or newest, and record the conflict and your choice in a clearly-marked **"Assumed conventions — confirm these"** section of the index so it's reviewable later.

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

### Step 7 — Write the index and wire it up

`00-index.md` contains, in order:

1. One paragraph: what this directory is and the authority rule ("specs and code are jointly authoritative; resolve drift explicitly, in the same change").
2. **Document Index** — table of every spec: filename, one-line contents. This is the router; write each line so an agent can pick the right doc from it alone.
3. **Product Summary** — 3–6 sentences: what the app is, who uses it, deployment shape.
4. **Key Decisions** — table of cross-cutting choices (Decision / Choice / Rationale), linking to ADRs where one exists.
5. **Assumed conventions — confirm these** (only if Step 3 ran non-interactively).

Finally, make the specs discoverable by agents: add (or append to) the repo's agent-instructions file — `CLAUDE.md`, `AGENTS.md`, or equivalent — a short block: read `docs/00-index.md` first, specs are the source of truth, follow the conventions specs, and update specs in the same PR as behavior changes. If no such file exists, create `AGENTS.md` with just that block. Don't overwrite existing content — append.

### Step 8 — Self-review

Before handing off, re-read the set as if you were a cold agent assigned a task ("add an endpoint", "add a table"): can you get from the index to the rule you'd need in two hops? Check that cross-reference links resolve, numbering has no gaps or duplicates, every conflict from Step 3 has exactly one canonical answer, and no spec contradicts another. Fix what you find, then summarize for the user: docs created, conflicts resolved (and how), and what they should verify.
