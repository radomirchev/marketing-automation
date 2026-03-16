#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp-servers"
echo "=== Setting up Ignite UI MCP servers ==="
if [[ -f "$SCRIPT_DIR/.env" ]]; then set -a; source "$SCRIPT_DIR/.env"; set +a; fi
CLONE_DIR="$MCP_DIR/igniteui-mcp-source"
if [[ -d "$CLONE_DIR/.git" ]]; then
  echo "Updating igniteui-mcp..."; cd "$CLONE_DIR"; git pull --quiet
else
  echo "Cloning igniteui-mcp..."; git clone --quiet https://github.com/IgniteUI/igniteui-mcp.git "$CLONE_DIR"
fi
echo "--- Building igniteui-cli-mcp ---"
CLI_DEST="$MCP_DIR/igniteui-cli-mcp"
mkdir -p "$CLI_DEST"
cp -r "$CLONE_DIR/igniteui-cli-mcp/"* "$CLI_DEST/"
cd "$CLI_DEST"
echo "GITHUB_TOKEN=${GITHUB_TOKEN:-}" > .env.local
npm install --no-audit --no-fund
npm run build
echo "igniteui-cli-mcp — READY"
echo "--- Building igniteui-doc-mcp ---"
DOC_DEST="$MCP_DIR/igniteui-doc-mcp"
mkdir -p "$DOC_DEST"
cp -r "$CLONE_DIR/igniteui-doc-mcp/"* "$DOC_DEST/"
cd "$DOC_DEST"
npm install --no-audit --no-fund
npm run build
echo "igniteui-doc-mcp — READY"
echo "=== Done ==="
