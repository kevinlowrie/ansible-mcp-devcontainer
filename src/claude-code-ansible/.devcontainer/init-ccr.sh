#!/bin/bash
# Start the claude-code-router (ccr) daemon if it isn't already running.
# Called from postStartCommand. Logs to /tmp/ccr-init.log for debugging.
#
# devcontainer.json's containerEnv points ANTHROPIC_BASE_URL at ccr's local
# port (default 3456) and sets ANTHROPIC_AUTH_TOKEN to a placeholder — ccr
# doesn't check that token against a real provider, it just needs *a*
# non-empty Bearer value from the client (Claude Code) before it applies its
# own routing and injects the real ANTHROPIC_API_KEY / OPENAI_API_KEY /
# GEMINI_API_KEY per-provider from ccr-config.json.

set -u

LOG=/tmp/ccr-init.log
echo "[$(date -Iseconds)] init-ccr.sh starting" > "$LOG"

if ! command -v ccr >/dev/null 2>&1; then
  echo "[$(date -Iseconds)] ERROR: ccr not on PATH (npm install -g @musistudio/claude-code-router failed?)" >> "$LOG"
  exit 1
fi

if ccr status >/dev/null 2>&1; then
  echo "[$(date -Iseconds)] ccr already running, skipping start" >> "$LOG"
  exit 0
fi

setsid ccr start >> "$LOG" 2>&1 &
DAEMON_PID=$!
sleep 2

if kill -0 "$DAEMON_PID" 2>/dev/null || ccr status >/dev/null 2>&1; then
  echo "[$(date -Iseconds)] ccr daemon started (PID $DAEMON_PID)" >> "$LOG"
else
  echo "[$(date -Iseconds)] ERROR: ccr daemon exited immediately, check log above" >> "$LOG"
  exit 1
fi
