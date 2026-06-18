# skill-arsenal

A curated collection of reusable Agent skills organized by category.


## Featured skills

<details>
<summary>**[Mastermind](skills/engineering/mastermind/)** is the flagship skill of this arsenal — a single command that takes any non-trivial task from raw problem to verified, reviewed completion without you having to orchestrate anything manually.  
**If you only install one skill, make it this one.**
</summary>

It chains the best skills in this repo into one seamless workflow:

1. **Interview** — understands the real goal, constraints, and definition of done before touching any code
2. **Fusion-reasoning** — fans out independent agents to stress-test solution approaches and converge on the right one
3. **Task-plan-architect** — builds a mapped, ordered implementation plan
4. **Planrunner** — executes the plan with token-efficient orchestration
5. **Completion audit** — independently confirms every tasked item was actually done
6. **Adversarial review** — hostile correctness, security, and edge-case pass

Three checkpoints keep you in control (confirm-understanding, confirm-plan, present-verification). Everything between checkpoints runs autonomously. Installing Mastermind also installs all five dependent skills automatically.

---
</details>

<details>
<summary>**[Spec Docs Generator](skills/engineering/spec-docs-generator/)** builds a numbered, navigable spec-document set (`docs/00-index.md`, spec files, ADRs) that becomes the project's source of truth — the architecture decisions, data shapes, API contracts, and conventions every agent must follow. Run it once on a new project, then again whenever the codebase drifts from the specs.</summary>

---
</details>

<details>
<summary>**[Code Quality Checklist](skills/engineering/code-quality-checklist/)** uses those specs as its quality bar. Before every task it surfaces assumptions, during work it enforces triggered workflows, and before marking anything done it verifies the implementation matches not just tests but the documented conventions and contracts. When Mastermind is running and this skill is installed, it automatically activates it at each execution slice — pointing it at `docs/00-index.md` so every piece of work is checked against the project's own specs, not just generic quality rules.</summary>
</details>


---

<details>
<summary>**All Skills**</summary>

### Engineering

| Skill | Description |
|-------|-------------|
| [adversarial-review](skills/engineering/adversarial-review/) | Adversarial code review via three hostile personas — Saboteur, New Hire, Security Auditor. BLOCK / CONCERNS / CLEAN verdict. |
| [code-audit-planner](skills/engineering/code-audit-planner/) | Audit a codebase across many dimensions and produce an ordered, verifiable implementation-plan folder. Plans only; never edits source. |
| [task-plan-architect](skills/engineering/task-plan-architect/) | Research a large task and produce a mapped implementation plan a smaller model can execute without losing the big picture. |
| [spec-docs-generator](skills/engineering/spec-docs-generator/) | Generate or update a numbered spec-document set (index, topics, ADRs) as the source of truth an agent obeys, and fix spec drift. |
| [frontend-code-layout](skills/engineering/frontend-code-layout/) | Keep frontend structure, styling, and behavior separable — semantic tokens + Model/View/Presenter layering so the look can swap without rewrites. |
| [pr-review](skills/engineering/pr-review/) | Review a GitHub PR for real, unflagged blockers — verified against the code. Returns APPROVE or confirmed blockers; never posts on its own. |
| [planrunner](skills/engineering/planrunner/) | Orchestrator-driven execution of an approved plan: slice → delegate → verify → adversarial review, fixing real blockers. |
| [modern-web-guidance](skills/engineering/modern-web-guidance/) | Curated database of standardized modern web-platform patterns so Claude uses the platform instead of heavy deps or ad-hoc CSS/JS. |
| [tdd](skills/engineering/tdd/) | Enforce the red → green → refactor TDD cycle for every new behavior or bug fix. |
| [codex](skills/engineering/codex/) | Bounded implementation worker rules for handing off to Codex — scope discipline, handoff checklist, Studio 2.0 conventions. |
| [code-quality-checklist](skills/engineering/code-quality-checklist/) | Pre/during/post-task quality guardrail — surfaces assumptions, enforces triggered workflows, and runs verification before marking done. Adapts to any codebase via project-rules.md. |
| [worker](skills/engineering/worker/) | Cursor task orchestrator — decompose a task JSON into slices, dispatch to Haiku subagents, adversarially review, fix blockers, and return a clean report. |
| [mastermind](skills/engineering/mastermind/) | End-to-end workflow conductor — interview → fusion-reasoning → task-plan-architect → planrunner → completion audit → adversarial review. Gates at confirm-understanding, confirm-plan, and present-verification; loops to root-cause and fix until satisfied. |

### Design

| Skill | Description |
|-------|-------------|
| [design-review-loop](skills/design/design-review-loop/) | Iterative multi-agent design review-and-build loop — screenshot, fan out specialist reviewers, reconcile, build, repeat until scores clear. |

### Productivity

| Skill | Description |
|-------|-------------|
| [fusion-reasoning](skills/productivity/fusion-reasoning/) | Reasoning amplifier — a panel of independent agents cross-examine and a judge synthesizes one answer that beats any single pass. |
| [efficient-orchestration](skills/productivity/efficient-orchestration/) | Always-on token-efficiency operating model: delegate mechanical work to the smallest capable model, monitor spend, checkpoint when deep. |

### Content

| Skill | Description |
|-------|-------------|
| [humanizer](skills/content/humanizer/) | Remove signs of AI-generated writing from text, based on Wikipedia's "Signs of AI writing" guide. |
| [comedy-writers-room](skills/content/comedy-writers-room/) | Write stand-up comedy — one subagent writes jokes while three play audience members reacting to them. |
| [gen-alpha-style](skills/content/gen-alpha-style/) | Gen Alpha / brainrot output-style transformation rules, glossary, and examples. |

### Automation

| Skill | Description |
|-------|-------------|
| [pinokio](skills/automation/pinokio/) | Discover, launch, and use apps and tools for the current task via Pinokio. |
| [gepeto](skills/automation/gepeto/) | Build 1-click launchers and apps with launchers built-in using Pinokio. |

> **Attribution.** Some skills are third-party, included here for easy reference and kept under their original licenses: **humanizer** by [Siqi Chen](https://github.com/blader/humanizer) (MIT), **comedy-writers-room** by [Tal Raviv](https://github.com/talsraviv/comedy-writers-room). Original LICENSE/README files are preserved inside each skill directory.

</details>

---

## Contributing

1. Fork this repo
2. Create your skill under `skills/<category>/<name>/` following the structure above
3. Add `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, and `skills/<name>/SKILL.md`
4. Add plugin entries to the root `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`
5. Validate the Codex manifest:
   ```bash
   python3 /path/to/plugin-creator/scripts/validate_plugin.py skills/<category>/<name>
   ```
6. Open a PR — category is confirmed in review

The authoring spec — exact manifest fields, required vs optional, and gotchas — lives in [CLAUDE.md](CLAUDE.md).

---

<details>
<summary>For AI agents: install instructions</summary>

## Agent install instructions

If a user points you at this README and asks you to install the skill-arsenal (or a specific skill from it), follow these steps. **You know your own platform's conventions** — where skills live, whether you use a plugin marketplace, a skills directory, or symlinks, and what makes a skill discoverable to you. These instructions give you the repo's structure and rules; apply your own platform mechanics to the rest.

### 1. Get the repo locally

If a local clone doesn't already exist, clone it:

```bash
git clone https://github.com/senigami/skill-arsenal.git
```

Put it wherever your platform expects marketplaces/plugins to live (e.g. a Claude Code marketplace dir, a Codex plugins dir, or any working location). If your platform has a native marketplace command (`/plugin marketplace add senigami/skill-arsenal`, `codex plugin marketplace add senigami/skill-arsenal`, etc.), prefer that and skip the manual clone.

### 2. Decide which skills to install

Read [`.claude-plugin/defaults.json`](.claude-plugin/defaults.json). It holds a `"defaults"` array — the curated set installed when the user doesn't name specific skills:

- **"install skill-arsenal" / "set this up"** → install only the skills in `defaults.json`
- **"install [skill name]"** → install that skill, whether or not it's a default
- **"install all skills"** → install everything in [`marketplace.json`](.claude-plugin/marketplace.json)
- **"show me what's available"** → present a table of all skills by category, then ask which they want

### 3. Locate each skill in the repo

Skill definitions live at `skills/<category>/<name>/skills/<name>/` — that inner folder contains `SKILL.md` and any `references/`. To map a skill name to its path, read its `"source"` field in `marketplace.json` (e.g. `"./skills/engineering/tdd"` → category `engineering`, name `tdd`).

### 4. Resolve dependencies

Before installing a skill, read the top of its `SKILL.md` for a `## Requirements` section. If it lists other skill-arsenal skills, install those too (recursively). Mastermind in particular pulls in a spine of skills; install its requirements so it works fully (it degrades gracefully if some are missing).

### 5. Install into your platform's skill location

Copy or symlink the inner `skills/<name>/` folder into wherever your platform loads skills from — for example `~/.claude/skills/<name>/`, `~/.gemini/config/skills/<name>/`, `.agents/skills/<name>/`, or your equivalent. Use whichever mechanism (copy vs. symlink, global vs. workspace) matches the user's request and your platform's norms.

### 6. Confirm and advise

Tell the user which skills were installed (and any dependencies pulled in), how to invoke them (e.g. `/mastermind`), and whether they need to restart or start a new session for the skills to appear.

</details>
