# AGENTS.md

## Repo summary

This is a marketing content automation repository for Infragistics. It contains Claude agent definitions, skill workflows, and scripts that orchestrate the production of developer-facing blog content, release announcements, and editorial review.

There is no application source code. The "product" this repo produces is Markdown draft files in `drafts/`.

## Commands

- No build step required
- Validate a topic brief: `.claude/skills/generate-blog/scripts/validate-brief.sh <brief.json>`
- Query the Gateway API: `.claude/skills/generate-blog/scripts/query-gateway.sh <productType> "<input>" [sessionId]`
- List current drafts: `ls drafts/`

## Working rules

- Keep changes small and focused on one agent or skill at a time.
- Do not modify `drafts/` — that folder is output only.
- When updating an agent definition, check whether dependent skills reference behavior that changed.
- When updating a skill, check whether the agent that uses it has a matching `skills:` frontmatter entry.
- Run `validate-brief.sh` before invoking any blog generation workflow.
- Do not commit `.env` — credentials live there.

## Project structure

- `.claude/agents/` — Claude subagent definitions (`.md` files with YAML frontmatter)
- `.claude/rules/` — Scoped Claude project rules (path-gated via `paths:` frontmatter)
- `.claude/skills/` — Reusable multi-step workflows, each a folder with `SKILL.md`
- `.claude/settings.json` — Claude Code project settings and hooks
- `scripts/hooks/` — Shell scripts called by hooks at session lifecycle events
- `drafts/` — Output folder for generated content; gitignored; do not edit directly

## Agent conventions

- Every agent file must have `name`, `description`, `tools`, and `model` in YAML frontmatter.
- The `description` field is the routing hint — it must clearly state when to use this agent.
- If an agent uses a skill, declare it in `skills:` frontmatter.
- Use `model: claude-sonnet-4-5` unless there is a specific reason for a different model.

## Skill conventions

- Every skill lives in its own folder under `.claude/skills/<skill-name>/`.
- Every skill folder must contain `SKILL.md` and at minimum one subfolder (`scripts/`, `references/`, or `assets/`).
- `SKILL.md` frontmatter must have `name` and `description`.
- Scripts in `skills/*/scripts/` must be executable and include a usage comment at the top.

## Boundaries

- Do not add new agents without a corresponding skill if the agent has a multi-step workflow.
- Do not query the Gateway API without setting `GATEWAY_TOKEN` in the environment.
- Do not commit draft content — `drafts/` is gitignored.
- Do not invent component API names — always ground technical claims via the Gateway API.
- Do not modify `.mcp.json` server URLs without testing the connection first.

## Pull request guidance

- State which agent or skill was changed and why.
- If adding a new agent, confirm it is registered in `CLAUDE.md` under the agents section.
- Include a sample brief or input that exercises the changed agent.
