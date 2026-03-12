---
description: Disable codemunch enforcement — turns off the PreToolUse hook and removes CLAUDE.md rules
---

Disable codemunch enforcement for this project. Do both steps:

## Step 1: Disable the PreToolUse hook

Write or update `.claude/codemunch/config.json` to set `hook_enabled` to `false`. If the file exists, preserve other settings and only change `hook_enabled`. If it doesn't exist, create it:

```json
{
  "hook_enabled": false
}
```

## Step 2: Remove CLAUDE.md enforcement rules

Open the project's `CLAUDE.md` file and remove the entire codemunch section — from `## Code Exploration — MANDATORY (codemunch)` through `The index auto-updates — no manual indexing needed.` (inclusive of the closing markdown code fence if inside one).

If `CLAUDE.md` has no codemunch section, skip this step.

Do NOT delete the entire `CLAUDE.md` file — only remove the codemunch block.

## After both steps

Report:
- "codemunch enforcement disabled. The hook and CLAUDE.md rules are off."
- "codemunch commands (`/codemunch:search`, `/codemunch:fetch`, etc.) still work — they're just not enforced."
- "Run `/codemunch:enable` to re-enable enforcement."
