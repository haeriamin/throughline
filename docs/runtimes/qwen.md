# Throughline with Qwen Code (preview)

Qwen Code loads root `AGENTS.md` and **`QWEN.md`** as project context. Personas are `.qwen/agents/*.md` (subagents); commands are `.qwen/commands/<ns>/<cmd>.md`. Slash names use the colon form taken from their paths (e.g. `/dev:analyze`, `/throughline:plan`); the runbooks they point to use the dot form in prose.

> **Preview.** Guards are declarative `permissions.deny` entries in `.qwen/settings.json` (read-only `/standards/` + `/exemplars/`, no `git push` / `git merge`) — not hooks — until verified. See [.qwen/VERIFICATION.md](../../.qwen/VERIFICATION.md).

## Setup

```bash
bash tools/install.sh --tool qwen
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool qwen
```

Loads: `QWEN.md`, `.qwen/agents/`, `.qwen/commands/`, `.qwen/settings.json` (permission denies, machine-local).

## First run

Run `qwen` in this repo, then drive the Throughline phases (delegate so the Reviewer stays independent):

```
/throughline:constitution
/dev:ingest-standards
/dev:ingest-exemplars
/dev:target register path/to/my-app
/dev:feature my-app "Your first slice"
```

More: [.qwen/README.md](../../.qwen/README.md).
