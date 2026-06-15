# Throughline on Cursor (preview adapter)

This folder is a **generated** thin adapter. It wires Cursor into the shared Throughline brain
(constitution, runbooks, throughline lifecycle agents, instructions, skills). Do not hand-edit these files — they
are rendered by `tools/convert` from `.throughline/adapters/source/`. Edit the source and regenerate.

## What loads from here

| Cursor feature | Files | Maps to |
|----------------|-------|---------|
| Subagents | `.cursor/agents/*.md` | the eight personas (`.throughline/adapters/source/personas/`) |
| Slash commands | `.cursor/commands/*.md` | `/dev.*` and `/dev.*`, each pointing at its runbook |
| Project rules | `.cursor/rules/throughline.mdc` | the non-negotiables (`alwaysApply: true`) |
| Hooks | `.cursor/hooks.json` | the guard + log hooks (installed per-OS, see below) |

Slash syntax is the dot form: `/dev.analyze`, `/throughline`.

## Hooks: installed per-OS, fail-open until verified

`tools/convert` does **not** write a live `.cursor/hooks.json`. It writes a staged template at
`.throughline/adapters/generated/cursor/hooks.template.json`. `tools/setup-hooks` installs the real
`.cursor/hooks.json` for your OS (PowerShell on Windows, bash on macOS/Linux) — the live file is
gitignored, like Claude's `settings.local.json`.

The hooks ship with **`failClosed: false`**. If a guard script can't run (wrong launcher, or Cursor's
hook input differs from what the shared scripts expect), the action is *allowed* rather than blocking
your whole session. That is a deliberate safety default for a preview adapter: a fail-closed hook
pointing at a script that errors will lock you out. Only after the spike in
[`VERIFICATION.md`](VERIFICATION.md) confirms the guards actually block do you flip the write/shell
hooks to `failClosed: true` for hard enforcement.

So today, on Cursor, the read-only guard on `/standards/` + `/exemplars/` and the no-push/no-merge
rule are **enforced if the scripts speak Cursor's hook protocol, and instructed (via the rules file)
regardless**. Treat Cursor as Tier A *pending verification*.

## Setup

```bash
# generate the adapter + wire hooks for your OS
bash tools/install.sh --tool cursor                                   # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool cursor   # Windows PowerShell
```
Then reload the Cursor window so it re-reads `.cursor/`.

Full walkthrough: [docs/runtimes/cursor.md](../docs/runtimes/cursor.md). Status is tracked in
[`STATUS.md`](../STATUS.md) like the other runtimes.
