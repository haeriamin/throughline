#!/usr/bin/env bash
# validate-bash-safety.sh (Claude Code PreToolUse hook, matcher: Bash — POSIX variant)
# Closes the shell bypass of the write-boundary and merge rules:
#  - blocks shell writes (redirect/copy/move/delete/in-place edit) touching /standards/ or /exemplars/
#  - blocks `git push` and `git merge` (merging/pushing is human — Constitution Principle VI)
# Conservative by design: read-only commands mentioning an immutable path together with a
# write token are blocked too — re-form the command without the write token.
# Protocol: stdin JSON {tool_name, tool_input:{command}}; exit 2 + stderr = block.
# Dependency-free: parses the command with a JSON tool if present; otherwise scans the raw
# payload (fail-safe — the raw JSON still contains the command, so this can only over-block).
set -uo pipefail

INPUT=$(cat)

PY="$(command -v python3 || command -v python || command -v py || true)"
if [ -n "$PY" ]; then
  CMD=$(printf '%s' "$INPUT" | "$PY" -c "
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    print(''); sys.exit(0)
print((data.get('tool_input') or {}).get('command', ''))
" 2>/dev/null || echo "")
  [ -n "$CMD" ] || exit 0
  C="${CMD//\\//}"
else
  # No interpreter: scan the whole raw payload. Conservative (may over-block, never under-block).
  C="${INPUT//\\//}"
fi

if echo "$C" | grep -qE '(^|[;&|"]|\\\\n)[[:space:]]*git([[:space:]]+(-c[[:space:]]+[^[:space:]]+|-C[[:space:]]+[^[:space:]]+|--[a-zA-Z-]+(=[^[:space:]]+)?|-[a-zA-Z]+))*[[:space:]]+(push|merge)([^a-zA-Z0-9_]|$)'; then
  echo "BLOCKED: 'git push' / 'git merge' are human-only actions (Constitution Principle VI)." >&2
  echo "Present the sdd/<slice> branch in your report; the human merges." >&2
  exit 2
fi

if echo "$C" | grep -qE '(^|/|[[:space:]"'"'"'=])(standards|exemplars)/'; then
  if echo "$C" | grep -qE '(>|>>|\btee\b|\bcp\b|\bmv\b|\brm\b|\brmdir\b|\btouch\b|\bln\b|\bsed[[:space:]]+-i\b|\bdd\b|\binstall\b)'; then
    echo "BLOCKED: shell command combines an immutable path (/standards/ or /exemplars/) with a write operation (Constitution Principle I)." >&2
    echo "These directories are human-curated and READ ONLY to agents. Read without redirection, or stop and escalate." >&2
    exit 2
  fi
fi
exit 0
