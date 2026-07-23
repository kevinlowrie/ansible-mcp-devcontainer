#!/bin/bash
# Merge the ansible-lint PostToolUse hook into /workspace/.claude/settings.json.
# Merge-or-create with jq additive merge to preserve existing user config,
# same pattern as init-mcp-config.sh. Called from postStartCommand.
#
# This is the Lightspeed replacement's other half: MCP servers (ansible-know,
# ansible) give Claude doc/module lookup, this hook gives it automatic lint
# feedback on every playbook/role edit — see ansible-lint-hook.sh.

set -euo pipefail

DEVCONTAINER_DIR="/workspace/.devcontainer"
WORKSPACE="/workspace"
SOURCE="$DEVCONTAINER_DIR/claude-settings-devcontainer.json"
TARGET="$WORKSPACE/.claude/settings.json"

if [ ! -f "$SOURCE" ]; then
  echo "init-claude-hooks: source not found: $SOURCE, skipping"
  exit 0
fi

mkdir -p "$WORKSPACE/.claude"

if [ ! -f "$TARGET" ]; then
  cp "$SOURCE" "$TARGET"
  echo "init-claude-hooks: created $TARGET"
  exit 0
fi

# Additive merge: existing settings are base, source hook config overlays.
# jq's `*` is a shallow merge per key, so an existing "hooks.PostToolUse"
# array would be replaced rather than appended-to — fine for this single-hook
# case, but worth knowing if more hooks get added later by hand.
merged=$(jq -s '.[0] * .[1]' "$TARGET" "$SOURCE")
printf '%s\n' "$merged" > "$TARGET"
echo "init-claude-hooks: updated $TARGET (merged)"
