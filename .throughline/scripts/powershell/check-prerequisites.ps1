# check-prerequisites.ps1 — verify lifecycle phase prerequisites for the active feature.
# Usage: .\check-prerequisites.ps1 -Phase plan|tasks|implement
# Outputs JSON: { OK, FEATURE_DIR, MISSING[] }
param([Parameter(Mandatory = $true)][ValidateSet("plan", "tasks", "implement")][string]$Phase)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$featureDir = Get-FeatureDirectory
$missing = @()

$require = @{ plan = @("spec.md"); tasks = @("spec.md", "plan.md"); implement = @("spec.md", "plan.md", "tasks.md") }
foreach ($f in $require[$Phase]) {
    if (-not (Test-Path (Join-Path $featureDir $f))) { $missing += $f }
}

# Clarification markers block plan and beyond.
$specPath = Join-Path $featureDir "spec.md"
if ((Test-Path $specPath) -and (Select-String -Path $specPath -Pattern '\[NEEDS CLARIFICATION' -Quiet)) {
    $missing += "unresolved [NEEDS CLARIFICATION] markers in spec.md"
}

# HIGH/CRITICAL complexity requires an approved design before tasks/implement.
if ($Phase -ne "plan" -and (Test-Path $specPath)) {
    $spec = Get-Content $specPath -Raw
    if ($spec -match '\*\*Class\*\*:\s*(HIGH|CRITICAL)') {
        $designPath = Join-Path $featureDir "design.md"
        if (-not (Test-Path $designPath)) { $missing += "design.md (required for $($Matches[1]) complexity)" }
        elseif (-not (Select-String -Path $designPath -Pattern '\*\*Status\*\*:\s*.*Approved' -Quiet)) {
            $missing += "design.md approval (Status must be Approved)"
        }
    }
}

$rel = $featureDir.Substring((Get-RepoRoot).Length).TrimStart('\').Replace('\', '/')
Write-JsonOutput @{ OK = ($missing.Count -eq 0); FEATURE_DIR = $rel; MISSING = $missing }
if ($missing.Count -gt 0) { exit 1 }
