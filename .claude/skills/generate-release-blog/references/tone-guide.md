# Tone and voice guide

Standards for all Infragistics developer blog content. Applies to blog-agent output. Proofreader enforces this guide during review.

## Core voice

**Direct.** State what the post is about in the first sentence. No wind-up.

**Technical.** Assume the reader can read code. Explain the *why* behind configurations; skip explaining what a `for` loop does.

**Respectful of the reader's time.** If something is straightforward, say so briefly and move on. If it's genuinely complex, spend the words — but earn them.

**Honest.** Acknowledge limitations, known bugs, or performance tradeoffs. Developers trust posts that say "this doesn't work well when X" more than posts that only describe the happy path.

## What Infragistics developer tone sounds like

Good:
> `IgxGridComponent` renders all rows into the DOM by default. For grids under 500 rows this is fine. For larger datasets, `[rowVirtualization]="true"` limits DOM nodes to the visible viewport plus a configurable buffer.

Bad:
> Ignite UI for Angular's world-class grid component offers an incredibly powerful virtualization feature that makes working with large datasets a breeze for modern enterprise development teams.

The difference: the good version is a fact. The bad version is a sales pitch wearing technical clothing.

## Banned phrases

These appear in first drafts and must be removed:

| Phrase | Why it's banned |
|---|---|
| "In today's fast-paced world" | Filler. Cut the entire sentence. |
| "easy", "simple", "just" | Condescending to readers who struggle |
| "powerful", "robust", "world-class" | Marketing words. Prove it with a benchmark instead. |
| "seamlessly" | Meaningless adverb |
| "leverage" (as a verb) | Jargon. Use "use" |
| "In conclusion" | Use "Summary" as the section header |
| "As you can see" | If we can't see it without prompting, the writing is unclear |
| "It's worth noting that" | Just note it. Remove the meta-commentary. |
| "This blog post will cover" | Just cover it. |
| "I hope this helps" | Sign-off filler. Cut. |

## Technical writing conventions

**API names** — use backtick code style for all component, property, method, and event names: `IgxGridComponent`, `[data]`, `onRowSelectionChange`.

**Versions** — always qualify version-specific behavior: "As of Ignite UI for Angular 18.1, `IgxGridComponent` supports...". Never leave a version claim undated.

**Code samples** — introduce every sample with one sentence explaining what it demonstrates. Don't leave a code block hanging without context.

**Acronyms** — spell out on first use: "Model Context Protocol (MCP)". After first use, abbreviation only.

**Numbers** — spell out one through nine; use numerals for 10 and above. Exception: always use numerals with units: "50,000 rows", "4 KB".

## Sentence structure

- Prefer active voice: "the grid renders" not "rows are rendered by the grid"
- Vary sentence length. Short sentences land punches. Longer ones build context. Mix them.
- One idea per paragraph for technical explanations
- Lists for 3+ parallel items; prose for 1–2

## Headers

- H2 for main sections
- H3 for subsections within a core section
- Sentence case only: "Virtual scrolling configuration" not "Virtual Scrolling Configuration"
- No headers for the opening paragraph — let it flow

## Code-to-prose ratio

- Tutorial posts: roughly 40% code, 60% explanation
- Deep-dive posts: roughly 30% code, 70% analysis
- Tips posts: roughly 50% code, 50% context

If a section runs 4 paragraphs of prose with no code, question whether it belongs in a developer blog or in docs instead.
