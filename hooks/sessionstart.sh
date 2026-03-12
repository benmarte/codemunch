#!/bin/bash
# codemunch SessionStart hook
# Checks for new releases on startup (max once per day).
# Prints a notification if an update is available.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
VERSION_FILE="$PLUGIN_ROOT/VERSION"
CACHE_DIR="${HOME}/.cache/codemunch"
LAST_CHECK_FILE="$CACHE_DIR/last_update_check"

# Read current version
if [[ ! -f "$VERSION_FILE" ]]; then
  exit 0
fi
CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')

# Only check once per day
mkdir -p "$CACHE_DIR"
if [[ -f "$LAST_CHECK_FILE" ]]; then
  LAST_CHECK=$(cat "$LAST_CHECK_FILE")
  NOW=$(date +%s)
  ELAPSED=$(( NOW - LAST_CHECK ))
  # 86400 = 24 hours
  if [[ $ELAPSED -lt 86400 ]]; then
    exit 0
  fi
fi

# Check GitHub for latest release (timeout after 3s to not block startup)
LATEST_VERSION=$(timeout 3 gh api repos/benmarte/codemunch/releases/latest --jq '.tag_name' 2>/dev/null | sed 's/^v//' || echo "")

# Record check time regardless of result
date +%s > "$LAST_CHECK_FILE"

if [[ -z "$LATEST_VERSION" ]]; then
  exit 0
fi

# Compare versions
if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
  # stderr → shown directly to user in status line
  echo "⬆ codemunch update available: v${CURRENT_VERSION} → v${LATEST_VERSION}. Run /codemunch:upgrade" >&2
  # additionalContext → Claude also knows and can remind user
  cat <<EOF
{
  "additionalContext": "<codemunch_update>\n  Update available: v${CURRENT_VERSION} → v${LATEST_VERSION}\n  Run /codemunch:upgrade to update.\n</codemunch_update>"
}
EOF
else
  exit 0
fi
