#!/bin/bash
# ansible-lint-hook.sh — Claude Code PostToolUse hook.
#
# Replaces the on-save/inline-suggestion half of what Ansible Lightspeed used
# to provide: whenever Claude edits or writes a playbook/role/task YAML file,
# run ansible-lint against it and surface the findings back into the
# conversation so Claude can act on them in the same turn.
#
# Wired up by init-claude-hooks.sh into /workspace/.claude/settings.json.
#
# Claude Code passes the hook a JSON payload on stdin with (at minimum)
# tool_name and tool_input.file_path. We only care about Edit/Write on
# Ansible-shaped YAML.

set -euo pipefail

PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

# Nothing to lint (hook fired for a non-file tool, or jq/parse failed)
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.yml|*.yaml) ;;
  *) exit 0 ;;
esac

# Only bother for paths that look Ansible-shaped, to avoid linting unrelated
# YAML (Helm values, docker-compose, etc.) that happens to live in the repo.
case "$FILE_PATH" in
  */playbooks/*|*/roles/*|*/tasks/*|*/handlers/*|*/molecule/*) ;;
  *) exit 0 ;;
esac

[ -f "$FILE_PATH" ] || exit 0
command -v ansible-lint >/dev/null 2>&1 || exit 0

LINT_OUTPUT=$(ansible-lint "$FILE_PATH" 2>&1) && STATUS=0 || STATUS=$?

if [ "$STATUS" -ne 0 ]; then
  echo "ansible-lint findings for $FILE_PATH:"
  echo "$LINT_OUTPUT"
fi

# Always exit 0 — this hook informs, it never blocks the edit.
exit 0
