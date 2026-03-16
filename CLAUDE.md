# CLAUDE.md

## Repo identity

This is a marketing content automation repo for Infragistics. It produces Markdown blog drafts grounded in Infragistics documentation via the AI Agent Gateway (AWS Bedrock + RAG).

@AGENTS.md

## Repository map

- `.claude/agents/` — subagent definitions
- `.claude/rules/` — scoped Claude rules
- `.claude/skills/` — reusable workflows
- `scripts/hooks/` — session lifecycle scripts
- `drafts/` — output only, gitignored

## Agents in this repo

| Agent | File | Role |
|---|---|---|
| Marketing orchestrator | `.claude/agents/marketing-orchestrator.md` | Routes all requests |
| Blog agent | `.claude/agents/blog-agent.md` | Technical blog drafts |
| Release blog agent | `.claude/agents/release-blog-agent.md` | Release announcement drafts |
| Topic refiner | `.claude/agents/topic-refiner.md` | Topic scoring and brief enrichment |
| Proofreader | `.claude/agents/proofreader.md` | Fact-check and editorial review |

## MCP servers

Two MCP servers are configured in `.mcp.json`:

- `gateway-api` — wraps the Infragistics AI Agent Gateway. Provides `invoke_by_product_type` and `invoke_master_agent` tools. Requires `GATEWAY_TOKEN` env var.
- `blog-strategy-mcp` — local MCP server for topic scoring, GEO/SEO analysis, and blog strategy. Path configured in `.mcp.json`.

If an MCP server is unavailable, agents fall back to direct `scripts/query-gateway.sh` shell calls.

## Core working rules

- Always confirm `GATEWAY_TOKEN` is set before running any agent that queries the Gateway.
- `drafts/` is output only — never edit files there directly, always regenerate.
- When a session starts, read `AGENTS.md` for shared rules, then this file for Claude-specific guidance.
- Prefer small, focused agent invocations over one giant orchestration pass.
- If a topic brief is missing required fields, stop and request them — do not proceed with incomplete input.

## Content quality rules

- All technical claims about Ignite UI components must be grounded in Gateway API responses.
- Flag uncertain claims with `<!-- VERIFY: reason -->` rather than publishing a guess.
- Follow the tone guide in `.claude/skills/generate-blog/references/tone-guide.md` for all drafted content.
- Do not generate CTAs — marketing adds those post-draft.

## Decision rule

Use:
- `CLAUDE.md` for always-on project guidance
- `.claude/rules/` for scoped rules (path-gated)
- `.claude/agents/` for specialist roles
- `.claude/skills/` for repeatable multi-step workflows
- `scripts/hooks/` for deterministic session automation only
