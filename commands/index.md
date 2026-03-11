---
description: Manually build or refresh the codemunch symbol index. Usually not needed — the index auto-updates when you use search, fetch, refs, or explore. Use this command with --force to rebuild from scratch, or if you want to see a full indexing report.
arguments: optional --force to rebuild from scratch
---

Run the detect-lsp skill to configure engines, then run the index skill to build the symbol map.

Note: You usually don't need to run this manually. The index auto-updates whenever you use `/codemunch:search`, `/codemunch:fetch`, `/codemunch:refs`, or `/codemunch:explore`. Use `/codemunch:index --force` if you want a clean rebuild.

After indexing report:
- Total symbols found
- Files indexed
- Engine used per language (LSP / ctags / rg)
- Top 5 files by symbol count
- "Run /codemunch:search <name> to look up any symbol"
