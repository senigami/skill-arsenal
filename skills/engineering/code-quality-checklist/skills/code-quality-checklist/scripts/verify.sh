#!/usr/bin/env bash
# Run project quality gates before marking a task complete.
# Runs type-check, lint, and the full test suite in sequence.
# Stops on first failure so you fix issues in order.
#
# Usage: ./scripts/verify.sh [--e2e]
#   --e2e   Also run E2E tests (slow; use when UI/integration flows changed)
#
# ─────────────────────────────────────────────────────────────────────────────
# CUSTOMIZE THIS SCRIPT PER PROJECT.
#
# Edit the three CHECK sections below ("Type-check", "Lint", "Unit tests") and
# the optional "E2E" section to match your project's commands. Keep these in
# sync with references/project-rules.md.
#
# Defaults below match a pnpm-based JS/TS monorepo (Basis). Replace with
# `cargo`, `pytest`, `make`, etc. as appropriate.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

run_e2e=false
for arg in "$@"; do
  case "$arg" in
    --e2e) run_e2e=true ;;
    -h|--help)
      sed -n '2,9p' "$0" | sed 's/^# //; s/^#//'
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown argument: $arg${NC}" >&2
      exit 2
      ;;
  esac
done

step() {
  echo ""
  echo -e "${BLUE}▶ $1${NC}"
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

fail() {
  echo -e "${RED}✗ $1${NC}" >&2
  echo -e "${YELLOW}Fix this before re-running.${NC}" >&2
  exit 1
}

# ─── Root check (customize sentinel file for non-Node projects) ──────────────
if [[ ! -f "package.json" ]]; then
  fail "package.json not found. Run this from the repo root."
fi

# ─── CHECK 1: Type-check ─────────────────────────────────────────────────────
step "Type-check"
if pnpm type-check; then
  success "Type-check passed"
else
  fail "Type-check failed"
fi

# ─── CHECK 2: Lint ───────────────────────────────────────────────────────────
# NOTE: This runs the FULL repo lint, not the pre-commit hook (which only
# lints staged files). The full lint is what CI runs.
step "Lint"
if pnpm lint; then
  success "Lint passed"
else
  fail "Lint failed"
fi

# ─── CHECK 3: Unit tests ─────────────────────────────────────────────────────
# NOTE: This runs the FULL test suite, not the pre-push hook (which runs
# changed files only). The full suite catches cross-file regressions.
step "Unit tests"
if pnpm vibecheck:all:run; then
  success "Unit tests passed"
else
  fail "Unit tests failed — triage per references/test-quality-bar.md (don't weaken assertions to force green)"
fi

# ─── OPTIONAL: E2E tests (--e2e flag) ────────────────────────────────────────
if $run_e2e; then
  step "E2E tests"
  if pnpm test; then
    success "E2E tests passed"
  else
    fail "E2E tests failed"
  fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ All verification gates passed${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next: self-review the diff (Stage 3.2) — see references/self-review-checklist.md"
echo "Run: git diff <base-branch>...HEAD"
