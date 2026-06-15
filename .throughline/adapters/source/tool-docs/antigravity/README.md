# Throughline on Antigravity (preview adapter)

This folder is a **generated** thin adapter for [Google Antigravity](https://antigravity.google/).
It wires Antigravity into the shared Throughline brain (constitution, runbooks, throughline lifecycle agents,
instructions, skills). Do not hand-edit the generated persona files — they are rendered by
`tools/convert` from `.throughline/adapters/source/`. Edit the source and regenerate.

## What Antigravity reads

| Antigravity feature | Files | Maps to |
|---------------------|-------|---------|
| Project instructions (highest priority) | `GEMINI.md` (repo root) | non-negotiables + wiring index |
| Rules panel | `.agent/rules/throughline.md`, `.agent/rules/commands/*.md` | global rules + lifecycle command runbook pointers |
| Personas | `.agents/personas/*.md` | the eight personas (`.throughline/adapters/source/personas/`) |
| Hooks | `.agents/hooks.json` | guard + log hooks (installed per-OS, see below) |

Root `AGENTS.md` is the **Codex** adapter peer — Antigravity may read it, but **`GEMINI.md` takes
precedence**. Do not edit `AGENTS.md` for Antigravity work.

Slash syntax in docs uses the dot form: `/dev.analyze`, `/throughline`. Antigravity has no
native slash-command directory; invoke phases by name or by following the command rules under
`.agent/rules/commands/`.

## Hooks: installed per-OS, best-effort matchers until verified

`tools/convert` writes a staged template at
`.throughline/adapters/generated/antigravity/hooks.template.json`. `tools/setup-hooks` installs the live
`.agents/hooks.json` for your OS (PowerShell on Windows, bash on macOS/Linux). The live file is
gitignored.

Hook **matchers** (`write_file|edit_file|create_file`, `run_command`) follow Google's codelabs and
are best-effort until the spike in [`VERIFICATION.md`](VERIFICATION.md) confirms Antigravity's exact
tool names and stdin shape. Until then, treat guards as **instructed in `GEMINI.md` first, enforced
if hooks fire**.

## Setup

```bash
# generate the adapter + wire hooks for your OS
bash tools/install.sh --tool antigravity                                   # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool antigravity   # Windows PowerShell
```

Open this repo in Antigravity so it loads `GEMINI.md`, `.agent/rules/`, `.agents/personas/`, and
`.agents/hooks.json`.

Full walkthrough: [docs/runtimes/antigravity.md](../docs/runtimes/antigravity.md). Status is tracked
in [`STATUS.md`](../STATUS.md) like the other runtimes.
