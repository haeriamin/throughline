#!/usr/bin/env bash
# log-tool-use.sh (Claude Code PostToolUse hook — POSIX variant)
# Appends a structured entry to wiki/log.md for file-writing tool calls (Principle VII).
# Never blocks (always exits 0). Dependency-free: JSON parser if present, else grep fallback.
set -uo pipefail

INPUT=$(cat)

PY="$(command -v python3 || command -v python || command -v py || true)"
TOOL_NAME=""; FILE_PATH=""; ROOT=""
if [ -n "$PY" ]; then
  eval "$(printf '%s' "$INPUT" | "$PY" -c "
import json, shlex, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get('tool_input') or {}
fp = next((ti[f] for f in ['file_path', 'path', 'notebook_path', 'target', 'destination'] if f in ti), '')
print('TOOL_NAME=' + shlex.quote(data.get('tool_name', 'unknown')))
print('FILE_PATH=' + shlex.quote(fp))
print('ROOT=' + shlex.quote(data.get('cwd', '.')))
" 2>/dev/null)" 2>/dev/null || true
fi
if [ -z "${FILE_PATH:-}" ]; then
  # No interpreter, or it produced nothing (e.g. a broken/stub python): fall back to grep.
  FILE_PATH=$(printf '%s' "$INPUT" \
    | grep -oE '"(file_path|path|notebook_path|target|destination)"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')
  TOOL_NAME=$(printf '%s' "$INPUT" \
    | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')
  ROOT=$(printf '%s' "$INPUT" \
    | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')
fi
TOOL_NAME="${TOOL_NAME:-unknown}"
ROOT="${ROOT:-.}"

[ -n "${FILE_PATH:-}" ] || exit 0
case "$FILE_PATH" in *wiki/log.md*) exit 0 ;; esac

LOG="${ROOT:-.}/wiki/log.md"
[ -f "$LOG" ] || exit 0

TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
printf '| %s | hook | %s | - | - | file written | %s |\n' "$TS" "${TOOL_NAME:-unknown}" "$FILE_PATH" >> "$LOG"
exit 0
