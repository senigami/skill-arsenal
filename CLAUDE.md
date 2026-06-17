# skill-arsenal — authoring guide for Claude

This repo is a **Claude Code plugin marketplace**. Each "skill" is packaged as a
self-contained plugin. When asked to add or modify a skill, follow this spec
exactly — it is verified against the official schemas, not reverse-engineered.

Sources of truth (re-check if anything seems off):
- Docs: https://code.claude.com/docs/en/plugins and https://code.claude.com/docs/en/plugins-reference
- Plugin manifest schema: https://www.schemastore.org/claude-code-plugin-manifest.json
- Marketplace manifest schema: https://www.schemastore.org/claude-code-marketplace.json

## Repository layout

```
skill-arsenal/
├── .claude-plugin/
│   └── marketplace.json          # the catalog — ONE entry per skill
├── skills/
│   └── <category>/               # e.g. engineering, productivity, research
│       └── <skill-name>/         # the plugin directory (source of the entry)
│           ├── .claude-plugin/
│           │   └── plugin.json    # plugin manifest
│           └── skills/
│               └── <skill-name>/
│                   ├── SKILL.md   # skill content + frontmatter
│                   └── references/ # optional supporting docs
├── install.sh                     # manual (non-plugin) installer; discovers via plugin.json
├── CLAUDE.md                      # this file
└── README.md
```

Categories are derived from the skill's purpose and **confirmed with the user**
before creating the directory (e.g. a code-review skill → `engineering`).

## Adding a new skill — checklist

1. Pick the category (confirm with the user). Create `skills/<category>/<name>/`.
2. Write `skills/<category>/<name>/.claude-plugin/plugin.json` (schema below).
3. Write `skills/<category>/<name>/skills/<name>/SKILL.md` (frontmatter below).
4. Add any reference docs under `.../skills/<name>/references/`.
5. Add a plugin entry to the root `.claude-plugin/marketplace.json`.
6. Update the README "Available skills" table.
7. Commit + push. Existing users pick it up with `/plugin update`.

## plugin.json (`<skill>/.claude-plugin/plugin.json`)

Only `name` is **required**. Keep the others for good metadata.

```json
{
  "name": "adversarial-review",
  "description": "One-line summary shown in the plugin manager.",
  "version": "2.9.0",
  "author": { "name": "ekreloff" },
  "homepage": "https://github.com/senigami/skill-arsenal/tree/main/skills/engineering/adversarial-review",
  "repository": "https://github.com/senigami/skill-arsenal",
  "license": "MIT",
  "skills": ["./skills"]
}
```

- `name` — REQUIRED. Becomes the namespace; skills invoke as `/<name>:<skill>`.
- `version` — optional but recommended. If set, users only get updates when it
  bumps. If omitted on a git-distributed plugin, every commit counts as a new version.
- `skills` — path(s) to the skill folder(s) inside the plugin. `["./skills"]`.
- Other valid fields: `author{name,email,url}`, `homepage`, `repository`,
  `license`, `keywords`, `dependencies`, `hooks`, `commands`, `agents`,
  `mcpServers`, `lspServers`, `monitors`, `settings`, `userConfig`.

## marketplace.json plugin entry (root `.claude-plugin/marketplace.json`)

Each entry requires `name` and `source`. Mirror the plugin's metadata.

```json
{
  "name": "adversarial-review",
  "source": "./skills/engineering/adversarial-review",
  "description": "Same one-liner as plugin.json.",
  "version": "2.9.0",
  "author": { "name": "ekreloff" },
  "keywords": ["code-review", "security", "quality"],
  "category": "engineering"
}
```

- `source` — REQUIRED. Relative path to the plugin directory.
- Top-level marketplace requires `name`, `owner`, `plugins`.

## SKILL.md frontmatter

```markdown
---
description: What it does + when to use it. This drives auto-invocation, so be specific.
---

# Skill body — instructions Claude follows when the skill runs.
```

`name` is taken from the folder name. `description` is the most important field;
it's how Claude decides when to use the skill. Optional frontmatter:
`disable-model-invocation: true` (manual-only), tool restrictions (see docs).

## Hard-won gotchas — do NOT repeat these

- **No icon support.** Neither schema has an `icon` field. Per-skill/per-plugin
  icons are not a thing; the browser placeholder is fixed UI. Don't add icon files.
- **`settings.json` is NOT display metadata.** A plugin-root `settings.json` only
  honors the `agent` and `subagentStatusLine` keys (ships default settings).
  `displayName`/`category`/`tags` there are silently ignored. Display name and
  description come from `plugin.json` + the marketplace entry. Don't create one
  for metadata.
- **No `skill.json`.** It is not part of the spec; Claude Code never reads it.
  `marketplace.json` is the single source of truth for the catalog.
- **Directory placement:** only `plugin.json` goes inside `.claude-plugin/`.
  `skills/` (and `agents/`, `hooks/`, etc.) live at the plugin root.
- A single-skill plugin *may* put `SKILL.md` at the plugin root, but this repo
  uses the `skills/<name>/SKILL.md` layout consistently — keep it that way.

## Verifying

- `./install.sh --list` should list every skill (it reads `plugin.json` + path).
- `claude plugin validate <plugin-dir>` runs the official validator if the CLI is present.
- After pushing, users run `/plugin update`; locally, `git -C ~/.claude/plugins/marketplaces/skill-arsenal pull` then restart.
