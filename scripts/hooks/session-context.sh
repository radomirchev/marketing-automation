#!/usr/bin/env bash
set -euo pipefail

cat <<'CONTEXT'
Marketing automation repo orientation:

Agents:
  - marketing-orchestrator  → route all requests here first
  - blog-agent              → technical developer blog drafts
  - release-blog-agent      → release announcement posts
  - topic-refiner           → raw idea → scored brief
  - proofreader             → fact-check and review drafts
  - code-agent              → generates + verifies Ignite UI code snippets (called by blog-agent)

Skills:
  - generate-blog           → .claude/skills/generate-blog/SKILL.md
  - generate-release-blog   → .claude/skills/generate-release-blog/SKILL.md
  - proofread-draft         → .claude/skills/proofread-draft/SKILL.md
  - scaffold-and-verify     → .claude/skills/scaffold-and-verify/SKILL.md

MCP servers (see .mcp.json):
  - gateway-api             → Infragistics AI Agent Gateway (Bedrock RAG)
  - blog-strategy-mcp       → topic scoring, GEO/SEO analysis

Scaffolds (pre-warmed, run setup once):
  - scaffolds/angular/      → Ignite UI Angular 18, all modules imported
  - scaffolds/react/        → Ignite UI React 18, grids/charts/inputs

Output: drafts/ (gitignored)

CONTEXT

# Environment check
if [[ -z "${GATEWAY_TOKEN:-}" ]]; then
  echo "  WARNING: GATEWAY_TOKEN not set — Gateway API queries will fail"
  echo "  Set it with: export GATEWAY_TOKEN=mcp-<kid>.<secret>"
else
  echo "  GATEWAY_TOKEN: set"
fi

# Scaffold readiness check
ANGULAR_READY=false
REACT_READY=false
[[ -d "$CLAUDE_PROJECT_DIR/scaffolds/angular/node_modules" ]] && ANGULAR_READY=true
[[ -d "$CLAUDE_PROJECT_DIR/scaffolds/react/node_modules" ]] && REACT_READY=true

if $ANGULAR_READY && $REACT_READY; then
  echo "  Scaffolds: Angular + React ready"
elif ! $ANGULAR_READY && ! $REACT_READY; then
  echo "  WARNING: Scaffolds not set up — code verification will fail"
  echo "  Run: ./scaffolds/setup.sh"
else
  $ANGULAR_READY && echo "  Scaffolds: Angular ready" || echo "  WARNING: Angular scaffold not ready — run: ./scaffolds/setup.sh angular"
  $REACT_READY && echo "  Scaffolds: React ready" || echo "  WARNING: React scaffold not ready — run: ./scaffolds/setup.sh react"
fi
