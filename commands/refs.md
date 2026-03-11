---
description: Find all references to a symbol across the codebase using LSP or ripgrep
argument-hint: "<symbol-name>"
---

**First**, run the staleness-gate skill to ensure the index is fresh.

Then run the LSP skill's "Find all references" operation for: $ARGUMENTS

1. Look up the symbol in the codemunch index to get its file and line
2. Use LSP textDocument/references at that position (if LSP configured)
3. OR use ripgrep fallback if no LSP available
4. Return compact list of references with file, line, and one line of context
5. Report token savings vs reading all reference files

End with: "Use /codemunch:fetch <n> to read any of these call sites."
