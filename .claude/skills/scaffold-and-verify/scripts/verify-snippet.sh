#!/usr/bin/env bash
# verify-snippet.sh — Inject a code snippet into the pre-warmed scaffold and verify it compiles.
#
# Usage:
#   ./verify-snippet.sh <framework> <snippet-file> [--keep]
#
# framework:    angular | react | web-components
# snippet-file: path to a .ts or .tsx file containing the snippet to verify
# --keep:       optional — don't reset the inject point after verification (for debugging)
#
# Exit codes:
#   0 = PASS (compiles cleanly)
#   1 = FAIL (type errors or compile errors)
#   2 = SETUP ERROR (scaffold not ready, missing files)
#
# Output:
#   Prints structured result to stdout:
#   STATUS: PASS | FAIL
#   ERRORS: (if FAIL) list of TypeScript errors
#   DURATION: seconds taken

set -euo pipefail

FRAMEWORK="${1:-}"
SNIPPET_FILE="${2:-}"
KEEP="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SCAFFOLDS_DIR="$REPO_ROOT/scaffolds"

START_TIME=$(date +%s)

# ── Validation ────────────────────────────────────────────────────────────────

if [[ -z "$FRAMEWORK" || -z "$SNIPPET_FILE" ]]; then
  echo "STATUS: ERROR"
  echo "ERROR: Usage: $0 <framework> <snippet-file> [--keep]"
  exit 2
fi

if [[ ! -f "$SNIPPET_FILE" ]]; then
  echo "STATUS: ERROR"
  echo "ERROR: Snippet file not found: $SNIPPET_FILE"
  exit 2
fi

# ── Framework routing ────────────────────────────────────────────────────────

case "$FRAMEWORK" in
  angular)
    SCAFFOLD_DIR="$SCAFFOLDS_DIR/angular"
    INJECT_POINT="$SCAFFOLD_DIR/src/app/verify/verify.component.ts"
    INJECT_TEMPLATE="$SCAFFOLD_DIR/src/app/verify/verify.component.ts.template"
    VERIFY_CMD="npx tsc --noEmit --project tsconfig.json"
    ;;
  react)
    SCAFFOLD_DIR="$SCAFFOLDS_DIR/react"
    INJECT_POINT="$SCAFFOLD_DIR/src/VerifyComponent.tsx"
    INJECT_TEMPLATE="$SCAFFOLD_DIR/src/VerifyComponent.tsx.template"
    VERIFY_CMD="npx tsc --noEmit --project tsconfig.json"
    ;;
  web-components)
    echo "STATUS: SKIP"
    echo "NOTE: Web Components scaffold not yet configured. Flag snippet for manual review."
    exit 0
    ;;
  *)
    echo "STATUS: ERROR"
    echo "ERROR: Unknown framework '$FRAMEWORK'. Use: angular | react | web-components"
    exit 2
    ;;
esac

# ── Scaffold readiness check ──────────────────────────────────────────────────

if [[ ! -d "$SCAFFOLD_DIR/node_modules" ]]; then
  echo "STATUS: ERROR"
  echo "ERROR: Scaffold not ready — node_modules missing in $SCAFFOLD_DIR"
  echo "Run: ./scaffolds/setup.sh $FRAMEWORK"
  exit 2
fi

# ── Save template if first run ────────────────────────────────────────────────

if [[ ! -f "$INJECT_TEMPLATE" ]]; then
  cp "$INJECT_POINT" "$INJECT_TEMPLATE"
fi

# ── Inject snippet ────────────────────────────────────────────────────────────

cp "$SNIPPET_FILE" "$INJECT_POINT"

# ── Run verification ──────────────────────────────────────────────────────────

VERIFY_OUTPUT=""
VERIFY_EXIT=0

cd "$SCAFFOLD_DIR"
VERIFY_OUTPUT=$(eval "$VERIFY_CMD" 2>&1) || VERIFY_EXIT=$?

# ── Reset inject point ────────────────────────────────────────────────────────

if [[ "$KEEP" != "--keep" ]]; then
  cp "$INJECT_TEMPLATE" "$INJECT_POINT"
fi

# ── Parse and report ──────────────────────────────────────────────────────────

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [[ $VERIFY_EXIT -eq 0 ]]; then
  echo "STATUS: PASS"
  echo "FRAMEWORK: $FRAMEWORK"
  echo "DURATION: ${DURATION}s"
else
  echo "STATUS: FAIL"
  echo "FRAMEWORK: $FRAMEWORK"
  echo "DURATION: ${DURATION}s"
  echo ""
  echo "ERRORS:"
  # Filter to only TypeScript errors, clean up absolute paths for readability
  echo "$VERIFY_OUTPUT" | grep -E "error TS|Cannot find|is not assignable|does not exist|has no exported" \
    | sed "s|$SCAFFOLD_DIR/||g" \
    || echo "$VERIFY_OUTPUT" | head -20
  exit 1
fi
