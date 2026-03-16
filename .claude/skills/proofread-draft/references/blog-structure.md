# Blog structure reference

This document defines the standard section structure and content rules for Infragistics developer blog posts. The blog-agent uses this as the structural contract for all drafts.

## Standard section order

### 1. Frontmatter (required)
```yaml
---
title: "Exact H1 title"
description: "1–2 sentence meta description for SEO. Include primary keyword."
tags: [ignite-ui-angular, grid, virtual-scrolling]
framework: angular
product: igniteui
depth: intermediate
estimated_read_time: "8 min"
draft: true
---
```

### 2. Opening (100–150 words)
- First sentence must state the problem or scenario directly
- No preamble about "modern development", "today's landscape", or company history
- Establish who this post is for and what they will be able to do after reading

Good opening pattern:
> When an Angular data grid renders 50,000 rows, the DOM pays for every one of them — unless you configure virtual scrolling. This post walks through enabling `IgxGridComponent` virtual scrolling, tuning row height for consistent render performance, and avoiding the three configuration mistakes that quietly tank scroll frame rate.

### 3. Prerequisites
- Bulleted list only
- Package version numbers where known (get from Gateway API)
- What the reader should already know
- Link to getting-started guide only if this is an intermediate or advanced post

### 4. Core section 1 — concept or setup
- For tutorials: the first implementation step
- For deep-dives: the foundational concept before the advanced technique
- For comparisons: the first option being evaluated
- Must include at least one code sample

### 5. Core section 2 (and optionally 3–4)
- Progressive: each section builds on the previous
- Code samples must be runnable in the stated framework
- Tables or lists for structured data (configuration options, API properties)
- Screenshots are noted as `[SCREENSHOT: description]` placeholders — not embedded

### 6. Key considerations (required for advanced/deep-dive posts)
Subsections covering one or more of:
- **Performance** — what to watch for at scale
- **Accessibility** — ARIA, keyboard nav, screen reader behavior
- **Known limitations** — things the API does not support, edge cases
- **Version notes** — behavior that changed between versions (get from Gateway)

### 7. Summary
- Bulleted list of 3–5 things the reader can now do
- Not a prose restatement of the intro
- Action-oriented ("You can now...", "You know how to...")

### 8. References
- All Gateway API citation URLs, each with a one-line description
- Internal Infragistics docs links where relevant
- No external competitor links

### 9. Draft notes (stripped before publication)
```markdown
## Draft notes
- Open questions: [list any technical claims that need verification]
- Screenshot suggestions: [describe any diagrams or UI states worth capturing]
- Internal link candidates: [related Infragistics docs or blog posts to link to]
- Review flags: [list all <!-- VERIFY: --> tags and their reason]
```

## Section length guidelines

| Section | Target length |
|---|---|
| Opening | 100–150 words |
| Prerequisites | 3–8 bullets |
| Each core section | 200–400 words + code |
| Key considerations | 150–300 words |
| Summary | 3–5 bullets |
| Draft notes | As needed |

## Code sample rules

- Use real Ignite UI component names — never `MyGrid`, `DataComponent`, etc.
- Angular: separate `.ts` and `.html` blocks, both required
- React: `.tsx` with hooks pattern (no class components)
- Web Components: vanilla JS registration + usage, no framework wrapper
- Blazor: `.razor` with `@using` imports shown
- Language tag every fence: ` ```typescript `, ` ```html `, ` ```razor `
- If a sample is truncated for brevity, say so: `// ... (see full sample in repo)`

## What never goes in a blog post

- Company taglines or award mentions
- "Easy", "simple", "just" — these are dismissive to readers who find it hard
- "In conclusion" as a section header — use "Summary"
- Competitor product names
- Undated performance claims without a version reference
- Marketing CTAs — these are added post-draft by the marketing team
