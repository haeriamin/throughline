# Throughline with OpenCode (preview)

OpenCode uses dot syntax in docs: `/dev.analyze`, `/throughline`. Native slash commands come from `.opencode/commands/*.md` (filename = command name).

> **Preview.** Guards are declarative in `opencode.json` `permission` until verified — see [.opencode/VERIFICATION.md](../../.opencode/VERIFICATION.md).

## Setup

```bash
bash tools/install.sh --tool opencode
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool opencode
```

OpenCode loads:

- `opencode.json` — instructions pointer + permission denies
- `.opencode/throughline.md` — non-negotiables
- `.opencode/agents/*.md` — subagents (@mention or command `agent:`)
- `.opencode/commands/*.md` — slash commands

Root `AGENTS.md` is the Codex adapter — do not edit it for OpenCode.

## First run

```
/throughline.constitution
/dev.ingest-standards
/dev.ingest-exemplars
/dev.target register path/to/my-app
/dev.feature my-app "Your first slice"
```

Phase commands: `/dev.analyze`, `/dev.review`, `/throughline`, etc. (see `.opencode/commands/`).

More: [.opencode/README.md](../../.opencode/README.md).
