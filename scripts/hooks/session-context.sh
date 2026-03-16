#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
Marketing automation repo orientation:

Agents:
  - marketing-orchestrator  → route all requests here first
  - blog-agent              → technical developer blog drafts
  - release-blog-agent      → release announcement posts
  - topic-refiner           → raw idea → scored brief
  - proofreader             → fact-check and review drafts

Skills:
  - generate-blog           → .claude/skills/generate-blog/SKILL.md
  - generate-release-blog   → .claude/skills/generate-release-blog/SKILL.md
  - proofread-draft         → .claude/skills/proofread-draft/SKILL.md

MCP servers (see .mcp.json):
  - gateway-api             → Infragistics AI Agent Gateway (Bedrock RAG)
  - blog-strategy-mcp       → topic scoring, GEO/SEO analysis

Output: drafts/ (gitignored)

Environment check:
EOF

if [[ -z "${GATEWAY_TOKEN:-}" ]]; then
  echo "  WARNING: GATEWAY_TOKEN not set — Gateway API queries will fail"
  echo "  Set it with: export GATEWAY_TOKEN=mcp-<kid>.<secret>"
else
  echo "  GATEWAY_TOKEN is set"
fi

if [[ -f "$CLAUDE_PROJECT_DIR/.env" ]]; then
  echo "  .env file present"
else
  echo "  No .env file — copy .env.example and add your token"
fi
