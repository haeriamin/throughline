# common.ps1 — shared helpers for Throughline lifecycle scripts (dot-source this file).

function Get-RepoRoot {
    $dir = Get-Location
    while ($dir) {
        if (Test-Path (Join-Path $dir ".throughline\memory\constitution.md")) { return $dir.ToString() }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir.ToString()) { break }
        $dir = $parent
    }
    throw "Not inside the framework (no .throughline/memory/constitution.md found upward from $(Get-Location))."
}

function Read-TargetField([string]$Id, [string]$Field, [string]$Default = "") {
    $root = Get-RepoRoot
    $yml = Join-Path $root "targets\$Id.yml"
    if (-not (Test-Path $yml)) { throw "Target '$Id' not registered ($yml missing)." }
    foreach ($line in Get-Content $yml) {
        if ($line -match "^\s*$Field\s*:\s*(.*)$") {
            $v = ($Matches[1] -replace '\s+#.*$', '').Trim().Trim('"')
            if ($v -ne "") { return $v }
        }
    }
    if ($Default -ne "") { return $Default }
    throw "Target '$Id' has no '$Field' in $yml."
}

function Get-TargetRoot([string]$Id) { return (Read-TargetField $Id "path") }
function Get-TargetThroughlineDir([string]$Id) { return (Read-TargetField $Id "throughline_dir" ".throughline") }
function Get-TargetSpecsDir([string]$Id) { return (Join-Path (Get-TargetRoot $Id) (Join-Path (Get-TargetThroughlineDir $Id) "specs")) }

function Get-FeatureDirectory {
    # Active slice's spec dir (absolute, target-side) from .throughline/feature.json.
    $root = Get-RepoRoot
    $featureJson = Join-Path $root ".throughline\feature.json"
    if (Test-Path $featureJson) {
        $data = Get-Content $featureJson -Raw | ConvertFrom-Json
        if ($data.feature_directory -and (Test-Path $data.feature_directory)) { return $data.feature_directory }
    }
    throw "No active feature directory. Run /throughline.specify first."
}

function Get-NextFeatureNumber([string]$Id) {
    # Per-target numbering: scan <target>/.throughline/specs/.
    $specs = Get-TargetSpecsDir $Id
    $max = 0
    Get-ChildItem $specs -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -match '^(\d{3})-') { $n = [int]$Matches[1]; if ($n -gt $max) { $max = $n } }
    }
    return "{0:D3}" -f ($max + 1)
}

function Write-JsonOutput([hashtable]$Data) {
    $Data | ConvertTo-Json -Compress | Write-Output
}
