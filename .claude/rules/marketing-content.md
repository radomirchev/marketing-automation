---
paths:
  - "drafts/**/*.md"
  - ".claude/agents/*.md"
  - ".claude/skills/**/*.md"
---

# Marketing content rule

This repository produces developer-facing marketing content for Infragistics. When working on files in these paths:

## Technical accuracy
- Every Ignite UI component name, property, method, and event must match what the Gateway API returns. If unsure, query before writing.
- Never invent API names. A fabricated `IgxVirtualScrollDirective` that doesn't exist destroys trust faster than a missing feature.
- Flag uncertain technical claims with `<!-- VERIFY: reason -->` rather than guessing.

## Tone
- Follow the tone guide in `.claude/skills/generate-blog/references/tone-guide.md`.
- No banned phrases. See the banned phrases table in the tone guide.
- Write for developers. They are skeptical readers who stop reading the moment they smell marketing copy.

## Structure
- Draft files follow the template in `.claude/skills/generate-blog/assets/blog-draft-template.md`.
- Agent definition files follow the pattern already established in `.claude/agents/`.
- Do not add sections not in the template without flagging them in `## Draft notes`.

## Boundaries
- `drafts/` is output only. Do not create draft files manually — they are produced by agents.
- Do not add CTAs to draft content. Marketing adds those.
- Do not reference competitor products by name in any draft content.
