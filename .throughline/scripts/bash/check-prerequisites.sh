#!/usr/bin/env bash
# check-prerequisites.sh — verify lifecycle phase prerequisites for the active feature.
# Usage: ./check-prerequisites.sh plan|tasks|implement
# Outputs JSON: { "OK": ..., "FEATURE_DIR": ..., "MISSING": [...] }
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

PHASE="${1:?usage: check-prerequisites.sh plan|tasks|implement}"
case "$PHASE" in plan|tasks|implement) ;; *) echo "ERROR: bad phase '$PHASE'" >&2; exit 2 ;; esac

ROOT="$(get_repo_root)"
FEATURE_DIR="$(get_feature_directory)"
MISSING=()

case "$PHASE" in
  plan)      REQUIRED=(spec.md) ;;
  tasks)     REQUIRED=(spec.md plan.md) ;;
  implement) REQUIRED=(spec.md plan.md tasks.md) ;;
esac
for f in "${REQUIRED[@]}"; do
  [ -f "$FEATURE_DIR/$f" ] || MISSING+=("$f")
done

SPEC="$FEATURE_DIR/spec.md"
if [ -f "$SPEC" ] && grep -q '\[NEEDS CLARIFICATION' "$SPEC"; then
  MISSING+=("unresolved [NEEDS CLARIFICATION] markers in spec.md")
fi

if [ "$PHASE" != "plan" ] && [ -f "$SPEC" ]; then
  CLASS="$(sed -n 's/.*\*\*Class\*\*:[[:space:]]*\(HIGH\|CRITICAL\).*/\1/p' "$SPEC" | head -n 1)"
  if [ -n "$CLASS" ]; then
    if [ ! -f "$FEATURE_DIR/design.md" ]; then
      MISSING+=("design.md (required for $CLASS complexity)")
    elif ! grep -q '\*\*Status\*\*:.*Approved' "$FEATURE_DIR/design.md"; then
      MISSING+=("design.md approval (Status must be Approved)")
    fi
  fi
fi

REL="${FEATURE_DIR#"$ROOT"/}"
if [ "${#MISSING[@]}" -eq 0 ]; then
  printf '{"OK":true,"FEATURE_DIR":"%s","MISSING":[]}\n' "$REL"
else
  ITEMS="$(printf '"%s",' "${MISSING[@]}")"
  printf '{"OK":false,"FEATURE_DIR":"%s","MISSING":[%s]}\n' "$REL" "${ITEMS%,}"
  exit 1
fi
