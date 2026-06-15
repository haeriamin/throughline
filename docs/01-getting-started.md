# 1 · Getting Started

## Prerequisites

- **An AI coding tool** — any Tier A host (Claude Code, GitHub Copilot for VS Code or CLI, Codex,
  Cursor, Antigravity, OpenCode, Qwen, Kimi) for enforced hooks, or a rules-only Tier B tool (Aider,
  Windsurf, advisory). Pick any; per-host setup: [docs/runtimes/](runtimes/).
- **git** — for the framework repo and for reversible changes on targets.
- **Node.js 20+** — only if you want to build the [dashboard extension](07-dashboard.md).

## Install

```bash
git clone <repo-url> throughline
cd throughline

# Pick your tool(s) — generates adapters and wires hooks for your OS:
bash tools/install.sh --list                    # Git Bash / macOS / Linux
bash tools/install.sh --tool claude             # one tool
bash tools/install.sh --all                     # every tool

# Windows without Git Bash:
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -List
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool claude
```

The installer runs `tools/convert` (renders thin adapters from `.throughline/adapters/source/`) and
`tools/setup-hooks` (per-OS hook wiring). Copilot needs no extra hook step — its hooks file already
carries a per-OS override. Re-run `tools/setup-hooks.{ps1,sh}` alone if you switch OS later.

No build step, no services, no Python required — the repo's markdown files *are* the framework.
The read-only guard on `/standards/` and `/exemplars/` is on even before you run the installer
(Claude Code: declarative deny in `.claude/settings.json`; other tools: hook or rules file).

## Slash syntax

Tools spell commands differently — same commands, same behavior:

| Tool | Syntax |
|------|--------|
| Claude Code, Qwen Code | `/dev:analyze`, `/throughline:specify` |
| Copilot (VS Code), Codex, Cursor, Antigravity, OpenCode, Kimi | `/dev.analyze`, `/throughline` |
| Copilot CLI | no slash commands — drive the lifecycle by asking for the agent (e.g. “use the dev.feature agent”) |
| Aider, Windsurf | no slash commands — adopt personas from the rules bundle |

Docs default to the Claude Code colon form. The mapping is mechanical. Full per-host walkthroughs:
[docs/runtimes/](runtimes/).

## First run (one time)

```bash
/throughline:constitution        # 1. review the framework's law; fill the Ratified date
/dev:ingest-standards        # 2. compile /standards/ into the wiki
/dev:ingest-exemplars        # 3. compile /exemplars/ into the pattern library
```

The shipped `/standards/` and `/exemplars/` are **replaceable seeds** — swap in your
team's own and re-run the ingests (see [Knowledge Base](05-knowledge-base.md)).

## Your first feature

```bash
/dev:target register path/to/my-app          # register the codebase you want to work on
/dev:feature my-app "Add cursor pagination to the orders endpoint"
```

That's the whole loop. Details: [Managing Targets](03-targets.md) and
[Building Features](04-building-features.md).

## Adopting incrementally

Start small:

1. **Knowledge only** — swap in your seeds, ingest, use the skills ad hoc in chat.
2. **Out-of-band** — `/dev:analyze`, `/dev:test`, `/dev:review` on a target, no specs.
3. **Full lifecycle** — `/dev:feature` when a change warrants traceability. Heavy machinery
   (design ADRs, human-led mode) engages only at HIGH/CRITICAL.

Solo dev? Relax the thresholds — a one-file [amendment](08-customization.md).

## Using as a template

Click **Use this template** on GitHub (or fork), then do the First Run above. Nothing
needs renaming — commands, hooks, and the dashboard are project-agnostic.

---
Next: [Core Concepts →](02-concepts.md)
