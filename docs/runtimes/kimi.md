# Throughline with Kimi Code (preview)

Kimi merges root `AGENTS.md` with **`.kimi/AGENTS.md`**. Personas are `.kimi/personas/*.md`; lifecycle phases are `.kimi/workflows/*.md` (invoke by name — no native slash-command dir).

> **Preview.** Hooks ship via `.kimi/config.toml` (best-effort matchers) — see [.kimi/VERIFICATION.md](../../.kimi/VERIFICATION.md).

## Setup

```bash
bash tools/install.sh --tool kimi
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool kimi
```

Loads: `.kimi/AGENTS.md`, `.kimi/personas/`, `.kimi/workflows/`, `.kimi/config.toml` (hooks, machine-local).

## First run

Ask Kimi to follow Throughline phases (or open `.kimi/workflows/dev.feature.md`):

```
/throughline.constitution
/dev.ingest-standards
/dev.ingest-exemplars
/dev.target register path/to/my-app
/dev.feature my-app "Your first slice"
```

More: [.kimi/README.md](../../.kimi/README.md).
