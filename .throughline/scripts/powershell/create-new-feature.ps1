# create-new-feature.ps1 — create <target>/.throughline/specs/NNN-<short-name>/ from the spec template.
# Usage: .\create-new-feature.ps1 -Target "my-app" -ShortName "jwt-auth" [-Template "spec-template.md"]
# Outputs JSON: { FEATURE_DIR, SPEC_FILE, FEATURE_NUM, TARGET }
param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string]$ShortName,
    [string]$Template = "spec-template.md"
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$root = Get-RepoRoot
if ($ShortName -notmatch '^[a-z0-9][a-z0-9-]*$') {
    throw "ShortName must be kebab-case (got '$ShortName')."
}

$specsDir = Get-TargetSpecsDir $Target
$num = Get-NextFeatureNumber $Target
$featureDir = Join-Path $specsDir "$num-$ShortName"
New-Item -ItemType Directory -Force $featureDir | Out-Null
New-Item -ItemType Directory -Force (Join-Path $featureDir "checklists") | Out-Null

$templatePath = Join-Path $root ".throughline\templates\$Template"
if (-not (Test-Path $templatePath)) { throw "Template not found: $templatePath" }
$specFile = Join-Path $featureDir "spec.md"
Copy-Item $templatePath $specFile

@{ target = $Target; feature_directory = $featureDir } | ConvertTo-Json | Set-Content (Join-Path $root ".throughline\feature.json") -Encoding utf8

Write-JsonOutput @{ FEATURE_DIR = $featureDir; SPEC_FILE = $specFile; FEATURE_NUM = $num; TARGET = $Target }
