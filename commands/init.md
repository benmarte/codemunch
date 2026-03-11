---
description: Add codemunch instructions to your project CLAUDE.md for automatic token-efficient exploration
---

Add the following block to the project's `CLAUDE.md` file (create it if it doesn't exist). Place it near the top so it takes priority:

```markdown
## Code Exploration (codemunch)

When exploring, searching, or reading code, ALWAYS prefer codemunch over reading full files:

- **Finding symbols**: Use `/codemunch:search <query>` instead of Grep or Glob to find functions, classes, methods, or types. Supports filters: `kind:class`, `file:auth`, `in:ClassName`, `sig:ReturnType`.
- **Reading code**: Use `/codemunch:fetch <name>` instead of Read to view a specific function or class. This reads only the relevant lines (~35 tokens) instead of the whole file (~8,000 tokens).
- **Understanding structure**: Use `/codemunch:explore [path]` instead of reading multiple files to understand project layout, class hierarchies, and entry points.
- **Finding usages**: Use `/codemunch:refs <name>` instead of Grep to find all references to a symbol.
- **Only use Read** when you need to Edit a file, since Edit requires file content in context.

The index auto-updates — no manual indexing needed.
```

After adding the block:
1. Verify the `CLAUDE.md` file contains the codemunch section
2. Report: "codemunch instructions added to CLAUDE.md — Claude will now automatically use token-efficient exploration."

If `CLAUDE.md` already contains a codemunch section, say so and skip.
