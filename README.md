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

Each skill is a self-contained directory under `skills/<category>/<name>/`:

```
skills/
└── engineering/
    └── adversarial-review/
        ├── .claude-plugin/
        │   └── plugin.json          # Claude Code native plugin manifest
        ├── skills/
        │   └── adversarial-review/
        │       ├── SKILL.md         # skill content (the thing Claude reads)
        │       └── references/      # supporting docs loaded as context (optional)
        └── skill.json               # human-readable metadata for this repo
```

The `.claude-plugin/plugin.json` is what the `/plugin` system uses. `SKILL.md` is what Claude Code loads when you invoke the skill. `skill.json` is a browsable index entry for this repo's own tooling.

### skill.json fields

| Field | Description |
|-------|-------------|
| `name` | Slug — becomes the `/skill-name` command |
| `displayName` | Human-readable title |
| `description` | One-line summary shown in skill pickers |
| `version` | Semver |
| `author` | Original author |
| `category` | Directory category (e.g. `engineering`) |
| `main` | `skills/<name>/SKILL.md` |
| `references` | Files in `references/` loaded as context |
| `license` | SPDX identifier |
| `tags` | Searchable tags |

---

## Contributing

1. Fork this repo
2. Create your skill under `skills/<category>/<name>/` following the structure above
3. Add a `skill.json` and `.claude-plugin/plugin.json`
4. Put the skill content in `skills/<name>/SKILL.md`
5. Add an entry to both `registry.json` and `.claude-plugin/marketplace.json`
6. Open a PR — category is confirmed in review

---

## Registry

[`registry.json`](registry.json) is the machine-readable index of all skills. [`\.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) is what Claude Code's `/plugin` system reads.
