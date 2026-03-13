#!/bin/bash
# codemunch PreToolUse hook
# Intercepts Read/Grep/Glob on source files and redirects to codemunch commands.
# Zero deps — just bash and jq (already a codemunch optional dep).

set -euo pipefail

# ─── Disable check ───────────────────────────────────────────────────────────
# Users can disable the hook in two ways:
#   1. Environment variable:  export CODEMUNCH_HOOK=off
#   2. Config file:           .claude/codemunch/config.json → { "hook_enabled": false }
#
# Either method silently disables enforcement. Re-enable by unsetting the env
# var or setting "hook_enabled": true in the config.

if [[ "${CODEMUNCH_HOOK:-}" == "off" ]]; then
  exit 0
fi

# Check config file (project-level)
CONFIG_FILE=".claude/codemunch/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
  HOOK_ENABLED=$(jq -r '.hook_enabled // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
  if [[ "$HOOK_ENABLED" == "false" ]]; then
    exit 0
  fi
fi

# ─── Source file extensions to intercept ─────────────────────────────────────
SOURCE_EXTS='\.ts$|\.tsx$|\.js$|\.jsx$|\.py$|\.go$|\.rs$|\.rb$|\.java$|\.kt$|\.c$|\.cpp$|\.h$|\.hpp$|\.cs$|\.php$|\.swift$|\.lua$|\.zig$|\.ex$|\.exs$|\.hs$|\.ml$|\.mli$|\.scala$|\.sh$|\.bash$|\.vue$|\.svelte$'

# Read JSON from stdin
INPUT=$(< /dev/stdin)

TOOL=$(jq -r '.tool_name // ""' <<< "$INPUT")
TOOL_INPUT=$(jq -r '.tool_input // {}' <<< "$INPUT")

# Helper: check if a path is a source file
is_source_file() {
  grep -qE "$SOURCE_EXTS" <<< "$1"
}

case "$TOOL" in
  Read)
    FILE_PATH=$(jq -r '.file_path // ""' <<< "$TOOL_INPUT")

    # Skip non-source files (config, json, md, yaml, etc.)
    if ! is_source_file "$FILE_PATH"; then
      exit 0
    fi

    # Output guidance message — don't block, just nudge
    cat <<'GUIDANCE'
{
  "additionalContext": "<codemunch_enforcement>\n  You are reading a source file. Before proceeding, ask yourself:\n\n  - Are you reading this file to EDIT it? → Allowed. Proceed.\n  - Are you reading to understand what a function/class does? → STOP. Use /codemunch:fetch <name> instead (~35 tokens vs ~8,000).\n  - Are you reading to find a symbol? → STOP. Use /codemunch:search <query> instead.\n  - Are you reading to understand project structure? → STOP. Use /codemunch:explore instead.\n\n  codemunch saves 95%+ of context tokens. Reading full source files for exploration is wasteful.\n</codemunch_enforcement>"
}
GUIDANCE
    ;;

  Grep)
    PATTERN=$(jq -r '.pattern // ""' <<< "$TOOL_INPUT")

    # Check if grep pattern looks like a symbol search:
    # - keyword prefixes (function, class, def, etc.)
    # - PascalCase identifiers (AuthService, UserModel)
    # - camelCase identifiers (validateToken, getUserById)
    # - snake_case identifiers (validate_token, get_user)
    # - identifiers followed by ( (function calls)
    if grep -qE '^(function |class |def |fn |func |type |interface |struct |enum |const |let |var |export |import |module )|^[A-Z][a-zA-Z0-9_]+$|^[a-z][a-zA-Z0-9]*[A-Z][a-zA-Z0-9_]*$|^[a-z]+(_[a-z]+)+$|^[a-zA-Z_][a-zA-Z0-9_]*\s*\(' <<< "$PATTERN"; then
      cat <<'GUIDANCE'
{
  "additionalContext": "<codemunch_enforcement>\n  This grep pattern looks like a symbol search. Use codemunch instead:\n\n  - Finding a function/class/type by name? → /codemunch:search <name>\n  - Finding all references to a symbol? → /codemunch:refs <name>\n  - Finding symbols of a specific kind? → /codemunch:search kind:class (or kind:function, kind:method)\n\n  codemunch's index is faster and more precise than grep for symbol lookups.\n</codemunch_enforcement>"
}
GUIDANCE
    else
      # Non-symbol grep (error messages, strings, config values) — allow
      exit 0
    fi
    ;;

  Glob)
    PATTERN=$(jq -r '.pattern // ""' <<< "$TOOL_INPUT")

    # Check if glob is searching for source files
    if grep -qE "$SOURCE_EXTS" <<< "$PATTERN"; then
      cat <<'GUIDANCE'
{
  "additionalContext": "<codemunch_enforcement>\n  You're searching for source files. Consider using codemunch instead:\n\n  - Understanding project structure? → /codemunch:explore [path]\n  - Finding a specific symbol? → /codemunch:search <name>\n\n  codemunch gives you structured symbol maps without reading file contents.\n</codemunch_enforcement>"
}
GUIDANCE
    else
      exit 0
    fi
    ;;

  *)
    # Not a tool we care about
    exit 0
    ;;
esac
