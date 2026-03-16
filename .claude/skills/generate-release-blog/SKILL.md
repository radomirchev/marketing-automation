---
name: generate-release-blog
description: Full workflow for generating an Infragistics product release blog draft. Use when release-blog-agent has a version number and optionally a changelog. Queries the Gateway API for feature details, triages changes into headline/notable/minor tiers, and outputs a structured release announcement draft.
allowed-tools: Bash, Read, Write
---

# Generate release blog

Use this skill when the task is to produce a release announcement draft from a version number and/or changelog.

## Prerequisites

Before starting, confirm the handoff has:
- `version` — the release version string (e.g. "18.2", "v25.1")
- `product` — one of: igniteui-angular | igniteui-react | igniteui-wc | igniteui-blazor
- `product_type` — gateway productType: igniteui | appbuilder | reveal | ultimate
- `changelog_path` — path to changelog or release notes file (optional but preferred)
- `highlights` — any specific features the requester wants emphasized (optional)

If `changelog_path` is not provided, proceed with Gateway API queries to discover what changed.

## Workflow

### Step 1 — Ingest the changelog

If `changelog_path` is provided, read it and extract:
- New features (categorize as headline or notable based on scope)
- Bug fixes
- Breaking changes or deprecations
- Migration notes

If no changelog is available, run:
```bash
./scripts/query-gateway.sh igniteui "What are the main new features in [product] [version]?" "session-release-[product]-[version]"
```

### Step 2 — Research headline features

For each feature identified as headline-worthy (max 3), run a targeted Gateway query:
```bash
./scripts/query-gateway.sh igniteui "Show code examples for [feature name] in [version]" "session-release-[product]-[version]"
```

Collect `output`, `citations`, and `confidenceLevel` for each.

### Step 3 — Triage the changelog

Classify every item into one of three tiers:

| Tier | Criteria | Treatment |
|---|---|---|
| Headline | New component, major new API, paradigm shift | Full section with description + code sample |
| Notable | Improved behavior, new option/property, perf improvement | Short paragraph, optional brief sample |
| Minor | Bug fix, small tweak, internal improvement | Bullet point only |

Breaking changes get their own section regardless of tier.

### Step 4 — Write the draft

Use `assets/release-blog-template.md` as the output structure.

Fill each section:
- **Frontmatter** — title, description, version, product, tags, `draft: true`
- **Opening (2–3 sentences)** — what version, what product, the most important thing that changed
- **Headline features** — one H2 per headline feature, with code sample
- **Notable improvements** — H2 section with subsections or bullets
- **Bug fixes** — bulleted list, grouped by area if more than 5
- **Upgrade notes** — only if breaking changes exist; blockquote format
- **Draft notes** — open questions, missing code samples, docs team flags

### Step 5 — Flag breaking changes

Any breaking change must appear in the draft as:
```markdown
> **Breaking change:** [description of what changed and what developers must update]
```

Do not bury breaking changes inside other sections.

### Step 6 — Output

Write to: `drafts/<product>-<version>-release-draft.md`

Example: `drafts/igniteui-angular-18-2-release-draft.md`

## Output requirements

- Frontmatter with all required meta fields
- At least one code sample per headline feature
- Breaking changes blockquoted and clearly marked
- `## References` with all Gateway citations
- `## Draft notes` with flags for any items needing docs team attention
- No feature claims without a Gateway citation or changelog source
