---
description: Token-efficient codebase overview showing symbol map, file structure, and entry points without reading source files
argument-hint: "[path]"
---

**First**, run the staleness-gate skill to ensure the index is fresh.

Then provide a structured overview using only the codemunch index and directory listing. Do NOT read any source files.

If $ARGUMENTS is a file path, show:
1. All symbols in that file (name, kind, line range)
2. Each symbol's signature (from index)
3. Estimated complexity (line count per symbol)
4. Total: "X symbols, Y lines — fetch any with /codemunch:fetch <n>"

If $ARGUMENTS is a directory or empty (whole project), show:
1. **File tree** — `find . -type f -name "*.ts" | head -30` (adjust extension per detected language)
2. **Class hierarchy** — all classes/structs/interfaces grouped by file
3. **Entry points** — top-level exported functions with no container
4. **Largest symbols** — top 10 by line count (most complex)
5. **Summary stats** from index

Always end with a tip on how to dig deeper:
"Use /codemunch:find <n> to search symbols, /codemunch:fetch <n> to read one, /codemunch:refs <n> to find usages."

Token target for a full project overview: under 200 tokens.
