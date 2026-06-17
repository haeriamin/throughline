# validate-bash-safety.ps1 (Claude Code PreToolUse hook, matcher: Bash)
# Closes the shell bypass of the write-boundary and merge rules:
#  - blocks shell writes (redirect/copy/move/delete/in-place edit) touching /standards/ or /exemplars/
#  - blocks `git push` and `git merge` (merging/pushing is human — Constitution Principle VI)
# Conservative by design: a read-only command that merely mentions an immutable path together
# with a write token is blocked too — re-form the command without the write token.
# Protocol: stdin JSON {tool_name, tool_input:{command}}; exit 1 + stdout = block.
$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$cmd = $data.tool_input.command
if ($null -eq $cmd -or "$cmd" -eq "") { exit 0 }
$c = "$cmd".Replace('\', '/')

if ($c -match '(^|[;&|"]|\\n)\s*git(\s+(-c\s+\S+|-C\s+\S+|--[a-zA-Z-]+(=\S+)?|-[a-zA-Z]+))*\s+(push|merge)([^a-zA-Z0-9_]|$)') {
    Write-Output "BLOCKED: 'git push' / 'git merge' are human-only actions (Constitution Principle VI)."
    Write-Output "Present the sdd/<slice> branch in your report; the human merges."
    exit 1
}

if ($c -match '(^|/|\s|["'']|=)(standards|exemplars)/') {
    $writeTokens = '(>|>>|\btee\b|\bcp\b|\bmv\b|\brm\b|\brmdir\b|\btouch\b|\bln\b|\bsed\s+-i\b|\bdd\b|\binstall\b|Set-Content|Add-Content|Out-File|Copy-Item|Move-Item|Remove-Item|New-Item)'
    if ($c -match $writeTokens) {
        Write-Output "BLOCKED: shell command combines an immutable path (/standards/ or /exemplars/) with a write operation (Constitution Principle I)."
        Write-Output "These directories are human-curated and READ ONLY to agents. Read without redirection, or stop and escalate."
        exit 1
    }
}
exit 0
