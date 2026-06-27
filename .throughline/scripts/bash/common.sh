#!/usr/bin/env bash
# common.sh — shared helpers for Throughline lifecycle scripts (source this file).
set -euo pipefail

get_repo_root() {
  local dir
  dir="$(pwd)"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.throughline/memory/constitution.md" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "ERROR: not inside the framework (no .throughline/memory/constitution.md found)" >&2
  return 1
}

# --- target resolution (target-side SDD provenance: specs live in <target>/.throughline/specs) ---
read_target_field() {
  # $1 = target id, $2 = field, $3 = default (optional)
  local root yml v
  root="$(get_repo_root)" || return 1
  yml="$root/targets/$1.yml"
  [ -f "$yml" ] || { echo "ERROR: target '$1' not registered ($yml missing)" >&2; return 1; }
  # tr -d '\r' strips CRLF carriage returns so values from Windows-authored target files do not leak a trailing \r.
  v="$(sed -n "s/^[[:space:]]*$2[[:space:]]*:[[:space:]]*//p" "$yml" | tr -d '\r' | head -n1 | sed -e 's/[[:space:]]*#.*$//' -e 's/^"//' -e 's/"$//')"
  if [ -z "$v" ]; then
    if [ -n "${3:-}" ]; then echo "$3"; return 0; fi
    echo "ERROR: target '$1' has no '$2' in $yml" >&2; return 1
  fi
  echo "$v"
}
# to_wsl_path: under WSL, map a Windows drive path (C:/... or C:\...) to its /mnt/<drive>/... mount
# so the bash lifecycle helpers can act on a Windows-checkout target. No-op on native Linux/macOS and
# under Git Bash (where C:/... already resolves) — gated on WSL detection so it never rewrites elsewhere.
to_wsl_path() {
  local p="$1"
  if grep -qi microsoft /proc/version 2>/dev/null && printf '%s' "$p" | grep -qE '^[A-Za-z]:[/\\]'; then
    local drive rest
    drive="$(printf '%s' "$p" | cut -c1 | tr '[:upper:]' '[:lower:]')"
    rest="$(printf '%s' "$p" | cut -c3- | tr '\\' '/')"
    printf '/mnt/%s%s' "$drive" "$rest"
    return 0
  fi
  printf '%s' "$p"
}
get_target_root() { to_wsl_path "$(read_target_field "$1" "path")"; }
get_target_throughline_dir() { read_target_field "$1" "throughline_dir" ".throughline"; }
get_target_specs_dir() {
  local tr td
  tr="$(get_target_root "$1")" || return 1
  td="$(get_target_throughline_dir "$1")" || return 1
  echo "$tr/$td/specs"
}

get_feature_directory() {
  # Active slice's spec dir (absolute, target-side) from .throughline/feature.json.
  local root feature_json fd
  root="$(get_repo_root)" || return 1
  feature_json="$root/.throughline/feature.json"
  if [ -f "$feature_json" ]; then
    fd="$(sed -n 's/.*"feature_directory"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$feature_json")"
    if [ -n "$fd" ] && [ -d "$fd" ]; then echo "$fd"; return 0; fi
  fi
  echo "ERROR: no active feature directory. Run /throughline.specify first." >&2
  return 1
}

get_next_feature_number() {
  # Per-target numbering: scan <target>/.throughline/specs/. $1 = target id.
  local specs max n d
  specs="$(get_target_specs_dir "$1")" || return 1
  max=0
  for d in "$specs"/[0-9][0-9][0-9]-*; do
    [ -d "$d" ] || continue
    n=$((10#$(basename "$d" | cut -c1-3)))
    [ "$n" -gt "$max" ] && max=$n
  done
  printf "%03d" $((max + 1))
}
