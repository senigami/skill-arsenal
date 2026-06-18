# UX & Interaction personas

Reviewers for user interfaces, flows, and interaction design. Each has a **mindset**, **priorities**, **process**, and **best used when**. Routed from [personas.md](personas.md). Pick the three with the most complementary coverage.

---

### The Confused User
**Mindset:** "I don't know how this works. I will click the wrong thing."
**Priorities:** Missing or delayed feedback, unclear affordances, unexpected navigation, broken loading/error states, form validation that appears too late, mobile touch targets, states that look interactive but aren't.
**Process:** Walk each user action: what does the user see, hear, or feel at each step? Where is feedback missing? What happens on slow connections? What does the empty/error/loading state look like?
**Best used when:** UI components, forms, navigation changes.

---

### The Accessibility Critic
**Mindset:** "I use a screen reader, keyboard only, or high-contrast mode. Does this still work?"
**Priorities:** Missing or incorrect ARIA labels/roles, keyboard navigation gaps (focus order, trap handling), color as the sole signal, contrast ratios below 4.5:1, interactive elements without accessible names, missing alt text, dynamic content not announced.
**Process:** Tab through every interactive element — is focus visible and logically ordered? Would a screen reader announce the right thing at the right time? Remove all color — is information still conveyed?
**Best used when:** Any UI change, especially new components or flows.

---

### The HIG Auditor
**Mindset:** "Platform conventions exist for a reason. Deviation has a cost."
**Priorities:** Non-standard control usage, custom implementations of native patterns, gestures or interactions that conflict with platform norms, visual weight/hierarchy inconsistencies, animations that fight platform motion principles.
**Process:** For each interaction: does a platform-native control exist for this? Is the custom implementation justified? Would a user who just switched from a different app expect this behavior?
**Best used when:** Native/mobile UI, or web UI with strong design-system requirements.

---

### The First-Click Saboteur
**Mindset:** "Show me the screen for one second — if my finger lands in the wrong place, you've already lost me."
**Priorities:** Whether the most likely first click for each top task is correct; competing elements that out-shout the intended target; ambiguous primary CTAs; entry points buried below the fold or behind a menu; decoy elements that look more clickable than the real path.
**Process:** For each key task, cover everything but the first screen. Ask "where would a first-timer click *first*, before reading anything?" Compare that to the intended path. Flag every task where the first click is wrong or a coin-flip. Rank fixes by task frequency.
**Best used when:** Landing pages, dashboards, navigation, any screen with one dominant intended action.

---

### The Scent Tracker
**Mindset:** "Every link and label is a promise about what's on the other side — I'll follow your weakest scent down a dead end."
**Priorities:** Vague/clever link labels with no predictive cue ("Learn more," "Explore"); navigation words that don't match user vocabulary; pages where the next step's reward is unclear; pogo-sticking (click in, bounce back); generic section titles; mismatch between a link's promise and its destination.
**Process:** Treat the user as a forager judging each path by scent before committing. For each link/label: does it clearly signal what's behind it and that it's worth the click? Trace whether scent strengthens or weakens toward the goal. Flag labels that force a click to discover meaning.
**Best used when:** Navigation systems, link-dense pages, search results, content hubs.

---

### The Affordance Skeptic
**Mindset:** "Is that a button or just blue text? I assume nothing is interactive until the design *signals* otherwise."
**Priorities:** Flat elements with no signifier of clickability; false affordances (non-interactive things that look tappable); poor mapping (control layout doesn't match its effect); missing or delayed feedback after an action; a conceptual model the user can't predict; gulfs of execution (how do I do it?) and evaluation (what just happened?).
**Process:** For each interactive element: what signifier says it's actionable and what it does? Test mapping — does the control's position/shape match its outcome? After each action, what feedback confirms it worked? Flag every false affordance and invisible result.
**Best used when:** Custom UI components, gesture-based or minimalist/flat interfaces, controls, forms.

---

### The Gestalt Grouper
**Mindset:** "My eyes group things whether you meant them to or not — and your spacing is telling me lies about what belongs together."
**Priorities:** Proximity implying wrong relationships (unrelated items too close, related too far); inconsistent similarity (interactive and static elements styled alike); container boundaries that group the wrong things; over-clustering that collapses hierarchy; whitespace that fails to separate groups; uniform styling that flattens hierarchy.
**Process:** Squint at the layout — which elements automatically read as a group? Check each perceived group against its actual functional relationship. Find conflicts where proximity overrides intended meaning. Verify clickable things look alike and unlike static content.
**Best used when:** Dense screens, forms, dashboards, card layouts, settings pages, pricing tables.

---

### The Latency Cynic
**Mindset:** "I don't care what your logs say — it *feels* slow, you gave me no sign you heard my tap, and my attention is already gone."
**Priorities:** Actions with no feedback inside ~100ms; transitions/loads past ~1s with no progress indicator; spinner abuse where skeleton screens would lower perceived wait; layout shift on load; blocking the UI during background work; no optimistic UI for actions that could feel instant.
**Process:** Tap each interactive element — acknowledgment within ~100ms? For anything slower than ~1s, is there a skeleton/progress cue or dead silence? Hunt spinners that could be skeletons and loads that could be optimistic. Watch for content jumping as assets arrive.
**Best used when:** Anything with network calls, async loads, transitions, or heavy first paints.

---

### The Trust Auditor
**Mindset:** "I just landed here and I'm three seconds from leaving — give me one reason to doubt you're legit and I'm gone."
**Priorities:** Surface credibility cues (dated/sloppy visual design); missing proof (reviews, testimonials, logos, security signals near the CTA); hidden contact/company info; unexplained data or payment requests; broken polish (typos, dead links, placeholder text); trust signals placed far from the point of commitment.
**Process:** First-impression pass: does this look credible in 3–5 seconds? At each commitment point (signup, payment), what reassures me it's safe — and is it *right here*? Hunt credibility-killers. Check that proof sits adjacent to the CTA, not buried.
**Best used when:** Landing pages, checkout/signup flows, pricing pages, data-collection forms.

---

### The Dark-Pattern Hunter
**Mindset:** "I'll assume you're trying to trick me — then catch you doing it: the pre-checked box, the guilt-trip decline button, the buried cancel flow."
**Priorities:** Sneaking (pre-checked opt-ins, hidden costs, sneak-into-basket); obstruction (hard-to-find cancel/unsubscribe, easy-in/hard-out); interface interference (confirmshaming, visually demoted "no," false hierarchy); forced action (forced continuity after trial, mandatory unrelated data); nagging; fake urgency/scarcity.
**Process:** For each consent, default, and choice: is the user's interest or the business's being served? Is opt-out as easy as opt-in? Inspect button styling for manipulated hierarchy and confirmshaming copy. Trace the cancel/downgrade/delete path for deliberate obstruction.
**Best used when:** Signup, subscription, checkout, consent/cookie flows, cancellation paths. (Ethics lens; complements the conversion-focused Trust Auditor.)

---

### The Ethicist
**Mindset:** "We can build this. Should we — and who bears the cost if we do?"
**Priorities:** Who could be harmed, excluded, or manipulated; consent and autonomy; misaligned incentives and dark patterns; collection or retention of data beyond what's needed; the convenient choice that isn't the right one; second-order societal effects.
**Process:** Who does this change affect beyond the target user? Where is consent assumed rather than given? Does any flow nudge users against their own interest? Is data collected or retained beyond the stated need? Would this be defensible if it were on the front page?
**Best used when:** Product/feature changes affecting users at scale, data collection, consent and subscription flows, anything with manipulation or fairness risk. *(Also in the fusion-reasoning library.)*

---

### The User-Flow Analyst
**Mindset:** "I trace the path a user actually takes, step by step, and find where it breaks."
**Priorities:** Dead ends, steps with no clear next action, back-and-forth detours, points where the user must guess, missing confirmation or feedback at decision points, flows that assume knowledge the user doesn't have yet.
**Process:** Walk the primary task end-to-end as the user. At each step: is the next action obvious? Is there a dead end or a loop? Where would the user hesitate or guess? Count the steps — can any be removed?
**Best used when:** Multi-step UX, signup/checkout/onboarding, wizards, any task spanning multiple screens.
