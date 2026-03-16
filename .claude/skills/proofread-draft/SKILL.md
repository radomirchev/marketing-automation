---
name: proofread-draft
description: Reviews an Infragistics blog draft for technical accuracy, tone compliance, and structural completeness. Use after blog-agent or release-blog-agent produces a draft. Queries the Gateway API to fact-check technical claims and produces an annotated draft plus a verdict summary.
allowed-tools: Bash, Read, Write
---

# Proofread draft

Use this skill when the task is to review, fact-check, and annotate a generated blog draft.

## Prerequisites

Before starting, confirm:
- `draft_path` — path to the draft file (e.g. `drafts/virtual-scrolling-angular-draft.md`)
- `product_type` — gateway productType for fact-checking (igniteui | appbuilder | reveal | ultimate | master)
- `framework` — the framework the draft targets (angular | react | web-components | blazor)

## Workflow

### Step 1 — Read the full draft

Read the draft file completely before annotating. Understand the post as a whole: what it claims, what it demonstrates, what the structure is.

Note:
- The overall verdict impression (accurate? structurally complete? tone correct?)
- Specific sections that need technical verification
- Any `<!-- VERIFY: -->` flags left by the blog-agent

### Step 2 — Fact-check via Gateway API

For each major technical claim in the draft, run a targeted query:

```bash
./scripts/query-gateway.sh <product_type> "Verify: [specific claim from draft]" "session-proof-<draft-slug>"
```

Focus Gateway queries on:
- Component names and whether they exist
- Property and method names used in code samples
- Version-specific behavior claims
- Any `<!-- VERIFY: -->` flags in the draft

Record each query result: confirmed, partially confirmed, or incorrect.

### Step 3 — Check tone compliance

Using `references/tone-guide.md`, scan for:

**Banned phrases** — search for each phrase in the banned table. Flag every instance.

**Structural issues:**
- Generic opener? (contains "fast-paced", "modern", "today's", "In this post we will")
- Any section that asserts without proving? (claim + no code or data)
- "In conclusion" as a header? → flag as `STRUCTURE`

**Active voice** — flag passive constructions where active would be clearer.

### Step 4 — Check structure compliance

Using `references/blog-structure.md`, verify:
- [ ] Frontmatter has: title, description, tags, framework, product, depth, estimated_read_time, draft
- [ ] Opening section present and under 150 words
- [ ] Prerequisites section present
- [ ] At least 2 core sections present
- [ ] Each core section has at least one code sample
- [ ] Summary section present with bullets (not prose)
- [ ] References section present
- [ ] Draft notes section present

### Step 5 — Annotate the draft

Add inline review comments using the format:
```
<!-- REVIEW [CATEGORY]: [description of issue] -->
```

Categories:
- `ACCURACY` — technically wrong or unverified claim
- `TONE` — banned phrase, superlative, passive, or off-voice
- `STRUCTURE` — missing section, wrong format, non-compliant element
- `CODE` — fabricated API name, wrong framework pattern, uncommented truncation
- `VERIFY` — claim could not be confirmed via Gateway; needs human check

Place the comment on the line immediately above or following the problematic content.

### Step 6 — Produce the review summary

Append to the end of the draft file:

```markdown
---

## Review summary

**Verdict:** APPROVED | MINOR REVISIONS | MAJOR REVISIONS

**Blocking issues (must fix before publication):**
- 

**Non-blocking suggestions:**
- 

**VERIFY flags resolved:**
- [claim] — confirmed accurate / confirmed incorrect / could not verify (needs human)

**Gateway queries run:**
- [query text] — confidence: [level] — result: [confirmed/incorrect/partial]
```

### Verdict criteria

- **APPROVED** — No technical inaccuracies. No banned phrases. All required sections present. All VERIFY flags resolved.
- **MINOR REVISIONS** — 1–3 non-blocking issues. Technical accuracy confirmed.
- **MAJOR REVISIONS** — Any fabricated API, code sample that won't compile, unresolved inaccurate VERIFY flag, or multiple banned phrase violations.

## Output

Write the annotated draft back to the same file path. Do not create a new file. Do not change the filename.

The `## Review summary` section and all `<!-- REVIEW -->` comments are stripped by editorial before publication.
