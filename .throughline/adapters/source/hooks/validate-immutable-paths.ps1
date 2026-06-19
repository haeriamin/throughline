# validate-immutable-paths.ps1
# PreToolUse hook — blocks write operations targeting immutable directories.
# Tool call context arrives as JSON on stdin. Exit 2 with a message to block; exit 0 to allow.
$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$ti = $data
if ($null -ne $data.tool_input) { $ti = $data.tool_input }

$filePath = $null
foreach ($field in @("file_path", "path", "notebook_path", "target", "destination")) {
    $val = $ti.$field
    if ($null -ne $val -and "$val" -ne "") { $filePath = "$val"; break }
}
if ($null -eq $filePath) { exit 0 }

$norm = $filePath.Replace('\', '/')

function Block-ImmutablePath($p) {
    Write-Output "BLOCKED: Attempted write to immutable path: $p"
    Write-Output "The framework seeds standards/ + exemplars/ and any target's .throughline/standards|exemplars are READ ONLY (Constitution Principle I)."
    Write-Output "These are human-curated. Re-form the command without the write, or stop and escalate."
    exit 2
}

# 1) Target-local overrides (<target>/.throughline/standards|exemplars) — immutable wherever the
#    target lives, at any depth.
if ($norm -match '(^|/)\.throughline/(standards|exemplars)/') { Block-ImmutablePath $filePath }

# 2) Framework org seeds at the repo root. Detect the framework root from THIS script's location
#    (walk up to the constitution marker) and block only <root>/standards and <root>/exemplars.
#    This is precise: a target's own src/standards or src/exemplars folder is NOT the framework
#    seed and must stay writable (the old bare "/standards/" substring match blocked it by mistake).
$root = $null
$dir = $PSScriptRoot
while ($dir) {
    if (Test-Path (Join-Path $dir ".throughline/memory/constitution.md")) { $root = $dir; break }
    $parent = Split-Path $dir -Parent
    if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
    $dir = $parent
}

if ($null -ne $root) {
    $rootNorm = ($root.Replace('\', '/')).TrimEnd('/')
    # A relative path denotes a framework file (the agent's cwd is the framework root); resolve it.
    $abs = $norm
    if ($norm -notmatch '^[A-Za-z]:/' -and -not $norm.StartsWith('/')) {
        $abs = "$rootNorm/" + ($norm -replace '^(\./)+', '')
    }
    $absLower = $abs.ToLower()
    foreach ($seed in @("standards", "exemplars")) {
        $seedRoot = "$rootNorm/$seed".ToLower()
        if ($absLower -eq $seedRoot -or $absLower.StartsWith("$seedRoot/")) { Block-ImmutablePath $filePath }
    }
}
else {
    # Degraded (script not inside a framework checkout — no root to anchor an absolute check):
    # block only relative seed paths so we never under-block; nothing to over-block here.
    if ($norm -match '^(\./)*(standards|exemplars)/') { Block-ImmutablePath $filePath }
}
exit 0
