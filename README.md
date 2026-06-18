# skill-arsenal

A curated collection of reusable Agent skills organized by category.


## Featured skills
<details>
<summary>**[mastermind](skills/engineering/mastermind/)** — End-to-end workflow conductor. Takes any non-trivial task from raw problem to verified, reviewed completion without you having to orchestrate anything manually.  
**If you only install one skill, make it this one.**
</summary>

It chains the best skills in this repo into one seamless workflow:

1. **Interview** — understands the real goal, constraints, and definition of done before touching any code
2. **Fusion-reasoning** — fans out independent agents to stress-test solution approaches and converge on the right one
3. **Task-plan-architect** — builds a mapped, ordered implementation plan
4. **Planrunner** — executes the plan with token-efficient orchestration
5. **Completion audit** — independently confirms every tasked item was actually done
6. **Adversarial review** — hostile correctness, security, and edge-case pass

Three checkpoints keep you in control (confirm-understanding, confirm-plan, present-verification). Everything between checkpoints runs autonomously. Installing Mastermind also installs all dependent skills automatically.

---
</details>

<details>
<summary>**[spec-docs-generator](skills/engineering/spec-docs-generator/)** — Generate or update a numbered spec-document set as your project's source of truth</summary>

Generates or updates a numbered spec-document set that becomes the source of truth an agent obeys when writing code.

**Produces:**
- `docs/00-index.md` — router index
- `docs/NN-topic.md` — numbered spec files (100–400 lines each)
- `docs/decisions/` — Architecture Decision Records (ADRs)

Detects existing specs, diffs them against the code, and fixes drift. ADRs are append-only — new ones supersede old ones, never deleted. Conflict resolution happens before writing.

Best paired with `code-quality-checklist`: once specs are generated, the checklist uses them as the authoritative source of conventions for every future implementation task.

</details>


<details>
<summary>**[code-quality-checklist](skills/engineering/code-quality-checklist/)** — Pre/during/post-task quality guardrail that adapts to your project's own specs</summary>

Pre/during/post-task quality guardrail — surfaces assumptions before coding, enforces triggered workflows during work, and runs full verification before marking done.

**Stages:**
1. Pre-task — surface assumptions, clarify scope, read project-rules.md
2. During — run triggered workflows (schema changes, UI changes, API changes)
3. Post-task — run scripts/verify.sh; self-review before handoff

Silent by default — fixes issues without listing them. Reads project-specific rules from `references/project-rules.md`. When `docs/00-index.md` exists, reads the relevant spec files as the authoritative source of conventions.

Best paired with `spec-docs-generator`: once specs exist, this skill enforces them automatically.

</details>

## All Skills

### Engineering

<details>
<summary>**[adversarial-review](skills/engineering/adversarial-review/)** — Three hostile personas tear your code apart before it ships</summary>

Adversarial code review that breaks the self-review monoculture — three hostile personas must each find at least one issue.

**Personas:**
1. Saboteur — hunts for production failures and logic errors
2. New Hire — flags unclear code, missing docs, and maintainability traps
3. Security Auditor — looks for vulnerabilities, auth gaps, and data exposure

Findings are deduplicated and severity-promoted when multiple personas catch the same issue. Delivers a structured BLOCK / CONCERNS / CLEAN verdict with exact file:line citations and paste-ready comments.

</details>


<details>
<summary>**[task-plan-architect](skills/engineering/task-plan-architect/)** — Research a large task and produce a mapped implementation plan any model can execute</summary>

Research a large task and produce a mapped implementation plan a smaller model can execute without losing the big picture.

**Produces:**
1. `00-overview.md` — goal, scope, and success criteria
2. `01-map.md` — parts, connections, contracts, and invariants
3. `02-roadmap.md` — ordered workloads and dependency graph
4. `tasks/NNN-slug.md` — self-contained, map-linked task files

Every task links back to the map so a context-limited executor knows what it connects to and must not break. Saves the plan outside the repo by default.

</details>

<details>
<summary>**[planrunner](skills/engineering/planrunner/)** — Orchestrator-driven execution of an approved implementation plan</summary>

Orchestrator-driven execution of an approved implementation plan — slices the work, delegates each slice to implementer subagents, verifies against intent, and runs adversarial review rounds.

**Execution loop:**
1. Green gate — tests, lint, and typecheck pass before review
2. Slice → delegate → verify — each slice checked against the plan's acceptance criteria
3. Adversarial review — up to 3 rounds fixing real blockers
4. Re-verify after each fix round

Consumes task-plan-architect output directly. File-collision guard prevents parallel slices from conflicting.

</details>

<details>
<summary>**[tdd](skills/engineering/tdd/)** — Enforces red → green → refactor for every new behavior or bug fix</summary>

Enforces the red → green → refactor TDD cycle for every new behavior or bug fix — no shortcuts.

**Cycle:**
1. Red — write a failing test that expresses the desired contract
2. Green — write the minimum code to make it pass
3. Refactor — clean up duplication and naming without breaking the test

Every failure must be for the right reason (not a setup error). Every implementation must be minimal — no over-engineering to anticipate future needs.

</details>

<details>
<summary>**[pr-review](skills/engineering/pr-review/)** — Reviews a GitHub PR for real blocking problems nobody has flagged yet</summary>

Reviews a GitHub PR for real blocking problems nobody has flagged yet — verified against the actual code before reporting.

**Checks for:**
- Correctness bugs and logic errors
- Security gaps and auth issues
- Broken contracts and data races
- Unmet acceptance criteria from the linked ticket

Reads files by ref (not checkout) to avoid corrupting local state. Returns APPROVE or REQUEST CHANGES with exact file:line citations and paste-ready comments. Never posts to GitHub on its own.

</details>

<details>
<summary>**[code-audit-planner](skills/engineering/code-audit-planner/)** — Audits a codebase across quality dimensions and produces an ordered implementation plan</summary>

Audits a codebase across many quality dimensions and produces a self-contained implementation-plan folder of ordered, verifiable tasks.

**Audit dimensions:**
- DRY/reuse and code organization
- Logic errors and test quality
- UX and responsive design
- Spec drift (code vs. spec gaps)
- Theming and accessibility

Fans reading out to light agents in parallel; writes numbered task files with exact acceptance criteria so a future agent can execute each independently. Plans only — never edits source.

</details>

<details>
<summary>**[frontend-code-layout](skills/engineering/frontend-code-layout/)** — Keep structure, styling, and behavior separable so the look can swap without rewrites</summary>

Keeps frontend code's structure, styling, and behavior separable so the look can swap without rewriting components.

**Core principles:**
1. Semantic tokens named by role (`--color-primary`) not value (`--blue-500`) — all in one file
2. Model/View/Presenter layering — data/logic separate from markup
3. View components are pure functions of props — renderable in tests with no side effects

To rebrand: only the token file changes. Color is never the sole signal for accessibility.

</details>

<details>
<summary>**[modern-web-guidance](skills/engineering/modern-web-guidance/)** — Curated modern web-platform patterns so Claude uses the platform instead of heavy deps</summary>

Searches a curated database of standardized modern web-platform patterns before writing any browser code — so Claude uses the platform instead of heavy dependencies or ad-hoc solutions.

**Covers:**
- Layout: container queries, `:has()`, subgrid
- Motion: View Transitions, scroll-driven animations
- Performance: LCP, Core Web Vitals, INP
- Platform APIs: anchor positioning, Popover API
- Accessibility and forms

Search first, then retrieve the full guide. Patterns default to Baseline Widely Available — safe across modern browsers.

</details>

<details>
<summary>**[codex](skills/engineering/codex/)** — Bounded implementation worker rules for handing off tasks to Codex</summary>

Bounded implementation worker rules for handing off tasks to Codex — enforces scope discipline, handoff checklist, and Studio 2.0 state conventions.

**Key rules:**
- Follow the prompt exactly before expanding scope
- Never modify files outside the task's scope
- Keep durable state in SQLite, not state.json
- Run git status before handoff; remove scratch files

Handoff always includes: changed files, tests run, pass/fail result, remaining risks, and artifacts left behind.

</details>

<details>
<summary>**[worker](skills/engineering/worker/)** — Cursor task orchestrator: decompose, dispatch to Haiku subagents, review, fix, report</summary>

Cursor task orchestrator — decomposes a task JSON into focused slices, dispatches each to Haiku subagents in parallel, adversarially reviews their output, fixes blockers, and returns a clean report.

**Execution loop:**
1. Parse task JSON and project rules
2. Decompose into independent slices
3. Dispatch each slice to Haiku with tight context
4. Adversarially review every return (max 3 fix rounds per slice)
5. Run full verification; report pass/fail honestly

You (the large model) are the orchestrator and quality gate — workers are cheap execution.

</details>

---

### Design

<details>
<summary>**[design-review-loop](skills/design/design-review-loop/)** — Iterative multi-agent design review loop: screenshot → review → build → repeat until scores clear</summary>

Iterative multi-agent design review loop — captures live screenshots, fans out specialist reviewers, synthesizes findings, builds the changes, and repeats until quality scores clear a threshold.

**Reviewers (run in parallel):**
1. General UX — usability and information hierarchy
2. UI Craft — visual polish and consistency
3. Apple HIG — platform convention compliance
4. Design System — token and component conformance
5. Accessibility — contrast, focus, ARIA

Tracks scores per dimension round-over-round. Escalates genuine reviewer disagreements to the user.

</details>

---

### Productivity

<details>
<summary>**[fusion-reasoning](skills/productivity/fusion-reasoning/)** — Panel of independent agents cross-examine, a judge synthesizes one answer that beats any single pass</summary>

Reasoning amplifier — runs an adaptive panel of independent agents from different angles, optionally cross-examines, and a judge synthesizes one answer that beats any single pass.

**How it works:**
1. Frame the problem and design a panel with distinct angles
2. Dispatch panel agents in parallel (independently, no cross-talk)
3. Optionally run a cross-examination reaction pass
4. Judge synthesizes consensus, resolves contradictions, surfaces blind spots

Panel size adapts to difficulty: 2 agents for light tasks, 3 for standard, 3–5 with cross-examination for hard problems.

</details>

<details>
<summary>**[efficient-orchestration](skills/productivity/efficient-orchestration/)** — Always-on token-efficiency model: delegate mechanical work to the smallest capable model</summary>

Always-on token-efficiency operating model — for every non-trivial task, decide inline vs. delegate to cheaper subagents, then monitor spend and checkpoint when work reclassifies.

**Delegation tiers:**
- Light (Haiku-class) — reading, grepping, listing, mechanical work
- Mid (Sonnet-class) — bounded judgment and implementation
- Top (Opus-class) — synthesis, cross-cutting review, high-stakes decisions

The large model holds strategy and verification; mechanical work fans out to the smallest capable model. Never spend a bigger model than the job needs.

</details>

---

### Content

<details>
<summary>**[humanizer](skills/content/humanizer/)** — Strip AI-writing signals from text while preserving specific detail and natural rhythm</summary>

Removes signs of AI-generated writing from text — based on Wikipedia's "Signs of AI writing" guide.

**Detects and fixes:**
- Inflated symbolism and promotional language
- Em dash overuse (zero allowed in final output)
- Rule of three and -ing padding
- AI vocabulary (delve, tapestry, showcase, etc.)
- Passive voice and negative parallelisms

Optionally voice-matches against a writing sample. Preserves specific detail, unresolved tension, and natural rhythm — the signals that make writing sound human.

</details>

<details>
<summary>**[comedy-writers-room](skills/content/comedy-writers-room/)** — One writer, three audience personas reacting in series — material iterates on real feedback</summary>

Write stand-up comedy, jokes, or humorous material — one subagent writes while three audience personas react, and the material iterates based on synthesized feedback.

**Audience personas:**
1. Enthusiast — what landed and why
2. Skeptic — what fell flat and why
3. Overthinker — finds unintended interpretations

Personas react in series so each reaction is visible. Synthesizes feedback and sends back to the writer for revision. Final output includes a summary of what got cut and what emerged.

</details>

<details>
<summary>**[gen-alpha-style](skills/content/gen-alpha-style/)** — Transform any output into Gen Alpha / brainrot internet slang (code blocks stay clean)</summary>

Transforms all explanatory text into Gen Alpha / brainrot internet slang while preserving code blocks, commands, and variable names exactly as written.

**Applies:**
- Vocabulary: no cap, fr fr, bussin, lowkey, rizz, gyatt, slay, etc.
- 3–5+ slang terms per paragraph
- Three intensity levels: light, moderate, full brainrot (default)

Code blocks stay clean and valid. Error messages get dramatic interpretation; success messages celebrate with hype. Configure intensity via `.claude/gen-alpha-output-style.local.md`.

</details>

---

### Automation

<details>
<summary>**[pinokio](skills/automation/pinokio/)** — Discover, launch, and use Pinokio-managed apps via the pterm CLI</summary>

Discovers, launches, and uses Pinokio-managed apps and tools via the pterm CLI control plane.

**Workflow:**
1. Search for the app (`pterm search`)
2. If not found, optionally search the registry with user approval
3. Launch and poll until ready (`pterm run <ref>`)
4. Use the app's HTTP API — direct call or generated client

Creates a reusable skill folder with SKILL.md and client code for the app. Supports parallel launch for multiple apps. Never hardcodes paths, ports, or tokens in client files.

</details>

<details>
<summary>**[gepeto](skills/automation/gepeto/)** — Development guide for building consistent, debuggable Pinokio launcher projects</summary>

Development guide for building Pinokio launcher projects — enforces a mandatory workflow and pattern-lock rules so launchers are consistent and debuggable.

**Mandatory before any edits:**
1. Check the examples folder — never invent syntax
2. Run pre-flight and mid-task verification steps
3. Use relative paths in scripts, never absolute
4. Store captured web URLs with `local.set` via the example's regex capture block

Supports app launchers (`api/<name>`) and plugin launchers (`plugin/<name>`). Check logs folder first when troubleshooting.

</details>

---

> **Attribution.** Some skills are third-party, included here for easy reference and kept under their original licenses: **humanizer** by [Siqi Chen](https://github.com/blader/humanizer) (MIT), **comedy-writers-room** by [Tal Raviv](https://github.com/talsraviv/comedy-writers-room). Original LICENSE/README files are preserved inside each skill directory.

---

## Contributing

1. Fork this repo
2. Create your skill under `skills/<category>/<name>/` following the structure above
3. Add `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, and `skills/<name>/SKILL.md`
4. Add plugin entries to the root `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`
5. Open a PR — category is confirmed in review

The authoring spec — exact manifest fields, required vs optional, and gotchas — lives in [CLAUDE.md](CLAUDE.md).

---

<details id="agent-install-instructions">
<summary>For AI agents: Skill Arsenal Manager</summary>

## Skill: skill-arsenal-manager

**Invoke when** a user points you at this URL or README and asks to install, manage, browse, or update skills from the skill-arsenal. Treat this section as a runnable skill — follow these steps exactly.

---

### Step 1 — Detect installed skills

Check your platform's skill location (e.g. `~/.claude/skills/`, `~/.gemini/config/skills/`, `.agents/skills/`, or your equivalent) for any folders whose names match skills listed in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json). Build two lists: **installed** and **not installed**.

If your platform has a native command to list installed skills (e.g. `/plugin list`), use that instead.

---

### Step 2 — Present the skill dashboard

Show the user a status table of **all skills**, organized by category. For each skill, show its name, a one-line description, whether it's installed, and whether it's in the recommended defaults ([`.claude-plugin/defaults.json`](.claude-plugin/defaults.json)).

Example format:

```
Engineering
  ✅ mastermind          End-to-end workflow conductor                    [default]
  ✅ adversarial-review  Three hostile personas tear your code apart      [default]
  ❌ codex               Bounded worker rules for Codex handoffs
  ❌ worker              Cursor task orchestrator (Haiku subagents)

Productivity
  ✅ fusion-reasoning    Panel of agents, judge synthesizes one answer    [default]
  ...
```

---

### Step 3 — Prompt the user

After showing the dashboard, present these options:

> **What would you like to do?**
> 1. Install recommended defaults (skills marked [default] that aren't installed yet)
> 2. Install all skills
> 3. Install specific skills — tell me which ones
> 4. Uninstall a skill — tell me which one
> 5. Nothing, just wanted to see what's here

If **all defaults are already installed**, lead with that and skip option 1.

If the user said "install skill-arsenal" or "set this up" without specifying further, **proceed with option 1 automatically** — install the defaults, then report what was done.

---

### Step 4 — Install skills

To install a skill:

1. **Get the repo** if not already local — clone it or use your platform's native marketplace command:
   ```bash
   git clone https://github.com/senigami/skill-arsenal.git
   ```
   Prefer native commands (`/plugin marketplace add senigami/skill-arsenal`, `codex plugin marketplace add senigami/skill-arsenal`, etc.) if your platform supports them.

2. **Locate the skill** in the repo: `skills/<category>/<name>/skills/<name>/` — that inner folder contains `SKILL.md` and any `references/`. To find the category for a skill name, read its `"source"` field in `marketplace.json`.

3. **Resolve dependencies**: read the skill's `SKILL.md` for a `## Requirements` section. If it lists other skill-arsenal skills, install those first (recursively). Mastermind in particular has a spine of dependencies — install them so it works fully.

4. **Copy or symlink** the inner `skills/<name>/` folder into your platform's skill location. Use whichever mechanism (copy vs. symlink, global vs. workspace) matches your platform's norms.

---

### Step 5 — Uninstall skills

To uninstall a skill, reverse whatever installation method was used:
- If installed via a native marketplace command, use the corresponding remove command (e.g. `/plugin remove <name>`, `codex plugin remove <name>`)
- If installed by copying to a skills folder, delete that folder from the skill location

You know your own platform's conventions — use the right uninstall mechanism for how the skill was installed.

---

### Step 6 — Confirm and report

Tell the user:
- Which skills were installed or uninstalled
- Any dependencies that were pulled in automatically
- How to invoke each installed skill (e.g. `/mastermind`, `/adversarial-review`)
- Whether they need to restart or start a new session for changes to take effect

</details>
