---
description: Fetch the exact source code of a named symbol, reading only the relevant lines
argument-hint: "<symbol-name>"
---

**First**, run the staleness-gate skill to ensure the index is fresh.

Then run the fetch skill with symbol name: $ARGUMENTS

If multiple matches are found, show a numbered disambiguation list and ask which one.
