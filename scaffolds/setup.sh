#!/usr/bin/env bash
# setup-scaffolds.sh — Run once after cloning to pre-warm all verification scaffolds.
# After this runs, tsc --noEmit verification takes ~8 seconds instead of 4+ minutes.
#
# Usage:
#   ./scaffolds/setup.sh
#   ./scaffolds/setup.sh angular     # Angular only
#   ./scaffolds/setup.sh react       # React only

set -euo pipefail

SCAFFOLDS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-all}"

echo ""
echo "=== Marketing Automation — Scaffold Setup ==="
echo ""

check_node() {
  if ! command -v node &>/dev/null; then
    echo "ERROR: Node.js is required. Install from https://nodejs.org (v20+)"
    exit 1
  fi
  NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VERSION" -lt 18 ]]; then
    echo "ERROR: Node.js 18+ required. Current: $(node --version)"
    exit 1
  fi
  echo "Node.js $(node --version) — OK"
}

setup_angular() {
  echo ""
  echo "--- Setting up Angular scaffold ---"
  cd "$SCAFFOLDS_DIR/angular"

  if [[ ! -f package.json ]]; then
    echo "ERROR: scaffolds/angular/package.json not found"
    exit 1
  fi

  if [[ -d node_modules ]]; then
    echo "node_modules already present — skipping install"
    echo "Run 'rm -rf node_modules && ./scaffolds/setup.sh angular' to reinstall"
  else
    echo "Installing Angular + Ignite UI dependencies..."
    npm install --prefer-offline --no-audit --no-fund
    echo "Angular scaffold ready"
  fi

  echo "Verifying TypeScript compiler..."
  npx tsc --version
  echo "Angular scaffold — READY"
}

setup_react() {
  echo ""
  echo "--- Setting up React scaffold ---"
  cd "$SCAFFOLDS_DIR/react"

  if [[ ! -f package.json ]]; then
    echo "ERROR: scaffolds/react/package.json not found"
    exit 1
  fi

  if [[ -d node_modules ]]; then
    echo "node_modules already present — skipping install"
  else
    echo "Installing React + Ignite UI dependencies..."
    npm install --prefer-offline --no-audit --no-fund
    echo "React scaffold ready"
  fi

  echo "React scaffold — READY"
}

check_node

case "$TARGET" in
  angular) setup_angular ;;
  react)   setup_react ;;
  all)
    setup_angular
    setup_react
    ;;
  *)
    echo "ERROR: Unknown target '$TARGET'. Use: angular | react | all"
    exit 1
    ;;
esac

echo ""
echo "=== Setup complete ==="
echo "Verification is now pre-warmed. Run snippets via:"
echo "  .claude/skills/scaffold-and-verify/scripts/verify-snippet.sh <framework> <snippet-file>"
echo ""
