# install.ps1 — interactive installer for Throughline tool adapters (Windows, no Python required).
#
# Picks which AI coding tools you want, generates their thin adapters from the single source of
# truth (tools/convert.ps1), and wires per-OS hooks for the tools that enforce them
# (tools/setup-hooks.ps1). The Unix peer is tools/install.sh.
#
#   powershell -ExecutionPolicy Bypass -File tools/install.ps1            # interactive
#   ... tools/install.ps1 -List                                          # list tools, exit
#   ... tools/install.ps1 -Tool cursor                                   # one tool
#   ... tools/install.ps1 -All                                           # every tool
#   ... tools/install.ps1 -Tool cursor -NoInteractive -DryRun            # show, write nothing
param(
    [string]$Tool,
    [switch]$All,
    [switch]$List,
    [switch]$NoInteractive,
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$profileDir = Join-Path $root ".throughline\adapters\profiles"
$Dash = [char]0x2014

function Get-Field($file, $key, $default = "") {
    foreach ($line in [System.IO.File]::ReadAllLines($file)) {
        if ($line.StartsWith("$key = ")) { return $line.Substring($key.Length + 3) }
    }
    return $default
}

# Discover tools from the profiles directory.
$tools = @()
foreach ($p in (Get-ChildItem $profileDir -Filter *.profile | Sort-Object Name)) {
    $tools += [pscustomobject]@{
        id      = [System.IO.Path]::GetFileNameWithoutExtension($p.Name)
        display = (Get-Field $p.FullName "display")
        status  = (Get-Field $p.FullName "status")
        tier    = (Get-Field $p.FullName "tier")
        emitHooks = ((Get-Field $p.FullName "emit_hooks" "false") -eq "true")
        rulesOnly = ((Get-Field $p.FullName "tier") -eq "B")
    }
}

function Show-Table {
    Write-Host ""
    Write-Host ("  {0,-3} {1,-10} {2,-14} {3,-12} {4}" -f "#", "id", "status", "tier", "name")
    Write-Host ("  " + ("-" * 60))
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $t = $tools[$i]
        $tierLabel = if ($t.tier -eq "A") { "A (enforced)" } else { "B (rules-only)" }
        Write-Host ("  {0,-3} {1,-10} {2,-14} {3,-12} {4}" -f ($i + 1), $t.id, $t.status, $tierLabel, $t.display)
    }
    Write-Host ""
}

if ($List) { Show-Table; exit 0 }

# Resolve the selection.
$selected = @()
if ($Tool) {
    $selected = @($tools | Where-Object { $_.id -eq $Tool })
    if (-not $selected) { Write-Error "Unknown tool '$Tool'. Run -List to see the choices."; exit 2 }
}
elseif ($All) { $selected = $tools }
elseif ($NoInteractive) { Write-Error "Non-interactive run needs -Tool <id> or -All."; exit 2 }
else {
    Write-Host "Throughline multi-tool installer"
    Write-Host "Pick the tools to set up. Tier A enforce the guards via hooks; Tier B are rules-only (advisory)."
    Show-Table
    $answer = Read-Host "Enter numbers (comma-separated), 'all', or blank to cancel"
    if (-not $answer) { Write-Host "Cancelled."; exit 0 }
    if ($answer.Trim() -eq "all") { $selected = $tools }
    else {
        foreach ($tok in ($answer -split "[,\s]+")) {
            if ($tok -match '^\d+$') {
                $idx = [int]$tok - 1
                if ($idx -ge 0 -and $idx -lt $tools.Count) { $selected += $tools[$idx] }
            }
            else { $selected += ($tools | Where-Object { $_.id -eq $tok }) }
        }
    }
    $selected = $selected | Sort-Object id -Unique
}
if (-not $selected) { Write-Host "Nothing selected."; exit 0 }

# 1. Generate shared content + tool adapters (single convert invocation).
$convert = Join-Path $PSScriptRoot "convert.ps1"
$convertArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $convert)
if ($DryRun) { $convertArgs += "-DryRun" }
if ($All -or ($selected.Count -gt 1)) {
    Write-Host ""
    Write-Host "==> Generating shared content + all tool adapters (convert -Tool all)"
    $convertArgs += @("-Tool", "all")
}
else {
    Write-Host ""
    Write-Host "==> Generating shared content + $($selected[0].display) (convert -Tool $($selected[0].id))"
    $convertArgs += @("-Tool", $selected[0].id)
}
& powershell @convertArgs

function Test-NeedHooks([string[]]$ids) {
    foreach ($id in $ids) {
        if ($id -in @("claude", "codex")) { return $true }
        $pf = Join-Path $profileDir "$id.profile"
        if ((Get-Field $pf "emit_hooks" "false") -eq "true") { return $true }
    }
    return $false
}

# 2. Wire hooks per-OS when a hook-using tool was installed (not rules-only Tier B).
if ((-not $DryRun) -and (Test-NeedHooks ($selected | ForEach-Object { $_.id }))) {
    Write-Host ""
    Write-Host "==> Wiring per-OS hooks (setup-hooks.ps1)"
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "setup-hooks.ps1")
}

# 3. Per-tool next steps.
Write-Host ""
Write-Host "Done.$(if ($DryRun) { ' (dry run - nothing written)' })"
foreach ($t in $selected) {
    switch ($t.id) {
        "codex"  { Write-Host "  codex:   copy .codex/prompts/*.md into `$CODEX_HOME/prompts/ (default ~/.codex/prompts)." }
        "cursor" { Write-Host "  cursor:  reload the window so Cursor reads .cursor/agents, .cursor/commands, and hooks.json." }
        "antigravity" { Write-Host "  antigravity: open this repo in Antigravity; it reads GEMINI.md, .agent/rules/, .agents/personas/, and .agents/hooks.json." }
        "opencode"  { Write-Host "  opencode:  run opencode in this repo; it reads opencode.json, .opencode/throughline.md, agents, and commands." }
        "qwen"      { Write-Host "  qwen:      run qwen in this repo; it reads QWEN.md, .qwen/agents/, .qwen/commands/, and .qwen/settings.json." }
        "kimi"      { Write-Host "  kimi:      run kimi in this repo; it reads .kimi/AGENTS.md, .kimi/personas/, workflows, and .kimi/config.toml." }
        default  {
            if ($t.rulesOnly) {
                $rf = Get-Field (Join-Path $profileDir "$($t.id).profile") "rules_file"
                Write-Host "  $($t.id): rules-only $Dash guards are INSTRUCTED, not enforced. Copy $rf into your workspace where $($t.display) reads its rules."
            }
        }
    }
}
