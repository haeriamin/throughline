#!/usr/bin/env bash
# check-code-quality.sh (Claude Code PostToolUse hook — POSIX variant)
# Lightweight quality lint on just-written source files. Warns via stdout; never blocks.
# Dependency-free: JSON parser if present, else grep fallback.
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
  # No interpreter, or it produced nothing (e.g. a broken/stub python): fall back to grep.
  FILE_PATH=$(printf '%s' "$INPUT" \
    | grep -oE '"(file_path|path|notebook_path|target|destination)"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')
fi

[ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ] || exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.py|*.cs|*.go|*.rs|*.java|*.rb|*.php) ;;
  *) exit 0 ;;
esac

WARNINGS=0
if grep -nE '^(<<<<<<<|=======|>>>>>>>)' "$FILE_PATH" >/dev/null 2>&1; then
  echo "WARN [$FILE_PATH]: merge-conflict markers present"; WARNINGS=$((WARNINGS + 1))
fi
if grep -nE '(console\.log\(|debugger;|breakpoint\(\)|pdb\.set_trace)' "$FILE_PATH" >/dev/null 2>&1; then
  echo "WARN [$FILE_PATH]: possible debug statements left in source"; WARNINGS=$((WARNINGS + 1))
fi
if grep -nE '\b(TODO|FIXME)\b' "$FILE_PATH" | grep -v 'DEV-STATUS' >/dev/null 2>&1; then
  echo "WARN [$FILE_PATH]: TODO/FIXME without DEV-STATUS annotation (Constitution Principle IV)"; WARNINGS=$((WARNINGS + 1))
fi

[ "$WARNINGS" -gt 0 ] && echo "check-code-quality: $WARNINGS warning(s) — review before handoff"
exit 0
