---
name: scaffold-and-verify
description: Verifies that a code snippet compiles cleanly in a pre-warmed Ignite UI scaffold. Use when code-agent needs to confirm a snippet is type-safe and uses correct APIs before it is included in a blog draft. Supports Angular and React. Returns PASS or FAIL with TypeScript errors.
allowed-tools: Bash, Read, Write
---

# Scaffold and verify

Use this skill when the task is to verify that a generated code snippet compiles correctly in the target framework with Ignite UI installed.

## Prerequisites

The pre-warmed scaffolds must be set up. Check with:

```bash
ls scaffolds/angular/node_modules 2>/dev/null && echo "Angular ready" || echo "Angular NOT ready — run: ./scaffolds/setup.sh angular"
ls scaffolds/react/node_modules 2>/dev/null && echo "React ready" || echo "React NOT ready — run: ./scaffolds/setup.sh react"
```

If a scaffold is not ready, run `./scaffolds/setup.sh <framework>` before proceeding. This takes 2–4 minutes once and is not repeated.

## Workflow

### Step 1 — Receive the snippet

Inputs from code-agent:
- `framework` — angular | react | web-components
- `snippet` — the raw code string to verify
- `context` — what this snippet demonstrates (for error interpretation)
- `attempt` — which iteration this is (1, 2, or 3)

### Step 2 — Write snippet to a temp file

```bash
SNIPPET_FILE="/tmp/igx-snippet-$(date +%s).ts"
cat > "$SNIPPET_FILE" << 'SNIPPET'
<snippet content here>
SNIPPET
```

### Step 3 — Wrap if needed

Detect snippet type and wrap appropriately:

```bash
WRAPPED_FILE="/tmp/igx-wrapped-$(date +%s).ts"
./scripts/wrap-snippet.sh <framework> "$SNIPPET_FILE" "$WRAPPED_FILE"
```

`wrap-snippet.sh` outputs the `WRAP_TYPE` so you know what wrapper was applied. Check the wrapped file looks sensible before proceeding.

### Step 4 — Run verification

```bash
./scripts/verify-snippet.sh <framework> "$WRAPPED_FILE"
```

Capture the full output. The script prints:
- `STATUS: PASS` or `STATUS: FAIL`
- `FRAMEWORK:` confirmation
- `DURATION:` seconds taken
- `ERRORS:` (on FAIL) — list of TypeScript errors

### Step 5 — Interpret results

**On PASS:**
Return the verified snippet to code-agent marked as `VERIFIED: true`. Include the wrap type so blog-agent knows whether the snippet needs additional context in the post.

**On FAIL:**
Parse the TypeScript errors. Common patterns and fixes:

| Error pattern | Likely cause | Fix |
|---|---|---|
| `Cannot find module 'igniteui-angular'` | Wrong import path | Check `references/igniteui-imports.md` for correct paths |
| `Property 'X' does not exist on type 'IgxGridComponent'` | Wrong property name | Query Gateway API for correct property name |
| `is not assignable to type` | Wrong data type | Fix the type annotation or cast |
| `Object is possibly 'undefined'` | Missing null check | Add `!` assertion or null guard |
| `Cannot find name 'X'` | Missing import | Add the correct import from `igniteui-angular` |

After interpreting errors, return structured feedback to code-agent for the fix iteration.

### Step 6 — Clean up temp files

```bash
rm -f "$SNIPPET_FILE" "$WRAPPED_FILE"
```

## Output format

Return to code-agent in this structure:

```
VERIFY_RESULT:
  status: PASS | FAIL | SKIP | ERROR
  framework: <framework>
  attempt: <n>
  duration: <seconds>
  wrap_type: <complete-component | class-body-fragment | statement-fragment>
  errors: []  # empty on PASS
  errors:     # on FAIL
    - "src/app/verify/verify.component.ts(12,5): error TS2339: Property 'rowVirtualize' does not exist..."
  fix_hint: ""  # on FAIL — your interpretation of what code-agent should change
```

## Iteration limit

Maximum 3 verification attempts per snippet. If FAIL after 3 attempts:
- Mark snippet as `VERIFIED: false, STATUS: MANUAL_REVIEW`
- Include all error output in the result
- Blog-agent will flag it with `<!-- VERIFY: build failed after 3 attempts -->`

Do not attempt a 4th iteration.
