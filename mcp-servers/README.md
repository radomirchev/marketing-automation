# MCP Servers

Local MCP servers that expose external APIs as native Claude tools.

## gateway-api

Wraps the Infragistics AI Agent Gateway (`ai-agent-gateway.infragistics.com`).

**Tools exposed:**
- `invoke_by_product_type` — routes to Bedrock agent by product (igniteui, appbuilder, reveal, ultimate)
- `invoke_master_agent` — queries the master agent directly (cross-product)
- `gateway_health` — checks Gateway reachability

**Build and run:**
```bash
cd mcp-servers/gateway-api
npm install
npm run build
```

After building, the server is referenced in `.mcp.json` and Claude Code loads it automatically on `claude .`.

**Environment:**
```
GATEWAY_TOKEN=mcp-<kid>.<secret>   # required — set in .env
GATEWAY_BASE_URL=https://ai-agent-gateway.infragistics.com  # optional override
```

**Why this instead of the bash scripts?**

The bash scripts (`query-gateway.sh`) still work and are used as fallback. The MCP server gives agents native tool call syntax instead of `Bash` tool invocations, which means:
- Cleaner agent context (no shell output parsing)
- Structured error handling per call
- Session continuity managed by the server
- Rate limit errors surfaced as tool errors, not exit codes

## Adding a new MCP server

1. Create `mcp-servers/<name>/` with `package.json`, `tsconfig.json`, `src/index.ts`
2. Follow the gateway-api pattern: `Server` + `StdioServerTransport` + tool definitions
3. Add to `.mcp.json`:
```json
"<name>": {
  "type": "stdio",
  "command": "node",
  "args": ["./mcp-servers/<name>/dist/index.js"],
  "env": {}
}
```
4. Run `npm install && npm run build` in the server directory
