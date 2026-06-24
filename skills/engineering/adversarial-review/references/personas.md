# Adversarial Reviewer Persona Library — router

52 reviewer personas across code, data, UX, and content. **Don't read every file** — use the selection guide below to pick the ~3 personas whose combined coverage best matches what's being reviewed, then open only the domain file(s) those personas live in to get their full mindset/priorities/process.

Each persona has a **mindset** (the lens it attacks from), **priorities** (what it looks hardest at), **process** (concrete questions), and **best used when**. Pick three with complementary coverage — don't stack two that hunt the same thing. If no preset fits a critical dimension, compose a new one with the template at the bottom.

## Quick selection guide

| What you're reviewing | Consider these personas | File |
|---|---|---|
| General code (no strong domain) | **Saboteur, New Hire, Security Auditor** (defaults) | code |
| Maintainability / refactor / cleanup | Regression Hunter, Dead Code Hunter, Nitpicker | code |
| Architectural / high-ripple change | Second-Order Thinker, Regression Hunter, Threat Modeler | code |
| Concurrent / async code | Concurrency Specialist, Resource Accountant, Saboteur | code |
| Error handling / resilience | Error-Path Auditor, Resource Accountant, Observability Critic | code |
| Typed-language code | Type Pedant, Saboteur | code |
| Tests | Test Skeptic, Mutant, Invariant Hunter | code |
| Config / infra / deployment | Misconfiguration Hunter, Observability Critic, Dependency Auditor | code |
| New / changed dependencies | Dependency Auditor, Security Auditor | code |
| Security-sensitive / auth / trust boundaries | Security Auditor, Threat Modeler, Red Teamer | code |
| Database / migrations / queries | Data Integrity Auditor, Query Planner, Regression Hunter | data-api |
| Caching | Stale Cache Hunter, Query Planner | data-api |
| API / contract changes | Contract Breaker, Integration Skeptic, Regression Hunter | data-api |
| External integrations / resilience | Integration Skeptic, Chaos Engineer, Error-Path Auditor | data-api |
| Performance-critical path | Load Tester, Chaos Engineer, Concurrency Specialist | data-api |
| Frontend / UI components | Confused User, Accessibility Critic, HIG Auditor | ux |
| Visual layout / hierarchy | Gestalt Grouper, Affordance Skeptic, Typesetter | ux / content |
| Navigation / link structure | Scent Tracker, First-Click Saboteur, User-Flow Analyst | ux |
| Perceived performance / responsiveness | Latency Cynic, Confused User | ux |
| Signup / checkout / conversion flows | Trust Auditor, Dark-Pattern Hunter, User-Flow Analyst | ux |
| Ethics / consent / harm / fairness | Ethicist, Dark-Pattern Hunter, Inclusion Auditor | ux / content |
| Multi-step UX / onboarding | User-Flow Analyst, First-Click Saboteur, Lost Reader | ux |
| Written content / docs / copy | Proofreader, Grammarian, Line Editor, Lost Reader | content |
| Marketing / landing-page copy | Claims Skeptic, Brand-Voice Enforcer, SEO/Discoverability Critic | content |
| Factual / data-cited content | Fact-Checker, Claims Skeptic | content |
| Readability / plain language | Plain-Language Auditor, Lost Reader | content |
| Inclusive / global content | Inclusion Auditor, Localization Adversary | content |
| Document structure / organization | Information Architect, Typesetter | content |

## Domain files

- **[personas-code.md](personas-code.md)** — General code (Saboteur, New Hire, Security Auditor), code quality (Nitpicker, Dead Code Hunter, Type Pedant), reliability (Regression Hunter, Concurrency Specialist, Resource Accountant, Error-Path Auditor, Second-Order Thinker), tests (Test Skeptic, Mutant, Invariant Hunter), operability (Observability Critic, Misconfiguration Hunter, Dependency Auditor), security specialists (Threat Modeler, Red Teamer)
- **[personas-data-api.md](personas-data-api.md)** — Data (Data Integrity Auditor, Stale Cache Hunter, Query Planner), API (Contract Breaker, Integration Skeptic), performance/resilience (Load Tester, Chaos Engineer)
- **[personas-ux.md](personas-ux.md)** — Confused User, Accessibility Critic, HIG Auditor, First-Click Saboteur, Scent Tracker, Affordance Skeptic, Gestalt Grouper, Latency Cynic, Trust Auditor, Dark-Pattern Hunter, Ethicist, User-Flow Analyst
- **[personas-content.md](personas-content.md)** — Proofreader, Grammarian, Line Editor, Humanizer, Fact-Checker, Claims Skeptic, Brand-Voice Enforcer, Plain-Language Auditor, Inclusion Auditor, Localization Adversary, SEO/Discoverability Critic, Typesetter, Information Architect, Lost Reader

## Composing a New Persona

If no preset fits a critical dimension of the change, construct one using this template (and add it to the relevant domain file so the library grows):

```
### The [Name]
**Mindset:** "[Single sentence: who am I and what am I trying to find/break/prove?]"
**Priorities:** [5–7 specific things this persona looks hardest at]
**Process:** [3–5 concrete questions or steps the persona runs through]
**Best used when:** [Change types this persona fits]
```

Keep the mindset adversarial — the persona should be looking for failure, not trying to validate the work.
