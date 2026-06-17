# Plan folder format

The output. By default it lives **outside the repo** at `~/.claude/plans/<project>/<task-slug>/` (chosen in Step 0) so it never contaminates the codebase; only write to `docs/plans/<task-slug>/` or similar inside the repo if the user asked. Everything here is plain Markdown.

**One subfolder per plan — always.** The `<project>/<task-slug>/` nesting is what keeps multiple plans from colliding: different repos separate under `<project>`, and each distinct task this skill is invoked for gets its own `<task-slug>` folder beneath it. Never write a plan's files loose into `~/.claude/plans/` or directly into a `<project>/` folder — they'd overwrite or interleave with another plan. Before creating the folder, check if it exists: a different task with a clashing slug gets a more specific slug (or a short discriminator) so nothing is clobbered; the same task re-run is an expand (see below), not an overwrite.

The guiding constraint for every file: **a context-limited stranger executes this.** The reader may be a small model with only one task file and `01-map.md` loaded — nothing else. If a task can't be done correctly from those two, it's underspecified. Over-link to the map and to source paths.

```
<plan-root>/
├── README.md            # what this is, where it lives, status protocol, how to pick up work
├── 00-overview.md       # the task, goal, scope/boundary, success criteria
├── 01-map.md            # the implementation map (see connection-map.md)
├── 02-roadmap.md        # ordered workloads + dependency graph + milestones
└── tasks/
    └── NNN-slug.md      # one self-contained, map-linked task each
```

## README.md

Short. State: this is the live plan for `<task>`; where it lives (and that it's intentionally outside the repo, if so); that `01-map.md` is the shared context every executor loads alongside its task; the status legend (`not-started | in-progress | blocked | done`); and the pickup protocol — read `02-roadmap.md`, take the next unblocked task in the current workload, open that task file **and `01-map.md`**, execute, update the task's status, and update the map if a contract/connection changed.

## 00-overview.md

```markdown
# <Task> — Overview

> **TL;DR:** What this delivers and the one-line approach.

## Goal
What is true when this is done that isn't now.

## Scope & boundary
In scope; explicitly out of scope (the boundary that stops the plan sprawling).

## Constraints
Hard requirements — stack, deadlines, compatibility, things that can't change.

## Success criteria
How we'll know it's done and done well — observable, checkable.
```

## 02-roadmap.md

```markdown
# Roadmap

> **TL;DR:** N workloads, ordered so each builds on finished ground. Start with <workload 1>.

## Sequencing rationale
Why this order — shared contracts and foundations (the things many parts depend on
in the map) before the work that depends on them.

## Dependency graph
Which tasks block which (list or Mermaid). Mirror the map's part-graph so order is consistent.

## Workloads
### Workload 1 — <name>
- **Goal:** what this batch achieves
- **Tasks:** NNN, NNN
- **Touches (map parts):** P1, P2
- **Why now:** what it unblocks
- **Verify the workload:** the single check that proves the batch landed
```

A **workload** is small enough to implement and verify as a unit. Each task belongs to exactly one.

## tasks/NNN-slug.md — the load-bearing file

Number `001`, `002`, … in suggested execution order. Use this template:

```markdown
# NNN — <imperative title>

- **Status:** not-started
- **Workload:** <name>
- **Effort:** S | M | L
- **Blocked by:** 003 (or "nothing")
- **Blocks:** 011 (or "nothing")

## Map links
- **Parts touched:** P2 (and P1 at the edge)
- **Connections affected:** P2→P1 call — must keep expecting `{id}` back
- **Invariants that apply:** INV-1 (UTC timestamps), INV-3 (error envelope)
> These point into `01-map.md`. Re-read those rows before starting — they're the
> context this task can't see on its own.

## Goal
One sentence: what's true after this task.

## Why this matters
Two or three sentences of intent, so the executor makes good micro-decisions and a
reviewer knows what "done well" means.

## Context an executor needs
Everything required without prior knowledge: the relevant source paths with what's
there now, the conventions to follow, links to specs if any. Assume the reader has
seen nothing but this file and the map.

## Target shape / contract
What the code should look like after — signatures, component props, data shape,
file layout. Concrete enough to be checkable. Small before→after sketch if it helps.

## Steps
1. Ordered, concrete steps small enough that a small model follows each without inventing approach.
2. Name the files to touch and what to do in each.
3. Note where to add/adjust tests.

## Acceptance criteria
- [ ] Behavioral, checkable conditions ("X works at 360px", "P1's return shape unchanged", "build + typecheck + new test pass").
- [ ] Tests for the new/changed behavior exist and pass.
- [ ] The map is updated if this task changed a contract or connection.

## Out of scope
What NOT to touch here — prevents sprawl. Point to the follow-up task if the temptation belongs elsewhere.
```

### Why the template is shaped this way

- **Map links** are the difference from a generic task: they reload the cross-cutting context (connections, invariants) exactly when the executor needs it, instead of trusting it to remember the whole project.
- **Status / blocked-by / blocks** let any agent resume cold: read the roadmap, take the next task whose blockers are `done`.
- **Acceptance criteria as checkboxes** make "done" objective and give a built-in self-review — including the "update the map" check that keeps the shared memory current.
- **Out of scope** keeps an autonomous executor from sprawling past the task.

## Re-running on an existing plan (verify or expand)

When Step 0 finds an existing plan for the same task, the user picks the intent.

### Verify / double-check (default)
The "run it again to make sure the plan still holds" case. Re-research the task against current reality and validate the existing plan, then update in place:
- **Re-check the map** — are the parts, connections, and invariants still accurate? Has the code moved under the plan (a contract changed, a file moved, a dependency added)?
- **Re-check task status** — is anything in the plan already done in the code? Mark it `done` with evidence. Anything now blocked or obsolete?
- **Find gaps** — new connections or invariants the original missed, or work the task now needs that wasn't planned.
- **Report drift** — summarize what changed: what you updated, what's now done, what you added, and anything contradictory you surfaced for the user. Don't churn parts that are still correct.

### Expand
When growing a plan with newly-scoped work:

1. **Ingest it.** Read the existing plan/notes and reconstruct its current state — what's planned, what's done, what its map (if any) already captures.
2. **Build or update the map first.** If it has no `01-map.md`, create one from what's there — the missing big-picture map is usually exactly why it needs expanding. If it has one, extend it with the new parts and connections.
3. **Add, don't churn.** Fold new work in as new tasks/workloads with stable new numbers; leave existing task numbers alone. Update the dependency graph and roadmap to place the new work.
4. **Reconcile contradictions.** If new work conflicts with an existing task or invariant, surface it rather than silently overriding — the user decides.
5. **Note what changed** in your summary: what was added, what the map gained, any conflicts surfaced.
