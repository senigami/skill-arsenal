# Panel design, angles, and prompt templates

The diversity that makes fusion work comes from giving each agent a **genuinely different angle**, not from model size. Below: angle menus per problem type, the dispatch prompt, the cross-examination prompt, and the judge meta-prompt. All ready to adapt.

## Angle menus by problem type

Pick 2–5 angles that genuinely pull in different directions. An angle is a *stance + a job*, not just a topic.

### Planning
| Angle | Stance it argues from |
|-------|----------------------|
| MVP-first | Smallest thing that delivers the core value; cut everything deferrable |
| Risk-first | What's most likely to go wrong or be expensive to reverse; sequence to de-risk early |
| User-value-first | What the end user feels soonest; order by visible payoff |
| Maintainability-first | The shape that's cheapest to live with in 6 months; boring over clever |
| Dependency-first | What unblocks the most other work; the critical path |

### Design (UI / Apple HIG)
| Angle | Lens to look for among available skills | Argues from |
|-------|------------------------------------------|-------------|
| HIG principles | a skill offering Apple HIG / platform design guidance | Clarity / deference / depth; platform convention; restraint |
| Visual hierarchy & craft | (usually none needed) | Spacing, type scale, what the eye hits first, the squint test |
| User flow & IA | (usually none needed) | Can a first-timer complete the task; cognitive load; step count |
| Design-system fit | a skill describing *this* repo's/project's design system or design-compliance rules | Token-driven, consistent with existing vocabulary |
| Accessibility & inclusivity | a skill offering an accessibility / WCAG audit rubric | Contrast, targets, color-isn't-the-only-signal, real-user range |

For the "lens to look for" column, match by capability against whatever skills are actually available in the environment — don't assume a specific skill name exists. If nothing matches, the agent reasons from its own domain expertise.

### Bug hunting
| Angle | Hunts for |
|-------|-----------|
| Correctness | Off-by-one, boundary, null/empty/error paths, logic that contradicts intent |
| Security | Unvalidated input, authz gaps, injection, secret handling, trust boundaries |
| Concurrency & state | Races, stale reads, ordering assumptions, shared-state mutation |
| Edge cases & inputs | Unusual/extreme/malformed inputs; the unhappy paths nobody tested |
| Contract & integration | Where this code's assumptions disagree with its callers/dependencies |

### General reasoning / decision
| Angle | Job |
|-------|-----|
| Steelman A | Build the strongest possible case for option A |
| Steelman B | Build the strongest possible case for the leading alternative |
| Disconfirming evidence | Actively hunt for what would prove the appealing answer wrong |
| First-principles | Ignore convention; reason up from fundamentals |
| Base-rate / outside view | What usually happens in situations like this, regardless of specifics |

## Dispatch prompt (independent pass, per agent)

> You are one member of a reasoning panel attacking a hard problem independently. Your assigned angle: **<angle + its stance>**. <If a domain skill applies:> First load the `<skill>` skill and reason through its lens.
>
> The problem: `<problem statement>`. <If research ran:> Shared facts to reason on (do not re-research): `<cited brief>`.
>
> Reason hard from your angle specifically — push it further than a balanced take would. Other panelists cover other angles, so don't hedge into neutrality; give this angle its strongest, most concrete expression. Then state the single strongest objection to your own conclusion.
>
> Return only this JSON:
> ```json
> {
>   "angle": "<your angle>",
>   "answer": "your conclusion / recommendation / findings, concrete",
>   "key_reasoning": ["the load-bearing steps that got you there"],
>   "assumptions": ["what you assumed that, if wrong, changes the answer"],
>   "strongest_objection": "the best case against your own conclusion",
>   "confidence": "high | medium | low"
> }
> ```

For bug-hunting panels, `answer` is a list of findings, each with `location` (path:line), `problem`, and `proposed_fix`.

## Cross-examination prompt (hard panels only)

After compiling the independent answers into one combined report tagged by angle:

> You are the **<angle>** panelist. Here are the panel's independent answers, tagged by angle: `<combined report>`.
>
> React as a panelist, don't re-solve from scratch:
> - Where do you **agree** with another angle's conclusion? (one line each)
> - Where do you **disagree**, and why is your reasoning stronger? Be specific and concrete.
> - What did another angle make you **newly see** that you missed?
> - Given the discussion, what's your **revised position and confidence**?
>
> Return only this JSON:
> ```json
> {
>   "angle": "<your angle>",
>   "agreements": [{"with": "<angle>", "on": "..."}],
>   "disagreements": [{"with": "<angle>", "claim": "...", "why_you_differ": "..."}],
>   "newly_seen": ["..."],
>   "revised_position": "your updated conclusion",
>   "confidence": "high | medium | low"
> }
> ```

## Judge meta-prompt (the fusion)

Use this whether you (the orchestrator) synthesize directly or spawn a fresh Opus judge. If spawning, the judge gets the panel answers (and cross-exam, if run) and nothing else — a clean read.

> You are the Fusion Judge. Below are independent reasoning reports from a panel that attacked this problem from different angles<, plus their cross-examination round>. You did not write any of them — read them fresh and build the best possible single answer.
>
> Problem: `<problem statement>`.
> Panel reports: `<bundled reports>`.
>
> Do not summarize or staple the reports together. Produce a unified answer by:
> 1. **Consensus** — what most/all angles agree on; treat as load-bearing unless you have reason to doubt it.
> 2. **Contradictions** — where they disagree, decide the most likely truth and justify it by the stronger reasoning, not by vote count. Commit to a call. Flag separately any disagreement that is *genuinely* a matter of taste, product priority, or a trade-off only the user can weigh — list those as "open forks for the user" with the options and your recommendation, rather than deciding them yourself.
> 3. **Unique insight** — the valuable point only one angle found; weigh it on merit, not on how many agreed.
> 4. **Blind spots** — what the whole panel missed that you can see from above it.
> 5. **Synthesis** — one cohesive, authoritative answer in the form the task needs (plan / design direction / ranked findings / decision + rationale).
>
> Flag any claim you're relying on that should be verified against real evidence before the user acts on it. Return the synthesized answer, then a 3–5 line note on the key contradiction(s) you resolved and overall confidence, and finally an **"open forks"** list (possibly empty) of any genuinely ambiguous decisions that should go to the user as a choice rather than be decided here — each with the realistic options and your recommendation.

## Sizing cheat-sheet

| Difficulty | Agents | Models (by angle) | Cross-exam |
|------------|--------|-------------------|------------|
| Light | 1–2 (or just answer) | Haiku/Sonnet | no |
| Standard | 3 | mostly Sonnet, Haiku for the broad/mechanical angle | optional |
| Hard / frontier stand-in | 3–5 | hardest angle on Opus, rest Sonnet | yes |

Match angles to the count: 3 agents = 3 sharply different angles, not 3 shades of the same one. If you can't name N genuinely distinct angles, the panel is too big — shrink it.
