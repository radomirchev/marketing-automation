# marketing-automation

AI-powered marketing content system for Infragistics. Orchestrates blog drafts, release blogs, topic refinement, and proofreading through specialized Claude agents grounded in Infragistics documentation via the AI Agent Gateway.

## What this repo does

Give the orchestrator a natural language request. It routes to the right agent. The agent queries the Gateway API for technically accurate content, applies Infragistics tone and structure standards, and produces a draft ready for editorial review.

## Quick navigation

- [Architecture overview](#architecture)
- [Setup](#setup)
- [Agents](#agents)
- [Workflow](#workflow)
- [Project structure](#structure)

## Architecture

```
Your request
     │
     ▼
marketing-orchestrator   ← classifies and routes
     │
     ├── topic-refiner        ← validates + scores raw topic ideas
     ├── blog-agent           ← writes technical developer blogs
     ├── release-blog-agent   ← writes release announcement posts
     └── proofreader          ← fact-checks and reviews drafts
          │
          ├── Blog Strategy MCP   ← topic scoring, GEO/SEO analysis
          └── Gateway API MCP     ← RAG on Infragistics docs (Bedrock)
```

## Setup

### 1. Clone and enter the repo

```bash
git clone https://github.com/radomirchev/marketing-automation.git
cd marketing-automation
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env and set GATEWAY_TOKEN=mcp-<kid>.<secret>
```

### 3. Configure MCP servers

Edit `.mcp.json` to confirm:
- `gateway-api` env block has your `GATEWAY_TOKEN`
- `blog-strategy-mcp` path points to your local build of the MCP server

### 4. Open in Claude Code

```bash
claude .
```

The `SessionStart` hook will orient Claude automatically on first load.

## Agents

| Agent | Trigger | Uses |
|---|---|---|
| `marketing-orchestrator` | Any free-form marketing request | Routes to sub-agents |
| `topic-refiner` | Raw topic idea | Blog Strategy MCP |
| `blog-agent` | Complete topic brief | Gateway API + Blog Strategy MCP |
| `release-blog-agent` | Version number + changelog | Gateway API |
| `proofreader` | Any draft file path | Gateway API |

## Workflow

**Standard blog post:**
1. Give the orchestrator a topic idea in plain language
2. Orchestrator delegates to `topic-refiner` → scored brief
3. Orchestrator delegates brief to `blog-agent` → draft in `drafts/`
4. Orchestrator delegates draft to `proofreader` → annotated review
5. You edit, approve, publish

**Release blog:**
1. Give the orchestrator a version number and a path to the changelog
2. Orchestrator delegates to `release-blog-agent` → draft in `drafts/`
3. Orchestrator delegates to `proofreader` → annotated review

## Structure

```
marketing-automation/
├── .claude/
│   ├── agents/              ← Claude subagent definitions
│   ├── rules/               ← Scoped Claude guidance
│   ├── skills/              ← Reusable multi-step workflows
│   └── settings.json        ← Hooks config (SessionStart)
├── scripts/hooks/           ← Hook support scripts
├── drafts/                  ← Generated content (gitignored)
├── .mcp.json                ← MCP server configuration
├── .env.example             ← Environment variable template
├── AGENTS.md                ← Shared agent instructions
└── CLAUDE.md                ← Claude-specific project guidance
```

## Prerequisites

- Claude Code installed
- Access to `ai-agent-gateway.infragistics.com` (PAT token required)
- `blog-strategy-mcp` built locally (optional — topic-refiner degrades gracefully)
- Node.js 20+ (for MCP servers)
