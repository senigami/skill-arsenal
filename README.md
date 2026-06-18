# skill-arsenal

A curated collection of reusable [Claude Code](https://claude.ai/code) and Codex skills organized by category.


## Featured skill — Mastermind

<details>
<summary>**[Mastermind](skills/engineering/mastermind/)** is the flagship skill of this arsenal — a single command that takes any non-trivial task from raw problem to verified, reviewed completion without you having to orchestrate anything manually.</summary>


```
/plugin install mastermind@skill-arsenal
```

It chains the best skills in this repo into one seamless workflow:

1. **Interview** — understands the real goal, constraints, and definition of done before touching any code
2. **Fusion-reasoning** — fans out independent agents to stress-test solution approaches and converge on the right one
3. **Task-plan-architect** — builds a mapped, ordered implementation plan
4. **Planrunner** — executes the plan with token-efficient orchestration
5. **Completion audit** — independently confirms every tasked item was actually done
6. **Adversarial review** — hostile correctness, security, and edge-case pass

Three checkpoints keep you in control (confirm-understanding, confirm-plan, present-verification). Everything between checkpoints runs autonomously. Installing Mastermind also installs all five dependent skills automatically.
</details>

> If you only install one skill, make it this one.

---

## Recommended pair — Spec Docs Generator + Code Quality Checklist

<details>
<summary>For any project where consistency matters, install these two skills together:</summary>

```
/plugin install spec-docs-generator@skill-arsenal
/plugin install code-quality-checklist@skill-arsenal
```

**[Spec Docs Generator](skills/engineering/spec-docs-generator/)** builds a numbered, navigable spec-document set (`docs/00-index.md`, spec files, ADRs) that becomes the project's source of truth — the architecture decisions, data shapes, API contracts, and conventions every agent must follow. Run it once on a new project, then again whenever the codebase drifts from the specs.

**[Code Quality Checklist](skills/engineering/code-quality-checklist/)** uses those specs as its quality bar. Before every task it surfaces assumptions, during work it enforces triggered workflows, and before marking anything done it verifies the implementation matches not just tests but the documented conventions and contracts. When Mastermind is running and this skill is installed, it automatically activates it at each execution slice — pointing it at `docs/00-index.md` so every piece of work is checked against the project's own specs, not just generic quality rules.

Together: the generator captures *what the project is supposed to be*; the checklist enforces *that every future change stays that way* — and Mastermind wires them together automatically with no extra configuration needed.

</details>

---

## Available skills
<details>
<summary>[Show all skills]</summary>

### Engineering

| Skill | Install command | Description |
|-------|----------------|-------------|
| [adversarial-review](skills/engineering/adversarial-review/) | `/plugin install adversarial-review@skill-arsenal` | Adversarial code review via three hostile personas — Saboteur, New Hire, Security Auditor. BLOCK / CONCERNS / CLEAN verdict. |
| [code-audit-planner](skills/engineering/code-audit-planner/) | `/plugin install code-audit-planner@skill-arsenal` | Audit a codebase across many dimensions and produce an ordered, verifiable implementation-plan folder. Plans only; never edits source. |
| [task-plan-architect](skills/engineering/task-plan-architect/) | `/plugin install task-plan-architect@skill-arsenal` | Research a large task and produce a mapped implementation plan a smaller model can execute without losing the big picture. |
| [spec-docs-generator](skills/engineering/spec-docs-generator/) | `/plugin install spec-docs-generator@skill-arsenal` | Generate or update a numbered spec-document set (index, topics, ADRs) as the source of truth an agent obeys, and fix spec drift. |
| [frontend-code-layout](skills/engineering/frontend-code-layout/) | `/plugin install frontend-code-layout@skill-arsenal` | Keep frontend structure, styling, and behavior separable — semantic tokens + Model/View/Presenter layering so the look can swap without rewrites. |
| [pr-review](skills/engineering/pr-review/) | `/plugin install pr-review@skill-arsenal` | Review a GitHub PR for real, unflagged blockers — verified against the code. Returns APPROVE or confirmed blockers; never posts on its own. |
| [planrunner](skills/engineering/planrunner/) | `/plugin install planrunner@skill-arsenal` | Orchestrator-driven execution of an approved plan: slice → delegate → verify → adversarial review, fixing real blockers. |
| [modern-web-guidance](skills/engineering/modern-web-guidance/) | `/plugin install modern-web-guidance@skill-arsenal` | Curated database of standardized modern web-platform patterns so Claude uses the platform instead of heavy deps or ad-hoc CSS/JS. |
| [tdd](skills/engineering/tdd/) | `/plugin install tdd@skill-arsenal` | Enforce the red → green → refactor TDD cycle for every new behavior or bug fix. |
| [codex](skills/engineering/codex/) | `/plugin install codex@skill-arsenal` | Bounded implementation worker rules for handing off to Codex — scope discipline, handoff checklist, Studio 2.0 conventions. |
| [code-quality-checklist](skills/engineering/code-quality-checklist/) | `/plugin install code-quality-checklist@skill-arsenal` | Pre/during/post-task quality guardrail — surfaces assumptions, enforces triggered workflows, and runs verification before marking done. Adapts to any codebase via project-rules.md. |
| [worker](skills/engineering/worker/) | `/plugin install worker@skill-arsenal` | Cursor task orchestrator — decompose a task JSON into slices, dispatch to Haiku subagents, adversarially review, fix blockers, and return a clean report. |
| [mastermind](skills/engineering/mastermind/) | `/plugin install mastermind@skill-arsenal` | End-to-end workflow conductor — interview → fusion-reasoning → task-plan-architect → planrunner → completion audit → adversarial review. Gates at confirm-understanding, confirm-plan, and present-verification; loops to root-cause and fix until satisfied. |

### Design

| Skill | Install command | Description |
|-------|----------------|-------------|
| [design-review-loop](skills/design/design-review-loop/) | `/plugin install design-review-loop@skill-arsenal` | Iterative multi-agent design review-and-build loop — screenshot, fan out specialist reviewers, reconcile, build, repeat until scores clear. |

### Productivity

| Skill | Install command | Description |
|-------|----------------|-------------|
| [fusion-reasoning](skills/productivity/fusion-reasoning/) | `/plugin install fusion-reasoning@skill-arsenal` | Reasoning amplifier — a panel of independent agents cross-examine and a judge synthesizes one answer that beats any single pass. |
| [efficient-orchestration](skills/productivity/efficient-orchestration/) | `/plugin install efficient-orchestration@skill-arsenal` | Always-on token-efficiency operating model: delegate mechanical work to the smallest capable model, monitor spend, checkpoint when deep. |

### Content

| Skill | Install command | Description |
|-------|----------------|-------------|
| [humanizer](skills/content/humanizer/) | `/plugin install humanizer@skill-arsenal` | Remove signs of AI-generated writing from text, based on Wikipedia's "Signs of AI writing" guide. |
| [comedy-writers-room](skills/content/comedy-writers-room/) | `/plugin install comedy-writers-room@skill-arsenal` | Write stand-up comedy — one subagent writes jokes while three play audience members reacting to them. |
| [gen-alpha-style](skills/content/gen-alpha-style/) | `/plugin install gen-alpha-style@skill-arsenal` | Gen Alpha / brainrot output-style transformation rules, glossary, and examples. |

### Automation

| Skill | Install command | Description |
|-------|----------------|-------------|
| [pinokio](skills/automation/pinokio/) | `/plugin install pinokio@skill-arsenal` | Discover, launch, and use apps and tools for the current task via Pinokio. |
| [gepeto](skills/automation/gepeto/) | `/plugin install gepeto@skill-arsenal` | Build 1-click launchers and apps with launchers built-in using Pinokio. |

> **Attribution.** Some skills are third-party, included here for easy reference and kept under their original licenses: **humanizer** by [Siqi Chen](https://github.com/blader/humanizer) (MIT), **comedy-writers-room** by [Tal Raviv](https://github.com/talsraviv/comedy-writers-room). Original LICENSE/README files are preserved inside each skill directory.

---
</details>

## Installation

> **Quickest path:** paste this page's URL into Claude or Codex and say *"install the skill-arsenal"*. The agent instructions at the bottom of this page tell it exactly what to do — it will clone the repo, register the marketplace, and install the recommended skills with no further input from you.

---

## Adding this store to Claude Code

Claude Code has a built-in plugin system. Register this repo once and you can browse and install skills without ever touching the filesystem.

<details>
<summary>[Expand for install steps]</summary>

### Step 1 — Add the marketplace

In any Claude Code session, run:

```
/plugin marketplace add senigami/skill-arsenal
```

This clones the repo into `~/.claude/plugins/marketplaces/skill-arsenal/` and registers it. You only need to do this once.

### Step 2 — Install a skill

```
/plugin install adversarial-review@skill-arsenal
```

The skill is now available as `/adversarial-review` in any project.

### Other useful commands

```
/plugin update                          # pull latest skill updates
/plugin update adversarial-review       # update one skill
/plugin remove adversarial-review       # uninstall a skill
/plugin marketplace remove skill-arsenal  # remove this store
```

## No CLI? Install via Claude chat

If you don't have the Claude Code CLI installed, paste this prompt directly into any Claude chat session and it will set everything up for you:

> Please install the skill-arsenal marketplace manually into Claude Code by running these two steps:
>
> 1. Clone the repo into the Claude marketplaces directory:
>    `git clone https://github.com/senigami/skill-arsenal.git ~/.claude/plugins/marketplaces/skill-arsenal`
>
> 2. Add "skill-arsenal" as an entry in `~/.claude/plugins/known_marketplaces.json` — read the file first, then add the new key alongside any existing entries:
>    ```json
>    "skill-arsenal": {
>      "source": { "source": "git", "url": "https://github.com/senigami/skill-arsenal.git" },
>      "installLocation": "<home-dir>/.claude/plugins/marketplaces/skill-arsenal",
>      "lastUpdated": "<today's date as ISO string>"
>    }
>    ```
>    Replace `<home-dir>` with the actual home directory path from the system.
>
> Then restart Claude Code. The skill-arsenal tab will appear under Plugins when you browse skills.

---

</details>

## Adding this store to Codex
Codex reads this repo as a plugin marketplace through [`.agents/plugins/marketplace.json`](.agents/plugins/marketplace.json). Register the marketplace once, then install individual skills from the Codex plugin picker.

<details>
<summary>[Expand for install steps]</summary>

### Step 1 — Add the marketplace

From Codex CLI, run:

```
codex plugin marketplace add senigami/skill-arsenal
```

Restart Codex after adding the marketplace.

### Step 2 — Install a skill

Open the Codex plugin picker:

```
codex
/plugins
```

Choose the `Skill Arsenal` marketplace, then install the skill you want. In the Codex app, open **Plugins**, switch to the `Skill Arsenal` source, and select **Add to Codex** for a skill.

After installation, start a new thread. You can ask for the task directly and let Codex pick the matching skill, or invoke an installed plugin/skill explicitly with `@` in the composer or `$skill-name` where skill mentions are available.
</details>

---

## Manual installation (no plugin system)

<details>
<summary>If you prefer not to use `/plugin`, you can install directly with the included script.</summary>

### Clone and install

```bash
git clone https://github.com/senigami/skill-arsenal.git
cd skill-arsenal
./install.sh adversarial-review
```

### List available skills

```bash
./install.sh --list
```

### What the script does

Copies the skill's `SKILL.md` (and any `references/`) into `~/.claude/skills/<skill-name>/`. Restart Claude Code for the skill to appear in the slash-command picker.

### Manual copy (no script)

```bash
cp -r skills/engineering/adversarial-review/skills/adversarial-review \
      ~/.claude/skills/adversarial-review
```

---

## Skill structure

Each skill is a self-contained Claude Code and Codex plugin under `skills/<category>/<name>/`:

```
skills/
└── engineering/
    └── adversarial-review/
        ├── .claude-plugin/
        │   └── plugin.json          # plugin manifest (Claude Code reads this)
        ├── .codex-plugin/
        │   └── plugin.json          # plugin manifest (Codex reads this)
        └── skills/
            └── adversarial-review/
                ├── SKILL.md         # shared skill content
                └── references/      # supporting docs loaded as context (optional)
```

The root [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) is the catalog Claude Code's `/plugin` system reads. The root [`.agents/plugins/marketplace.json`](.agents/plugins/marketplace.json) is the catalog Codex reads. Each plugin's `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` are the platform-specific manifests. `SKILL.md` is the shared skill content loaded when the skill is invoked.
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

<details>
<summary>For Claude and Codex / AI assistants: quick self install</summary>

## Claude agent quick install

If a user points this README at a Claude chat session and asks to set up the skill-arsenal, follow these steps:

**Step 1 — Check if already registered**

Read `~/.claude/plugins/known_marketplaces.json`. If a `skill-arsenal` key already exists, the marketplace is registered — skip to Step 3. If the file doesn't exist yet, you'll create it in Step 2.

**Step 2 — Clone the repo and register the marketplace**

```bash
git clone https://github.com/senigami/skill-arsenal.git ~/.claude/plugins/marketplaces/skill-arsenal
```

Then read `~/.claude/plugins/known_marketplaces.json` (or start fresh if it doesn't exist) and add the `skill-arsenal` entry alongside any existing entries:

```json
"skill-arsenal": {
  "source": { "source": "git", "url": "https://github.com/senigami/skill-arsenal.git" },
  "installLocation": "<actual-home-dir>/.claude/plugins/marketplaces/skill-arsenal",
  "lastUpdated": "<today's date as ISO 8601>"
}
```

Replace `<actual-home-dir>` with the real home directory path from the system (run `echo $HOME` to get it). Write the updated file back.

**Step 3 — Install skills**

If the user hasn't specified which skills to install, recommend starting with Mastermind and the recommended pair:

```bash
# Copy each skill's folder into ~/.claude/skills/
cp -r ~/.claude/plugins/marketplaces/skill-arsenal/skills/engineering/mastermind/skills/mastermind ~/.claude/skills/mastermind
cp -r ~/.claude/plugins/marketplaces/skill-arsenal/skills/engineering/spec-docs-generator/skills/spec-docs-generator ~/.claude/skills/spec-docs-generator
cp -r ~/.claude/plugins/marketplaces/skill-arsenal/skills/engineering/code-quality-checklist/skills/code-quality-checklist ~/.claude/skills/code-quality-checklist
```

For any other skill, the pattern is:
```bash
cp -r ~/.claude/plugins/marketplaces/skill-arsenal/skills/<category>/<name>/skills/<name> ~/.claude/skills/<name>
```

**Step 4 — Confirm and advise restart**

Tell the user which skills were installed and their invoke commands (e.g. `/mastermind`). Let them know Claude Code needs to be restarted (or a new session started) for new skills to appear in the slash-command picker.

**If the user only wants one skill**, install Mastermind — it auto-invokes the rest of the spine when they're present, and the workflow degrades gracefully to inline when they're not.


## Codex agent quick install

If a user points Codex at this repository and asks to use the skills here, install the marketplace first, then install the requested skill:

```bash
codex plugin marketplace add senigami/skill-arsenal
codex plugin add <skill-name>@skill-arsenal
```

If the user's shell does not have `codex` on `PATH`, use the Codex app binary directly:

```bash
/Applications/Codex.app/Contents/Resources/codex plugin marketplace add senigami/skill-arsenal
/Applications/Codex.app/Contents/Resources/codex plugin add <skill-name>@skill-arsenal
```

If the user is testing unpublished local changes from a checkout, register the local repo path instead of the GitHub shorthand:

```bash
/Applications/Codex.app/Contents/Resources/codex plugin marketplace add /path/to/skill-arsenal
/Applications/Codex.app/Contents/Resources/codex plugin add <skill-name>@skill-arsenal
```

After installing, restart Codex or start a new thread so the skill appears in the picker/context.
</details>
