---
description: Add codemunch instructions to your project CLAUDE.md for automatic token-efficient exploration
---

Add the following block to the project's `CLAUDE.md` file (create it if it doesn't exist). Place it near the top so it takes priority:

```markdown
## Code Exploration — MANDATORY (codemunch)

<CRITICAL>
You MUST use codemunch for ALL code exploration. This is NON-NEGOTIABLE. Do NOT ignore this rule.
Reading full files when a codemunch command exists for the task is a violation of your instructions.
</CRITICAL>

### Rules (enforced, no exceptions)

1. **NEVER read a full source file to understand what a function/class does.** Use `/codemunch:fetch <name>` instead. It reads ~35 tokens instead of ~8,000.
2. **NEVER use Grep or Glob to find functions, classes, or types.** Use `/codemunch:search <query>` instead. Supports filters: `kind:class`, `file:auth`, `in:ClassName`, `sig:ReturnType`.
3. **NEVER read multiple files to understand project structure.** Use `/codemunch:explore [path]` instead.
4. **NEVER use Grep to find symbol usages.** Use `/codemunch:refs <name>` instead.
5. **The ONLY exception**: Use Read when you need to Edit a file, since Edit requires file content in context.

### Decision tree

- Need to find a symbol? → `/codemunch:search`
- Need to read a symbol's code? → `/codemunch:fetch`
- Need to understand structure? → `/codemunch:explore`
- Need to find references? → `/codemunch:refs`
- Need to edit a file? → Read first, then Edit (this is the ONLY valid use of Read for source files)

The index auto-updates — no manual indexing needed.
```

After adding the block:
1. Verify the `CLAUDE.md` file contains the codemunch section
2. Report: "codemunch instructions added to CLAUDE.md — Claude will now automatically use token-efficient exploration."

If `CLAUDE.md` already contains a codemunch section, say so and skip.
