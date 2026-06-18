---
name: task-plan-architect
description: Research a large task and produce a detailed, mapped implementation plan that a smaller model can execute without losing the big picture. Use whenever the user wants to "plan out", "make a plan for", "map out", "research and plan", "break down a big task", "architect an approach", "scope this feature", or "expand an existing plan" — anything large or multi-part enough that no single context can hold all of it at once. It does NOT audit the whole repo for problems; it takes a given task (or an existing plan to grow) and builds the big-picture map: the parts, how they connect, the contracts and invariants between them, and an ordered set of self-contained tasks that each link back to the map. Saves the plan OUTSIDE the repo by default so it never contaminates the codebase, and asks upfront whether to keep it apart or in-repo. The result keeps a long project on track, connected, and organized as cheaper executor agents work through it.
---

# Task Plan Architect

A large task fails not because any one piece is hard, but because the **connections** between pieces fall out of memory: an executor fixes module A and forgets it changed a contract B relied on. Current models can't hold a whole project in context at once. This skill compensates by building that whole-project picture **once, on paper** — a map of the parts and the wires between them — so any executor (a small model, a future session, a teammate) can reload the relevant slice and stay oriented.

It produces a durable, hand-offable plan folder, but it **assumes a specific task** to research and plan (or an existing plan to expand) rather than scanning the repo for problems. It plans; it does not edit code.

It runs as an orchestration: you (the large model) are the architect holding the whole picture and doing the high-judgment work — the map and the sequencing — while fanning the focused reading out to the smallest capable agents and keeping your own context free. Match the model to the job: mechanical reading goes to light, cheap agents; judgment stays with you. Never spend a bigger model than the work needs.

**Model-agnostic by design.** Don't assume a specific provider or model name. Determine what models the `Agent` tool actually offers at runtime and sort them into capability tiers — **light** (fastest/cheapest: Haiku-, Flash-, Mini/Nano-class), **mid** (Sonnet-class), **top** (Opus-class) — then delegate by tier, not by name: send the mechanical file-reading to the light tier whatever it happens to be, and keep the synthesis and mapping for yourself. If only one tier is available, use it for everything. The principle holds across any model lineup.

## Step 0 — Settle the basics (ask upfront)

Before researching, confirm three things. Ask them in **one** batch; skip any the user already specified.

1. **Where does the plan live?** This is the important one. **Default: outside the repo**, and **every plan gets its own dedicated subfolder** so multiple plans never collide. The path is `~/.claude/plans/<project>/<task-slug>/` — namespaced by project (so plans for different repos stay separate) and then by an descriptive task-slug (so each task this skill is invoked for gets its own folder). Derive `<project>` from the repo/directory name and `<task-slug>` from the task itself (kebab-case, specific — `add-sso-login`, not `feature`). Ask the user: *"Keep the plan apart (default, outside the repo) or put it in-repo (e.g. `docs/plans/<task-slug>/`)?"* — and note that in-repo also gets its own per-task subfolder. Only write inside the repo if the user chooses it. Either way, report the absolute path in your summary so they can find it.

   **If a folder for this exact task already exists, don't guess — ask what to do.** A second run on the same task almost never means "make a duplicate." Surface that you found an existing plan and offer the three real intents (use `AskUserQuestion`):
   - **Verify / double-check it** *(recommended default)* — re-research the task and validate the existing plan against current reality: is it still accurate, has the code moved under it, are tasks already done, are there new connections or gaps? Report drift and update in place. This is the "I'm running it again to make sure the plan is still good" case.
   - **Expand it** — keep what's there and add newly-scoped work (the expand flow below).
   - **Start fresh / separate** — genuinely a different take or a parallel variant; only then use a new discriminated slug so the existing plan is untouched.

   Only fall back to auto-picking a more specific slug when it's a *different* task that merely collided on slug — never silently duplicate the same task.
2. **New plan or expand an existing one?** If expanding, get the path to the existing plan/notes and treat this as a grow-and-reconcile run (see [references/plan-folder.md](references/plan-folder.md) — "Expanding an existing plan").
3. **What's the task, really?** If the task as stated is vague or huge, get the goal, the boundaries (what's explicitly out of scope), any hard constraints, and what "done" looks like. A sharp task statement is what keeps the map from sprawling.

## Step 1 — Research the task (focused, not a repo audit)

Understand only what this task touches — its blast radius — not the whole codebase. Fan the reading out to light, cheap agents (mechanical file reading needs no large model) and keep the synthesis yourself. Run the scouts in parallel (multiple `Agent` calls in one message), and give each a **tight return contract** — the specific files or question to investigate and exactly what to report back (the contract shape, the caller list, the pattern in use) — so findings land in your context compact and digested, not as raw file dumps. Cover:

- **The surface the task touches**: the modules, files, routes, schemas, components, and services in scope, and the ones immediately adjacent (callers, dependents).
- **The contracts at the edges**: the interfaces, types, API shapes, events, and data formats where this task meets the rest of the system. These are where executors break things they can't see.
- **Existing patterns to follow**: how similar things are already done here, so the plan extends conventions instead of inventing parallel ones. (Match against the project's specs if a spec set exists.)
- **The unknowns**: what genuinely needs research or a decision before building. For external/library/factual unknowns, use a research capability if one is available (look for a deep-research-style skill); for hard design or approach calls, use a reasoning-fusion capability if available — otherwise reason it through yourself and record the decision.

The goal of this step is not coverage for its own sake — it's everything you need to draw the map accurately. Stop when you can.

## Step 2 — Build the map (the centerpiece)

This is what makes the plan more than a to-do list, and it's the high-judgment work you keep for yourself. Produce the **implementation map**: the big picture plus the connective tissue an executor must keep in mind. Full format in [references/connection-map.md](references/connection-map.md). It captures:

- **The big picture** — what's being built, in one screen, and the shape of the approach.
- **The parts** — the components/modules/units of work and what each is responsible for.
- **The connections** — how the parts depend on and talk to each other: the contracts, data flows, shared state, and ordering constraints between them. This is the part no single executor sees on its own.
- **Invariants & things to keep in mind** — the cross-cutting rules that must hold across the whole task (a type that several places must agree on, an auth check that can't be skipped, a migration that must run before a read). Each tagged so tasks can point back to it.
- **Risks & open questions** — what could go wrong, and what's still undecided.

Draw the connections explicitly (a dependency list or a Mermaid graph). The map is the externalized memory — when an executor opens task 7, the map tells it what task 7 connects to and must not break.

## Step 3 — Decompose into ordered, mapped tasks

Break the work into **workloads** (batches small enough to implement and verify as a unit) and, within them, self-contained tasks. The difference from a generic plan: **every task links back to the map** — which parts it touches, which contracts it must honor, which invariants apply, what depends on it. That backlink is what keeps a context-limited executor from breaking a connection it can't see.

Order by dependency: foundation and shared-contract work before what builds on it. Record the dependency graph so work can be parallelized safely. Task file template, workload definition, and the map-linkage fields are in [references/plan-folder.md](references/plan-folder.md).

## Step 4 — Write the plan folder

Write to the location chosen in Step 0. Structure (detail in [references/plan-folder.md](references/plan-folder.md)):

```
<plan-root>/
├── README.md            # what this is, where it lives, status protocol, how to pick up a task
├── 00-overview.md       # the task, goal, scope/boundary, success criteria
├── 01-map.md            # THE implementation map: parts, connections, invariants, risks
├── 02-roadmap.md        # ordered workloads + dependency graph + milestones
└── tasks/
    └── NNN-slug.md      # one self-contained, map-linked task per unit of work
```

Each task file stands alone: goal, why it matters, the exact files, the target shape/contract, ordered steps, acceptance criteria, dependencies, the **map links**, and out-of-scope — written so a small model can execute it with nothing but that file and the map open.

## Step 5 — Self-review for the executor

Re-read the plan as the stranger who'll execute it — a small model with only one task file and the map loaded. Check: could it do task N correctly without the rest of the context? Does every task's map-linkage actually point at real parts/contracts in `01-map.md`? Is the dependency order free of forward references? Do two tasks contradict each other? Does the map capture every connection the tasks rely on? Fix what you find, then summarize for the user: where the plan lives (absolute path), the big picture, the workload order, the first task to pick up, and any open questions you left for them.

## Guardrails

- **Don't contaminate the repo.** Out-of-repo is the default; only write inside the repo when the user said so. Never leave plan files staged for commit unless asked.
- **Don't audit — plan.** Research only the task's blast radius. If you find unrelated problems, note them for the user; don't fold a repo cleanup into this plan.
- **The map is the product.** A plan that lists tasks but doesn't wire them together is just a checklist — and checklists are exactly what lose the big picture. The connections are the value.
- **Plan for a context-limited stranger.** If a task can't be executed from its own file plus the map, it's underspecified. Over-link to the map and to source paths; never rely on "as we discussed."
