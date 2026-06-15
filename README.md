<div align="center">

<img src="media/throughline-mark.svg" alt="Throughline" width="100" />

# Throughline

### *An unbroken line from spec to reviewed code.*

**You describe a change; Throughline turns it into a tested, independently reviewed feature on a branch only you can merge — using the AI coding tool you already have. Your code stays where it is; it works on any codebase, in any language.**

[![License: MIT](https://img.shields.io/badge/license-MIT-4F46E5)](LICENSE)&nbsp;
[![Status: experimental](https://img.shields.io/badge/status-experimental-d29922)](STATUS.md)&nbsp;
[![Docs](https://img.shields.io/badge/docs-user%20guide-4F46E5)](docs/README.md)&nbsp;
[![GitHub stars](https://img.shields.io/github/stars/haeriamin/throughline?style=social)](https://github.com/haeriamin/throughline/stargazers)

</div>

```bash
/dev:target register path/to/my-app
/dev:feature my-app "Add cursor pagination to the orders endpoint"
# spec -> plan -> tasks -> implement -> tests -> review -> branch sdd/<slice>.   You do the merge.
```

> **v0.1, experimental.** [STATUS.md](STATUS.md) is an account of what's actually enforced versus only instructed, and what hasn't been tested yet. Read it before you rely on this for real work.
>
> Ask for auth, payments, or personal-data work and Throughline marks it CRITICAL. From there you lead and the agents only assist. That limit is deliberate.

## What it is

Throughline is a spec-driven, multi-agent layer that drives your AI coding tool. You describe a change; a team of eight single-purpose agents specs it, plans it, writes it on a branch, tests it, and an **independent reviewer** checks it against your standards before anyone calls it done. Nothing merges without you. The process and the knowledge live in this repo; your product code never does.

→ New here? Start with the [user guide](docs/README.md) and [core concepts](docs/02-concepts.md).

## How it works

```mermaid
flowchart LR
  R([request]) --> SP[specify] --> PL[plan] --> IM[implement] --> TS[test] --> G{review}
  G -- fail · max 2 --> IM
  G -- unsure --> HX[ask the human]
  G -- pass --> BR[branch sdd/slice]
  BR --> HM([human merges])
```

Eight single-purpose agents (Orchestrator, Analyst, Architect, Implementer, Tester, Reviewer, Archivist, Auditor) hand off through files. The Reviewer reads your standards from source, not the implementer's summary — but it's the same kind of model on both sides, so your merge is the real final check. Every change cites the spec rule, standard, and example it follows (cite-or-don't-ship); each slice lands on its own `sdd/<slice>` branch in your target's repo; agents never merge or push, and `/standards/` is read-only at the hook level.

→ Deeper design: [ARCHITECTURE.md](ARCHITECTURE.md) · the rules every agent obeys: [the constitution](.throughline/memory/constitution.md).

## Requirements

**git** and **one AI coding tool** from the table below (that's the engine) — nothing else. Hooks need no extra runtime (PowerShell on Windows, bash elsewhere; **no Python**), and the VS Code dashboard is optional. Generated tool folders aren't in git: run `tools/install.*` after a fresh clone (see [First run](#first-run)).

## Getting started

### Pick your tool

Throughline is the same framework behind many thin adapters, all generated from one source of truth. Use whichever tool you already have; the commands are identical and only the slash punctuation changes. **These docs default to the Claude Code colon form** (`/dev:feature`); the dot-form tools use `/dev.feature`. Run `tools/install.sh --list` (or `install.ps1 -List`) to see every tool, then install the ones you want.

| Tool | Slash syntax | Tier | Status | Guide |
|------|--------------|------|--------|-------|
| Claude Code | `/dev:feature` | A | Supported | [docs/runtimes/claude-code.md](docs/runtimes/claude-code.md) |
| GitHub Copilot (VS Code) | `/dev.feature` | A | Supported | [docs/runtimes/copilot.md](docs/runtimes/copilot.md) |
| **GitHub Copilot CLI** | agents | A | Preview | [docs/runtimes/copilot-cli.md](docs/runtimes/copilot-cli.md) |
| Codex | `/dev.feature` | A | Preview | [docs/runtimes/codex.md](docs/runtimes/codex.md) |
| Cursor | `/dev.feature` | A | Preview | [docs/runtimes/cursor.md](docs/runtimes/cursor.md) |
| **Antigravity** | `/dev.feature` | A | Preview | [docs/runtimes/antigravity.md](docs/runtimes/antigravity.md) |
| **OpenCode** | `/dev.feature` | A | Preview | [docs/runtimes/opencode.md](docs/runtimes/opencode.md) |
| **Qwen Code** | `/dev:feature` | A | Preview | [docs/runtimes/qwen.md](docs/runtimes/qwen.md) |
| **Kimi Code** | `/dev.feature` | A | Preview | [docs/runtimes/kimi.md](docs/runtimes/kimi.md) |
| Aider, Windsurf | rules file | B | Rules-only | [docs/runtimes/](docs/runtimes/) |

Tier A tools enforce the guards (hooks); Tier B tools are advisory (rules-only). Start here for the overview and a comparison: [docs/runtimes/](docs/runtimes/).

### First run

**Required:** run the installer before opening the repo in your AI tool. A fresh clone has no
`.claude/`, `.github/agents/`, `.cursor/rules/`, or other generated wiring until you do.

```bash
git clone <repo-url> && cd throughline
# Windows — pick one:
powershell -ExecutionPolicy Bypass -File tools\install.ps1   # PowerShell
bash tools/install.sh                                        # Git Bash (same scripts as macOS/Linux)
# macOS / Linux:
bash tools/install.sh
# open in VS Code (Copilot), or run `claude` (Claude Code), `codex` (Codex), or reload Cursor
/throughline:constitution && /dev:ingest-standards && /dev:ingest-exemplars   # one-time: load the rules
/dev:target register path/to/my-app                                       # point at your code
/dev:feature my-app "Add cursor pagination to the orders endpoint"        # build it
```

### Ways to use it

`/dev:feature` runs the whole lifecycle from one request. `--micro` (implement → test → review) and `--express` (skip the optional approval pauses) trade thoroughness for speed. Each is spelled out per tool in the [runtime guides](docs/runtimes/) and the [building features](docs/04-building-features.md) guide.

**Skip it** for throwaway scripts or plain questions — a change goes through Throughline; a question goes to plain chat. ([what to use it for](docs/use-cases.md))

## Layout

**Two homes.** This repo is the portable **framework** — the engine (`.throughline/`), your `standards/` + `exemplars/`, the shared `wiki/`, the live cross-target `work-queue/`, and the Auditor's `audit/` roll-up. Each registered **target** carries its own SDD record under `<target>/.throughline/` (its `specs/`, `review-reports/`, `work-queue/` history, target-local rules, `wiki/`, and `CHANGELOG.md`) on the slice branch, so it travels with the code. Full map: [core concepts](docs/02-concepts.md).

## More

[User guide](docs/README.md) · [Runtime guides](docs/runtimes/) · [Commands](COMMANDS.md) · [Architecture](ARCHITECTURE.md) · [Status](STATUS.md) · [Contributing](CONTRIBUTING.md) · [Constitution](.throughline/memory/constitution.md)

MIT, see [LICENSE](LICENSE). The standards and examples that ship are starter seeds; swap in your own.
