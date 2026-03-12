<div align="center">

```
 ██████╗ ██████╗ ██████╗ ███████╗███╗   ███╗██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝████╗ ████║██║   ██║████╗  ██║██╔════╝██║  ██║
██║     ██║   ██║██║  ██║█████╗  ██╔████╔██║██║   ██║██╔██╗ ██║██║     ███████║
██║     ██║   ██║██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║██║     ██╔══██║
╚██████╗╚██████╔╝██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║
 ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝
```

**Zero-config, token-efficient code exploration for Claude Code — no MCP server, no Python, no database**

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e.svg)](LICENSE)
[![Languages](https://img.shields.io/badge/languages-40%2B-3b82f6)](#supported-languages)
[![Zero Deps](https://img.shields.io/badge/dependencies-zero-f59e0b)](#requirements)

</div>

---

## The problem

When Claude Code explores a codebase, the naive approach is to read whole files. An 800-line file costs ~8,000 tokens. Read ten files to find one function and you've burned 80,000 tokens before writing a single line of code.

Other solutions add an MCP server, a Python runtime, or a database — all of which consume their own resources and add complexity. codemunch takes a different approach: **a pure Claude Code plugin that runs with zero infrastructure overhead.**

**codemunch fixes this.** It auto-indexes your codebase into a flat JSON file and lets Claude fetch the exact 20 lines it needs instead of the 800-line file. No server process, no database daemon, no Python dependency — just install and start using it.

```
Without codemunch:  read auth.ts (800 lines) → ~8,000 tokens
With codemunch:     fetch validateToken()     →    ~35 tokens

Savings: 99.6%
```

---

## Why use codemunch?

Claude Code bills by token. Every file read costs tokens — and most of those tokens are wasted on code you didn't need to see.

| Scenario | Without codemunch | With codemunch | Savings |
|---|---|---|---|
| Find a function | Read full file (~8,000 tokens) | `search` + `fetch` (~47 tokens) | **99.4%** |
| Trace all usages of a symbol | Read 14 files (~112,000 tokens) | `refs` (~45 tokens) | **99.96%** |
| Understand project structure | Read 10+ files (~80,000 tokens) | `explore` (~200 tokens) | **99.75%** |
| Typical debugging session (30 lookups) | ~240,000 tokens | ~1,200 tokens | **99.5%** |

### Benchmarked context savings

We benchmarked codemunch against three real open-source repos — running 5 typical exploration tasks on each and measuring token consumption with vs without codemunch:

| Repo | Size | Traditional | codemunch | Savings |
|---|---|---|---|---|
| [expressjs/cors](https://github.com/expressjs/cors) | 6 files, ~8K tokens | 18,810 tokens | 1,281 tokens | **93.2%** |
| [koajs/koa](https://github.com/koajs/koa) | 82 files, ~52K tokens | 24,565 tokens | 2,316 tokens | **90.6%** |
| [fastify/fastify](https://github.com/fastify/fastify) | 290 files, ~468K tokens | 103,891 tokens | 3,174 tokens | **96.9%** |
| **Combined (15 tasks)** | **378 files** | **147,266 tokens** | **6,771 tokens** | **95.4%** |

Best case: **99.0% savings** (finding all references to `.send()` across 139 test files — `refs` instead of grep + reading files).
Worst case: **69.8% savings** (multi-fetch of related functions — still cheaper than reading one full file).

> Full benchmark methodology and per-task breakdown: [docs/benchmark-results.md](docs/benchmark-results.md)

That's **~22x less context usage** on average, which means:

- **Longer conversations** — you stay well within Claude's context window instead of hitting limits mid-task
- **Lower costs** — fewer tokens consumed per task directly reduces your API bill
- **Faster responses** — less input for Claude to process means quicker replies
- **Better results** — Claude sees only the relevant code, not thousands of lines of noise, leading to more focused and accurate responses

---

## How it works

codemunch uses a **three-tier engine** — it picks the best available tool per language and falls back automatically. No configuration required.

```
Tier 1 — LSP (Language Server)
  Byte-exact symbol boundaries, type signatures, cross-file references.
  Same engine powering "Go to Definition" in VS Code.
         ↓ not available?
Tier 2 — Universal ctags
  40+ languages. Near-exact boundaries. Ships with most Unix systems.
         ↓ not available?
Tier 3 — ripgrep
  Works on literally any language via regex patterns.
  If rg is installed, codemunch works.
```

### Auto-indexing

**You never need to manually index.** codemunch automatically:

- **First use**: Detects your stack, configures engines, and builds the full index when you run any command
- **Subsequent uses**: Checks if files have changed since the last index and incrementally re-indexes only what's different
- **Incremental updates**: Tracks git blob hashes per file — only re-processes files that actually changed

```
First /codemunch:search → auto-detects stack → builds full index → runs your search
Next  /codemunch:fetch  → checks git diff → 2 files changed → re-indexes those 2 → fetches symbol
Later /codemunch:refs   → checks git diff → no changes → runs immediately
```

---

## Quick start

```bash
# 1. Add the marketplace and install the plugin
/plugin marketplace add benmarte/codemunch
/plugin install codemunch@codemunch

# 2. Start using it — indexing happens automatically
/codemunch:explore

# 3. Search for symbols
/codemunch:search validateToken

# 4. Read just that function — not the whole file
/codemunch:fetch validateToken

# 5. Find every place it's called
/codemunch:refs validateToken
```

That's it. No `/codemunch:index` needed. No config files to create. Just install and use.

---

## User guide

### Exploring a new codebase

When you first open a project, start with `/codemunch:explore` to get the lay of the land:

```bash
# Get a bird's-eye view of the whole project
/codemunch:explore

# Drill into a specific directory
/codemunch:explore src/api/

# Outline a single file
/codemunch:explore src/api/invoices.ts
```

This shows you the class hierarchy, entry points, and largest symbols — all without reading any source files. Token cost: under 200.

### Finding symbols

Use `/codemunch:search` for all symbol lookups — it handles both fuzzy name matching and structured filters:

```bash
# Fuzzy name search
/codemunch:search validate          # matches validateToken, validateEmail, etc.
/codemunch:search AuthService       # exact class name
/codemunch:search inv               # matches Invoice, invalidate, invoiceRouter

# Filter by kind
/codemunch:search kind:class        # all classes
/codemunch:search kind:interface    # all interfaces
/codemunch:search kind:method       # all methods

# Filter by file
/codemunch:search file:auth         # symbols in auth-related files

# Filter by container (class/module)
/codemunch:search in:AuthService    # methods on AuthService

# Filter by signature
/codemunch:search sig:Promise       # functions returning Promise

# Combine filters
/codemunch:search kind:method in:Invoice              # Invoice methods
/codemunch:search validate kind:function              # functions named "validate*"
/codemunch:search kind:interface file:api             # interfaces in api files
```

Output:
```
Found 6 symbols matching "validate":

  1.  validateToken     function   src/auth/tokens.ts:142      AuthService
  2.  validateInvoice   function   src/lib/validation.ts:89    —
  3.  validateAmount    function   src/lib/validation.ts:112   —
  4.  validateEmail     method     src/models/user.ts:34       UserModel
  5.  validateExpense   function   convex/expenses.ts:67       —
  6.  validateDate      function   src/utils/dates.ts:23       —

Use /codemunch:fetch <name> to read the source of any symbol.
Tokens used: 12
```

### Reading symbol source

Once you've found what you need, use `/codemunch:fetch` to read just that symbol:

```bash
/codemunch:fetch validateToken
/codemunch:fetch AuthService
/codemunch:fetch getUserById
```

Output:
```
📍 validateToken  [function]  src/auth/tokens.ts:142–163
   Signature: validateToken(token: string): Promise<User | null>
   Container: AuthService  |  References: 14
   ─────────────────────────────────────────
   async function validateToken(token: string): Promise<User | null> {
     ...20 lines of source...
   }
   ─────────────────────────────────────────
   Tokens: ~35  (saved ~8,400 vs reading full file)
```

If the same name exists in multiple files, you'll get a numbered disambiguation list.

### Finding references

Use `/codemunch:refs` to find every place a symbol is used:

```bash
/codemunch:refs validateToken
```

Output:
```
14 references to validateToken:

  src/api/auth.ts:23          authRouter.post('/login', validateToken, ...)
  src/api/invoices.ts:45      export const getInvoice = [validateToken, ...]
  src/middleware/index.ts:12  app.use('/api', validateToken)
  tests/auth.test.ts:34       await validateToken('expired-token')
  ...

Tokens: ~45  (saved ~42,000 vs reading 14 files)
```

Uses LSP for semantic precision (no false positives from comments or strings); falls back to ripgrep.

### Checking status

See your engine config, index freshness, and session savings:

```bash
/codemunch:status
```

```
codemunch status

Engines:
  TypeScript  → typescript-language-server (LSP) ✅
  Python      → universal-ctags ✅
  Bash        → ripgrep ✅

Index:
  Built:      2026-03-11 02:14 (3 hours ago)
  Symbols:    1,247 across 89 files
  Status:     ✅ fresh (auto-updates on next query if stale)

Session stats:
  Fetches:        23
  Tokens used:    ~840
  Tokens saved:   ~186,000
  Savings:        99.5%
```

---

## Commands

| Command | What it does | Typical token cost |
|---|---|---|
| `/codemunch:init` | Add auto-use instructions to CLAUDE.md (run once per project) | — |
| `/codemunch:search <query>` | Search symbols by name, kind, file, or container | ~12 |
| `/codemunch:fetch <name>` | Read exact source of one symbol | ~35 |
| `/codemunch:refs <name>` | Find all usages across codebase | ~45 |
| `/codemunch:explore [path]` | Structured overview of project or file | ~15–200 |
| `/codemunch:status` | Engine config, index freshness, session savings | — |
| `/codemunch:index [--force]` | Manually rebuild index (rarely needed) | ~50 |
| `/codemunch:disable` | Turn off enforcement (hook + CLAUDE.md rules) | — |
| `/codemunch:enable` | Turn enforcement back on | — |

---

## Supported languages

### Tier 1 — via LSP (byte-exact + type info + cross-file refs)

| Language | Language Server | Availability |
|---|---|---|
| TypeScript / JavaScript | `typescript-language-server` | usually with VS Code |
| Python | `pylsp` or `pyright` | likely |
| Go | `gopls` | with Go toolchain |
| Rust | `rust-analyzer` | with rustup |
| C / C++ | `clangd` or `ccls` | often |
| C# / .NET | `omnisharp` or `csharp-ls` | with VS/Rider |
| Java | `jdtls` | with IntelliJ |
| Kotlin | `kotlin-language-server` | maybe |
| Ruby | `solargraph` or `ruby-lsp` | maybe |
| PHP | `phpactor` or `intelephense` | maybe |
| Swift | `sourcekit-lsp` | macOS with Xcode |
| Lua | `lua-language-server` | maybe |
| Zig | `zls` | with Zig toolchain |
| Elixir | `elixir-ls` or `lexical` | maybe |
| Haskell | `haskell-language-server` | maybe |
| OCaml | `ocamllsp` | maybe |
| Bash | `bash-language-server` | rarely |

codemunch detects all of these automatically — no config needed.

### Tier 2 — via Universal ctags (40+ languages, no server needed)

ActionScript, Ada, Ant, Awk, Bash, C, C++, C#, Clojure, CoffeeScript, D, Elixir, Erlang, Fortran, Go, Groovy, Haskell, HTML, Java, JavaScript, JSON, Julia, Kotlin, Lisp, Lua, Make, Matlab, Objective-C, OCaml, Pascal, Perl, PHP, PowerShell, Python, R, Ruby, Rust, Scala, Scheme, Shell, SQL, Swift, Tcl, TypeScript, Verilog, VHDL, Vim, YAML, Zig, and more.

Install ctags if you don't have it:
```bash
brew install universal-ctags           # macOS
apt install universal-ctags            # Ubuntu/Debian
scoop install ctags                    # Windows
```

### Tier 3 — via ripgrep (any language)

Built-in patterns for TypeScript, JavaScript, Python, Go, Rust, Ruby, Java, Kotlin, C, C++, PHP, Swift, Lua, Zig, and Bash.

For any other language, add custom patterns to `.claude/codemunch/config.json`:

```json
{
  "custom_patterns": {
    "solidity": {
      "function": "^\\s*(function|modifier|event)\\s+(\\w+)",
      "class":    "^(contract|library|interface)\\s+(\\w+)"
    },
    "hcl": {
      "function": "^(resource|data|module|variable|output)\\s+\"(\\w+)\"\\s+\"(\\w+)\""
    },
    "prisma": {
      "class": "^(model|enum)\\s+(\\w+)\\s+\\{"
    }
  }
}
```

---

## Requirements

**Claude Code** — this is a Claude Code plugin, not an MCP server.

For the best experience, install **all** of the following. codemunch uses them as a fallback chain (LSP → ctags → ripgrep), so having all three ensures maximum precision and coverage:

```bash
# macOS (Homebrew)
brew install universal-ctags ripgrep jq

# Ubuntu / Debian
apt install universal-ctags ripgrep jq

# Windows (Scoop)
scoop install ctags ripgrep jq
```

| Tool | Why | Required? |
|---|---|---|
| **LSP server** | Most precise — exact types, signatures, cross-file references. Usually already installed if you use VS Code. | Recommended |
| **universal-ctags** | Fast symbol extraction for 40+ languages. Used when LSP isn't available for a language. | Recommended |
| **ripgrep** | Last-resort pattern matching. Also used for reference search fallback. | Recommended |
| **jq** | Fast JSON index queries. Falls back to Python if unavailable. | Optional |

codemunch works with just **one** of the above, but having all three gives you the best results — LSP for precision, ctags for breadth, and ripgrep as a safety net.

**No MCP server. No Python packages. No database. No npm install. No background processes. No compilation.**

---

## Installation

```bash
# Add the marketplace and install
/plugin marketplace add benmarte/codemunch
/plugin install codemunch@codemunch
```

Then run the one-time init to make Claude use codemunch automatically:
```bash
/codemunch:init
```

This adds instructions to your project's `CLAUDE.md` so Claude **automatically** uses codemunch for all code exploration — you never have to type `/codemunch:search` yourself. Claude will just do it whenever it needs to find or read code.

Alternatively, add the instructions manually to your project's `CLAUDE.md`:

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

### Enforcement hook (PreToolUse)

codemunch includes a **PreToolUse hook** that programmatically nudges Claude toward codemunch commands when it tries to `Read`, `Grep`, or `Glob` source files. The hook is installed automatically with the plugin — no setup needed.

**How it works:**

| Claude tries to... | Hook response |
|---|---|
| `Read` a `.ts`/`.py`/`.go`/etc. file (not for editing) | Nudge: "Use `/codemunch:fetch` instead" |
| `Grep` for a symbol pattern (function/class names) | Nudge: "Use `/codemunch:search` or `/codemunch:refs` instead" |
| `Glob` for source files | Nudge: "Use `/codemunch:explore` instead" |
| `Read` for editing, non-source files, non-symbol grep | Allowed through silently |

The hook doesn't block — it injects guidance so Claude self-corrects. Combined with `CLAUDE.md` instructions (from `/codemunch:init`), this achieves ~98% enforcement vs ~60-80% with instructions alone.

**Disabling enforcement:**

If you prefer codemunch as opt-in rather than enforced, disable it with a single command:

```bash
/codemunch:disable
```

This turns off the PreToolUse hook **and** removes the CLAUDE.md enforcement rules in one step. codemunch commands still work — they just won't be enforced.

To re-enable:
```bash
/codemunch:enable
```

---

After init (or manual setup), just talk to Claude normally:
```
"Fix the bug in the validateToken function"
→ Claude auto-uses /codemunch:search to find it, /codemunch:fetch to read it, then fixes it

"How does the auth flow work?"
→ Claude auto-uses /codemunch:explore and /codemunch:refs to trace the flow
```

---

## The index file

codemunch writes `.claude/codemunch/index.json` to your project and adds `.claude/codemunch/` to your `.gitignore` automatically. The index is a flat JSON file — no database, no daemon, no background process.

Each symbol entry:
```json
{
  "name": "validateToken",
  "kind": "function",
  "file": "src/auth/tokens.ts",
  "start_line": 142,
  "end_line": 163,
  "signature": "validateToken(token: string): Promise<User | null>",
  "container": "AuthService",
  "engine": "lsp"
}
```

The index also tracks `file_hashes` — a mapping of each file to its git blob hash. This powers incremental re-indexing: when you edit 3 files, only those 3 are re-processed instead of the entire project.

You never need to manually re-index. The index auto-updates when any query command detects stale files. If you want a clean rebuild, use `/codemunch:index --force`.

---

## Plugin structure

```
codemunch/
├── .claude-plugin/
│   ├── plugin.json           # plugin manifest
│   └── hooks/
│       └── hooks.json        # PreToolUse hook registration
├── hooks/
│   └── pretooluse.sh         # enforcement hook (disable via env or config)
├── skills/
│   ├── detect-lsp/           # detects installed language servers
│   ├── index/                # builds symbol index (LSP → ctags → rg)
│   ├── staleness-gate/       # auto-checks index freshness before queries
│   ├── fetch/                # reads exact symbol source from index
│   ├── search/               # queries index without reading files
│   ├── lsp/                  # direct LSP ops: refs, hover, definition, rename
│   ├── ctags/                # ctags indexing and JSON parsing
│   └── rg-fallback/          # ripgrep pattern-based indexing + custom patterns
└── commands/
    ├── init.md               # /codemunch:init (one-time CLAUDE.md setup)
    ├── search.md             # /codemunch:search
    ├── fetch.md              # /codemunch:fetch
    ├── refs.md               # /codemunch:refs
    ├── explore.md            # /codemunch:explore
    ├── status.md             # /codemunch:status
    ├── index.md              # /codemunch:index (manual, rarely needed)
    ├── disable.md            # /codemunch:disable (turn off enforcement)
    └── enable.md             # /codemunch:enable (turn enforcement back on)
```

---

## How codemunch compares

### codemunch vs context-mode

[context-mode](https://github.com/mksglu/context-mode) is an MCP server that sandboxes raw tool output (bash, web fetches, grep) to keep it out of your context window. It solves a different problem than codemunch — here's how they compare:

| Dimension | codemunch | context-mode |
|---|---|---|
| **What it solves** | Code exploration eats tokens (reading full files) | Tool output eats tokens (bash, web, grep dumps) |
| **Architecture** | Pure Claude Code plugin — flat JSON index | MCP server + SQLite database + FTS5 search |
| **Runtime deps** | None (uses existing `rg`, `ctags`, `jq`) | Node.js (`npx`/`npm install -g`), SQLite |
| **Background process** | None | MCP server running continuously |
| **Storage** | `.claude/codemunch/index.json` (~142 KB) | SQLite database (grows with sessions) |
| **Hook system** | 1 PreToolUse hook (optional, disableable) | 5+ hooks intercepting Bash, Read, WebFetch, Grep, Task |
| **Files it creates** | 1 JSON file | CLAUDE.md routing rules, SQLite DB, hooks config |
| **Context savings** | **95.4%** on code exploration (benchmarked) | **98%** on raw tool output (claimed) |
| **Scope** | Code navigation only | All tool output (bash, web, grep, screenshots) |
| **License** | MIT | ELv2 (restrictive) |

**Key insight:** They're complementary, not competing. codemunch prevents wasted tokens *before* they happen (by reading only the symbol you need). context-mode catches wasted tokens *after* they happen (by sandboxing large tool output). A user running both saves on code exploration (codemunch) AND on bash/web/grep output (context-mode).

### Resource overhead

| Resource | codemunch | context-mode |
|---|---|---|
| CPU at rest | 0 (no process) | MCP server idle |
| Memory | 0 (no process) | Node.js process + SQLite |
| Disk | ~142 KB JSON | SQLite DB (grows with sessions) |
| npm packages | 0 | Full npm dependency tree |
| Startup cost | None | MCP server spawn |

codemunch's design goal is **zero-overhead infrastructure** — no server, no database, no npm. If you want context savings with the absolute minimum resource footprint, codemunch is the lighter option. If you need broader coverage (sandboxing all tool output, session continuity), context-mode adds that at the cost of more infrastructure.

---

## FAQ

**Do I have to type `/codemunch:search` every time?**

No. Run `/codemunch:init` once per project — it adds instructions to your `CLAUDE.md` so Claude automatically uses codemunch whenever it needs to explore code. You just talk to Claude normally and it uses codemunch behind the scenes.

**Do I need to run `/codemunch:index` before using other commands?**

No. The index builds automatically on first use and stays up-to-date via incremental re-indexing. You never need to think about it.

**How does auto-indexing work?**

Every query command (search, fetch, refs, explore) runs a lightweight staleness check first. It compares the index timestamp against `git diff` to find changed files. If files changed, only those files are re-indexed. If no index exists, a full index is built. The overhead for a fresh index is negligible (<100ms).

**What if the same function name exists in multiple files?**

`fetch` shows a numbered disambiguation list and asks which one you want.

**Does this work with monorepos?**

Yes. Run any command from the repo root. Use `file:` filters in search to scope to a specific package.

**Does codemunch send my code anywhere?**

No. Everything stays local. The index lives in `.claude/codemunch/` in your project. No network calls.

**Why not just use LSP directly?**

codemunch does use LSP for operations that need it (refs, hover, rename). The index layer adds fast offline search without spinning up a language server for every lookup, plus ctags/rg fallback for languages without an LSP.

**Can I force a full re-index?**

Yes: `/codemunch:index --force` rebuilds from scratch.

---

## Inspiration

Conceptually inspired by [jgravelle/jcodemunch-mcp](https://github.com/jgravelle/jcodemunch-mcp) — a Python MCP server using tree-sitter for symbol-based retrieval. This plugin is an independent reimplementation as a native Claude Code plugin: no shared code, no MCP server, no Python dependency, no database — just a flat JSON index and 40+ languages via the LSP/ctags/rg tier system.

---

## License

MIT — see [LICENSE](LICENSE)
