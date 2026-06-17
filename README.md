# skill-arsenal

A curated collection of reusable [Claude Code](https://claude.ai/code) skills organized by category.

## Adding this store to Claude Code

Claude Code has a built-in plugin system. Register this repo once and you can browse and install skills without ever touching the filesystem.

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

---

## Available skills

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

### Design

| Skill | Install command | Description |
|-------|----------------|-------------|
| [design-review-loop](skills/design/design-review-loop/) | `/plugin install design-review-loop@skill-arsenal` | Iterative multi-agent design review-and-build loop — screenshot, fan out specialist reviewers, reconcile, build, repeat until scores clear. |

### Productivity

| Skill | Install command | Description |
|-------|----------------|-------------|
| [fusion-reasoning](skills/productivity/fusion-reasoning/) | `/plugin install fusion-reasoning@skill-arsenal` | Reasoning amplifier — a panel of independent agents cross-examine and a judge synthesizes one answer that beats any single pass. |
| [efficient-orchestration](skills/productivity/efficient-orchestration/) | `/plugin install efficient-orchestration@skill-arsenal` | Always-on token-efficiency operating model: delegate mechanical work to the smallest capable model, monitor spend, checkpoint when deep. |

---

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

## Manual installation (no plugin system)

If you prefer not to use `/plugin`, you can install directly with the included script.

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

Each skill is a self-contained Claude Code plugin under `skills/<category>/<name>/`:

```
skills/
└── engineering/
    └── adversarial-review/
        ├── .claude-plugin/
        │   └── plugin.json          # plugin manifest (Claude Code reads this)
        └── skills/
            └── adversarial-review/
                ├── SKILL.md         # skill content (the thing Claude loads)
                └── references/      # supporting docs loaded as context (optional)
```

The root [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) is the catalog Claude Code's `/plugin` system reads. Each plugin's `.claude-plugin/plugin.json` is its manifest. `SKILL.md` is the content Claude loads when the skill is invoked.

---

## Contributing

1. Fork this repo
2. Create your skill under `skills/<category>/<name>/` following the structure above
3. Add `.claude-plugin/plugin.json` and `skills/<name>/SKILL.md`
4. Add a plugin entry to the root `.claude-plugin/marketplace.json`
5. Open a PR — category is confirmed in review

The authoring spec — exact manifest fields, required vs optional, and gotchas — lives in [CLAUDE.md](CLAUDE.md).
