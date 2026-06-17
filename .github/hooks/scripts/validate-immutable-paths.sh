#!/usr/bin/env bash
# validate-immutable-paths.sh (Claude Code PreToolUse hook — POSIX variant)
# Blocks write tools targeting /standards/ or /exemplars/ (Constitution Principle I).
# Claude Code protocol: stdin JSON {tool_name, tool_input}; exit 1 + stderr = block.
# Dependency-free: uses a JSON parser if one is present, else a tolerant grep fallback.
set -uo pipefail

INPUT=$(cat)

PY="$(command -v python3 || command -v python || command -v py || true)"
FILE_PATH=""
if [ -n "$PY" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | "$PY" -c "
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    print(''); sys.exit(0)
ti = data.get('tool_input') or {}
for field in ['file_path', 'path', 'notebook_path', 'target', 'destination']:
    if field in ti:
        print(ti[field]); sys.exit(0)
print('')
" 2>/dev/null || echo "")
fi
if [ -z "$FILE_PATH" ]; then
  # No interpreter, or it produced nothing (e.g. a broken/stub python): fall back to grep
  # rather than trusting the empty result — a stub must not silently disable the guard.
  FILE_PATH=$(printf '%s' "$INPUT" \
    | grep -oE '"(file_path|path|notebook_path|target|destination)"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')
fi

[ -n "$FILE_PATH" ] || exit 0

NORMALIZED="${FILE_PATH//\\//}"
case "$NORMALIZED" in
  standards/*|*/standards/*|exemplars/*|*/exemplars/*)
    echo "BLOCKED: '$FILE_PATH' is inside an immutable directory (/standards/ or /exemplars/)."
    echo "Constitution Principle I: these paths are human-curated and READ ONLY to agents."
    echo "Stop and escalate per .github/instructions/escalation-protocol.instructions.md."
    exit 1
    ;;
esac
exit 0
