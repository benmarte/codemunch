# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.3.1] - 2026-03-13

### Fixed
- Expanded .gitignore with codemunch generated files, editor files, and OS entries

## [1.3.0] - 2026-03-13

### Fixed
- Replace echo-pipe patterns with herestrings and input redirection in hooks
- Add jq availability guard to PreToolUse hook
- Add gh/timeout guards to SessionStart hook for portability

### Added
- Upgrade instructions for users with stale installs (pre-upgrade-command)

## [1.2.0] - 2026-03-12

### Added
- `/codemunch:upgrade` command to check for and install the latest version
- SessionStart hook for daily update checks with stderr notification

## [1.1.0] - 2026-03-12

### Added
- PreToolUse hook for programmatic codemunch enforcement
- `/codemunch:disable` and `/codemunch:enable` commands
- Disable option to PreToolUse hook with documentation

## [1.0.0] - 2026-03-11

### Added
- Initial release
- `/codemunch:index` — build symbol index using LSP, ctags, or ripgrep
- `/codemunch:search` — search symbols by name, kind, file, or container
- `/codemunch:fetch` — fetch exact source of a named symbol
- `/codemunch:refs` — find all references to a symbol
- `/codemunch:explore` — token-efficient codebase overview
- `/codemunch:init` — add codemunch rules to project CLAUDE.md
- Support for TypeScript, JavaScript, Python, Go, Rust, Ruby, Java, C#, PHP, Swift, Kotlin
- Benchmark results: 91.7% context savings

[Unreleased]: https://github.com/benmarte/codemunch/compare/v1.3.1...HEAD
[1.3.1]: https://github.com/benmarte/codemunch/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/benmarte/codemunch/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/benmarte/codemunch/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/benmarte/codemunch/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/benmarte/codemunch/releases/tag/v1.0.0
