#requires -Version 5.1
# Throughline adapter generator (PowerShell, Windows PowerShell 5.1 compatible).
#
# Renders the thin per-tool adapter wiring from the single source of truth in
# .throughline/adapters/source/, driven by the per-tool profiles in .throughline/adapters/profiles/.
# Canonical procedure (runbooks, instructions, agent bodies, skills) lives in
# .throughline/adapters/source/; this script emits thin per-tool wiring only.
#
# Usage:
#   powershell -File tools/convert.ps1                 # generate every tool
#   powershell -File tools/convert.ps1 -Tool cursor    # generate one tool
#   powershell -File tools/convert.ps1 -List           # list known tools
#   powershell -File tools/convert.ps1 -DryRun         # show what would be written, write nothing
#
# JSON is hand-built (not ConvertTo-Json) so output is byte-identical to tools/convert.sh.

[CmdletBinding()]
param(
    [string]$Tool = "all",
    [switch]$DryRun,
    [switch]$List
)

$ErrorActionPreference = "Stop"

$RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SourceDir  = Join-Path $RepoRoot ".throughline/adapters/source"
$ProfileDir = Join-Path $RepoRoot ".throughline/adapters/profiles"
$Utf8NoBom  = New-Object System.Text.UTF8Encoding($false)
$Dash       = [char]0x2014   # em dash, emitted via code point so this script stays pure ASCII

# --- helpers ---------------------------------------------------------------

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Rel([string]$Path) {
    $p = $Path -replace "/", "\"
    if ($p.StartsWith($RepoRoot)) { return $p.Substring($RepoRoot.Length).TrimStart("\") }
    return $p
}

function Write-Generated([string]$Path, [string]$Content) {
    $normalized = ($Content -replace "`r`n", "`n").TrimEnd("`n") + "`n"
    if ($DryRun) { Write-Host "  would write $(Rel $Path)"; return }
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $normalized, $Utf8NoBom)
    Write-Host "  wrote $(Rel $Path)"
}

function ConvertFrom-MetaText([string]$Text) {
    $map = @{}
    foreach ($line in ($Text -replace "`r`n", "`n").Split("`n")) {
        $trimmed = $line.TrimStart()
        if ($trimmed -eq "" -or $trimmed.StartsWith("#")) { continue }
        $idx = $line.IndexOf("=")
        if ($idx -lt 0) { continue }
        $map[$line.Substring(0, $idx).Trim()] = $line.Substring($idx + 1).Trim()
    }
    return $map
}

function Get-Field($map, [string]$key, $default = "") {
    if ($map.ContainsKey($key) -and $map[$key] -ne "") { return $map[$key] }
    return $default
}

function Is-True($map, [string]$key) { return ((Get-Field $map $key "false") -eq "true") }

function Esc-Yaml([string]$s) { if ($null -eq $s) { return "" } return $s.Replace('"', '\"') }

function Esc-Json([string]$s) {
    if ($null -eq $s) { return "" }
    return $s.Replace("\", "\\").Replace('"', '\"').Replace("`n", "\n").Replace("`t", "\t")
}

# Rewrite slash-command references to the tool's punctuation. The source uses the colon form
# (/dev:review); tools that use the dot form get /dev.review. File PATHS like
# .throughline/extensions/dev/commands/dev.review.md contain "/dev/" or "dev." (never "/dev:") and are
# left untouched.
function Apply-Slash([string]$text, [string]$sep) {
    if ($null -eq $text) { return "" }
    if ($sep -eq ":") { return $text }
    return (($text -replace "/dev:", "/dev$sep") -replace "/throughline:", "/throughline$sep")
}

# --- load source -----------------------------------------------------------

function Read-Persona([string]$Path) {
    $raw = (Read-Utf8 $Path) -replace "`r`n", "`n"
    $parts = $raw -split "(?m)^@@BODY@@\s*$", 2
    $meta = ConvertFrom-MetaText $parts[0]
    $body = if ($parts.Count -gt 1) { $parts[1].Trim("`n") } else { "" }
    return @{ meta = $meta; body = $body }
}

function Get-MarkdownBody([string]$Path) {
    $raw = (Read-Utf8 $Path) -replace "`r`n", "`n"
    if ($raw -match '(?m)^---\s*$') {
        $parts = $raw -split '(?m)^---\s*$', 3
        if ($parts.Count -ge 3) { return $parts[2].Trim("`n") }
    }
    return $raw.Trim("`n")
}

function Get-Personas {
    $list = @()
    foreach ($f in (Get-ChildItem (Join-Path $SourceDir "personas") -Filter *.persona | Sort-Object Name)) {
        $p = Read-Persona $f.FullName
        $name = $p.meta["name"]
        $body = $p.body
        $agentPath = Join-Path $SourceDir "agents/$name.agent.md"
        if (Test-Path $agentPath) { $body = Get-MarkdownBody $agentPath }
        $list += [pscustomobject]@{
            name           = $name
            display        = Get-Field $p.meta "display" $name
            tools          = Get-Field $p.meta "tools"
            description    = Get-Field $p.meta "description"
            sandbox        = Get-Field $p.meta "codex_sandbox" "workspace-write"
            sandboxComment = Get-Field $p.meta "codex_sandbox_comment"
            codexNote      = Get-Field $p.meta "codex_note"
            readonly       = Get-Field $p.meta "cursor_readonly" "false"
            body           = $body
        }
    }
    return $list
}

function Get-Commands {
    $list = @()
    foreach ($f in (Get-ChildItem (Join-Path $SourceDir "commands") -Filter *.command | Sort-Object Name)) {
        $m = ConvertFrom-MetaText (Read-Utf8 $f.FullName)
        $list += [pscustomobject]@{
            ns            = $m["ns"]
            cmd           = $m["cmd"]
            full          = "$($m['ns']).$($m['cmd'])"
            persona       = Get-Field $m "persona"
            description   = Get-Field $m "description"
            argHint       = Get-Field $m "argument_hint"
            personaAction = Get-Field $m "persona_action"
            runbookSteps  = Get-Field $m "runbook_steps" "preconditions, steps, exit criteria, failure modes"
            runbookTail   = Get-Field $m "runbook_tail"
            finalNote     = Get-Field $m "final_note"
        }
    }
    return $list
}

function Get-Hooks {
    $list = @()
    foreach ($line in ((Read-Utf8 (Join-Path $SourceDir "hook-spec.tsv")) -replace "`r`n", "`n").Split("`n")) {
        if ($line.TrimStart().StartsWith("#") -or $line.Trim() -eq "") { continue }
        $cols = $line.Split("`t")
        if ($cols.Count -lt 6) { continue }
        $list += [pscustomobject]@{ id = $cols[0]; phase = $cols[1]; kind = $cols[2]; script = $cols[3]; timeout = $cols[4]; message = $cols[5] }
    }
    return $list
}

# --- body builders ---------------------------------------------------------

function Build-CommandCore($cmd, [string]$format, $prof) {
    if ($cmd.ns -eq "dev") {
        if ($cmd.persona -eq "") { throw "Dev command '$($cmd.full)' requires a persona field" }
        $ref = (Get-Field $prof "persona_ref" ".claude/agents/{persona}.md").Replace("{persona}", $cmd.persona)
        $word = if ($format -eq "claude") { "subagent " } else { "" }
        $action = if ($cmd.personaAction -ne "") { $cmd.personaAction } else { Get-Field $prof "spawn_note" "delegate to it as a subagent." }
        $runbookPath = ".throughline/extensions/dev/commands/dev.$($cmd.cmd).md"
        $tailPart = if ($cmd.runbookTail -ne "") { " $($cmd.runbookTail)" } else { "" }
        $personaLine = "Adopt the **$($cmd.persona)** ${word}persona (``$ref``) $Dash $action"
        $runbookLine = "Follow the canonical runbook at ``$runbookPath`` step-by-step: $($cmd.runbookSteps).$tailPart The constitution at ``.throughline/memory/constitution.md`` overrides everything else."
        $final = if ($cmd.finalNote -ne "") { $cmd.finalNote } else { "Bootstrap first (Constitution Principle II); append the outcome to ``wiki/log.md`` (Principle VII)." }
        return "$personaLine`n`n$runbookLine`n`n$final"
    }
    if ($cmd.ns -eq "throughline") {
        $runbookPath = ".github/agents/throughline.$($cmd.cmd).agent.md"
        $line1 = "Follow the runbook at ``$runbookPath`` $Dash its content is runtime-neutral; ignore Copilot-specific frontmatter (tools/handoffs) and use your own tools. Helper scripts referenced there live under ``.throughline/scripts/`` (PowerShell and bash variants)."
        $line2 = "Check ``.throughline/extensions.yml`` for lifecycle hooks per ``.github/instructions/extension-hooks.instructions.md``. The constitution at ``.throughline/memory/constitution.md`` overrides everything else."
        return "$line1`n`n$line2"
    }
    throw "Unknown command namespace '$($cmd.ns)' for $($cmd.full)"
}

function Build-FrontmatterCommand($cmd, [string]$format, $prof, [string]$leadComment) {
    $core = Build-CommandCore $cmd $format $prof
    $sb = @()
    if ($leadComment -ne "") { $sb += $leadComment }
    $sb += "---"
    $sb += "description: `"$(Esc-Yaml $cmd.description)`""
    $sb += "argument-hint: `"$(Esc-Yaml $cmd.argHint)`""
    $sb += "---"
    $sb += ""
    $sb += "## Arguments"
    $sb += ""
    $sb += '$ARGUMENTS'
    $sb += ""
    $sb += $core
    return ($sb -join "`n")
}

# --- emitters --------------------------------------------------------------

function Emit-Personas($prof, $personas) {
    $dir = Join-Path $RepoRoot (Get-Field $prof "personas_dir")
    $fmt = Get-Field $prof "persona_format" "md"
    $ext = Get-Field $prof "persona_ext" ".md"
    $sep = Get-Field $prof "slash_sep" "."
    foreach ($p in $personas) {
        $path = Join-Path $dir "$($p.name)$ext"
        switch ($fmt) {
            "md" {
                $content = "---`nname: $($p.name)`ndescription: $($p.description)`ntools: $($p.tools)`n---`n`n$($p.body)`n`n<!-- generated by tools/convert from .throughline/adapters/source/agents/$($p.name).agent.md + personas/$($p.name).persona; edit the source, not this file. -->"
            }
            "md-cursor" {
                $content = "---`nname: $($p.name)`ndescription: $($p.description)`nmodel: inherit`nreadonly: $($p.readonly)`n---`n`n$($p.body)`n`n<!-- generated by tools/convert from .throughline/adapters/source/personas/$($p.name).persona; edit there. -->"
            }
            "md-antigravity" {
                $content = "---`nname: $($p.name)`ndescription: $($p.description)`n---`n`n$($p.body)`n`n<!-- generated by tools/convert from .throughline/adapters/source/personas/$($p.name).persona; edit there. -->"
            }
            "md-opencode" {
                $perm = if ($p.readonly -eq "true") { "permission:`n  edit: deny`n  bash:`n    `"*`": ask`n" } else { "" }
                $content = "---`ndescription: $($p.description)`nmode: subagent`n$perm---`n`n$($p.body)`n`n<!-- generated by tools/convert from .throughline/adapters/source/personas/$($p.name).persona; edit there. -->"
            }
            "md-qwen" {
                $content = "---`nname: $($p.name)`ndescription: $($p.description)`n---`n`n$($p.body)`n`n<!-- generated by tools/convert from .throughline/adapters/source/personas/$($p.name).persona; edit there. -->"
            }
            "md-kimi" {
                $content = "<!-- generated by tools/convert from .throughline/adapters/source/personas/$($p.name).persona; edit there. -->`n`n# $($p.display)`n`n$($p.body)"
            }
            "toml" {
                $hdr = "# GENERATED by tools/convert from .throughline/adapters/source/personas/$($p.name).persona $Dash edit there.`n# Peer to .claude/agents/$($p.name).md and .github/agents/$($p.name).agent.md (shared, runtime-neutral)."
                # sandbox_mode is a Codex concept; carry its surface comment when the source supplies one.
                $sandboxLine = "sandbox_mode = `"$($p.sandbox)`""
                if ($p.sandboxComment -ne "") { $sandboxLine += "   # $($p.sandboxComment)" }
                # Codex has no declarative handoff graph, so any handoff/delegation note is appended here.
                $instr = $p.body
                if ($p.codexNote -ne "") { $instr = "$($p.body)`n`n$($p.codexNote)" }
                $content = "$hdr`n`nname = `"$($p.display)`"`ndescription = `"$(Esc-Yaml $p.description)`"`nmodel_reasoning_effort = `"high`"`n$sandboxLine`n`ndeveloper_instructions = `"`"`"`n$instr`n`"`"`"`n"
            }
            default { throw "Unknown persona_format: $fmt" }
        }
        Write-Generated $path (Apply-Slash $content $sep)
    }
}

function Emit-Commands($prof, $commands) {
    $dir = Join-Path $RepoRoot (Get-Field $prof "commands_dir")
    $layout = Get-Field $prof "command_layout" "flat"
    $ext = Get-Field $prof "command_ext" ".md"
    $fmt = Get-Field $prof "command_format" "claude"
    $sep = Get-Field $prof "slash_sep" "."
    foreach ($c in $commands) {
        if ($layout -eq "subdir") { $path = Join-Path (Join-Path $dir $c.ns) "$($c.cmd)$ext" }
        else { $path = Join-Path $dir "$($c.full)$ext" }
        switch ($fmt) {
            "claude" { $content = Build-FrontmatterCommand $c "claude" $prof "" }
            "codex"  {
                $lead = "<!-- Codex CLI adapter for /$($c.full) $Dash generated from .throughline/adapters/source. Filename ($($c.full).md) is the slash command; install by copying .codex/prompts/*.md into `$CODEX_HOME/prompts/. -->"
                $content = Build-FrontmatterCommand $c "codex" $prof $lead
            }
            "cursor" {
                $core = Build-CommandCore $c "cursor" $prof
                $content = "<!-- generated by tools/convert from .throughline/adapters/source/commands/$($c.full).command; edit there. -->`n`n# /$($c.full)`n`n$core`n`nUser input follows after the command: `$ARGUMENTS"
            }
            "antigravity-rule" {
                $core = Build-CommandCore $c "cursor" $prof
                $content = "<!-- generated by tools/convert from .throughline/adapters/source/commands/$($c.full).command; edit there. -->`n`n# Command: /$($c.full)`n`n$core`n`nUse this rule when the user asks for ``/$($c.full)`` or describes this lifecycle phase."
            }
            "opencode" {
                $core = Build-CommandCore $c "cursor" $prof
                $agentLine = if ($c.ns -eq "dev" -and $c.persona -ne "") { "agent: $($c.persona)`nsubtask: true`n" } else { "" }
                $content = "<!-- generated by tools/convert from .throughline/adapters/source/commands/$($c.full).command; edit there. -->`n---`ndescription: `"$(Esc-Yaml $c.description)`"`n$agentLine---`n`n$core`n`n`$ARGUMENTS"
            }
            "qwen" {
                $core = Build-CommandCore $c "cursor" $prof
                $content = "<!-- generated by tools/convert from .throughline/adapters/source/commands/$($c.full).command; edit there. -->`n---`ndescription: `"$(Esc-Yaml $c.description)`"`n---`n`n$core`n`n{{args}}"
            }
            default { throw "Unknown command_format: $fmt" }
        }
        Write-Generated $path (Apply-Slash $content $sep)
    }
}

function Emit-Prompts($prof, $commands) {
    $dir = Join-Path $RepoRoot (Get-Field $prof "prompts_dir")
    foreach ($c in $commands) {
        Write-Generated (Join-Path $dir "$($c.full).prompt.md") "---`nagent: $($c.full)`n---"
    }
}

function Emit-Hooks($prof, $hooks) {
    $fmt = Get-Field $prof "hook_format" "none"
    $path = Join-Path $RepoRoot (Get-Field $prof "hooks_file")
    $base = ".github/hooks/scripts"
    if ($fmt -eq "github-json") {
        $lines = @("{", '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; cross-OS (the windows field carries the PowerShell variant)",', '  "hooks": {')
        $phases = @(@{ key = "PreToolUse"; phase = "pre" }, @{ key = "PostToolUse"; phase = "post" })
        for ($pi = 0; $pi -lt $phases.Count; $pi++) {
            $entries = @($hooks | Where-Object { $_.phase -eq $phases[$pi].phase })
            $lines += "    `"$($phases[$pi].key)`": ["
            for ($i = 0; $i -lt $entries.Count; $i++) {
                $h = $entries[$i]
                $lines += "      {"
                $lines += "        `"type`": `"command`","
                $lines += "        `"command`": `"$base/$($h.script).sh`","
                $lines += "        `"windows`": `"powershell -NoProfile -ExecutionPolicy Bypass -File $base/$($h.script).ps1`","
                $lines += "        `"timeout`": $($h.timeout),"
                $lines += "        `"description`": `"$(Esc-Json $h.message)`""
                $lines += ("      }" + $(if ($i -lt $entries.Count - 1) { "," } else { "" }))
            }
            $lines += ("    ]" + $(if ($pi -lt $phases.Count - 1) { "," } else { "" }))
        }
        $lines += "  }"
        $lines += "}"
        Write-Generated $path ($lines -join "`n")
    }
    elseif ($fmt -eq "cursor-json") {
        # failClosed defaults to false: if a guard script errors (e.g. wrong OS launcher, or Cursor's
        # hook stdin shape differs from the Claude shape the scripts expect), the action is ALLOWED
        # rather than blocking the whole session. The verification spike (.cursor/VERIFICATION.md)
        # confirms the guards actually block; only then flip these to true for hard enforcement.
        $pre = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "write" })
        $shell = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "shell" })
        $post = @($hooks | Where-Object { $_.phase -eq "post" })
        $lines = @("{", '  "version": 1,', '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; tools/setup-hooks installs this to .cursor/hooks.json and rewrites commands per OS. failClosed is false until the verification spike passes.",', '  "hooks": {')
        $lines += '    "preToolUse": ['
        for ($i = 0; $i -lt $pre.Count; $i++) {
            $sep = if ($i -lt $pre.Count - 1) { "," } else { "" }
            $lines += "      { `"command`": `"$base/$($pre[$i].script).sh`", `"matcher`": `"Write|Delete`", `"failClosed`": false }$sep"
        }
        $lines += '    ],'
        $lines += '    "beforeShellExecution": ['
        for ($i = 0; $i -lt $shell.Count; $i++) {
            $sep = if ($i -lt $shell.Count - 1) { "," } else { "" }
            $lines += "      { `"command`": `"$base/$($shell[$i].script).sh`", `"failClosed`": false }$sep"
        }
        $lines += '    ],'
        $lines += '    "afterFileEdit": ['
        for ($i = 0; $i -lt $post.Count; $i++) {
            $sep = if ($i -lt $post.Count - 1) { "," } else { "" }
            $lines += "      { `"command`": `"$base/$($post[$i].script).sh`" }$sep"
        }
        $lines += '    ]'
        $lines += "  }"
        $lines += "}"
        Write-Generated $path ($lines -join "`n")
    }
    elseif ($fmt -eq "antigravity-json") {
        # Staged template; setup-hooks installs to .agents/hooks.json with per-OS commands.
        # Matchers follow Google codelabs (run_command for shell); file-write matchers are best-effort
        # until .agents/VERIFICATION.md confirms the exact Antigravity tool names.
        $preWrite = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "write" })
        $preShell = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "shell" })
        $post = @($hooks | Where-Object { $_.phase -eq "post" })
        $lines = @("{", '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; tools/setup-hooks installs this to .agents/hooks.json and rewrites commands per OS. Matchers are best-effort until the verification spike passes.",', '  "hooks": {')
        $lines += '    "PreToolUse": ['
        $preAll = @($preWrite + $preShell)
        for ($i = 0; $i -lt $preAll.Count; $i++) {
            $h = $preAll[$i]
            $matcher = if ($h.kind -eq "shell") { "run_command" } else { "write_file|edit_file|create_file" }
            $sep = if ($i -lt $preAll.Count - 1) { "," } else { "" }
            $lines += "      { `"type`": `"command`", `"command`": `"$base/$($h.script).sh`", `"matcher`": `"$matcher`", `"timeout`": $($h.timeout) }$sep"
        }
        $lines += '    ],'
        $lines += '    "PostToolUse": ['
        for ($i = 0; $i -lt $post.Count; $i++) {
            $sep = if ($i -lt $post.Count - 1) { "," } else { "" }
            $lines += "      { `"type`": `"command`", `"command`": `"$base/$($post[$i].script).sh`", `"timeout`": $($post[$i].timeout) }$sep"
        }
        $lines += '    ]'
        $lines += "  }"
        $lines += "}"
        Write-Generated $path ($lines -join "`n")
    }
    elseif ($fmt -eq "kimi-toml") {
        $preWrite = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "write" })
        $preShell = @($hooks | Where-Object { $_.phase -eq "pre" -and $_.kind -eq "shell" })
        $post = @($hooks | Where-Object { $_.phase -eq "post" })
        $lines = @(
            "# Generated by tools/convert from .throughline/adapters/source/hook-spec.tsv.",
            "# tools/setup-hooks installs this to .kimi/config.toml (hooks-only; merge with your Kimi config if needed).",
            "# Matchers are best-effort until .kimi/VERIFICATION.md confirms Kimi's exact tool names.",
            ""
        )
        foreach ($h in ($preWrite + $preShell)) {
            $matcher = if ($h.kind -eq "shell") { "Shell|Bash" } else { "WriteFile|StrReplaceFile" }
            $lines += "[[hooks]]"
            $lines += "event = `"PreToolUse`""
            $lines += "matcher = `"$matcher`""
            $lines += "command = `".github/hooks/scripts/$($h.script).sh`""
            $lines += "timeout = $($h.timeout)"
            $lines += ""
        }
        foreach ($h in $post) {
            $lines += "[[hooks]]"
            $lines += "event = `"PostToolUse`""
            $lines += "matcher = `"WriteFile|StrReplaceFile`""
            $lines += "command = `".github/hooks/scripts/$($h.script).sh`""
            $lines += "timeout = $($h.timeout)"
            $lines += ""
        }
        Write-Generated $path (($lines -join "`n").TrimEnd() + "`n")
    }
    elseif ($fmt -eq "copilot-cli-json") {
        # GitHub Copilot CLI reads .github/hooks/*.json (version 1). PascalCase event names select the
        # VS Code-compatible payload (tool_name/tool_input) the shared guard scripts already parse; each
        # entry carries both bash + powershell so one file works on every OS. NOTE: on the CLI a preToolUse
        # exit code 2 is a non-blocking warning, so guard ENFORCEMENT is advisory until verified -- see
        # docs/runtimes/copilot-cli.md.
        $preAll = @($hooks | Where-Object { $_.phase -eq "pre" })
        $post   = @($hooks | Where-Object { $_.phase -eq "post" })
        $lines = @("{", '  "version": 1,', '  "_generated": "by tools/convert from .throughline/adapters/source/hook-spec.tsv; .github/hooks/*.json for GitHub Copilot CLI. PascalCase events use the VS Code-compatible tool_name/tool_input payload. Guards run on both PreToolUse (advisory: a CLI preToolUse exit 2 is a warning) and PermissionRequest (enforcing: exit 2 denies) -- see docs/runtimes/copilot-cli.md.",', '  "hooks": {')
        $lines += '    "PreToolUse": ['
        for ($i = 0; $i -lt $preAll.Count; $i++) {
            $h = $preAll[$i]
            $matcher = if ($h.kind -eq "shell") { "Bash" } else { "Edit|Write" }
            $sep = if ($i -lt $preAll.Count - 1) { "," } else { "" }
            $lines += "      { `"type`": `"command`", `"matcher`": `"$matcher`", `"bash`": `"bash $base/$($h.script).sh`", `"powershell`": `"powershell -NoProfile -ExecutionPolicy Bypass -File $base/$($h.script).ps1`", `"timeoutSec`": $($h.timeout) }$sep"
        }
        $lines += '    ],'
        # PermissionRequest fires before the CLI permission flow; a command-hook exit 2 = DENY there,
        # so the same guard scripts that only WARN on PreToolUse actually block on the CLI. Non-violations
        # exit 0 and fall through. (PermissionRequest does not fire on cloud agent.)
        $lines += '    "PermissionRequest": ['
        for ($i = 0; $i -lt $preAll.Count; $i++) {
            $h = $preAll[$i]
            $matcher = if ($h.kind -eq "shell") { "Bash" } else { "Edit|Write" }
            $sep = if ($i -lt $preAll.Count - 1) { "," } else { "" }
            $lines += "      { `"type`": `"command`", `"matcher`": `"$matcher`", `"bash`": `"bash $base/$($h.script).sh`", `"powershell`": `"powershell -NoProfile -ExecutionPolicy Bypass -File $base/$($h.script).ps1`", `"timeoutSec`": $($h.timeout) }$sep"
        }
        $lines += '    ],'
        $lines += '    "PostToolUse": ['
        for ($i = 0; $i -lt $post.Count; $i++) {
            $h = $post[$i]
            $sep = if ($i -lt $post.Count - 1) { "," } else { "" }
            $lines += "      { `"type`": `"command`", `"matcher`": `"Edit|Write`", `"bash`": `"bash $base/$($h.script).sh`", `"powershell`": `"powershell -NoProfile -ExecutionPolicy Bypass -File $base/$($h.script).ps1`", `"timeoutSec`": $($h.timeout) }$sep"
        }
        $lines += '    ]'
        $lines += "  }"
        $lines += "}"
        Write-Generated $path ($lines -join "`n")
    }
    else { throw "Unknown hook_format: $fmt" }
}

function Emit-Rules($prof, $personas, $commands) {
    $fmt = Get-Field $prof "rules_format" "mdc"
    $path = Join-Path $RepoRoot (Get-Field $prof "rules_file")
    $sep = Get-Field $prof "slash_sep" "."
    $global = ((Read-Utf8 (Join-Path $SourceDir "global-rules.md")) -replace "`r`n", "`n").TrimEnd("`n")
    if ($fmt -eq "mdc") {
        Write-Generated $path (Apply-Slash "---`ndescription: Throughline non-negotiables and bootstrap sequence`nalwaysApply: true`n---`n`n$global" $sep)
    }
    elseif ($fmt -eq "bundle") {
        $disp = Get-Field $prof "display" (Get-Field $prof "id")
        $sb = @()
        $sb += "# Throughline $Dash rules-only integration for $disp"
        $sb += ""
        $sb += "WARNING: $disp has no hooks and no subagents. The read-only guard on /standards/ and"
        $sb += "/exemplars/ and the no-merge/no-push rule are INSTRUCTED here, not enforced. Honor them"
        $sb += "yourself. For enforced guards, use a Tier A tool (Claude Code, Cursor, Codex, Copilot)."
        $sb += ""
        $sb += $global
        $sb += ""
        $sb += "## Personas (adopt the matching one for each phase)"
        $sb += ""
        foreach ($p in $personas) { $sb += "- **$($p.display)** $Dash $($p.description)" }
        $sb += ""
        $sb += "## Commands (follow the runbook for each)"
        $sb += ""
        foreach ($c in ($commands | Sort-Object full)) { $sb += "- /$($c.full) $Dash $($c.description)" }
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    elseif ($fmt -eq "gemini") {
        $disp = Get-Field $prof "display" (Get-Field $prof "id")
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/antigravity.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' Antigravity (`GEMINI.md`)'
        $sb += ''
        $sb += 'Antigravity reads this file with **higher priority** than root `AGENTS.md`. The committed'
        $sb += '`AGENTS.md` is the **Codex** adapter peer ' + $Dash + ' do not edit it for Antigravity; use this file'
        $sb += 'and `.agent/rules/` instead.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## Antigravity wiring'
        $sb += ''
        $sb += '- **Personas**: `.agents/personas/*.md` ' + $Dash + ' adopt the matching one when delegating (Orchestrator spawns separate contexts).'
        $sb += '- **Commands**: `.agent/rules/commands/*.md` ' + $Dash + ' one rule file per lifecycle command; follow its runbook when invoked.'
        $sb += '- **Hooks**: `.agents/hooks.json` (machine-local, wired by `tools/setup-hooks` from the staged template).'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        $sb += ''
        $sb += '> Preview adapter ' + $Dash + ' see `.agents/VERIFICATION.md` before trusting hook enforcement.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
        $extra = Get-Field $prof "rules_extra_file"
        if ($extra -ne "") {
            $extraPath = Join-Path $RepoRoot $extra
            $extraBody = "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md; edit there. -->`n`n$global"
            Write-Generated $extraPath (Apply-Slash $extraBody $sep)
        }
    }
    elseif ($fmt -eq "qwen") {
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/qwen.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' Qwen Code (`QWEN.md`)'
        $sb += ''
        $sb += 'Qwen Code loads this file as project context (alongside root `AGENTS.md`). The committed'
        $sb += '`AGENTS.md` is the **Codex** adapter peer ' + $Dash + ' do not edit it for Qwen; use this file and'
        $sb += '`.qwen/` instead.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## Qwen Code wiring'
        $sb += ''
        $sb += '- **Personas**: `.qwen/agents/*.md` ' + $Dash + ' subagents; delegate so the Reviewer stays independent.'
        $sb += '- **Commands**: `.qwen/commands/<ns>/<cmd>.md` ' + $Dash + ' slash names use colons from paths (e.g. `/dev:analyze`); runbooks use dot form in prose.'
        $sb += '- **Guards**: `.qwen/settings.json` ' + $Dash + ' `permissions.deny` for `/standards/` + `/exemplars/` and git push/merge.'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        $sb += ''
        $sb += '> Preview adapter ' + $Dash + ' see `.qwen/VERIFICATION.md` before trusting permission enforcement.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    elseif ($fmt -eq "kimi") {
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/kimi.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' Kimi Code (`.kimi/AGENTS.md`)'
        $sb += ''
        $sb += 'Kimi merges this file with root `AGENTS.md`. The committed `AGENTS.md` is the **Codex**'
        $sb += 'adapter peer ' + $Dash + ' do not edit it for Kimi; use this overlay and `.kimi/` instead.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## Kimi Code wiring'
        $sb += ''
        $sb += '- **Personas**: `.kimi/personas/*.md` ' + $Dash + ' adopt or delegate via the Agent tool (Orchestrator spawns separate contexts).'
        $sb += '- **Workflows**: `.kimi/workflows/*.md` ' + $Dash + ' lifecycle phase runbook pointers (no native slash-command dir).'
        $sb += '- **Hooks**: `.kimi/config.toml` (machine-local, wired by `tools/setup-hooks` from the staged template).'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        $sb += ''
        $sb += '> Preview adapter ' + $Dash + ' see `.kimi/VERIFICATION.md` before trusting hook enforcement.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    elseif ($fmt -eq "opencode-index") {
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/opencode.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' OpenCode (`.opencode/throughline.md`)'
        $sb += ''
        $sb += 'OpenCode loads this file via `opencode.json` `instructions`. Root `AGENTS.md` is the **Codex**'
        $sb += 'adapter peer ' + $Dash + ' do not edit it for OpenCode; use this file and `.opencode/` instead.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## OpenCode wiring'
        $sb += ''
        $sb += '- **Personas**: `.opencode/agents/*.md` ' + $Dash + ' subagents; @mention or set `agent` on commands.'
        $sb += '- **Commands**: `.opencode/commands/*.md` ' + $Dash + ' native slash commands (filename = command name).'
        $sb += '- **Guards**: `opencode.json` ' + $Dash + ' declarative `permission` denies on `/standards/` + `/exemplars/` and git push/merge.'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        $sb += ''
        $sb += '> Preview adapter ' + $Dash + ' see `.opencode/VERIFICATION.md` before trusting permission enforcement.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    elseif ($fmt -eq "codex") {
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/codex.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' Codex (`AGENTS.md`)'
        $sb += ''
        $sb += 'Codex reads this `AGENTS.md` as the root agent instructions for the repo; it is also the'
        $sb += 'shared `AGENTS.md` other adapters point at as the **Codex** peer. Personas are'
        $sb += '`.codex/agents/*.toml`; commands are `.codex/prompts/*.md`.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## Codex wiring'
        $sb += ''
        $sb += '- **Personas**: `.codex/agents/*.toml` ' + $Dash + ' spawn the matching one as a separate Codex subagent so the Reviewer stays independent.'
        $sb += '- **Commands**: `.codex/prompts/*.md` ' + $Dash + ' copy into `$CODEX_HOME/prompts/`; each points at its runbook.'
        $sb += '- **Hooks**: `.codex/hooks.json` (machine-local, wired by `tools/setup-hooks` for your OS) ' + $Dash + ' blocks writes to `/standards/` + `/exemplars/` and git push/merge.'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        $sb += ''
        $sb += '> Preview adapter ' + $Dash + ' see `.codex/VERIFICATION.md` before trusting hook enforcement.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    elseif ($fmt -eq "claude") {
        $sb = @()
        $sb += "<!-- generated by tools/convert from .throughline/adapters/source/global-rules.md + profiles/claude.profile; edit the source, not this file. -->"
        $sb += ""
        $sb += '# Throughline ' + $Dash + ' Claude Code (`CLAUDE.md`)'
        $sb += ''
        $sb += 'Claude Code loads this `CLAUDE.md` as project memory at the start of every session.'
        $sb += 'Personas are `.claude/agents/*.md`; commands are `.claude/commands/<ns>/<cmd>.md`.'
        $sb += ''
        $sb += $global
        $sb += ''
        $sb += '## Claude Code wiring'
        $sb += ''
        $sb += '- **Personas**: `.claude/agents/*.md` ' + $Dash + ' delegate via the Agent tool so the Reviewer stays independent.'
        $sb += '- **Commands**: `.claude/commands/<ns>/<cmd>.md` ' + $Dash + ' native slash commands; each points at its runbook.'
        $sb += '- **Skills**: `.claude/skills/` ' + $Dash + ' byte-identical mirror of `.github/skills/`.'
        $sb += '- **Hooks**: `.claude/settings.local.json` (machine-local, wired by `tools/setup-hooks`) ' + $Dash + ' blocks writes to `/standards/` + `/exemplars/` and git push/merge; the committed `.claude/settings.json` keeps the always-on read-only guard.'
        $sb += '- **Canonical brain**: `.throughline/extensions/dev/commands/`, `.github/instructions/`, `/standards/`.'
        Write-Generated $path (Apply-Slash ($sb -join "`n") $sep)
    }
    else { throw "Unknown rules_format: $fmt" }
}

function Emit-Config($prof) {
    $fmt = Get-Field $prof "config_format" "none"
    $path = Join-Path $RepoRoot (Get-Field $prof "config_file")
    if ($fmt -eq "opencode-json") {
        $lines = @(
            "{",
            '  "$schema": "https://opencode.ai/config.json",',
            '  "_generated": "by tools/convert from profiles/opencode.profile; edit the profile source, not this file.",',
            '  "instructions": [".opencode/throughline.md"],',
            '  "permission": {',
            '    "edit": {',
            '      "standards/**": "deny",',
            '      "exemplars/**": "deny"',
            '    },',
            '    "bash": {',
            '      "git push*": "deny",',
            '      "git merge*": "deny"',
            '    }',
            '  }',
            "}"
        )
        Write-Generated $path ($lines -join "`n")
    }
    elseif ($fmt -eq "qwen-json") {
        $lines = @(
            "{",
            '  "_generated": "by tools/convert from profiles/qwen.profile; edit the profile source, not this file.",',
            '  "context": {',
            '    "fileName": ["QWEN.md", "AGENTS.md"]',
            '  },',
            '  "permissions": {',
            '    "deny": [',
            '      "Write(standards/**)",',
            '      "Edit(standards/**)",',
            '      "Write(exemplars/**)",',
            '      "Edit(exemplars/**)",',
            '      "Bash(git push *)",',
            '      "Bash(git merge *)"',
            '    ]',
            '  }',
            "}"
        )
        Write-Generated $path ($lines -join "`n")
    }
    else { throw "Unknown config_format: $fmt" }
}

function Copy-SourceTree([string]$srcSubdir, [string]$dstSubdir, [switch]$AddMarker) {
    $srcRoot = Join-Path $SourceDir $srcSubdir
    if (-not (Test-Path $srcRoot)) { return }
    Get-ChildItem $srcRoot -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($srcRoot.Length).TrimStart('\','/')
        $outPath = Join-Path (Join-Path $RepoRoot $dstSubdir) $rel
        $text = ((Read-Utf8 $_.FullName) -replace "`r`n", "`n").TrimEnd("`n")
        if ($AddMarker -and $_.Extension -eq ".md" -and -not $text.StartsWith("<!-- generated")) {
            $text = "<!-- generated by tools/convert from .throughline/adapters/source/$srcSubdir/$rel; edit the source, not this file. -->`n`n" + $text
        }
        Write-Generated $outPath $text
    }
}

function Emit-ToolDocs {
    $base = Join-Path $SourceDir "tool-docs"
    if (-not (Test-Path $base)) { return }
    $map = @{
        "codex/config.toml"           = ".codex/config.toml"
        "codex/README.md"               = ".codex/README.md"
        "codex/VERIFICATION.md"         = ".codex/VERIFICATION.md"
        "claude-hooks/README.md"        = ".claude/hooks/README.md"
        "cursor/README.md"              = ".cursor/README.md"
        "cursor/VERIFICATION.md"        = ".cursor/VERIFICATION.md"
        "antigravity/README.md"         = ".agents/README.md"
        "antigravity/VERIFICATION.md"   = ".agents/VERIFICATION.md"
        "opencode/README.md"            = ".opencode/README.md"
        "opencode/VERIFICATION.md"        = ".opencode/VERIFICATION.md"
        "qwen/README.md"                = ".qwen/README.md"
        "qwen/VERIFICATION.md"            = ".qwen/VERIFICATION.md"
        "kimi/README.md"                = ".kimi/README.md"
        "kimi/VERIFICATION.md"            = ".kimi/VERIFICATION.md"
    }
    foreach ($rel in ($map.Keys | Sort-Object)) {
        $src = Join-Path $base ($rel -replace '/', '\')
        if (-not (Test-Path $src)) { continue }
        $dest = Join-Path $RepoRoot ($map[$rel].Replace('/', '\'))
        $text = ((Read-Utf8 $src) -replace "`r`n", "`n").TrimEnd("`n")
        if ($rel -match '\.md$' -and -not $text.StartsWith("<!-- generated")) {
            $text = "<!-- generated by tools/convert from .throughline/adapters/source/tool-docs/$rel; edit the source, not this file. -->`n`n" + $text
        }
        Write-Generated $dest $text
    }
}

function Emit-Shared {
    Write-Host "[shared] canonical GitHub + globals from .throughline/adapters/source/"
    Copy-SourceTree "instructions" ".github/instructions" -AddMarker
    Copy-SourceTree "skills" ".github/skills"
    Copy-SourceTree "skills" ".claude/skills"
    Copy-SourceTree "hooks" ".github/hooks/scripts"
    Copy-SourceTree "hooks" ".claude/hooks"
    Copy-SourceTree "agents" ".github/agents" -AddMarker
    Emit-ToolDocs
    $globalsDir = Join-Path $SourceDir "globals"
    $globalMap = @{
        "copilot-instructions.md"   = ".github/copilot-instructions.md"
        "claude-settings.json"      = ".claude/settings.json"
        "pull_request_template.md"  = ".github/pull_request_template.md"
    }
    foreach ($name in $globalMap.Keys) {
        $srcPath = Join-Path $globalsDir $name
        if (-not (Test-Path $srcPath)) { continue }
        $text = ((Read-Utf8 $srcPath) -replace "`r`n", "`n").TrimEnd("`n")
        if ($name -match '\.md$' -and -not $text.StartsWith("<!-- generated")) {
            $text = "<!-- generated by tools/convert from .throughline/adapters/source/globals/$name; edit the source, not this file. -->`n`n" + $text
        }
        Write-Generated (Join-Path $RepoRoot $globalMap[$name]) $text
    }
}

function Emit-Manifest($prof) {
    $path = Join-Path $RepoRoot (Get-Field $prof "manifest_path")
    $entries = @()
    if (Is-True $prof "emit_personas")  { $entries += "    `"personas_dir`": `"$(Get-Field $prof 'personas_dir')`"" }
    if (Is-True $prof "emit_commands")  { $entries += "    `"commands_dir`": `"$(Get-Field $prof 'commands_dir')`"" }
    if (Is-True $prof "emit_prompts")   { $entries += "    `"prompts_dir`": `"$(Get-Field $prof 'prompts_dir')`"" }
    if (Is-True $prof "emit_hooks")     { $entries += "    `"hooks`": `"$(Get-Field $prof 'hooks_file')`"" }
    if (Is-True $prof "emit_rules_file") {
        $entries += "    `"rules_file`": `"$(Get-Field $prof 'rules_file')`""
        $rex = Get-Field $prof "rules_extra_file"
        if ($rex -ne "") { $entries += "    `"rules_extra`": `"$rex`"" }
    }
    if (Is-True $prof "emit_config")   { $entries += "    `"config_file`": `"$(Get-Field $prof 'config_file')`"" }
    $id = Get-Field $prof "id"
    $lines = @("{")
    $lines += "  `"integration`": `"$id`","
    $lines += "  `"version`": `"0.1.0`","
    $lines += "  `"status`": `"$(Get-Field $prof 'status')`","
    $lines += "  `"tier`": `"$(Get-Field $prof 'tier')`","
    $lines += "  `"slash_syntax`": `"$(Esc-Json (Get-Field $prof 'slash_example'))`","
    $lines += "  `"generated_by`": `"tools/convert from .throughline/adapters/source + profiles/$id.profile`","
    $lines += "  `"entry_points`": {"
    $lines += ($entries -join ",`n")
    $lines += "  },"
    $lines += "  `"notes`": `"Thin adapter generated from the single source. Canonical procedure lives in .throughline/extensions/dev/commands/ and .throughline/adapters/source/agents/.`""
    $lines += "}"
    Write-Generated $path ($lines -join "`n")
}

# --- driver ----------------------------------------------------------------

function Get-AllToolIds {
    return (Get-ChildItem $ProfileDir -Filter *.profile | Sort-Object Name | ForEach-Object { $_.BaseName })
}

function Convert-Tool([string]$id) {
    $profilePath = Join-Path $ProfileDir "$id.profile"
    if (-not (Test-Path $profilePath)) { throw "No profile for tool '$id' ($profilePath)" }
    $prof = ConvertFrom-MetaText (Read-Utf8 $profilePath)
    Write-Host "[$id] $(Get-Field $prof 'display' $id) $Dash tier $(Get-Field $prof 'tier'), $(Get-Field $prof 'status')"
    $personas = Get-Personas
    $commands = Get-Commands
    $hooks    = Get-Hooks
    if (Is-True $prof "emit_personas")   { Emit-Personas $prof $personas }
    if (Is-True $prof "emit_commands")   { Emit-Commands $prof $commands }
    if (Is-True $prof "emit_prompts")    { Emit-Prompts $prof $commands }
    if (Is-True $prof "emit_hooks")      { Emit-Hooks $prof $hooks }
    if (Is-True $prof "emit_rules_file") { Emit-Rules $prof $personas $commands }
    if (Is-True $prof "emit_config")     { Emit-Config $prof }
    if (Is-True $prof "emit_manifest")   { Emit-Manifest $prof }
}

if ($List) {
    foreach ($id in Get-AllToolIds) {
        $p = ConvertFrom-MetaText (Read-Utf8 (Join-Path $ProfileDir "$id.profile"))
        "{0,-10} {1,-12} tier {2}  {3}" -f $id, (Get-Field $p 'status'), (Get-Field $p 'tier'), (Get-Field $p 'display')
    }
    return
}

if ($Tool -eq "shared") { Emit-Shared }
elseif ($Tool -eq "all") {
    Emit-Shared
    foreach ($id in Get-AllToolIds) { Convert-Tool $id }
}
else {
    Emit-Shared
    Convert-Tool $Tool
}
Write-Host "done."
