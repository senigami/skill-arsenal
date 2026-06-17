#!/usr/bin/env bash
# Install a skill from skill-arsenal into ~/.claude/skills/
# Usage: ./install.sh <skill-name>
#        ./install.sh --list

set -euo pipefail

SKILLS_DIR="${HOME}/.claude/skills"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

list_skills() {
  echo "Available skills:"
  while IFS= read -r -d '' skill_json; do
    local name category version
    name=$(grep '"name"' "$skill_json" | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
    category=$(grep '"category"' "$skill_json" | head -1 | sed 's/.*"category": *"\([^"]*\)".*/\1/')
    version=$(grep '"version"' "$skill_json" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    printf "  %-30s %s  v%s\n" "$name" "$category" "$version"
  done < <(find "$REPO_DIR/skills" -name "skill.json" -print0 | sort -z)
}

install_skill() {
  local skill_name="$1"
  local plugin_dir

  plugin_dir=$(find "$REPO_DIR/skills" -type d -name "$skill_name" 2>/dev/null | head -1)

  if [ -z "$plugin_dir" ]; then
    echo "Error: skill '$skill_name' not found."
    echo ""
    list_skills
    exit 1
  fi

  # Skill content lives at skills/<skill-name>/SKILL.md within the plugin dir
  local skill_content_dir="$plugin_dir/skills/$skill_name"

  if [ ! -f "$skill_content_dir/SKILL.md" ]; then
    echo "Error: $skill_content_dir/SKILL.md not found — invalid skill directory."
    exit 1
  fi

  local target_dir="$SKILLS_DIR/$skill_name"
  mkdir -p "$target_dir"

  cp "$skill_content_dir/SKILL.md" "$target_dir/SKILL.md"

  if [ -d "$skill_content_dir/references" ] && [ -n "$(ls -A "$skill_content_dir/references" 2>/dev/null)" ]; then
    mkdir -p "$target_dir/references"
    cp -r "$skill_content_dir/references/"* "$target_dir/references/"
  fi

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
