---
description: Re-enable codemunch enforcement — turns on the PreToolUse hook and restores CLAUDE.md rules
---

Re-enable codemunch enforcement for this project. Do both steps:

## Step 1: Enable the PreToolUse hook

Write or update `.claude/codemunch/config.json` to set `hook_enabled` to `true`. If the file exists, preserve other settings and only change `hook_enabled`. If it doesn't exist, create it:

```json
{
  "hook_enabled": true
}
```

## Step 2: Restore CLAUDE.md enforcement rules

Run `/codemunch:init` to add the enforcement rules back to `CLAUDE.md`. If the codemunch section already exists, skip this step.

## After both steps

Report:
- "codemunch enforcement enabled. The hook and CLAUDE.md rules are active."
- "Run `/codemunch:disable` to turn off enforcement."
