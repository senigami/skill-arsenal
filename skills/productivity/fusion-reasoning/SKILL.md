---
name: fusion-reasoning
description: >-
  A reasoning amplifier for hard problems — fuses several independent model
  attempts into one answer that beats any single pass. Use whenever the user
  wants to "think hard about", "reason through", "create a plan for", "find the
  best approach", "find bugs in", "design this properly", or "get multiple
  perspectives" on a problem too tricky for one attempt to be trustworthy —
  especially planning, UI / Apple HIG design reasoning, architecture decisions,
  and bug hunting. A stand-in for a frontier reasoning model: it runs an
  adaptively-sized panel of independent Claude agents, optionally has them
  cross-examine, and a judge synthesizes consensus, resolves contradictions, and
  surfaces blind spots into one unified result. Discovers and invokes whatever
  relevant skills are available (research, design, accessibility) by matching
  their descriptions to the need, rather than depending on any specific skill
  being installed.
---

# Fusion Reasoning

One model's answer to a hard question carries that model's blind spots. Fusion removes them by having **several agents reason independently, then fusing their work** — the same problem attacked from different angles, with a judge that keeps the agreements, resolves the contradictions, and notices what only one agent saw. The result is reliably better than any single attempt, even when every agent is the same model run with a different stance ("self-fusion" works because each run searches, reasons, and trades off differently).

Use it as a **frontier-reasoning stand-in**: when you'd want your most capable reasoning model for a plan, a design call, or a bug hunt and it isn't available, fusion approximates that caliber by spending breadth instead of a single bigger brain.

This skill runs as an orchestration: you (the large model) are the orchestrator and the judge; the panel work fans out to the smallest agents that can do it well, and you keep your context for synthesis. Size the panel to the problem — match the model to each persona's difficulty, and don't spend a five-Opus panel on a question one good pass would answer.

## The shape

```
0. Frame    → classify the problem, decide if external facts are needed, design the panel
1. Research → (only if needed) invoke a research capability — if available — for a cited factual brief the panel reasons on
2. Panel    → N independent agents reason in parallel, each as a distinct PERSONA, structured returns
3. Cross-exam → (hard problems) panel sees each other's answers once, flags agreements/contradictions, revises
4. Fuse     → YOU (or a fresh Opus judge) synthesize: consensus + resolved contradictions + unique insights + blind spots
5. Deliver  → one unified answer; escalate ONLY genuinely ambiguous forks to the user (options + your pick) + Fusion Summary
```

## Step 0 — Frame the problem & design the panel

Read the task and decide four things:

1. **Type & persona selection** — what kind of reasoning is this? Read [references/personas.md](references/personas.md) — it's a lightweight **router**: a selection guide mapping problem type to a persona shortlist, plus which domain file each lives in. Don't read all the domain files; from the guide, pick the personas your panel size calls for, then open only the relevant domain file(s) (`personas-planning.md`, `personas-creative.md`, `personas-technical.md`, `personas-reasoning.md`) for their full mindset/priorities.

   Pick the personas whose combined angles give the most independent coverage of the problem, and include at least one whose job is to oppose the likely consensus. Goal: each agent knows exactly what kind of thinker it is, and the set would genuinely disagree. Two personas with the same underlying stance are one persona run twice.

   If no preset fits a critical dimension of the problem, compose a new one using the template at the bottom of the router — same structure, same cost to invoke, added to the relevant domain file for future use.

   **If the task is to critique existing work** (review this PR, audit this design or doc) rather than decide what to build, you may also borrow personas from the `adversarial-review` skill's library if it's installed — its router lists 52 reviewer personas tuned for scrutiny. Treat both libraries as one pool and combine freely (e.g. a fusion Devil's Advocate plus two adversarial review personas matched to the artifact). See "Borrowing review personas" in the router.

   State the chosen personas and one-line rationale for each before dispatching.

2. **External facts?** If the answer depends on real-world current information (library behavior, benchmarks, prices, recent events, anything you can't reason out from first principles), plan to run **Step 1**. If it's pure reasoning over what's already known or in the repo, skip it.

3. **Panel size & models (adaptive)** — match spend to difficulty. The diversity of *personas* matters more than raw model size; a panel of three Sonnets with sharply different stances often beats one Opus.
   - *Light* (genuinely answerable in one good pass, low stakes): 2 agents, or skip fusion entirely and just answer — say so.
   - *Standard* (most real problems): 3 agents, mixed Sonnet/Haiku by persona difficulty.
   - *Hard* (high stakes, subtle, or you're explicitly subbing for a frontier model): 3–5 agents, the hardest persona on Opus, plus cross-examination.

4. **Match personas to available skills (don't hardcode names).** For each persona, decide what *kind* of expertise would sharpen it (e.g. "Apple HIG guidance", "an accessibility rubric", "a security checklist"). Then scan the **currently available skills** and have the agent invoke whichever genuinely matches that need. Match by what a skill *does*, not by a name this file guessed. If none fit, the agent reasons from its own expertise — say so in its prompt. Never block the panel waiting for a skill that isn't there.

State the panel design — personas chosen, why, models assigned — in two or three lines before dispatching, so the cost and reasoning are visible.

## Step 1 — Research substrate (only when external facts are needed)

If Step 0 flagged external facts, produce a shared cited brief first. Check the available skills for a deep-research capability (a skill whose description is about multi-source, fact-checked research) and invoke it; if none exists, run the research yourself with a web-search/fetch agent. Either way that brief becomes shared input every panel agent reasons on — so the panel argues over *interpretation and approach*, not over what the facts are. Don't make each panel agent re-research the same thing; research once, reason many. (For light factual needs, a single web-search agent is enough — reserve a full deep-research pass for genuinely deep questions.)

## Step 2 — Dispatch the panel (parallel, independent)

Dispatch all panel agents in **one batch** so they run concurrently. Each agent:
- Gets the problem, the shared research brief (if any), and **its persona** — name, mindset, and priorities (pass all three, not just the name) — but *not* the other agents' work. Independence is the whole point; anchoring kills the diversity that makes fusion work.
- Loads its domain skill where one applies.
- Returns the **structured verdict** (its answer + key reasoning + evidence + assumptions + confidence + the strongest objection to its own answer), not a loose essay.

Model per agent follows the panel design — match the model to the persona's difficulty; never spend a bigger model than the persona needs. Dispatch prompt template and return schema are in [references/panel-and-prompts.md](references/panel-and-prompts.md).

## Step 3 — Cross-examination (hard problems only)

For hard/high-stakes panels, run one reaction pass: compile the answers into a combined report (tagged by which agent said what), send it back to each agent. Each replies with where it **agrees**, where it **disagrees and why**, what it **now sees** that it missed, and any **revised position**. One pass only — the panel sharpens its disagreements; you make the final call in Step 4. Skip this for light/standard panels where it isn't worth the tokens, and say you skipped it.

## Step 4 — Fuse (the judge)

This is the payoff and the high-judgment core. Synthesize the panel into **one** answer. You (the orchestrator) are the natural judge — you didn't generate any panel answer, so you're already the unbiased fresh eye. For very large panels, or to keep your context lean, spawn a **fresh Opus judge agent** instead and have it return the synthesis.

The judge's job, explicitly (full meta-prompt in [references/panel-and-prompts.md](references/panel-and-prompts.md)):
1. **Consensus** — what all/most agents agree on; treat as load-bearing.
2. **Contradictions** — where they disagree, split them in two:
   - *Resolvable* — one side's reasoning is clearly stronger, or it's a factual question. Decide it yourself, say *why*, and fold the call into the answer. Don't paper over it with "some say X, some say Y."
   - *Genuinely ambiguous* — a real fork where it comes down to taste, product priorities, or a trade-off only the user can weigh (and the panel didn't converge in cross-exam). These you do **not** decide silently — they go to the user in Step 5.
3. **Unique insights** — the valuable point only one agent found; these are often the highest-value output and are exactly what a single pass would have missed.
4. **Blind spots** — what the whole panel missed, that you can see from above the fray.
5. **Synthesis** — one cohesive answer, not a stapled-together digest. It must read as a single authoritative result.

**Verify, don't just collate.** A panel agreeing on something doesn't make it true — spot-check load-bearing claims (especially any factual ones, and any bug a single agent reported) against the real evidence before they enter the final answer. Consensus on a wrong premise is still wrong.

## Step 5 — Deliver (and escalate only what's ambiguous)

Lead with the fused answer in whatever form the task wants (a plan, a design direction, a ranked bug list, a decision + rationale). Everything the panel agreed on, and every contradiction you resolved confidently, is simply *in* that answer — the user doesn't need to ratify what the panel already settled. That's the point of fusion: it does the deciding it can.

**Then, only if Step 4 surfaced genuinely ambiguous forks, put those to the user as choices.** Use `AskUserQuestion`: one question per open fork, each with the realistic options drawn from the panel's positions, a one-line note on the trade-off, and **your recommendation marked** (the option you'd pick, why). Batch all open forks into one round, not a drip. If there are no ambiguous forks, ask nothing — deliver the answer and proceed. Don't manufacture a decision to seem rigorous; agreement needs no vote.

Close with a short **Fusion Summary**:
- Panel used (how many agents, which models, which personas) and whether cross-exam ran.
- The key contradictions you resolved and which way (so the user can see what you decided on their behalf).
- Overall confidence. (The open forks, if any, are the `AskUserQuestion` above — not buried here.)

The summary makes the process transparent and shows where the extra spend went.

## When NOT to use fusion

- Trivial or factual-lookup questions — one pass (or one search) is correct and cheaper. Fusion on an easy question just burns tokens to reach the same answer.
- When the user needs a fast, cheap answer and has said so. Offer a Light panel or a single pass instead.
- Pure execution of an already-decided plan — that's a separate execution pass, not this. Fusion decides *what* to do; it doesn't grind out the implementation.

## Guardrails

- **Adaptive means honest sizing.** Don't default to the biggest panel to look thorough; match it to difficulty and say why. A skill that always runs five Opus agents is overfit to seeming impressive.
- **Diversity comes from personas, not just models.** Two agents with the same stance are one agent run twice. Assign genuinely different personas, and include at least one whose job is to disagree with the likely consensus (see the composition guardrails in [references/panel-and-prompts.md](references/panel-and-prompts.md)).
- **Independence first, then deliberation.** Never let the panel see each other's work before the independent pass — it collapses the diversity fusion depends on.
- **The judge synthesizes; it doesn't average.** A muddy "on the one hand / on the other" is a failed fusion. The output is a decision with reasoning.
