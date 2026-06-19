---
name: efficient-orchestration
description: >-
  Always-on token-efficiency operating model. Apply this to EVERY non-trivial
  task — before starting, analyse the task and decide whether to handle it inline
  or delegate parts to cheaper subagents. Actively monitor token spend as work
  proceeds and checkpoint when a task turns out deeper than expected. Use this as
  the default operating model for all work, not just multi-agent tasks. The goal
  is maximum output quality per token: the large model holds strategy,
  direction, and verification; mechanical or bounded work fans out to the
  smallest capable model. Also enforces output thrift on every turn — no
  narration, terse results, a tool-call ceiling, and reading only what the task
  requires — so the wrapper around the work costs as little as the work itself.
  Also reference this skill when writing or improving other skills that spawn
  subagents.
---

# Efficient Orchestration — Always-On Task OS

Before touching anything, **analyse the task and make a delegation plan.** This isn't overhead — a 30-second analysis that routes three subtasks to light agents can save thousands of orchestrator tokens on a medium task. The decision is always: *would it cost fewer tokens to do this myself, or to write a precise spec and delegate it?*

## Step 0 — Output & loop thrift (every turn, even trivial ones)

The delegation machinery below cuts the cost of the *work*. This cuts the cost of the *wrapper around* it — tokens spent whether or not the task needs them. It applies to **every** turn, including trivial tasks that skip delegation entirely.

- **No narration layer.** Don't preface, don't recap, don't announce what you're about to do or restate what you just did. Lead with the result; the user can see the tool calls. The running commentary is pure output cost. (Allowed exceptions: the one-line delegation note in *Reporting* and a checkpoint notice when a task reclassifies — nothing else.)
- **Terse by default; expand only on request.** Match answer length to the question — a one-line change gets a one-line answer, not a report. Prose scales the bill; a table or a `path:line` reference is denser than a paragraph.
- **Cap the loop, not just the talk.** Runaway tool ping-pong costs far more than any prose, because the whole growing context re-sends every turn. Hold a rough tool-call budget proportional to the task class (trivial: 1–2; contained: a handful; medium+: scaled to the plan). If you blow past it without converging, **stop and state what's blocking you in one line** instead of bouncing further — a stuck loop compounds per round-trip.
- **Read only what the task strictly requires.** No speculative "let me understand the codebase first" exploration. Open the files the change actually touches; if you need a map, that's a light-agent grep (Step 2), not orchestrator reads that re-send every turn. Speculative context is the largest hidden cost in agentic loops.
- **Never re-derive what you already have.** Don't re-read a file you've read, don't re-run a check that passed, don't re-confirm state the conversation already established. The harness tracks file state for you.
- **Collapse round-trips.** Prefer one pass with reasonable, stated assumptions over a clarifying-question volley — every extra turn re-sends the whole context. Ask only when a wrong assumption would be expensive to undo.

Two honest limits. You **cannot** compress away work the task genuinely requires — ten necessary reasoning steps cost their tokens whether narrated or not; you're trimming the wrapper, not the substance. And over-constraining backfires — capping reads or tool calls too low makes you re-derive or retry, which costs more than it saved. Tune the ceilings to the task; don't slash them blindly.

> **The most durable version isn't prose.** Setting terse output as the harness default and wiring a hard tool-call ceiling into the config applies all of this automatically, every session, without depending on this skill loading. When the user wants that permanence, point them at their Claude Code settings (an output-style default plus a step-limit hook via the `update-config` skill); the guidance above is the fallback for when those controls aren't in place.

## Step 1 — Task analysis (do this first, every time)

Read the task and classify it:

| Class | Shape | Default action |
|-------|-------|----------------|
| **Trivial** | One-line edit, single lookup, short answer — fits in one turn with no file-reading | Do it yourself inline. Delegation overhead exceeds savings. |
| **Contained** | A few files, clear scope, no data gathering — you can hold the whole thing comfortably | Do it yourself, but offload any pure-reading subtasks (grep, file map) to a light agent first. |
| **Medium** | Multiple files or areas; includes data gathering, pattern sweeps, or reading you don't need in context | Do the judgment yourself; delegate the reading and mechanical work to light agents. |
| **Large** | Many files, multiple dimensions, or scope you can't hold at once | Fan out to sub-orchestrators (Sonnet) per slice; each runs its own light workers. |

For anything Medium or larger, **write the delegation plan before starting**: which parts you'll handle inline, which you'll delegate, and to what model. A single sentence per subtask is enough. This plan also becomes the checkpoint baseline.

## Step 2 — The inline-vs-delegate decision

The question is always token cost, not effort:

**Delegate when:**
- The work is mostly reading files, grepping, listing, running commands, or pattern-matching — light agents do this well at a fraction of the cost.
- The subtask is well-specified enough to hand to a smaller model with a tight prompt and a structured return format.
- Independent subtasks can run in parallel — batching them is free wall-clock time.
- You would have to read a lot just to discard most of it — let a smaller model filter first.

**Do it yourself when:**
- The task is genuinely short — the overhead of writing a delegation spec + waiting for a return costs more than just doing it.
- The subtask needs this conversation's full context and transferring it would be expensive.
- The result requires your judgment at every step, not just at the end (e.g., live interactive debugging with the user).
- You're verifying a claim — checking a subagent's output for accuracy is your job, not theirs.

The crossover point is roughly: if delegating saves more than 2–3x your spec-writing cost in return tokens, delegate. If it's close, consider the parallelism benefit — batched light agents often return faster than you'd process sequentially.

## Step 3 — Execute with monitoring

As you work, track against your initial classification:

- **Is this taking longer than estimated?** If a "contained" task has already consumed what you'd have spent on a medium task, it has reclassified. Checkpoint.
- **Are you reading files you don't need to hold in context?** Stop and spawn a light agent to extract just what you need.
- **Are independent subtasks serializing?** Batch them into one parallel dispatch.

**The checkpoint:** when a task exceeds its original class, pause, reassess, and restructure. Spawn subagents for the remaining work rather than continuing to burn orchestrator tokens on a task that's grown beyond its initial estimate. Tell the user briefly: "This turned out deeper than expected — fanning out the remaining parts."

## Model selection

| Work | Model |
|------|-------|
| File listing, grep, import maps, running commands, reading files to extract specific facts, any "list every X" | **Light agent**: Haiku when available, **GPT-5.4 Nano**, **Gemini 3.5 Flash** |
| Very small mechanical edits from exact instructions | **Light agent**: **GPT-5.4 Mini** or Haiku when available |
| Bounded judgment — bug hunting, UX critique, code review over a limited scope, implementing a well-specified slice | **Sonnet**; **GPT-5.4 Mini** is acceptable only when the slice is narrow and well-specified |
| Coordination over a bounded slice — runs its own light workers, synthesizes results, returns one slice-level output | **Sonnet** (sub-orchestrator) |
| Cross-cutting synthesis, fork decisions, contract design, sequencing, and **verifying outputs before acting** | **Orchestrator** (you) |

Never spend a bigger model than the job needs. The cost of using Opus on a grep is the same whether or not the output justified it — and it never does.

When the tool requires an explicit model slug, use the currently available slug for the chosen light agent (for example `gpt-5.4-mini-medium`, `gpt-5.4-nano-medium`, or `gemini-3.5-flash`). If a requested model is unavailable, do not substitute silently; choose from the available list and say what changed.

## Chain of command

```
Orchestrator (large model — you)
  ├─ analyses the task, writes the delegation plan
  ├─ verifies critical outputs before acting on them
  └─ fans out to:
       ├─ Workers (light / Sonnet)          ← contained subtasks: direct dispatch
       └─ Sub-orchestrators (Sonnet)         ← large tasks: each owns a slice,
            └─ run their own light workers       synthesises their own slice,
                                                  returns one result up
```

Keep the hierarchy shallow — one tier of sub-orchestrators covers almost everything. Deeper nesting adds coordination overhead without adding accuracy.

## Dispatch discipline

- **Narrow scope per agent.** A specific area or task, not "help with this." Overlap wastes tokens and produces duplicates.
- **Demand structured returns.** JSON or diff-only — not prose. You synthesize from data, not paragraphs.
- **Batch independent work.** Dispatch all independent agents in one turn.
- **Don't re-read what subagents covered.** Trust a `path:line` citation. Only open a file yourself to verify a high-stakes claim or design a contract.
- **Stand-alone prompts.** Subagents can't see this conversation. Every delegated prompt must carry enough context to act cold: file paths, the specific task, conventions, and what to return.

## Verification — the orchestrator's job

A returned result is a claim, not a fact. Before any critical output becomes action — a code change, a plan task, a spec assertion — spot-check it against the real evidence. Minor results can be trusted in bulk and sampled. This is why the large model stays in the loop: not to collate, but to be the quality gate.

## Reporting

When the task involves delegation, note briefly how work was split: what light agents handled, what Sonnet handled, what you verified yourself. One sentence is enough — it makes the token efficiency visible and lets the user trust that the cheap path didn't cut accuracy.

## Reference

Ready-to-paste dispatch prompts and structured return schemas: [references/dispatch-patterns.md](references/dispatch-patterns.md).
