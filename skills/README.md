# External skills — Ignite UI

The `code-agent` reads Ignite UI Skill files before generating any code snippet. These are the official skills that ship with the Ignite UI product repos and contain correct API patterns, common pitfalls, and working examples.

## How to wire them

Ignite UI Skills live in the product repos (e.g. `igniteui-angular`). There are two ways to make them available here:

### Option A — Git submodule (recommended for teams)

```bash
# From repo root
git submodule add https://github.com/IgniteUI/igniteui-angular.git vendor/igniteui-angular
git submodule add https://github.com/IgniteUI/igniteui-react.git vendor/igniteui-react
```

Then reference skill files from `vendor/igniteui-angular/skills/`.

### Option B — Symlink (local dev)

```bash
# If you have igniteui-angular cloned locally
ln -s /path/to/igniteui-angular/skills skills/igniteui-angular
ln -s /path/to/igniteui-react/skills skills/igniteui-react
```

### Option C — Copy (simplest, no sync)

```bash
cp -r /path/to/igniteui-angular/skills/igniteui-angular-grids skills/
cp -r /path/to/igniteui-angular/skills/igniteui-angular-components skills/
cp -r /path/to/igniteui-angular/skills/igniteui-angular-theming skills/
```

## Skills code-agent looks for

| Skill folder | Contents | Used when |
|---|---|---|
| `skills/igniteui-angular-grids/` | Grid, TreeGrid, HierarchicalGrid, PivotGrid patterns | Any Angular grid snippet |
| `skills/igniteui-angular-components/` | Form controls, layout, overlays | Non-grid Angular components |
| `skills/igniteui-angular-theming/` | Theming engine, Sass mixins, tokens | SCSS / theming snippets |
| `skills/igniteui-react-grids/` | React grid patterns | Any React grid snippet |

## Fallback behavior

If a skill file is not found, `code-agent` proceeds without it and flags the result with `skill_grounded: false`. The snippet still goes through `tsc` verification — it just lacks the semantic pattern guidance the Skill provides.

## Theming MCP

The `igniteui-theming` MCP server (configured in `.mcp.json`) gives `code-agent` live access to:
- Available palettes and their token names
- Component theme mixins and their parameters
- Current design token values

When a snippet involves theming or SCSS, `code-agent` queries the Theming MCP for token names before writing any Sass rather than guessing them.
