---
description: Show codemunch configuration, index status, and session token savings
---

Read .claude/codemunch/config.json and .claude/codemunch/index.json and .claude/codemunch/session.log and report:

1. **Engine config** — per language: LSP / ctags / rg and which server
2. **Index status** — last built, total symbols, files covered, auto-update enabled
3. **Session stats** — fetches this session, total tokens used, total tokens saved vs reading full files
4. **Stale check** — compare index `generated` timestamp against `git diff --name-only` to find files changed since index was built. Report how many files are stale (if any). Note: the index auto-updates on next query, so manual action is rarely needed.

Format:
```
codemunch status

Engines:
  TypeScript  → typescript-language-server (LSP) ✅
  Python      → ctags ✅  
  Bash        → ripgrep ✅

Index:
  Built:      2026-03-11 02:14 (3 hours ago)
  Symbols:    1,247 across 89 files
  Status:     ✅ fresh (no changes since last index)

Session:
  Fetches:    23
  Tokens used:     ~840
  Tokens saved:    ~186,000
  Savings:         99.5%
```
