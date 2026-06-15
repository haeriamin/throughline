# Claude Code Hooks

Four hooks enforce the constitution at the tool-call boundary:

| Hook | Event | Behavior |
|------|-------|----------|
| `validate-immutable-paths` | PreToolUse (Write/Edit/MultiEdit/NotebookEdit) | **Blocks** writes to `/standards/` and `/exemplars/` (exit 2 + stderr per Claude Code protocol) |
| `validate-bash-safety` | PreToolUse (Bash) | **Blocks** shell writes touching `/standards/` or `/exemplars/`, and `git push` / `git merge` (human-only, Principle VI). Conservative: an immutable path + any write token in one command is blocked even if the write targets elsewhere — re-form the command |
| `log-tool-use` | PostToolUse | Appends file writes to `wiki/log.md` (Principle VII); never blocks. Shell-mediated file changes are NOT auto-logged — runbooks require the acting agent to append its own entry |
| `check-code-quality` | PostToolUse | Warns on conflict markers, debug statements, unannotated TODOs; never blocks |

**Honest scope note**: hooks raise the cost of violation; they are not a sandbox. A
sufficiently creative command could still evade string matching — the Reviewer's
source-grounded verification and the human-only merge are the backstops.

## Platform setup (Windows / macOS / Linux)

No single hook command works on every OS — Windows runs `powershell`, macOS/Linux run `bash`,
and `bash` isn't on the Windows PATH outside Git Bash. The installer (`tools/install.{ps1,sh}`)
calls `tools/setup-hooks`, which writes the per-OS wiring into the gitignored
`.claude/settings.local.json`:

```bash
# Recommended — generates adapters + wires hooks:
bash tools/install.sh --tool claude             # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool claude   # Windows PowerShell

# Hooks only (e.g. after switching OS):
powershell -ExecutionPolicy Bypass -File tools\setup-hooks.ps1   # Windows
bash tools/setup-hooks.sh                                        # Git Bash / macOS / Linux
```

It picks `powershell -File …​.ps1` on Windows and `bash …​.sh` on macOS/Linux, and also rebuilds
`.codex/hooks.json` and `.cursor/hooks.json` when those adapters are present. **No Python is
required** — neither the setup nor the hooks need it. There's also a `tools/setup-hooks.py` if
you prefer Python. Re-run setup after switching OS.

The committed `.claude/settings.json` carries **no** OS-specific commands — only the cross-platform
`permissions.deny` guard on `/standards/` and `/exemplars/`, which is always on even before setup.

Defense in depth: that declarative deny backs up the file-write hook, and `/dev:*` runbooks
instruct agents to respect the boundary in their own logic. Hooks raise the cost of violation;
the Reviewer's source-grounded check and the human-only merge are the real backstops.
