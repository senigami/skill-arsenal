# Panel design, personas, and prompt templates

The diversity that makes fusion work comes from giving each agent a **genuinely different persona** — a stance *plus* a job — not from model size. This file covers: how to compose a sound panel, the dispatch prompt, the cross-examination prompt, the judge meta-prompt, and the robustness guardrails that keep a panel from agreeing its way into a wrong answer.

## Composing the panel

Personas come from [personas.md](personas.md) — that's the library, organized by problem type with a quick selection guide at the top. Pick from it; compose a new persona only when no preset covers a critical dimension.

A persona carries three things into the dispatch prompt: its **name**, its **mindset** (one sentence), and its **priorities** (the specific things it weighs hardest). Pass all three — an agent told only "you are the Risk Scout" reasons more weakly than one given the full mindset and priority list.

For a quick, low-stakes panel you can use a lighter **angle** instead of a full persona — just a stance + a job ("MVP-first: smallest thing that delivers the core value; cut everything deferrable"). Angles and personas mix freely in one panel.

### Composition guardrails (check before dispatching)

1. **Distinctness** — no two panelists should hunt the same thing. Two personas with the same core concern are one persona run twice; replace one. If you can't name N genuinely distinct stances, the panel is too big — shrink it.
2. **Coverage** — between them, do the personas cover the dimensions on which this problem could actually go wrong? A planning panel of three optimists has a hole where risk should be.
3. **Built-in opposition** — include at least one persona whose job is to disagree with the likely consensus (Devil's Advocate, Disconfirmer, Skeptic, or a domain critic). A panel with no dissenter tends to converge prematurely.
4. **Balance the tilt** — if the natural panel skews one way (all skeptics, all builders), add the counterweight (Optimist/Maximalist against skeptics; Risk Scout/Skeptic against builders) so the fusion isn't lopsided.

## Dispatch prompt (independent pass, per agent)

> You are one member of a reasoning panel attacking a hard problem **independently**. You have not seen the other panelists' work, and you must not try to produce a balanced, all-sides answer — that's the judge's job. Your job is to push *your* persona's view as far as it honestly goes.
>
> **Your persona: <name>.**
> Mindset: *<one-sentence mindset>*
> You weigh these hardest: *<priority list>*.
>
> <If a domain skill applies:> First load the `<skill>` skill and reason through its lens.
>
> The problem: `<problem statement>`. <If research ran:> Shared facts to reason on — treat as given, do not re-research: `<cited brief>`.
>
> Reason concretely, not abstractly: name specifics, cite locations/evidence where they exist, and commit to a position. Ground every factual claim in the shared brief or in evidence you can point to — if you're inferring or assuming, say so. Then state the single strongest objection to your own conclusion honestly.
>
> Return only this JSON:
> ```json
> {
>   "persona": "<your persona name>",
>   "answer": "your conclusion / recommendation / findings — concrete and committed",
>   "key_reasoning": ["the load-bearing steps that got you there"],
>   "evidence": ["facts/locations/citations the answer rests on; empty if pure reasoning"],
>   "assumptions": ["what you assumed that, if wrong, changes the answer"],
>   "strongest_objection": "the best case against your own conclusion",
>   "confidence": "high | medium | low"
> }
> ```

For bug-hunting panels, `answer` is a list of findings, each with `location` (path:line), `problem`, `severity` (critical | warning | note), and `proposed_fix`.

## Cross-examination prompt (hard panels only)

After compiling the independent answers into one combined report tagged by persona:

> You are the **<persona name>** panelist. Here are the panel's independent answers, tagged by persona: `<combined report>`.
>
> React as a panelist — don't re-solve from scratch:
> - Where do you **agree** with another persona's conclusion? (one line each)
> - Where do you **disagree**, and why is your reasoning stronger? Be specific and concrete — point to the flaw, don't just restate your view.
> - What did another persona make you **newly see** that you missed?
> - Given the discussion, what's your **revised position and confidence**? Changing your mind is a valid and valuable outcome — say so plainly if another persona convinced you.
>
> Return only this JSON:
> ```json
> {
>   "persona": "<your persona name>",
>   "agreements": [{"with": "<persona>", "on": "..."}],
>   "disagreements": [{"with": "<persona>", "claim": "...", "why_you_differ": "..."}],
>   "newly_seen": ["..."],
>   "revised_position": "your updated conclusion",
>   "confidence": "high | medium | low"
> }
> ```

## Judge meta-prompt (the fusion)

Use this whether you (the orchestrator) synthesize directly or spawn a fresh Opus judge. If spawning, the judge gets the panel answers (and cross-exam, if run) and nothing else — a clean read.

> You are the Fusion Judge. Below are independent reasoning reports from a panel that attacked this problem from different personas<, plus their cross-examination round>. You did not write any of them — read them fresh and build the best possible single answer.
>
> Problem: `<problem statement>`.
> Panel reports: `<bundled reports>`.
>
> Do not summarize or staple the reports together. Produce a unified answer by working through these in order:
> 1. **Verify before trusting.** A panel agreeing on something does not make it true. Spot-check every load-bearing claim — especially factual ones and any bug a single persona reported — against the evidence each cited. If a claim rests on an unsupported assumption, mark it unverified and do not let it carry the answer.
> 2. **Consensus** — what most/all personas agree on *and survives verification*; treat that as load-bearing.
> 3. **Contradictions** — where they disagree, decide the most likely truth by the stronger reasoning, not by vote count. Commit to a call and say why. Flag separately any disagreement that is *genuinely* a matter of taste, product priority, or a trade-off only the user can weigh — those become "open forks for the user," not decisions you make.
> 4. **Unique insight** — the valuable point only one persona found. Weigh it on merit, not on how many agreed. A correct minority insight is exactly what a single pass would have missed — do not discard it just because it stood alone.
> 5. **Blind spots** — what the whole panel missed that you can see from above it.
> 6. **Deduplicate** — where several personas raised the same point in different words, merge it into one; don't inflate the answer by counting it many times.
> 7. **Synthesis** — one cohesive, authoritative answer in the form the task needs (plan / design direction / ranked findings / decision + rationale).
>
> Then return, in this order:
> - The synthesized answer.
> - A 3–5 line **judge's note**: the key contradiction(s) you resolved and which way, anything you marked unverified, and overall calibrated confidence.
> - An **"open forks"** list (possibly empty) of genuinely ambiguous decisions for the user — each with the realistic options and your recommendation.

### Degenerate panels — catch these in the judge

- **Trivial consensus.** If every persona agreed easily with high confidence and found nothing to push back on, the panel was probably too homogeneous (or the problem didn't need fusion). Say so, and treat the agreement with mild suspicion rather than as strong signal.
- **Uniformly low confidence.** If no persona got above "low/medium," the bottleneck is usually missing information, not missing reasoning. Don't manufacture false certainty — recommend the cheap experiment, the fact to gather, or the question to ask, and say what would raise confidence.
- **Two-against-one on a factual point.** Majority is not evidence. Resolve it by checking the fact, not by counting votes.

## Sizing cheat-sheet

| Difficulty | Agents | Models (by persona) | Cross-exam |
|------------|--------|---------------------|------------|
| Light | 1–2 (or just answer) | Haiku/Sonnet | no |
| Standard | 3 | mostly Sonnet, Haiku for the broad/mechanical persona | optional |
| Hard / frontier stand-in | 3–5 | hardest persona on Opus, rest Sonnet | yes |

Match personas to the count: 3 agents = 3 sharply different personas, not 3 shades of one. If you can't name N genuinely distinct stances, the panel is too big — shrink it.
