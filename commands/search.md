---
description: Search for symbols by name, kind, file, container, or pattern. Supports plain text for fuzzy name matching and filters like "kind:class", "file:auth", "in:AuthService". Returns a compact index listing with no file reads. The index auto-updates if stale.
arguments: symbol name, pattern, or filter query
---

**First**, run the staleness-gate skill to ensure the index is fresh.

Then run the search skill with query: $ARGUMENTS

Support these query forms:
- Plain text (e.g. `validateToken`) — fuzzy name match (also handles what `/codemunch:find` used to do)
- `kind:function` / `kind:class` / `kind:method` / `kind:interface` etc.
- `file:auth` — symbols in files matching "auth"
- `in:AuthService` — symbols inside a container
- `sig:Promise` — symbols whose signature contains "Promise"

Multiple filters can be combined: `kind:method in:AuthService`

If $ARGUMENTS is empty, show the top 20 symbols by file and ask what to search for.

Always end with: "Use /codemunch:fetch <name> to read any symbol's source."
