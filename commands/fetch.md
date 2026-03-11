---
description: Fetch the exact source code of a named symbol using the codemunch index. Reads only the lines for that symbol, not the whole file. Includes type signature and hover docs from LSP when available.
arguments: symbol name (e.g. "validateToken", "AuthService", "getUserById")
---

**First**, run the staleness-gate skill to ensure the index is fresh.

Then run the fetch skill with symbol name: $ARGUMENTS

If multiple matches are found, show a numbered disambiguation list and ask which one.
