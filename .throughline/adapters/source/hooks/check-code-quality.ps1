# check-code-quality.ps1
# PostToolUse hook — lightweight quality lint on just-written source files.
# Warns (stdout) but never blocks (always exits 0).
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
if ($null -eq $filePath -or -not (Test-Path $filePath)) { exit 0 }

$ext = [System.IO.Path]::GetExtension($filePath).ToLower()
if ($ext -notin @(".ts", ".tsx", ".js", ".jsx", ".py", ".cs", ".go", ".rs", ".java", ".rb", ".php")) { exit 0 }

$content = Get-Content $filePath -Raw
if ($null -eq $content) { exit 0 }
$warnings = 0

if ($content -match '(?m)^(<<<<<<<|=======|>>>>>>>)') {
    Write-Output "WARN [$filePath]: merge-conflict markers present"
    $warnings++
}
if ($content -match 'console\.log\(|debugger;|breakpoint\(\)|pdb\.set_trace') {
    Write-Output "WARN [$filePath]: possible debug statements left in source"
    $warnings++
}
$todoLines = ($content -split "`n") | Where-Object { $_ -match '\b(TODO|FIXME)\b' -and $_ -notmatch 'DEV-STATUS' }
if ($todoLines.Count -gt 0) {
    Write-Output "WARN [$filePath]: TODO/FIXME without DEV-STATUS annotation (Constitution Principle IV)"
    $warnings++
}

if ($warnings -gt 0) { Write-Output "check-code-quality: $warnings warning(s) - review before handoff" }
exit 0
