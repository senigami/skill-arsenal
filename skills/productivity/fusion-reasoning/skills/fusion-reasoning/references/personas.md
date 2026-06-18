# Fusion Panel Persona Library — router

39 panel personas across planning, creative thinking, technical work, and general reasoning. **Don't read every file** — use the selection guide below to pick the personas your panel size calls for (2–5), then open only the domain file(s) those personas live in to get their full mindset/priorities.

**Review-shaped problems can also borrow from the adversarial-review library.** If the task is to critique existing work (code, a design, a document) rather than decide what to build, and the `adversarial-review` skill is available, you may select personas from *its* library too (its `references/personas.md` router lists 52 reviewer personas across code, data, UX, and content) and combine them with fusion personas in one panel. See "Borrowing review personas" below.

Each persona has a **mindset** (the angle it reasons from), **priorities** (what it weighs hardest), and **best used when**. The goal is panel *diversity*: two personas with the same underlying stance are one persona run twice. Pick personas that would genuinely disagree, and include at least one whose job is to oppose the likely consensus. If no preset fits a critical dimension, compose a new one with the template at the bottom.

## Quick selection guide

| Problem type | Consider these personas | File |
|---|---|---|
| Planning / strategy / roadmap | Pragmatist, Risk Scout, User Advocate, Economist, Resource Minimalist | planning |
| High-commitment plan / launch | Pre-Mortem Coroner, Risk Scout, Working-Backwards Narrator | planning |
| Estimation / forecasting / go-no-go | Base-Rate Statistician, Risk Scout, Empiricist | planning / reasoning |
| Prioritization / build-vs-buy | Economist, Resource Minimalist, Historian | planning |
| Product / feature definition | Working-Backwards Narrator, User Advocate, Confused User | planning / technical |
| Brainstorming / stuck / greenfield | Innovator, First-Principles Reasoner, Beginner's Mind, Maximalist | creative |
| Goal-setting stuck ("what should we do?") | Inverter, Innovator, First-Principles Reasoner | creative |
| Architecture / system design | Skeptic, Operator, Evolver, Performance Pessimist | technical |
| Bug hunting / correctness | Saboteur, Edge-Case Hunter, Integration Skeptic | technical |
| Concurrent / distributed design | Concurrency Specialist, Operator, Edge-Case Hunter | technical |
| Security design / threat modeling | Threat Modeler, Attacker, Insider Threat, Compliance Auditor | technical |
| UI / UX / design | Confused User, HIG Auditor, Accessibility Critic | technical |
| Decision between options | Devil's Advocate, Steelman Advocate, Contrarian Synthesizer, Disconfirmer | planning / reasoning |
| Open-ended reasoning / claims | Disconfirmer, Second-Order Thinker, Empiricist, Ethicist | reasoning |
| How to *approach* an unfamiliar problem | Cynefin Sorter, First-Principles Reasoner | reasoning / creative |
| Candid critique of a draft / design | Braintrust Peer, Skeptic, User Advocate | reasoning / technical |
| Risk-averse panel needs balance | Optimist, Maximalist (pair against the skeptics) | reasoning / creative |

## Domain files

- **[personas-planning.md](personas-planning.md)** — Pragmatist, Risk Scout, User Advocate, Devil's Advocate, Economist, Historian, Resource Minimalist, Pre-Mortem Coroner, Working-Backwards Narrator, Base-Rate Statistician
- **[personas-creative.md](personas-creative.md)** — Innovator, First-Principles Reasoner, Beginner's Mind, Maximalist, Inverter
- **[personas-technical.md](personas-technical.md)** — Skeptic, Operator, Evolver, Performance Pessimist, Saboteur, Edge-Case Hunter, Integration Skeptic, Concurrency Specialist, Attacker, Insider Threat, Compliance Auditor, Threat Modeler, Confused User, HIG Auditor, Accessibility Critic
- **[personas-reasoning.md](personas-reasoning.md)** — Disconfirmer, Second-Order Thinker, Contrarian Synthesizer, Empiricist, Optimist, Ethicist, Steelman Advocate, Cynefin Sorter, Braintrust Peer

## Borrowing review personas (when critiquing existing work)

Fusion's own personas are tuned for *deciding and designing*. When the panel's job is to **scrutinize something that already exists** — review this PR, critique this mockup, audit this doc — the sharper critics live in the **adversarial-review** library. If that skill is installed:

- Open its router at `references/personas.md` (in the adversarial-review skill) and use its selection guide to pull review personas — e.g. Regression Hunter, Mutant, Query Planner (code); First-Click Saboteur, Affordance Skeptic (UX); Fact-Checker, Plain-Language Auditor (content).
- **Combine freely:** a strong review panel often mixes a fusion reasoning persona (e.g. Devil's Advocate, Second-Order Thinker) with two adversarial review personas matched to the artifact. Treat both libraries as one pool and pick the most complementary set.
- If `adversarial-review` is *not* available, fall back to fusion's own technical/UX personas (Saboteur, Edge-Case Hunter, Confused User, etc.) and reason from your own expertise.

The dual-use personas that appear in both libraries (Concurrency Specialist, Threat Modeler, Second-Order Thinker, Ethicist, Saboteur, Confused User, HIG Auditor, Accessibility Critic) need only be picked once — don't double-count them across the two pools.

## Composing a New Persona

If no preset covers a critical dimension of the problem, construct one (and add it to the relevant domain file so the library grows):

```
### The [Name]
**Mindset:** "[Single sentence: what angle am I reasoning from?]"
**Priorities:** [5–7 things this persona weighs most heavily]
**Best used when:** [Problem types]
```

Keep mindsets genuinely distinct — if two personas share the same core concern, merge them or replace one.
