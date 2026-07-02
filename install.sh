#!/usr/bin/env bash
# Install a skill from skill-arsenal into ~/.claude/skills/
# Usage: ./install.sh <skill-name>
#        ./install.sh --list

set -euo pipefail

SKILLS_DIR="${HOME}/.claude/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

list_skills() {
  echo "Available skills:"
  # Discover skills from the spec'd plugin manifests (.claude-plugin/plugin.json).
  while IFS= read -r -d '' manifest; do
    local plugin_dir name version category
    plugin_dir=$(dirname "$(dirname "$manifest")")
    name=$(grep '"name"' "$manifest" | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
    version=$(grep '"version"' "$manifest" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    # Category is the path segment between skills/ and the plugin directory.
    category=$(echo "${plugin_dir#"$REPO_DIR"/skills/}" | cut -d/ -f1)
    printf "  %-30s %s  v%s\n" "$name" "$category" "${version:-?}"
  done < <(find "$REPO_DIR/skills" -path '*/.claude-plugin/plugin.json' -print0 | sort -z)
}

install_skill() {
  local skill_name="$1"
  local plugin_dir

  plugin_dir=$(find "$REPO_DIR/skills" -type d -name "$skill_name" -print -quit 2>/dev/null)

  if [ -z "$plugin_dir" ]; then
    echo "Error: skill '$skill_name' not found."
    echo ""
    list_skills
    exit 1
  fi

  # Skill content lives at the plugin root (flat layout): SKILL.md + optional
  # references/, scripts/, evals/ — everything except the manifest folders.
  if [ ! -f "$plugin_dir/SKILL.md" ]; then
    echo "Error: $plugin_dir/SKILL.md not found — invalid skill directory."
    exit 1
  fi

  local target_dir="$SKILLS_DIR/$skill_name"
  mkdir -p "$target_dir"

  cp "$plugin_dir/SKILL.md" "$target_dir/SKILL.md"

  local sub
  for sub in "$plugin_dir"/*/; do
    [ -d "$sub" ] || continue
    case "$(basename "$sub")" in
      .claude-plugin|.codex-plugin) continue ;;
    esac
    cp -r "${sub%/}" "$target_dir/"
  done

  echo "Installed: $skill_name → $target_dir"
}

if [ "${1:-}" = "--list" ] || [ "${1:-}" = "-l" ]; then
  list_skills
  exit 0
fi

if [ -z "${1:-}" ]; then
  echo "Usage: ./install.sh <skill-name>"
  echo "       ./install.sh --list"
  exit 1
fi

install_skill "$1"
