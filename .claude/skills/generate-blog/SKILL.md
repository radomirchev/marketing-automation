---
name: generate-blog
description: Full workflow for generating a Infragistics technical blog draft. Use when blog-agent has a complete topic brief and needs to produce a draft. Queries the Gateway API for technical grounding, structures the post, and outputs a file ready for proofreading.
allowed-tools: Bash, Read, Write
---

# Generate blog

Use this skill when the task is to produce a complete blog draft from a topic brief.

## Prerequisites

Before starting, confirm the brief has:
- `topic` — the specific subject (not just a product name)
- `framework` — one of: angular | react | web-components | blazor | cross-framework
- `angle` — the editorial hook (tutorial | deep-dive | comparison | announcement | tips)
- `keywords` — at least 2 target SEO/GEO keywords
- `depth` — beginner | intermediate | advanced
- `word_count` — target range (e.g. 1200–1600)
- `product_type` — gateway productType to use for RAG queries: igniteui | appbuilder | reveal | ultimate

If any of these are missing, stop and request them. Do not start writing without a complete brief.

## Workflow

### Step 1 — Research phase

Run Gateway API queries to ground the content before writing. Use `scripts/query-gateway.sh`.

Required queries (adjust wording to match the brief topic):
1. Query the primary component or feature covered in the topic
2. Query for code examples and API details relevant to the topic
3. Query for any version-specific behavior referenced in the brief

```bash
# Example — brief is about virtual scrolling in Ignite UI for Angular
./scripts/query-gateway.sh igniteui "How does virtual scrolling work in IgxGridComponent? What are the key inputs and performance considerations?" "session-blog-001"
./scripts/query-gateway.sh igniteui "Show me code examples for enabling virtual scrolling on IgxGridComponent" "session-blog-001"
```

Collect all `output` text, `citations`, and `confidenceLevel` values. Note any response with `confidenceLevel < 60`.

### Step 2 — Outline validation

Before writing prose, produce a 5-line outline:
1. Hook / opening problem
2. What this post covers (scope statement)
3. Core section 1 — [topic]
4. Core section 2 — [topic]
5. Takeaway / what the reader can now do

Review the outline against the brief's `angle`. A `tutorial` angle needs step-by-step flow. A `deep-dive` needs progressively technical sections. A `comparison` needs a structured evaluation matrix.

### Step 3 — Write the draft

Use `assets/blog-draft-template.md` as the output structure.

Fill each section:
- **Header / meta block** — title (H1), description, tags, framework, read time estimate
- **Opening (100–150 words)** — establish the problem or scenario. No intros about "modern development". Get to the point in sentence 1.
- **Prerequisites** — what the reader needs installed, what version is assumed
- **Core sections (2–4)** — technical content, grounded in Gateway API responses. Code samples in every section that covers implementation.
- **Key considerations** — performance, accessibility, known limitations
- **Summary** — 3–5 bullets of what was covered. No fluff.
- **Draft notes** — open questions, screenshot suggestions, internal link candidates

### Step 4 — Code sample validation

For every code sample in the draft:
- Confirm it matches the framework stated in the brief (`angular` → `.ts` + `.html` pattern, `react` → `.tsx`, `web-components` → vanilla JS with custom element syntax, `blazor` → `.razor`)
- Confirm API names match Gateway API responses
- Flag uncertain samples with `<!-- VERIFY: reason -->`

### Step 5 — Citation integration

- Add a `## References` section at the end of the draft
- List each Gateway citation URL with a short description
- For any claim flagged as low-confidence, add `[citation needed]` inline

### Step 6 — Output

Write the finished draft to:
```
drafts/<slug>-draft.md
```
Where `<slug>` is a kebab-case version of the post title.

Example: `drafts/virtual-scrolling-angular-grid-draft.md`

## Output requirements

The draft file must contain:
- Frontmatter block with all required meta fields
- All sections from the template
- At least one code sample per technical section
- `## References` with all Gateway citations
- `## Draft notes` with open questions and review flags
- No fabricated API names — every component API must trace to a Gateway response or a `<!-- VERIFY: -->` flag

## Common mistakes to avoid

- Writing generic Angular/React intros that ignore Ignite UI specifics
- Using placeholder component names (`MyComponent`, `DataService`) instead of real Ignite UI component names
- Skipping the prerequisites section — advanced developers skip it, beginners need it
- Writing a "conclusion" that just restates the intro — use the Summary bullets format instead
- Forgetting to pass `sessionId` across Gateway queries — context leaks without it
