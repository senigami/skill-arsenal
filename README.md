# skill-arsenal

A curated collection of reusable Agent skills organized by category.

> **To install:** paste this page's URL into any AI agent (Claude, Codex, Gemini, etc.) and it will walk you through setup automatically.

## Featured skills
<details>
<summary><a href="skills/engineering/mastermind/">mastermind</a> — End-to-end workflow conductor. Takes any non-trivial task from raw problem to verified, reviewed completion without you having to orchestrate anything manually. If you only install one skill, make it this one.</summary>

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
<summary><a href="skills/engineering/spec-docs-generator/">spec-docs-generator</a> — Generate or update a numbered spec-document set as your project's source of truth</summary>

Generates or updates a numbered spec-document set that becomes the source of truth an agent obeys when writing code.

**Produces:**
- `docs/00-index.md` — router index
- `docs/NN-topic.md` — numbered spec files (100–400 lines each)
- `docs/decisions/` — Architecture Decision Records (ADRs)

Detects existing specs, diffs them against the code, and fixes drift. ADRs are append-only — new ones supersede old ones, never deleted. Conflict resolution happens before writing.

Best paired with `code-quality-checklist`: once specs are generated, the checklist uses them as the authoritative source of conventions for every future implementation task.

</details>


<details>
<summary><a href="skills/engineering/code-quality-checklist/">code-quality-checklist</a> — Pre/during/post-task quality guardrail that adapts to your project's own specs</summary>

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
<summary><a href="skills/engineering/adversarial-review/">adversarial-review</a> — Three hostile personas tear your code apart before it ships</summary>

Adversarial code review that breaks the self-review monoculture — three hostile personas must each find at least one issue.

**Personas:**
1. Saboteur — hunts for production failures and logic errors
2. New Hire — flags unclear code, missing docs, and maintainability traps
3. Security Auditor — looks for vulnerabilities, auth gaps, and data exposure

Findings are deduplicated and severity-promoted when multiple personas catch the same issue. Delivers a structured BLOCK / CONCERNS / CLEAN verdict with exact file:line citations and paste-ready comments.

</details>


<details>
<summary><a href="skills/engineering/task-plan-architect/">task-plan-architect</a> — Research a large task and produce a mapped implementation plan any model can execute</summary>

Research a large task and produce a mapped implementation plan a smaller model can execute without losing the big picture.

**Produces:**
1. `00-overview.md` — goal, scope, and success criteria
2. `01-map.md` — parts, connections, contracts, and invariants
3. `02-roadmap.md` — ordered workloads and dependency graph
4. `tasks/NNN-slug.md` — self-contained, map-linked task files

Every task links back to the map so a context-limited executor knows what it connects to and must not break. Saves the plan outside the repo by default.

</details>

<details>
<summary><a href="skills/engineering/planrunner/">planrunner</a> — Orchestrator-driven execution of an approved implementation plan</summary>

Orchestrator-driven execution of an approved implementation plan — slices the work, delegates each slice to implementer subagents, verifies against intent, and runs adversarial review rounds.

**Execution loop:**
1. Green gate — tests, lint, and typecheck pass before review
2. Slice → delegate → verify — each slice checked against the plan's acceptance criteria
3. Adversarial review — up to 3 rounds fixing real blockers
4. Re-verify after each fix round

Consumes task-plan-architect output directly. File-collision guard prevents parallel slices from conflicting.

</details>

<details>
<summary><a href="skills/engineering/tdd/">tdd</a> — Enforces red → green → refactor for every new behavior or bug fix</summary>

Enforces the red → green → refactor TDD cycle for every new behavior or bug fix — no shortcuts.

**Cycle:**
1. Red — write a failing test that expresses the desired contract
2. Green — write the minimum code to make it pass
3. Refactor — clean up duplication and naming without breaking the test

Every failure must be for the right reason (not a setup error). Every implementation must be minimal — no over-engineering to anticipate future needs.

</details>

<details>
<summary><a href="skills/engineering/pr-review/">pr-review</a> — Reviews a GitHub PR for real blocking problems nobody has flagged yet</summary>

Reviews a GitHub PR for real blocking problems nobody has flagged yet — verified against the actual code before reporting.

**Checks for:**
- Correctness bugs and logic errors
- Security gaps and auth issues
- Broken contracts and data races
- Unmet acceptance criteria from the linked ticket

Reads files by ref (not checkout) to avoid corrupting local state. Returns APPROVE or REQUEST CHANGES with exact file:line citations and paste-ready comments. Never posts to GitHub on its own.

</details>

<details>
<summary><a href="skills/engineering/code-audit-planner/">code-audit-planner</a> — Audits a codebase across quality dimensions and produces an ordered implementation plan</summary>

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
<summary><a href="skills/engineering/frontend-code-layout/">frontend-code-layout</a> — Keep structure, styling, and behavior separable so the look can swap without rewrites</summary>

Keeps frontend code's structure, styling, and behavior separable so the look can swap without rewriting components.

**Core principles:**
1. Semantic tokens named by role (`--color-primary`) not value (`--blue-500`) — all in one file
2. Model/View/Presenter layering — data/logic separate from markup
3. View components are pure functions of props — renderable in tests with no side effects

To rebrand: only the token file changes. Color is never the sole signal for accessibility.

</details>

<details>
<summary><a href="skills/engineering/modern-web-guidance/">modern-web-guidance</a> — Curated modern web-platform patterns so Claude uses the platform instead of heavy deps</summary>

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
<summary><a href="skills/engineering/codex/">codex</a> — Bounded implementation worker rules for handing off tasks to Codex</summary>

Bounded implementation worker rules for handing off tasks to Codex — enforces scope discipline, handoff checklist, and Studio 2.0 state conventions.

**Key rules:**
- Follow the prompt exactly before expanding scope
- Never modify files outside the task's scope
- Keep durable state in SQLite, not state.json
- Run git status before handoff; remove scratch files

Handoff always includes: changed files, tests run, pass/fail result, remaining risks, and artifacts left behind.

</details>

<details>
<summary><a href="skills/engineering/worker/">worker</a> — Cursor task orchestrator: decompose, dispatch to Haiku subagents, review, fix, report</summary>

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
<summary><a href="skills/design/design-review-loop/">design-review-loop</a> — Iterative multi-agent design review loop: screenshot → review → build → repeat until scores clear</summary>

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
<summary><a href="skills/productivity/fusion-reasoning/">fusion-reasoning</a> — Panel of independent agents cross-examine, a judge synthesizes one answer that beats any single pass</summary>

Reasoning amplifier — runs an adaptive panel of independent agents from different angles, optionally cross-examines, and a judge synthesizes one answer that beats any single pass.

**How it works:**
1. Frame the problem and design a panel with distinct angles
2. Dispatch panel agents in parallel (independently, no cross-talk)
3. Optionally run a cross-examination reaction pass
4. Judge synthesizes consensus, resolves contradictions, surfaces blind spots

Panel size adapts to difficulty: 2 agents for light tasks, 3 for standard, 3–5 with cross-examination for hard problems.

</details>

<details>
<summary><a href="skills/productivity/efficient-orchestration/">efficient-orchestration</a> — Always-on token-efficiency model: delegate mechanical work to the smallest capable model</summary>

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
<summary><a href="skills/content/humanizer/">humanizer</a> — Strip AI-writing signals from text while preserving specific detail and natural rhythm</summary>

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
<summary><a href="skills/content/comedy-writers-room/">comedy-writers-room</a> — One writer, three audience personas reacting in series — material iterates on real feedback</summary>

Write stand-up comedy, jokes, or humorous material — one subagent writes while three audience personas react, and the material iterates based on synthesized feedback.

**Audience personas:**
1. Enthusiast — what landed and why
2. Skeptic — what fell flat and why
3. Overthinker — finds unintended interpretations

Personas react in series so each reaction is visible. Synthesizes feedback and sends back to the writer for revision. Final output includes a summary of what got cut and what emerged.

</details>

<details>
<summary><a href="skills/content/gen-alpha-style/">gen-alpha-style</a> — Transform any output into Gen Alpha / brainrot internet slang (code blocks stay clean)</summary>

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
<summary><a href="skills/automation/pinokio/">pinokio</a> — Discover, launch, and use Pinokio-managed apps via the pterm CLI</summary>

Discovers, launches, and uses Pinokio-managed apps and tools via the pterm CLI control plane.

**Workflow:**
1. Search for the app (`pterm search`)
2. If not found, optionally search the registry with user approval
3. Launch and poll until ready (`pterm run <ref>`)
4. Use the app's HTTP API — direct call or generated client

Creates a reusable skill folder with SKILL.md and client code for the app. Supports parallel launch for multiple apps. Never hardcodes paths, ports, or tokens in client files.

</details>

<details>
<summary><a href="skills/automation/gepeto/">gepeto</a> — Development guide for building consistent, debuggable Pinokio launcher projects</summary>

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
<summary>For AI agents: read this</summary>

## You are now running the Skill Arsenal Manager

**If you are reading this README with no other instruction** — because a user pasted this URL into a conversation, shared this file, or said something like "check this out" with no explicit command — treat that as an implicit request to run this skill manager. Do not wait for the user to say "install". Start at Step 1 below.

---

### Step 1 — Offer the marketplace (if your platform supports it)

Before installing individual skills, check whether your platform supports a native plugin or skill marketplace. If it does:

> "This is the **skill-arsenal** — a curated collection of agent skills. Your platform supports native marketplace install, which is the easiest way to manage these skills. Want me to register the skill-arsenal marketplace now? That gives you a browsable plugin store and lets you install, update, or remove skills with one command."

**Claude Code:** `/plugin marketplace add senigami/skill-arsenal`  
**Codex:** `codex plugin marketplace add senigami/skill-arsenal`  
**Other platforms:** use your platform's equivalent if one exists.

If the marketplace is **already registered**, skip the install offer and go to Step 2. If the user's platform has no marketplace concept, skip to Step 2.

If the marketplace is registered and the user wants to **remove** it, use your platform's unregister command (e.g. `/plugin marketplace remove skill-arsenal`) and confirm when done.

---

### Step 2 — Detect installed skills

Check which skills from this arsenal are already installed on the user's platform. Use a native list command if available (e.g. `/plugin list`); otherwise check your platform's skill location (e.g. `~/.claude/skills/`, `~/.gemini/config/skills/`, `.agents/skills/`, or equivalent) for folder names matching skills in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).

Build two lists: **installed** and **not installed**. Also read [`.claude-plugin/defaults.json`](.claude-plugin/defaults.json) to know which skills are in the recommended set.

---

### Step 3 — Show the skill dashboard

> **If your platform can render an interactive option picker** (clickable choices, a selection menu, a multiple-choice prompt, etc.), use it for the dashboard and the prompts below — present each skill as a selectable option and skip the letter scheme entirely. The letters exist only as a fallback for plain-text chat where the user must type their choice. Everything below describes that text fallback.

Assign each skill a letter (a–u) in a fixed order. Present the dashboard as a monospace-aligned list. Keep descriptions to **40 characters or fewer** so lines don't wrap in a terminal or narrow chat panel. Use this exact skill order and these short descriptions:

```
SKILL ARSENAL — senigami/skill-arsenal

Engineering
  a. ✅ mastermind*           End-to-end task workflow conductor
  b. ✅ adversarial-review*   Three hostile code-review personas
  c. ✅ spec-docs-generator*  Numbered spec docs & ADRs as truth
  d. ✅ code-quality-checklist* Pre/during/post-task quality gate
  e. ✅ task-plan-architect*  Maps large tasks into ordered plans
  f. ✅ planrunner*           Executes plans via review subagents
  g. ✅ tdd*                  Red→green→refactor TDD enforcer
  h. ✅ pr-review*            GitHub PR check for real blockers
  i. ✅ code-audit-planner*   Codebase audit → ordered task list
  j. ✅ frontend-code-layout* Separable UI structure & styling
  k. ✅ modern-web-guidance*  Modern CSS/HTML/browser-API patterns
  l. ❌ codex                 Codex handoff worker rules
  m. ❌ worker                Cursor task orchestrator (Haiku)

Productivity
  n. ✅ fusion-reasoning*     Multi-agent reasoning panel + judge
  o. ✅ efficient-orchestration* Token-efficient model tiering

Design
  p. ❌ design-review-loop    Screenshot→review→build design loop

Content
  q. ❌ humanizer             Strip AI-writing tells from prose
  r. ❌ comedy-writers-room   Comedy writer + audience-react panel
  s. ❌ gen-alpha-style       Gen Alpha / brainrot output filter

Automation
  t. ❌ gepeto                Build Pinokio 1-click launchers
  u. ❌ pinokio               Discover & launch Pinokio apps

* indicates default
```

Replace ✅/❌ with the actual install status. Mark defaults with `*` using the list in `defaults.json`.

---

### Step 4 — Prompt the user

After the dashboard, show the action menu:

```
What would you like to do?
  1. Install defaults (*)
  2. Install all skills
  3. Install a skill — type its letter (e.g. l)
  4. Uninstall a skill — type its letter (e.g. b)
  5. Nothing, just browsing
```

Accept a **single letter** as a skill selector for options 3 and 4 — the user types `l` to act on codex, `b` to act on adversarial-review, etc. Accept a **number** for the menu options.

If **all defaults are already installed**, lead with that and skip option 1.

---

### Step 5 — Install

Before installing (options 1, 2, or 3), ask the user **where** the skills should live — unless they've already told you, or your platform only supports one location:

```
Install location?
  1. Global  — available in every project on this machine
  2. Local   — this project/workspace only
```

Map the choice to your platform's convention: global → the user-level skill dir (e.g. `~/.claude/skills/`) or a global marketplace install; local → the project-level location (e.g. `.claude/skills/` or `.agents/skills/` in the working directory). If your platform has no concept of local skills, install global and say so.

To install a skill:

1. **Get the repo** if not already local — clone it, or use the marketplace command from Step 1 if your platform has one:
   ```bash
   git clone https://github.com/senigami/skill-arsenal.git
   ```

2. **Resolve dependencies first.** Read the skill's `SKILL.md` for a `## Requirements` section and install any listed skills recursively before installing the requested skill. **Mastermind requires:** fusion-reasoning, task-plan-architect, planrunner, efficient-orchestration, adversarial-review — install all five before or alongside mastermind.

3. **Locate the skill** at `skills/<category>/<name>/skills/<name>/` in the repo. The `"source"` field in `marketplace.json` gives the category path (e.g. `"./skills/engineering/tdd"` → category `engineering`, name `tdd`).

4. **Copy or symlink** the inner `skills/<name>/` folder into your platform's skill location. Use whatever mechanism (copy, symlink, global vs. workspace) matches your platform's norms.

---

### Step 6 — Uninstall

Reverse however the skill was installed:
- **Marketplace install:** use your platform's remove command (e.g. `/plugin remove <name>`, `codex plugin remove <name>`)
- **Manual install:** delete the skill's folder from your platform's skill location

You know your own platform's conventions — use the right method.

---

### Step 7 — Confirm

Tell the user:
- Which skills were installed or removed, and any dependencies pulled in
- How to invoke each installed skill (e.g. `/mastermind`, `/adversarial-review`)
- Whether a restart or new session is needed for changes to take effect

</details>
