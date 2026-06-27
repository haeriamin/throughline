#!/usr/bin/env bash
# Throughline adapter generator (bash; POSIX-friendly, works on bash 3.2+).
#
# Parity port of tools/convert.ps1. Renders the thin per-tool adapter wiring from the single source
# of truth in .throughline/adapters/source/, driven by the per-tool profiles in
# .throughline/adapters/profiles/. Output is byte-identical to convert.ps1 (LF line endings, same
# strings, hand-built JSON). CI runs both and diffs them to keep parity honest.
#
# Usage:
#   bash tools/convert.sh                 # generate every tool
#   bash tools/convert.sh --tool cursor   # generate one tool
#   bash tools/convert.sh --list          # list known tools
#   bash tools/convert.sh --dry-run       # show what would be written, write nothing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/.throughline/adapters/source"
PROFILES="$REPO_ROOT/.throughline/adapters/profiles"
DASH=$'\xe2\x80\x94'   # em dash (U+2014)

TOOL="all"
DRYRUN=0
LIST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tool) TOOL="$2"; shift 2 ;;
    --list) LIST=1; shift ;;
    --dry-run) DRYRUN=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# --- helpers ---------------------------------------------------------------

rel() { printf '%s' "${1#$REPO_ROOT/}"; }

write_generated() {
  # $1 = path, stdin = content. Normalizes CRLF, trims trailing newlines, writes exactly one LF newline.
  local path="$1" content
  content="$(cat)"
  content="${content//$'\r'/}"
  content="${content%"${content##*[![:space:]]}"}"
  if [ "$DRYRUN" -eq 1 ]; then echo "  would write $(rel "$path")"; return; fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
  echo "  wrote $(rel "$path")"
}

# Read a "key = value" field from a meta file (first match wins; value may contain ' = ').
get_field() {
  local file="$1" key="$2" default="${3:-}" val
  # Parity with convert.ps1 ConvertFrom-MetaText: skip blank/comment lines, split on the FIRST '=',
  # trim key and value, last assignment wins, and tolerate indentation / 'key=value' without spaces.
  val="$(awk -v k="$key" '
    { line = $0; sub(/\r$/, "", line)
      t = line; sub(/^[[:space:]]+/, "", t)
      if (t == "" || substr(t, 1, 1) == "#") next
      eq = index(line, "=")
      if (eq == 0) next
      kk = substr(line, 1, eq - 1); vv = substr(line, eq + 1)
      sub(/^[[:space:]]+/, "", kk); sub(/[[:space:]]+$/, "", kk)
      sub(/^[[:space:]]+/, "", vv); sub(/[[:space:]]+$/, "", vv)
      if (kk == k) { val = vv; found = 1 }
    }
    END { if (found) printf "%s", val }
  ' "$file")"
  if [ -z "$val" ]; then printf '%s' "$default"; else printf '%s' "$val"; fi
}

is_true() { [ "$(get_field "$1" "$2" false)" = "true" ]; }

esc_yaml() { printf '%s' "$1" | sed 's/"/\\"/g'; }
esc_json() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

# Filter: rewrite slash-command references (/dev:review) to the tool's punctuation. The source uses
# the colon form; dot-form tools get /dev.review. File PATHS contain "/dev/" or "dev." (never
# "/dev:") so they are untouched. $1 = separator (":" = no-op).
apply_slash() {
  if [ "$1" = ":" ]; then cat; else sed -e 's#/dev:#/dev'"$1"'#g' -e 's#/throughline:#/throughline'"$1"'#g'; fi
}

persona_body() {
  awk 'f{print} /^@@BODY@@[[:space:]]*$/{f=1}' "$1" \
    | awk 'BEGIN{b=0} {lines[NR]=$0} END{ s=1; while(s<=NR && lines[s]=="") s++; e=NR; while(e>=1 && lines[e]=="") e--; for(i=s;i<=e;i++) print lines[i] }'
}

markdown_body() {
  awk 'BEGIN{p=0;b=0} /^---[[:space:]]*$/{p++; if(p==2){b=1; next}} b{print}' "$1" \
    | awk 'BEGIN{b=0} {lines[NR]=$0} END{ s=1; while(s<=NR && lines[s]=="") s++; e=NR; while(e>=1 && lines[e]=="") e--; for(i=s;i<=e;i++) print lines[i] }'
}

persona_body_for() {
  local p="$1" name agent
  name="$(get_field "$p" name)"
  agent="$SRC/agents/$name.agent.md"
  if [ -f "$agent" ]; then markdown_body "$agent"; else persona_body "$p"; fi
}

list_ids() { for f in "$PROFILES"/*.profile; do basename "$f" .profile; done | sort; }

# --- command body builders -------------------------------------------------

build_command_core() {
  # $1=command-meta-file  $2=format  $3=profile-file
  local cf="$1" format="$2" pf="$3"
  local ns cmd persona ref word action steps tail final runbook
  ns="$(get_field "$cf" ns)"; cmd="$(get_field "$cf" cmd)"
  if [ "$ns" = "dev" ]; then
    persona="$(get_field "$cf" persona)"
    if [ -z "$persona" ]; then echo "Dev command '$ns.$cmd' requires a persona field" >&2; return 1; fi
    ref="$(get_field "$pf" persona_ref ".claude/agents/{persona}.md")"; ref="${ref/\{persona\}/$persona}"
    word=""; [ "$format" = "claude" ] && word="subagent "
    action="$(get_field "$cf" persona_action)"
    [ -z "$action" ] && action="$(get_field "$pf" spawn_note "delegate to it as a subagent.")"
    steps="$(get_field "$cf" runbook_steps "preconditions, steps, exit criteria, failure modes")"
    tail="$(get_field "$cf" runbook_tail)"
    final="$(get_field "$cf" final_note)"
    [ -z "$final" ] && final="Bootstrap first (Constitution Principle II); append the outcome to \`wiki/log.md\` (Principle VII)."
    runbook=".throughline/extensions/dev/commands/dev.$cmd.md"
    local tailpart=""; [ -n "$tail" ] && tailpart=" $tail"
    printf '%s\n\n%s\n\n%s' \
      "Adopt the **$persona** ${word}persona (\`$ref\`) $DASH $action" \
      "Follow the canonical runbook at \`$runbook\` step-by-step: ${steps}.${tailpart} The constitution at \`.throughline/memory/constitution.md\` overrides everything else." \
      "$final"
  elif [ "$ns" = "throughline" ]; then
    runbook=".github/agents/throughline.$cmd.agent.md"
    printf '%s\n\n%s' \
      "Follow the runbook at \`$runbook\` $DASH its content is runtime-neutral; ignore Copilot-specific frontmatter (tools/handoffs) and use your own tools. Helper scripts referenced there live under \`.throughline/scripts/\` (PowerShell and bash variants)." \
      "Check \`.throughline/extensions.yml\` for lifecycle hooks per \`.github/instructions/extension-hooks.instructions.md\`. The constitution at \`.throughline/memory/constitution.md\` overrides everything else."
  else
    echo "Unknown command namespace '$ns' for $cmd" >&2; return 1
  fi
}

build_frontmatter_command() {
  # $1=command-meta  $2=format  $3=profile  $4=lead-comment(optional)
  local cf="$1" format="$2" pf="$3" lead="${4:-}" desc hint core
  desc="$(get_field "$cf" description)"; hint="$(get_field "$cf" argument_hint)"
  core="$(build_command_core "$cf" "$format" "$pf")"
  { [ -n "$lead" ] && printf '%s\n' "$lead"
    printf '%s\n' "---"
    printf 'description: "%s"\n' "$(esc_yaml "$desc")"
    printf 'argument-hint: "%s"\n' "$(esc_yaml "$hint")"
    printf '%s\n\n' "---"
    printf '%s\n\n' "## Arguments"
    printf '%s\n\n' '$ARGUMENTS'
    printf '%s' "$core"
  }
}

# --- emitters --------------------------------------------------------------

emit_personas() {
  local pf="$1" dir fmt ext sep p name disp tools desc sandbox sbcomment note ro body sandbox_line instr
  dir="$REPO_ROOT/$(get_field "$pf" personas_dir)"; fmt="$(get_field "$pf" persona_format md)"; ext="$(get_field "$pf" persona_ext .md)"
  sep="$(get_field "$pf" slash_sep .)"
  for p in "$SRC"/personas/*.persona; do
    name="$(get_field "$p" name)"; disp="$(get_field "$p" display "$name")"; tools="$(get_field "$p" tools)"
    desc="$(get_field "$p" description)"; sandbox="$(get_field "$p" codex_sandbox workspace-write)"; ro="$(get_field "$p" cursor_readonly false)"
    sbcomment="$(get_field "$p" codex_sandbox_comment)"; note="$(get_field "$p" codex_note)"
    body="$(persona_body_for "$p")"
    case "$fmt" in
      md)        printf -- '---\nname: %s\ndescription: %s\ntools: %s\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/agents/%s.agent.md + personas/%s.persona; edit the source, not this file. -->' "$name" "$desc" "$tools" "$body" "$name" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      md-cursor) printf -- '---\nname: %s\ndescription: %s\nmodel: inherit\nreadonly: %s\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->' "$name" "$desc" "$ro" "$body" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      md-antigravity) printf -- '---\nname: %s\ndescription: %s\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->' "$name" "$desc" "$body" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      md-opencode)
        if [ "$ro" = "true" ]; then
          printf -- '---\ndescription: %s\nmode: subagent\npermission:\n  edit: deny\n  bash:\n    "*": ask\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->' "$desc" "$body" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext"
        else
          printf -- '---\ndescription: %s\nmode: subagent\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->' "$desc" "$body" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext"
        fi ;;
      md-qwen) printf -- '---\nname: %s\ndescription: %s\n---\n\n%s\n\n<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->' "$name" "$desc" "$body" "$name" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      md-kimi) printf -- '<!-- generated by tools/convert from .throughline/adapters/source/personas/%s.persona; edit there. -->\n\n# %s\n\n%s' "$name" "$disp" "$body" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      toml)      sandbox_line="sandbox_mode = \"$sandbox\""
                 [ -n "$sbcomment" ] && sandbox_line="$sandbox_line   # $sbcomment"
                 instr="$body"
                 [ -n "$note" ] && instr="$body"$'\n\n'"$note"
                 printf -- '# GENERATED by tools/convert from .throughline/adapters/source/personas/%s.persona %s edit there.\n# Peer to .claude/agents/%s.md and .github/agents/%s.agent.md (shared, runtime-neutral).\n\nname = "%s"\ndescription = "%s"\nmodel_reasoning_effort = "high"\n%s\n\ndeveloper_instructions = """\n%s\n"""\n' "$name" "$DASH" "$name" "$name" "$disp" "$(esc_yaml "$desc")" "$sandbox_line" "$instr" | apply_slash "$sep" | write_generated "$dir/$name$ext" ;;
      *) echo "Unknown persona_format: $fmt" >&2; exit 1 ;;
    esac
  done
}

emit_commands() {
  local pf="$1" dir layout ext fmt sep c ns cmd full path lead core
  dir="$REPO_ROOT/$(get_field "$pf" commands_dir)"; layout="$(get_field "$pf" command_layout flat)"
  ext="$(get_field "$pf" command_ext .md)"; fmt="$(get_field "$pf" command_format claude)"; sep="$(get_field "$pf" slash_sep .)"
  for c in "$SRC"/commands/*.command; do
    ns="$(get_field "$c" ns)"; cmd="$(get_field "$c" cmd)"; full="$ns.$cmd"
    if [ "$layout" = "subdir" ]; then path="$dir/$ns/$cmd$ext"; else path="$dir/$full$ext"; fi
    case "$fmt" in
      claude) build_frontmatter_command "$c" claude "$pf" "" | apply_slash "$sep" | write_generated "$path" ;;
      codex)  lead="<!-- Codex CLI adapter for /$full $DASH generated from .throughline/adapters/source. Filename ($full.md) is the slash command; install by copying .codex/prompts/*.md into \$CODEX_HOME/prompts/. -->"
              build_frontmatter_command "$c" codex "$pf" "$lead" | apply_slash "$sep" | write_generated "$path" ;;
      cursor) core="$(build_command_core "$c" cursor "$pf")"
              printf -- '<!-- generated by tools/convert from .throughline/adapters/source/commands/%s.command; edit there. -->\n\n# /%s\n\n%s\n\nUser input follows after the command: $ARGUMENTS' "$full" "$full" "$core" | apply_slash "$sep" | write_generated "$path" ;;
      antigravity-rule) core="$(build_command_core "$c" cursor "$pf")"
              printf -- '<!-- generated by tools/convert from .throughline/adapters/source/commands/%s.command; edit there. -->\n\n# Command: /%s\n\n%s\n\nUse this rule when the user asks for `/%s` or describes this lifecycle phase.' "$full" "$full" "$core" "$full" | apply_slash "$sep" | write_generated "$path" ;;
      opencode)
        core="$(build_command_core "$c" cursor "$pf")"
        persona="$(get_field "$c" persona)"
        ns="$(get_field "$c" ns)"
        if [ "$ns" = "dev" ] && [ -n "$persona" ]; then
          printf -- '<!-- generated by tools/convert from .throughline/adapters/source/commands/%s.command; edit there. -->\n---\ndescription: "%s"\nagent: %s\nsubtask: true\n---\n\n%s\n\n$ARGUMENTS' "$full" "$(esc_yaml "$(get_field "$c" description)")" "$persona" "$core" | apply_slash "$sep" | write_generated "$path"
        else
          printf -- '<!-- generated by tools/convert from .throughline/adapters/source/commands/%s.command; edit there. -->\n---\ndescription: "%s"\n---\n\n%s\n\n$ARGUMENTS' "$full" "$(esc_yaml "$(get_field "$c" description)")" "$core" | apply_slash "$sep" | write_generated "$path"
        fi ;;
      qwen) core="$(build_command_core "$c" cursor "$pf")"
            printf -- '<!-- generated by tools/convert from .throughline/adapters/source/commands/%s.command; edit there. -->\n---\ndescription: "%s"\n---\n\n%s\n\n{{args}}' "$full" "$(esc_yaml "$(get_field "$c" description)")" "$core" | apply_slash "$sep" | write_generated "$path" ;;
      *) echo "Unknown command_format: $fmt" >&2; exit 1 ;;
    esac
  done
}

emit_prompts() {
  local pf="$1" dir c full
  dir="$REPO_ROOT/$(get_field "$pf" prompts_dir)"
  for c in "$SRC"/commands/*.command; do
    full="$(get_field "$c" ns).$(get_field "$c" cmd)"
    printf -- '---\nagent: %s\n---' "$full" | write_generated "$dir/$full.prompt.md"
  done
}

emit_hooks() {
  local pf="$1" fmt path base
  fmt="$(get_field "$pf" hook_format none)"; path="$REPO_ROOT/$(get_field "$pf" hooks_file)"
  base=".github/hooks/scripts"
  # read hook-spec rows into parallel arrays
  local ids=() phases=() kinds=() scripts=() timeouts=() msgs=()
  while IFS=$'\t' read -r id phase kind script timeout msg; do
    case "$id" in ''|\#*) continue ;; esac
    # Strip CR from every field (hook-spec.tsv may carry CRLF on Windows checkouts).
    id="${id//$'\r'/}"; phase="${phase//$'\r'/}"; kind="${kind//$'\r'/}"
    script="${script//$'\r'/}"; timeout="${timeout//$'\r'/}"; msg="${msg//$'\r'/}"
    ids+=("$id"); phases+=("$phase"); kinds+=("$kind"); scripts+=("$script"); timeouts+=("$timeout"); msgs+=("$msg")
  done < "$SRC/hook-spec.tsv"

  if [ "$fmt" = "github-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; cross-OS (the windows field carries the PowerShell variant)",'
      printf '%s\n' '  "hooks": {'
      local phasekey phaseval idx i n
      for pi in 0 1; do
        if [ "$pi" = 0 ]; then phasekey="PreToolUse"; phaseval="pre"; else phasekey="PostToolUse"; phaseval="post"; fi
        printf '    "%s": [\n' "$phasekey"
        local sel=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = "$phaseval" ] && sel+=("$i"); done
        n=${#sel[@]}
        for ((j=0;j<n;j++)); do
          i=${sel[$j]}
          printf '      {\n'
          printf '        "type": "command",\n'
          printf '        "command": "%s/%s.sh",\n' "$base" "${scripts[$i]}"
          printf '        "windows": "powershell -NoProfile -ExecutionPolicy Bypass -File %s/%s.ps1",\n' "$base" "${scripts[$i]}"
          printf '        "timeout": %s,\n' "${timeouts[$i]}"
          printf '        "description": "%s"\n' "$(esc_json "${msgs[$i]}")"
          if [ $j -lt $((n-1)) ]; then printf '      },\n'; else printf '      }\n'; fi
        done
        if [ "$pi" = 0 ]; then printf '    ],\n'; else printf '    ]\n'; fi
      done
      printf '  }\n'
      printf '}'
    } | write_generated "$path"
  elif [ "$fmt" = "cursor-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "version": 1,'
      printf '%s\n' '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; tools/setup-hooks installs this to .cursor/hooks.json and rewrites commands per OS. failClosed is false until the verification spike passes.",'
      printf '%s\n' '  "hooks": {'
      local i
      printf '    "preToolUse": [\n'
      local pw=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = pre ] && [ "${kinds[$i]}" = write ] && pw+=("$i"); done
      for ((j=0;j<${#pw[@]};j++)); do i=${pw[$j]}; local sep=","; [ $j -eq $((${#pw[@]}-1)) ] && sep=""
        printf '      { "command": "%s/%s.sh", "matcher": "Write|Delete", "failClosed": false }%s\n' "$base" "${scripts[$i]}" "$sep"; done
      printf '    ],\n'
      printf '    "beforeShellExecution": [\n'
      local ps=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = pre ] && [ "${kinds[$i]}" = shell ] && ps+=("$i"); done
      for ((j=0;j<${#ps[@]};j++)); do i=${ps[$j]}; local sep=","; [ $j -eq $((${#ps[@]}-1)) ] && sep=""
        printf '      { "command": "%s/%s.sh", "failClosed": false }%s\n' "$base" "${scripts[$i]}" "$sep"; done
      printf '    ],\n'
      printf '    "afterFileEdit": [\n'
      local po=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = post ] && po+=("$i"); done
      for ((j=0;j<${#po[@]};j++)); do i=${po[$j]}; local sep=","; [ $j -eq $((${#po[@]}-1)) ] && sep=""
        printf '      { "command": "%s/%s.sh" }%s\n' "$base" "${scripts[$i]}" "$sep"; done
      printf '    ]\n'
      printf '  }\n'
      printf '}'
    } | write_generated "$path"
  elif [ "$fmt" = "antigravity-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; tools/setup-hooks installs this to .agents/hooks.json and rewrites commands per OS. Matchers are best-effort until the verification spike passes.",'
      printf '%s\n' '  "hooks": {'
      printf '%s\n' '    "PreToolUse": ['
      local pre=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = pre ] && pre+=("$i"); done
      local n=${#pre[@]} j i hkind matcher sep
      for ((j=0;j<n;j++)); do
        i=${pre[$j]}; hkind="${kinds[$i]}"
        if [ "$hkind" = shell ]; then matcher="run_command"; else matcher="write_file|edit_file|create_file"; fi
        sep=","; [ $j -eq $((n-1)) ] && sep=""
        printf '      { "type": "command", "command": "%s/%s.sh", "matcher": "%s", "timeout": %s }%s\n' "$base" "${scripts[$i]}" "$matcher" "${timeouts[$i]}" "$sep"
      done
      printf '%s\n' '    ],'
      printf '%s\n' '    "PostToolUse": ['
      local po=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = post ] && po+=("$i"); done
      n=${#po[@]}
      for ((j=0;j<n;j++)); do
        i=${po[$j]}; sep=","; [ $j -eq $((n-1)) ] && sep=""
        printf '      { "type": "command", "command": "%s/%s.sh", "timeout": %s }%s\n' "$base" "${scripts[$i]}" "${timeouts[$i]}" "$sep"
      done
      printf '    ]\n'
      printf '  }\n'
      printf '}'
    } | write_generated "$path"
  elif [ "$fmt" = "kimi-toml" ]; then
    {
      printf '%s\n' "# Generated by tools/convert from .throughline/adapters/source/hook-spec.tsv."
      printf '%s\n' "# tools/setup-hooks installs this to .kimi/config.toml (hooks-only; merge with your Kimi config if needed)."
      printf '%s\n' "# Matchers are best-effort until .kimi/VERIFICATION.md confirms Kimi's exact tool names."
      printf '\n'
      local i hkind matcher
      for i in "${!ids[@]}"; do
        [ "${phases[$i]}" = pre ] || continue
        hkind="${kinds[$i]}"
        if [ "$hkind" = shell ]; then matcher="Shell|Bash"; else matcher="WriteFile|StrReplaceFile"; fi
        printf '%s\n' "[[hooks]]"
        printf '%s\n' 'event = "PreToolUse"'
        printf 'matcher = "%s"\n' "$matcher"
        printf 'command = ".github/hooks/scripts/%s.sh"\n' "${scripts[$i]}"
        printf 'timeout = %s\n\n' "${timeouts[$i]}"
      done
      for i in "${!ids[@]}"; do
        [ "${phases[$i]}" = post ] || continue
        printf '%s\n' "[[hooks]]"
        printf '%s\n' 'event = "PostToolUse"'
        printf '%s\n' 'matcher = "WriteFile|StrReplaceFile"'
        printf 'command = ".github/hooks/scripts/%s.sh"\n' "${scripts[$i]}"
        printf 'timeout = %s\n\n' "${timeouts[$i]}"
      done
    } | write_generated "$path"
  elif [ "$fmt" = "copilot-cli-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "version": 1,'
      printf '%s\n' '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; .github/hooks/*.json for GitHub Copilot CLI. PascalCase events use the VS Code-compatible tool_name/tool_input payload. Guards run on both PreToolUse (advisory: a CLI preToolUse exit 2 is a warning) and PermissionRequest (enforcing: exit 2 denies) -- see docs/runtimes/copilot-cli.md.",'
      printf '%s\n' '  "hooks": {'
      printf '%s\n' '    "PreToolUse": ['
      local pre=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = pre ] && pre+=("$i"); done
      local n=${#pre[@]} j i matcher sep
      for ((j=0;j<n;j++)); do
        i=${pre[$j]}
        if [ "${kinds[$i]}" = shell ]; then matcher="Bash"; else matcher="Edit|Write"; fi
        sep=","; [ $j -eq $((n-1)) ] && sep=""
        printf '      { "type": "command", "matcher": "%s", "bash": "bash %s/%s.sh", "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File %s/%s.ps1", "timeoutSec": %s }%s\n' "$matcher" "$base" "${scripts[$i]}" "$base" "${scripts[$i]}" "${timeouts[$i]}" "$sep"
      done
      printf '%s\n' '    ],'
      # PermissionRequest fires before the CLI permission flow; a command-hook exit 2 = DENY there,
      # so the same guard scripts that only WARN on PreToolUse actually block on the CLI. Non-violations
      # exit 0 and fall through. (PermissionRequest does not fire on cloud agent.)
      printf '%s\n' '    "PermissionRequest": ['
      for ((j=0;j<n;j++)); do
        i=${pre[$j]}
        if [ "${kinds[$i]}" = shell ]; then matcher="Bash"; else matcher="Edit|Write"; fi
        sep=","; [ $j -eq $((n-1)) ] && sep=""
        printf '      { "type": "command", "matcher": "%s", "bash": "bash %s/%s.sh", "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File %s/%s.ps1", "timeoutSec": %s }%s\n' "$matcher" "$base" "${scripts[$i]}" "$base" "${scripts[$i]}" "${timeouts[$i]}" "$sep"
      done
      printf '%s\n' '    ],'
      printf '%s\n' '    "PostToolUse": ['
      local po=(); for i in "${!ids[@]}"; do [ "${phases[$i]}" = post ] && po+=("$i"); done
      n=${#po[@]}
      for ((j=0;j<n;j++)); do
        i=${po[$j]}; sep=","; [ $j -eq $((n-1)) ] && sep=""
        printf '      { "type": "command", "matcher": "Edit|Write", "bash": "bash %s/%s.sh", "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File %s/%s.ps1", "timeoutSec": %s }%s\n' "$base" "${scripts[$i]}" "$base" "${scripts[$i]}" "${timeouts[$i]}" "$sep"
      done
      printf '    ]\n'
      printf '  }\n'
      printf '}'
    } | write_generated "$path"
  else echo "Unknown hook_format: $fmt" >&2; exit 1; fi
}

emit_rules() {
  local pf="$1" fmt path sep global disp
  fmt="$(get_field "$pf" rules_format mdc)"; path="$REPO_ROOT/$(get_field "$pf" rules_file)"; sep="$(get_field "$pf" slash_sep .)"
  global="$(cat "$SRC/global-rules.md")"
  if [ "$fmt" = "mdc" ]; then
    printf -- '---\ndescription: Throughline non-negotiables and bootstrap sequence\nalwaysApply: true\n---\n\n%s' "$global" | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "bundle" ]; then
    disp="$(get_field "$pf" display "$(get_field "$pf" id)")"
    {
      printf '# Throughline %s rules-only integration for %s\n\n' "$DASH" "$disp"
      printf 'WARNING: %s has no hooks and no subagents. The read-only guard on /standards/ and\n' "$disp"
      printf '/exemplars/ and the no-merge/no-push rule are INSTRUCTED here, not enforced. Honor them\n'
      printf 'yourself. For enforced guards, use a Tier A tool (Claude Code, Cursor, Codex, Copilot).\n\n'
      printf '%s\n\n' "$global"
      printf '## Personas (adopt the matching one for each phase)\n\n'
      local p; for p in "$SRC"/personas/*.persona; do printf -- '- **%s** %s %s\n' "$(get_field "$p" display "$(get_field "$p" name)")" "$DASH" "$(get_field "$p" description)"; done
      printf '\n## Commands (follow the runbook for each)\n\n'
      local c key line
      while IFS= read -r line; do
        c="${line#*$'\t'}"
        [ -n "$c" ] || continue
        printf -- '- /%s.%s %s %s\n' "$(get_field "$c" ns)" "$(get_field "$c" cmd)" "$DASH" "$(get_field "$c" description)"
      done < <(for c in "$SRC"/commands/*.command; do printf '%s\t%s\n' "$(get_field "$c" ns).$(get_field "$c" cmd)" "$c"; done | sort -t "$(printf '\t')" -k1,1)
    } | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "gemini" ]; then
    disp="$(get_field "$pf" display "$(get_field "$pf" id)")"
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/antigravity.profile; edit the source, not this file. -->"
      printf '# Throughline %s Antigravity (`GEMINI.md`)\n\n' "$DASH"
      printf 'Antigravity reads this file with **higher priority** than root `AGENTS.md`. The committed\n'
      printf '`AGENTS.md` is the **Codex** adapter peer %s do not edit it for Antigravity; use this file\n' "$DASH"
      printf 'and `.agent/rules/` instead.\n\n'
      printf '%s\n\n' "$global"
      printf '## Antigravity wiring\n\n'
      printf -- '- **Personas**: `.agents/personas/*.md` %s adopt the matching one when delegating (Orchestrator spawns separate contexts).\n' "$DASH"
      printf -- '- **Commands**: `.agent/rules/commands/*.md` %s one rule file per lifecycle command; follow its runbook when invoked.\n' "$DASH"
      printf -- '- **Hooks**: `.agents/hooks.json` (machine-local, wired by `tools/setup-hooks` from the staged template).\n'
      printf -- '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n\n'
      printf '> Preview adapter %s see `.agents/VERIFICATION.md` before trusting hook enforcement.\n' "$DASH"
    } | apply_slash "$sep" | write_generated "$path"
    rex="$(get_field "$pf" rules_extra_file)"
    if [ -n "$rex" ]; then
      printf '%s\n\n%s' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md; edit there. -->" "$global" \
        | apply_slash "$sep" | write_generated "$REPO_ROOT/$rex"
    fi
  elif [ "$fmt" = "qwen" ]; then
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/qwen.profile; edit the source, not this file. -->"
      printf '# Throughline %s Qwen Code (`QWEN.md`)\n\n' "$DASH"
      printf 'Qwen Code loads this file as project context (alongside root `AGENTS.md`). The committed\n'
      printf '`AGENTS.md` is the **Codex** adapter peer %s do not edit it for Qwen; use this file and\n' "$DASH"
      printf '`.qwen/` instead.\n\n'
      printf '%s\n\n' "$global"
      printf '## Qwen Code wiring\n\n'
      printf -- '- **Personas**: `.qwen/agents/*.md` %s subagents; delegate so the Reviewer stays independent.\n' "$DASH"
      printf -- '- **Commands**: `.qwen/commands/<ns>/<cmd>.md` %s slash names use colons from paths (e.g. `/dev:analyze`); runbooks use dot form in prose.\n' "$DASH"
      printf -- '- **Guards**: `.qwen/settings.json` %s `permissions.deny` for `/standards/` + `/exemplars/` and git push/merge.\n' "$DASH"
      printf -- '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n\n'
      printf '> Preview adapter %s see `.qwen/VERIFICATION.md` before trusting permission enforcement.\n' "$DASH"
    } | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "kimi" ]; then
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/kimi.profile; edit the source, not this file. -->"
      printf '# Throughline %s Kimi Code (`.kimi/AGENTS.md`)\n\n' "$DASH"
      printf 'Kimi merges this file with root `AGENTS.md`. The committed `AGENTS.md` is the **Codex**\n'
      printf 'adapter peer %s do not edit it for Kimi; use this overlay and `.kimi/` instead.\n\n' "$DASH"
      printf '%s\n\n' "$global"
      printf '## Kimi Code wiring\n\n'
      printf -- '- **Personas**: `.kimi/personas/*.md` %s adopt or delegate via the Agent tool (Orchestrator spawns separate contexts).\n' "$DASH"
      printf -- '- **Workflows**: `.kimi/workflows/*.md` %s lifecycle phase runbook pointers (no native slash-command dir).\n' "$DASH"
      printf -- '- **Hooks**: `.kimi/config.toml` (machine-local, wired by `tools/setup-hooks` from the staged template).\n'
      printf -- '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n\n'
      printf '> Preview adapter %s see `.kimi/VERIFICATION.md` before trusting hook enforcement.\n' "$DASH"
    } | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "opencode-index" ]; then
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/opencode.profile; edit the source, not this file. -->"
      printf '# Throughline %s OpenCode (`.opencode/throughline.md`)\n\n' "$DASH"
      printf 'OpenCode loads this file via `opencode.json` `instructions`. Root `AGENTS.md` is the **Codex**\n'
      printf 'adapter peer %s do not edit it for OpenCode; use this file and `.opencode/` instead.\n\n' "$DASH"
      printf '%s\n\n' "$global"
      printf '## OpenCode wiring\n\n'
      printf -- '- **Personas**: `.opencode/agents/*.md` %s subagents; @mention or set `agent` on commands.\n' "$DASH"
      printf -- '- **Commands**: `.opencode/commands/*.md` %s native slash commands (filename = command name).\n' "$DASH"
      printf -- '- **Guards**: `opencode.json` %s declarative `permission` denies on `/standards/` + `/exemplars/` and git push/merge.\n' "$DASH"
      printf -- '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n\n'
      printf '> Preview adapter %s see `.opencode/VERIFICATION.md` before trusting permission enforcement.\n' "$DASH"
    } | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "codex" ]; then
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md; this is the shared root AGENTS.md (Codex + GitHub Copilot CLI both load it); edit the source, not this file. -->"
      printf '# Throughline %s root `AGENTS.md` (Codex + Copilot CLI)\n\n' "$DASH"
      printf 'Codex reads this `AGENTS.md` as the root agent instructions for the repo, and **GitHub Copilot CLI**\n'
      printf 'loads it too (together with `.github/copilot-instructions.md` + `.github/instructions/`). It is also\n'
      printf 'the shared `AGENTS.md` other adapters point at as the **Codex** peer. Codex personas are\n'
      printf '`.codex/agents/*.toml` and commands `.codex/prompts/*.md`; Copilot CLI uses the `.github/` surface\n'
      printf 'instead (see the Copilot CLI bullet below) %s do not follow the `.codex/` paths on Copilot CLI.\n\n' "$DASH"
      printf '%s\n\n' "$global"
      printf '## Tool wiring\n\n'
      printf -- '- **Codex** %s personas `.codex/agents/*.toml` (spawn each as a separate Codex subagent so the Reviewer stays independent); commands `.codex/prompts/*.md` (copy into `$CODEX_HOME/prompts/`); hooks `.codex/hooks.json` (wired by `tools/setup-hooks`).\n' "$DASH"
      printf -- '- **GitHub Copilot CLI** %s personas and commands are the custom agents under `.github/agents/` (the eight personas + the `dev.*`/`throughline.*` command agents; delegate review to a separate agent so the Reviewer stays independent); instructions `.github/copilot-instructions.md` + `.github/instructions/`; guards `.github/hooks/copilot-cli.json`. The `.codex/` paths above do not apply.\n' "$DASH"
      printf -- '- **Both** %s blocks writes to `/standards/` + `/exemplars/` and git push/merge; canonical brain `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n\n' "$DASH"
      printf '> Preview adapters %s see `.codex/VERIFICATION.md` (Codex) or `docs/runtimes/copilot-cli.md` (Copilot CLI) before trusting hook enforcement.\n' "$DASH"
    } | apply_slash "$sep" | write_generated "$path"
  elif [ "$fmt" = "claude" ]; then
    {
      printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/claude.profile; edit the source, not this file. -->"
      printf '# Throughline %s Claude Code (`CLAUDE.md`)\n\n' "$DASH"
      printf 'Claude Code loads this `CLAUDE.md` as project memory at the start of every session.\n'
      printf 'Personas are `.claude/agents/*.md`; commands are `.claude/commands/<ns>/<cmd>.md`.\n\n'
      printf '%s\n\n' "$global"
      printf '## Claude Code wiring\n\n'
      printf -- '- **Personas**: `.claude/agents/*.md` %s delegate via the Agent tool so the Reviewer stays independent.\n' "$DASH"
      printf -- '- **Commands**: `.claude/commands/<ns>/<cmd>.md` %s native slash commands; each points at its runbook.\n' "$DASH"
      printf -- '- **Skills**: `.claude/skills/` %s byte-identical mirror of `.github/skills/`.\n' "$DASH"
      printf -- '- **Hooks**: `.claude/settings.local.json` (machine-local, wired by `tools/setup-hooks`) %s blocks writes to `/standards/` + `/exemplars/` and git push/merge; the committed `.claude/settings.json` keeps the always-on read-only guard.\n' "$DASH"
      printf -- '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.\n'
    } | apply_slash "$sep" | write_generated "$path"
  else echo "Unknown rules_format: $fmt" >&2; exit 1; fi
}

emit_config() {
  local pf="$1" fmt path
  fmt="$(get_field "$pf" config_format none)"; path="$REPO_ROOT/$(get_field "$pf" config_file)"
  if [ "$fmt" = "opencode-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "$schema": "https://opencode.ai/config.json",'
      printf '%s\n' '  "_generated": "by tools/convert from profiles/opencode.profile; edit the profile source, not this file.",'
      printf '%s\n' '  "instructions": [".opencode/throughline.md"],'
      printf '%s\n' '  "permission": {'
      printf '%s\n' '    "edit": {'
      printf '%s\n' '      "standards/**": "deny",'
      printf '%s\n' '      "exemplars/**": "deny"'
      printf '%s\n' '    },'
      printf '%s\n' '    "bash": {'
      printf '%s\n' '      "git push*": "deny",'
      printf '%s\n' '      "git merge*": "deny"'
      printf '%s\n' '    }'
      printf '%s\n' '  }'
      printf '%s\n' "}"
    } | write_generated "$path"
  elif [ "$fmt" = "qwen-json" ]; then
    {
      printf '%s\n' "{"
      printf '%s\n' '  "_generated": "by tools/convert from profiles/qwen.profile; edit the profile source, not this file.",'
      printf '%s\n' '  "context": {'
      printf '%s\n' '    "fileName": ["QWEN.md", "AGENTS.md"]'
      printf '%s\n' '  },'
      printf '%s\n' '  "permissions": {'
      printf '%s\n' '    "deny": ['
      printf '%s\n' '      "Write(standards/**)",'
      printf '%s\n' '      "Edit(standards/**)",'
      printf '%s\n' '      "Write(exemplars/**)",'
      printf '%s\n' '      "Edit(exemplars/**)",'
      printf '%s\n' '      "Bash(git push *)",'
      printf '%s\n' '      "Bash(git merge *)"'
      printf '%s\n' '    ]'
      printf '%s\n' '  }'
      printf '%s\n' "}"
    } | write_generated "$path"
  else echo "Unknown config_format: $fmt" >&2; exit 1; fi
}

emit_manifest() {
  local pf="$1" path id
  path="$REPO_ROOT/$(get_field "$pf" manifest_path)"; id="$(get_field "$pf" id)"
  local entries=()
  is_true "$pf" emit_personas   && entries+=("    \"personas_dir\": \"$(get_field "$pf" personas_dir)\"")
  is_true "$pf" emit_commands   && entries+=("    \"commands_dir\": \"$(get_field "$pf" commands_dir)\"")
  is_true "$pf" emit_prompts    && entries+=("    \"prompts_dir\": \"$(get_field "$pf" prompts_dir)\"")
  is_true "$pf" emit_hooks      && entries+=("    \"hooks\": \"$(get_field "$pf" hooks_file)\"")
  is_true "$pf" emit_rules_file && {
    entries+=("    \"rules_file\": \"$(get_field "$pf" rules_file)\"")
    rex="$(get_field "$pf" rules_extra_file)"
    [ -n "$rex" ] && entries+=("    \"rules_extra\": \"$rex\"")
  }
  is_true "$pf" emit_config     && entries+=("    \"config_file\": \"$(get_field "$pf" config_file)\"")
  {
    printf '%s\n' "{"
    printf '  "integration": "%s",\n' "$id"
    printf '  "version": "0.1.0",\n'
    printf '  "status": "%s",\n' "$(get_field "$pf" status)"
    printf '  "tier": "%s",\n' "$(get_field "$pf" tier)"
    printf '  "slash_syntax": "%s",\n' "$(esc_json "$(get_field "$pf" slash_example)")"
    printf '  "generated_by": "tools/convert from .throughline/adapters/source + profiles/%s.profile",\n' "$id"
    printf '  "entry_points": {\n'
    local n=${#entries[@]} k
    for ((k=0;k<n;k++)); do if [ $k -lt $((n-1)) ]; then printf '%s,\n' "${entries[$k]}"; else printf '%s\n' "${entries[$k]}"; fi; done
    printf '  },\n'
    printf '  "notes": "Thin adapter generated from the single source. Canonical procedure lives in .throughline/extensions/dev/commands/ and .throughline/adapters/source/agents/."\n'
    printf '}'
  } | write_generated "$path"
}

copy_source_tree() {
  # $1=src subdir under source/  $2=dest subdir under repo root  $3=add_marker(0|1)
  local srcSub="$1"
  local dest="$2"
  local marker="${3:-0}"
  local srcRoot="$SRC/$srcSub"
  local f rel out cmt body
  [ -d "$srcRoot" ] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#$srcRoot/}"; rel="${rel//\\//}"; out="$REPO_ROOT/$dest/$rel"
    if [ "$marker" -eq 1 ] && [[ "$f" == *.md ]] && ! head -n1 "$f" | grep -q 'generated by tools/convert'; then
      cmt="<!-- generated by tools/convert from .throughline/adapters/source/$srcSub/$rel; edit the source, not this file. -->"
      if head -n1 "$f" | grep -q '^---[[:space:]]*$'; then
        # Source carries YAML frontmatter; VS Code needs --- on line 1, so append the marker at the end (matches emit_personas).
        body="$(cat "$f")"
        printf '%s\n\n%s\n' "$body" "$cmt" | write_generated "$out"
      else
        { printf '%s\n\n' "$cmt"; cat "$f"; } | write_generated "$out"
      fi
    else
      cat "$f" | write_generated "$out"
    fi
  done < <(find "$srcRoot" -type f -print0)
}

emit_tool_docs() {
  local base="$SRC/tool-docs" rel src dest only="$*"
  [ -d "$base" ] || return 0
  emit_one() {
    rel="$1"; dest="$2"; src="$base/$rel"
    [ -f "$src" ] || return 0
    # claude-hooks/* is part of the always-on .claude mirror; every other prefix is a tool id
    # emitted only when that tool is being converted (so a single-tool install stays clean).
    local prefix="${rel%%/*}"
    if [ "$prefix" != "claude-hooks" ] && [ -n "$only" ] && ! printf ' %s ' "$only" | grep -q " $prefix "; then
      return 0
    fi
    if [[ "$rel" == *.md ]] && ! head -n1 "$src" | grep -q 'generated by tools/convert'; then
      { printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/tool-docs/$rel; edit the source, not this file. -->"
        cat "$src"
      } | write_generated "$REPO_ROOT/$dest"
    else
      cat "$src" | write_generated "$REPO_ROOT/$dest"
    fi
  }
  emit_one "codex/config.toml" ".codex/config.toml"
  emit_one "codex/README.md" ".codex/README.md"
  emit_one "codex/VERIFICATION.md" ".codex/VERIFICATION.md"
  emit_one "claude-hooks/README.md" ".claude/hooks/README.md"
  emit_one "cursor/README.md" ".cursor/README.md"
  emit_one "cursor/VERIFICATION.md" ".cursor/VERIFICATION.md"
  emit_one "antigravity/README.md" ".agents/README.md"
  emit_one "antigravity/VERIFICATION.md" ".agents/VERIFICATION.md"
  emit_one "opencode/README.md" ".opencode/README.md"
  emit_one "opencode/VERIFICATION.md" ".opencode/VERIFICATION.md"
  emit_one "qwen/README.md" ".qwen/README.md"
  emit_one "qwen/VERIFICATION.md" ".qwen/VERIFICATION.md"
  emit_one "kimi/README.md" ".kimi/README.md"
  emit_one "kimi/VERIFICATION.md" ".kimi/VERIFICATION.md"
}

emit_shared() {
  echo "[shared] canonical GitHub + globals from .throughline/adapters/source/"
  copy_source_tree instructions .github/instructions 1
  copy_source_tree skills .github/skills 0
  copy_source_tree skills .claude/skills 0
  copy_source_tree hooks .github/hooks/scripts 0
  copy_source_tree hooks .claude/hooks 0
  copy_source_tree agents .github/agents 1
  emit_tool_docs "$@"
  local gdir="$SRC/globals" name dest text
  for name in copilot-instructions.md claude-settings.json pull_request_template.md; do
    [ -f "$gdir/$name" ] || continue
    case "$name" in
      copilot-instructions.md) dest=".github/copilot-instructions.md" ;;
      claude-settings.json) dest=".claude/settings.json" ;;
      pull_request_template.md) dest=".github/pull_request_template.md" ;;
    esac
    if [[ "$name" == *.md ]] && ! head -n1 "$gdir/$name" | grep -q 'generated by tools/convert'; then
      { printf '%s\n\n' "<!-- generated by tools/convert from .throughline/adapters/source/globals/$name; edit the source, not this file. -->"
        cat "$gdir/$name"
      } | write_generated "$REPO_ROOT/$dest"
    else
      cat "$gdir/$name" | write_generated "$REPO_ROOT/$dest"
    fi
  done
}

# --- driver ----------------------------------------------------------------

convert_tool() {
  local id="$1" pf="$PROFILES/$1.profile"
  [ -f "$pf" ] || { echo "No profile for tool '$id' ($pf)" >&2; exit 1; }
  echo "[$id] $(get_field "$pf" display "$id") $DASH tier $(get_field "$pf" tier), $(get_field "$pf" status)"
  is_true "$pf" emit_personas   && emit_personas "$pf"
  is_true "$pf" emit_commands   && emit_commands "$pf"
  is_true "$pf" emit_prompts    && emit_prompts "$pf"
  is_true "$pf" emit_hooks      && emit_hooks "$pf"
  is_true "$pf" emit_rules_file && emit_rules "$pf"
  is_true "$pf" emit_config     && emit_config "$pf"
  is_true "$pf" emit_manifest   && emit_manifest "$pf"
  return 0
}

if [ "$LIST" -eq 1 ]; then
  for id in $(list_ids); do
    pf="$PROFILES/$id.profile"
    printf '%-10s %-12s tier %s  %s\n' "$id" "$(get_field "$pf" status)" "$(get_field "$pf" tier)" "$(get_field "$pf" display)"
  done
  exit 0
fi

if [ "$TOOL" = "shared" ]; then emit_shared
elif [ "$TOOL" = "all" ]; then emit_shared; for id in $(list_ids); do convert_tool "$id"; done
else emit_shared "$TOOL"; convert_tool "$TOOL"; fi
echo "done."
