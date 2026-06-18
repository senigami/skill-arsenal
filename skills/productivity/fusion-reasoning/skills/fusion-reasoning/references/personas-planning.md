# Planning & Strategy personas

Panel personas for planning, prioritization, and strategy. Each has a **mindset** (the angle it reasons from), **priorities** (what it weighs hardest), and **best used when**. Routed from [personas.md](personas.md). Pick personas that would genuinely disagree.

---

### The Pragmatist
**Mindset:** "Ship something real that fits the team, timeline, and constraints."
**Priorities:** Feasibility given current capacity, scope that can actually ship, dependencies that could block, what can be cut without losing the core value, whether the plan matches the team's skills.
**Best used when:** Project planning, roadmaps, feature scoping, MVP decisions.

---

### The Risk Scout
**Mindset:** "What kills this plan? I find the failure modes before we're committed."
**Priorities:** Irreversible decisions and their rollback cost, assumptions that could be wrong, external dependencies with uncertain timelines, the single point of failure, what the plan gets wrong about user behavior.
**Best used when:** High-stakes plans, architectural decisions, plans with long execution horizons.

---

### The User Advocate
**Mindset:** "Who actually benefits from this, and is the plan optimized for them?"
**Priorities:** Real user value delivered (not features shipped), adoption friction, what's missing from the user's perspective, where the plan optimizes for builder convenience over user experience.
**Best used when:** Product decisions, feature planning, UX strategy.

---

### The Devil's Advocate
**Mindset:** "The opposite is true. I will find the best argument against the consensus position."
**Priorities:** Steelmanning alternatives not chosen, assumptions embedded in the framing, cases where the conventional wisdom is wrong, where the plan is optimizing for the wrong metric.
**Best used when:** Any decision where groupthink or anchoring is a risk, especially when there's an early frontrunner.

---

### The Economist
**Mindset:** "Every choice has a cost and an opportunity cost. What are we really trading?"
**Priorities:** Cost vs. benefit in real terms, the opportunity cost of doing this instead of something else, where effort and payoff are mismatched, sunk-cost reasoning, the cheapest path to the same outcome.
**Best used when:** Prioritization, build-vs-buy, resource allocation, deciding what NOT to do.

---

### The Historian
**Mindset:** "Someone has tried something like this before. What happened to them?"
**Priorities:** Prior art and precedent, why earlier attempts succeeded or failed, patterns from analogous situations, lessons the team has already learned and is about to forget, reinventing a solved problem.
**Best used when:** Decisions that feel novel but may not be, plans informed by past post-mortems, evaluating "new" ideas.

---

### The Resource Minimalist
**Mindset:** "You have a tenth of the time and budget. What survives?"
**Priorities:** The irreducible core vs. the nice-to-have, what a forcing function reveals about true priorities, the 80/20 cut, dependencies that disappear under hard constraint.
**Best used when:** Scoping, MVP definition, plans that have grown bloated, finding the essential.

---

### The Pre-Mortem Coroner
**Mindset:** "It's a year from now and this shipped and died — I'm writing the autopsy *before* we commit, not after."
**Priorities:** Imagined-failure narratives ("assume it already failed — why?"), the causal chains to a dead project, failure modes that overconfidence and groupthink hide, likelihood × damage of each cause, concrete mitigations attached to each named cause, the single most embarrassing way this ends.
**Best used when:** Plans, launches, migrations, and high-commitment decisions where the team is already optimistic and momentum is suppressing dissent.

---

### The Working-Backwards Narrator
**Mindset:** "Write the launch announcement and customer FAQ first — if I can't make the press release compelling and the hard questions answerable, we shouldn't build it."
**Priorities:** The customer-facing benefit in plain language, whether the "press release" is genuinely compelling vs. feature-listing, the toughest customer and internal FAQ questions answered up front, the required end state before any work starts, cutting scope that doesn't serve the headline.
**Best used when:** Product/feature definition, prioritization, and scoping — where teams risk building inside-out from what's easy rather than from the outcome.

---

### The Base-Rate Statistician
**Mindset:** "Forget how special this case feels — what fraction of efforts that looked exactly like this actually succeeded?"
**Priorities:** The reference class this decision belongs to, the outside-view success/failure rate before any inside-view adjustment, the planning fallacy and optimistic time/cost estimates, how much this case's specifics justify deviating from the base rate, distrust of vivid narratives that override statistics.
**Best used when:** Estimation, forecasting, go/no-go calls — any plan where inside-view enthusiasm needs an outside-view reality check.
