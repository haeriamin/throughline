#!/usr/bin/env bash
# install.sh — interactive installer for Throughline tool adapters (macOS/Linux, no Python required).
#
# Picks which AI coding tools you want, generates their thin adapters from the single source of
# truth (tools/convert.sh), and wires per-OS hooks for the tools that enforce them
# (tools/setup-hooks.sh). The Windows peer is tools/install.ps1.
#
#   bash tools/install.sh                       # interactive
#   bash tools/install.sh --list                # list tools, exit
#   bash tools/install.sh --tool cursor         # one tool
#   bash tools/install.sh --all                 # every tool
#   bash tools/install.sh --tool cursor --no-interactive --dry-run
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILES="$ROOT/.throughline/adapters/profiles"
DASH=$'\xe2\x80\x94'

TOOL=""; ALL=0; LIST=0; NOINT=0; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tool) TOOL="$2"; shift 2 ;;
    --all) ALL=1; shift ;;
    --list) LIST=1; shift ;;
    --no-interactive) NOINT=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

get_field() { awk -v k="$2" 'index($0, k" = ")==1 { print substr($0, length(k)+4); exit }' "$1"; }

IDS=()
for f in "$PROFILES"/*.profile; do IDS+=("$(basename "$f" .profile)"); done
IFS=$'\n' IDS=($(printf '%s\n' "${IDS[@]}" | sort)); unset IFS

field_for() { get_field "$PROFILES/$1.profile" "$2"; }

show_table() {
  printf '\n  %-3s %-10s %-12s %-16s %s\n' "#" "id" "status" "tier" "name"
  printf '  %s\n' "------------------------------------------------------------"
  local i=1 id tier label
  for id in "${IDS[@]}"; do
    tier="$(field_for "$id" tier)"
    if [ "$tier" = "A" ]; then label="A (enforced)"; else label="B (rules-only)"; fi
    printf '  %-3s %-10s %-12s %-16s %s\n' "$i" "$id" "$(field_for "$id" status)" "$label" "$(field_for "$id" display)"
    i=$((i+1))
  done
  printf '\n'
}

if [ "$LIST" -eq 1 ]; then show_table; exit 0; fi

# Resolve selection into SELECTED[].
SELECTED=()
if [ -n "$TOOL" ]; then
  case " ${IDS[*]} " in *" $TOOL "*) SELECTED=("$TOOL") ;; *) echo "Unknown tool '$TOOL'. Run --list." >&2; exit 2 ;; esac
elif [ "$ALL" -eq 1 ]; then SELECTED=("${IDS[@]}")
elif [ "$NOINT" -eq 1 ]; then echo "Non-interactive run needs --tool <id> or --all." >&2; exit 2
else
  echo "Throughline multi-tool installer"
  echo "Pick the tools to set up. Tier A enforce the guards via hooks; Tier B are rules-only (advisory)."
  show_table
  printf "Enter numbers (comma/space separated), 'all', or blank to cancel: "
  read -r answer
  if [ -z "$answer" ]; then echo "Cancelled."; exit 0; fi
  if [ "$answer" = "all" ]; then SELECTED=("${IDS[@]}")
  else
    for tok in $(echo "$answer" | tr ',' ' '); do
      if printf '%s' "$tok" | grep -qE '^[0-9]+$'; then
        idx=$((tok-1)); [ "$idx" -ge 0 ] && [ "$idx" -lt "${#IDS[@]}" ] && SELECTED+=("${IDS[$idx]}")
      else
        case " ${IDS[*]} " in *" $tok "*) SELECTED+=("$tok") ;; esac
      fi
    done
  fi
fi
[ "${#SELECTED[@]}" -eq 0 ] && { echo "Nothing selected."; exit 0; }

# 1. Generate shared content + tool adapters (single convert invocation).
if [ "$ALL" -eq 1 ] || [ "${#SELECTED[@]}" -gt 1 ]; then
  printf '\n==> Generating shared content + all tool adapters (convert --tool all)\n'
  args=(--tool all); [ "$DRY" -eq 1 ] && args+=(--dry-run)
  bash "$SCRIPT_DIR/convert.sh" "${args[@]}"
else
  printf '\n==> Generating shared content + %s (convert --tool %s)\n' "$(field_for "${SELECTED[0]}" display)" "${SELECTED[0]}"
  args=(--tool "${SELECTED[0]}"); [ "$DRY" -eq 1 ] && args+=(--dry-run)
  bash "$SCRIPT_DIR/convert.sh" "${args[@]}"
fi

need_hooks() {
  local id pf
  for id in "$@"; do
    case "$id" in claude|codex) return 0 ;; esac
    pf="$PROFILES/$id.profile"
    [ "$(field_for "$id" emit_hooks)" = "true" ] && return 0
  done
  return 1
}

# 2. Wire hooks per-OS when a hook-using tool was installed (not rules-only Tier B).
if [ "$DRY" -eq 0 ] && need_hooks "${SELECTED[@]}"; then
  printf '\n==> Wiring per-OS hooks (setup-hooks.sh)\n'
  bash "$SCRIPT_DIR/setup-hooks.sh"
fi

# 3. Per-tool next steps.
printf '\nDone.'; [ "$DRY" -eq 1 ] && printf ' (dry run - nothing written)'; printf '\n'
for id in "${SELECTED[@]}"; do
  case "$id" in
    codex)  echo "  codex:   copy .codex/prompts/*.md into \$CODEX_HOME/prompts/ (default ~/.codex/prompts)." ;;
    cursor) echo "  cursor:  reload the window so Cursor reads .cursor/agents, .cursor/commands, and hooks.json." ;;
    antigravity) echo "  antigravity: open this repo in Antigravity; it reads GEMINI.md, .agent/rules/, .agents/personas/, and .agents/hooks.json." ;;
    opencode) echo "  opencode:  run opencode in this repo; it reads opencode.json, .opencode/throughline.md, agents, and commands." ;;
    qwen) echo "  qwen:      run qwen in this repo; it reads QWEN.md, .qwen/agents/, .qwen/commands/, and .qwen/settings.json." ;;
    kimi) echo "  kimi:      run kimi in this repo; it reads .kimi/AGENTS.md, .kimi/personas/, workflows, and .kimi/config.toml." ;;
    *) [ "$(field_for "$id" tier)" = "B" ] && echo "  $id: rules-only $DASH guards are INSTRUCTED, not enforced. Copy $(field_for "$id" rules_file) into your workspace where $(field_for "$id" display) reads its rules." ;;
  esac
done
