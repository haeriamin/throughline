#!/usr/bin/env bash
# validate-immutable-paths.sh (Claude Code PreToolUse hook — POSIX variant)
# Blocks write tools targeting /standards/ or /exemplars/ (Constitution Principle I).
# Claude Code protocol: stdin JSON {tool_name, tool_input}; exit 2 + stderr = block.
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

block_immutable() {
  echo "BLOCKED: '$FILE_PATH' is inside an immutable directory (framework standards/ + exemplars/, or a target's .throughline/standards|exemplars)."
  echo "Constitution Principle I: these paths are human-curated and READ ONLY to agents."
  echo "Stop and escalate per .github/instructions/escalation-protocol.instructions.md."
  exit 2
}

# 1) Target-local overrides (<target>/.throughline/standards|exemplars) — immutable at any depth.
case "$NORMALIZED" in
  *"/.throughline/standards/"*|".throughline/standards/"*|*"/.throughline/exemplars/"*|".throughline/exemplars/"*)
    block_immutable ;;
esac

# 2) Framework org seeds at the repo root. Find the framework root from THIS script's location
#    (walk up to the constitution marker) and block only <root>/standards and <root>/exemplars.
#    Precise by design: a target's own src/standards or src/exemplars folder stays writable (the old
#    bare "*/standards/*" match blocked it by mistake).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
ROOT=""
d="$SCRIPT_DIR"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -f "$d/.throughline/memory/constitution.md" ]; then ROOT="$d"; break; fi
  d="$(dirname "$d")"
done

if [ -n "$ROOT" ]; then
  ROOTNORM="${ROOT//\\//}"
  ABS="$NORMALIZED"
  case "$NORMALIZED" in
    /*|[A-Za-z]:/*) : ;;                    # already absolute
    *) ABS="$ROOTNORM/${NORMALIZED#./}" ;;  # relative path → a framework file
  esac
  case "$ABS" in
    "$ROOTNORM/standards"|"$ROOTNORM/standards/"*|"$ROOTNORM/exemplars"|"$ROOTNORM/exemplars/"*)
      block_immutable ;;
  esac
else
  # Degraded (not inside a framework checkout): block only relative seed paths; never under-block.
  case "$NORMALIZED" in
    standards/*|exemplars/*) block_immutable ;;
  esac
fi
exit 0
