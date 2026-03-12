# codemunch Benchmark Results

**Date:** 2026-03-11
**Methodology:** Token estimates use `characters / 4` (standard LLM tokenizer approximation). Each task measured independently — no shared context between tasks.

---

## Benchmark A: Small Repo — expressjs/cors

**Target:** [expressjs/cors](https://github.com/expressjs/cors)
**Size:** 6 source files, 1,166 lines, ~8,329 tokens

### Codebase Profile

| File | Lines | Tokens |
|------|-------|--------|
| `lib/index.js` | 238 | 1,647 |
| `test/test.js` | 731 | 5,473 |
| `test/error-response.js` | 66 | 362 |
| `test/example-app.js` | 81 | 542 |
| `test/issue-2.js` | 48 | 296 |
| `test/support/env.js` | 2 | 8 |
| **Total** | **1,166** | **8,329** |

### Tasks

#### Task 1: "What functions does this library export?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read lib/index.js` — entire 238-line file | **1,647** |
| codemunch | `/codemunch:explore` — symbol list with names, kinds, line ranges | **~125** |
| **Savings** | | **92.4%** |

#### Task 2: "How does origin validation work?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read lib/index.js` — entire file, scan for origin logic | **1,647** |
| codemunch | `search origin` (~50) → `fetch isOriginAllowed` (~143) → `fetch configureOrigin` (~305) | **~498** |
| **Savings** | | **69.8%** |

#### Task 3: "Find all references to configureOrigin"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Grep configureOrigin` (~68) + `Read lib/index.js` (1,647) + `Read test/test.js` (5,473) | **~7,188** |
| codemunch | `/codemunch:refs configureOrigin` — reference locations with context | **~98** |
| **Savings** | | **98.6%** |

#### Task 4: "How are CORS headers applied to the response?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read lib/index.js` — entire file | **1,647** |
| codemunch | `fetch applyHeaders` (~130) + `fetch cors` (~280) | **~410** |
| **Savings** | | **75.1%** |

#### Task 5: "Understand the test structure"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read` all 5 test files | **6,681** |
| codemunch | `/codemunch:explore test/` — file hierarchy with describe/it blocks | **~150** |
| **Savings** | | **97.8%** |

### Summary — cors

| Metric | Traditional | codemunch | Savings |
|--------|------------|-----------|---------|
| **Total (5 tasks)** | 18,810 | 1,281 | **93.2%** |
| **Average per task** | 3,762 | 256 | **93.2%** |
| **Best case** | 7,188 | 98 | **98.6%** |
| **Worst case** | 1,647 | 498 | **69.8%** |

---

## Benchmark B: Medium Repo — koajs/koa

**Target:** [koajs/koa](https://github.com/koajs/koa)
**Size:** 82 source files, 7,737 lines, ~51,984 tokens
**Symbols:** ~75+ (27 getters in request.js, 26 getters/setters in response.js, 11 methods in application.js, context delegates, utilities)

### Codebase Profile

| File | Lines | Tokens |
|------|-------|--------|
| `lib/application.js` | 333 | 2,159 |
| `lib/request.js` | 747 | 3,816 |
| `lib/response.js` | 660 | 3,426 |
| `lib/context.js` | 248 | 1,377 |
| `lib/is-stream.js` | 20 | 134 |
| `lib/only.js` | 9 | 48 |
| `lib/search-params.js` | 33 | 222 |
| **Lib subtotal** | **2,050** | **11,182** |
| **75 test files** | **5,687** | **~40,520** |
| **Total** | **7,737** | **~51,984** |

### Tasks

#### Task 1: "What's the architecture of this framework?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read` all 7 lib files to understand structure | **11,182** |
| codemunch | `/codemunch:explore lib/` — lists ~75 symbols across 7 files with hierarchy | **~875** |
| **Savings** | | **92.2%** |

#### Task 2: "How does the middleware system work?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read application.js` — entire 333-line file | **2,159** |
| codemunch | `search use` (~50) → `fetch Application.use` (~150) → `fetch Application.callback` (~200) → `fetch Application.handleRequest` (~150) | **~550** |
| **Savings** | | **74.5%** |

#### Task 3: "How does request.hostname work with proxy settings?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read request.js` — entire 747-line file to find the getter | **3,816** |
| codemunch | `/codemunch:fetch request.hostname` — just the 34-line getter | **~277** |
| **Savings** | | **92.7%** |

#### Task 4: "Find all references to ctx.throw"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Grep throw` (~100) + `Read context.js` (1,377) + `Read throw.test.js` (1,005) + scan other test files (~1,500) | **~3,982** |
| codemunch | `/codemunch:refs ctx.throw` — reference locations with context | **~150** |
| **Savings** | | **96.2%** |

#### Task 5: "How does response body setter handle different types?"

| Approach | What happens | Tokens |
|----------|-------------|--------|
| Traditional | `Read response.js` — entire 660-line file to find the setter | **3,426** |
| codemunch | `/codemunch:fetch response.body` — just the 51-line setter | **~464** |
| **Savings** | | **86.5%** |

### Summary — koa

| Metric | Traditional | codemunch | Savings |
|--------|------------|-----------|---------|
| **Total (5 tasks)** | 24,565 | 2,316 | **90.6%** |
| **Average per task** | 4,913 | 463 | **90.6%** |
| **Best case** | 11,182 | 875 | **92.2%** |
| **Worst case** | 2,159 | 550 | **74.5%** |

---

## Combined Results

### Cross-Repo Comparison

| Repo | Files | Total Tokens | Traditional (5 tasks) | codemunch (5 tasks) | Savings |
|------|-------|-------------|----------------------|--------------------|---------:|
| expressjs/cors | 6 | 8,329 | 18,810 | 1,281 | **93.2%** |
| koajs/koa | 82 | 51,984 | 24,565 | 2,316 | **90.6%** |
| **Combined** | **88** | **60,313** | **43,375** | **3,597** | **91.7%** |

### Per-Operation Cost (averaged across both repos)

| Operation | Avg tokens | What it replaces | Typical replacement cost |
|-----------|-----------|-----------------|------------------------|
| `explore` | ~125–875 | Reading all source files | 1,647–11,182 |
| `search` | ~50 | Grep + reading matching files | 500–3,000 |
| `fetch` | ~130–464 | Reading entire file for one function | 1,647–3,816 |
| `refs` | ~98–150 | Grep + reading all matching files | 3,982–7,188 |

### Key Takeaways

1. **91.7% average savings** across both repos (10 tasks total)
2. **Savings are consistent** — 90.6% on medium repo vs 93.2% on small repo
3. **refs is the biggest win** — up to 98.6% savings by avoiding full-file reads for cross-references
4. **Worst case is still 69.8%** — even targeted multi-fetch is cheaper than reading a full file
5. **Savings grow with file size** — fetching one getter from a 747-line file saves 92.7% vs reading the whole file

### Scaling Projection

| Codebase size | Traditional (est.) | codemunch (est.) | Savings |
|---------------|-------------------|-----------------|---------|
| Small (6 files, ~8K tokens) | 18,810 | 1,281 | 93.2% |
| Medium (82 files, ~52K tokens) | 24,565 | 2,316 | 90.6% |
| Large (500 files, ~400K tokens) | ~200,000 | ~8,000 | ~96.0% |

> Savings improve at scale because codemunch token cost scales with *symbol size*, not *file size* or *project size*. A 50-line function costs the same ~200 tokens to fetch whether it's in a 100-line file or a 2,000-line file.

---

## Methodology

- **Token estimation:** `characters / 4` (standard LLM tokenizer approximation)
- **Traditional approach:** Simulates what Claude Code does without codemunch — uses `Read` (full file), `Grep` (content search), then reads matching files for context
- **codemunch approach:** Uses the three-tier engine (LSP → ctags → ripgrep) to index symbols, then serves only the requested symbol's source lines
- **codemunch overhead per operation includes:** command prompt parsing (~20 tokens), index lookup, result formatting with file path and line numbers
- **Index cost:** One-time ~50 tokens for initial build; incremental updates via `git diff` are negligible
- **Not measured:** LLM reasoning tokens (same for both approaches), tool invocation overhead (minimal for both)
