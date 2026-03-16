#!/usr/bin/env bash
# sync-skills.sh — Copy Ignite UI Skill files from installed node_modules into skills/
#
# Why this approach:
#   Skills ship inside the igniteui-angular npm package.
#   After 'npm install', they live in scaffolds/angular/node_modules/igniteui-angular/skills/
#   This script copies them to skills/ so code-agent can load them without knowing
#   the node_modules path. When you update igniteui-angular, re-run this script.
#
# Usage:
#   ./scaffolds/sync-skills.sh           # sync all
#   ./scaffolds/sync-skills.sh angular   # Angular skills only
#   ./scaffolds/sync-skills.sh react     # React skills only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="${1:-all}"

ANGULAR_SKILLS_SRC="$SCRIPT_DIR/angular/node_modules/igniteui-angular/skills"
REACT_SKILLS_SRC="$SCRIPT_DIR/react/node_modules/igniteui-react-grids/skills"
SKILLS_DEST="$REPO_ROOT/skills"

echo ""
echo "=== Syncing Ignite UI Skills ==="
echo ""

sync_angular() {
  if [[ ! -d "$ANGULAR_SKILLS_SRC" ]]; then
    echo "WARNING: Angular skills not found at $ANGULAR_SKILLS_SRC"
    echo "  Run './scaffolds/setup.sh angular' first"
    return 1
  fi

  echo "Syncing Angular skills from node_modules..."
  for skill_dir in "$ANGULAR_SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    dest="$SKILLS_DEST/$skill_name"
    mkdir -p "$dest"
    cp -r "$skill_dir"* "$dest/"
    echo "  Synced: $skill_name"
  done
  echo "Angular skills synced to skills/"
}

sync_react() {
  if [[ ! -d "$REACT_SKILLS_SRC" ]]; then
    echo "NOTE: React skills not found at $REACT_SKILLS_SRC (may not ship skills yet)"
    return 0
  fi

  echo "Syncing React skills from node_modules..."
  for skill_dir in "$REACT_SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    dest="$SKILLS_DEST/$skill_name"
    mkdir -p "$dest"
    cp -r "$skill_dir"* "$dest/"
    echo "  Synced: $skill_name"
  done
  echo "React skills synced to skills/"
}

case "$TARGET" in
  angular) sync_angular ;;
  react)   sync_react ;;
  all)
    sync_angular
    sync_react
    ;;
  *)
    echo "ERROR: Unknown target '$TARGET'. Use: angular | react | all"
    exit 1
    ;;
esac

echo ""
echo "Skills available in skills/:"
ls "$SKILLS_DEST/" 2>/dev/null | grep -v README.md | sed 's/^/  /' || echo "  (none yet)"
echo ""
echo "code-agent will load these automatically when generating snippets."
echo ""
