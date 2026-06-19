# Throughline

*An unbroken line from spec to reviewed code: every change cites the rule it follows, the test that proves it, and the reason it exists.*

You describe a change. Throughline turns it into a tested, independently reviewed feature on a branch that only you can merge — using the AI coding tool you already have. Your code stays where it is; the framework holds the process, your standards, and the shared memory. It works on any codebase, in any language.

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

## What it's good for (and what it's not)

Reach for it on a change you'd want a careful teammate to review:

- **Ship a feature** — `/dev:feature orders-api "add cursor pagination to GET /orders"` specs it, writes it on a branch, adds tests, and has an independent reviewer sign off before *you* merge.
- **Fix a bug, with proof** — add `--micro` for a test that fails before the fix and passes after, plus a one-line record of why it changed (the exact shape of a real [pytest bug](docs/validation-runs/2026-06-16-swebench-pytest-11143.md) it fixed end to end).
- **Get your bearings** — `/dev:analyze orders-api src/billing` maps the modules and the conventions they actually follow.
- **Second opinion** — `/dev:review <slice>` re-reads your standards from source and returns PASS / CONDITIONAL_PASS / FAIL with cited reasons.

**Skip it** for throwaway scripts, one-line tweaks, or plain questions — those go to your tool's normal chat. The rule of thumb: **a change goes through Throughline; a question goes to plain chat.** Full examples: [what to use Throughline for](docs/use-cases.md).

## Why it exists

Frontier models nail the happy path and miss the boring parts: forgotten validation, edge cases, error handling. Asking for "more" or "thorough" tests doesn't fix these *specification-completeness* bugs — it just adds happy-path tests.

What works is **grounding**: tie each test to an enumerated spec rule, then have an independent reviewer check the result against the source standards. In a controlled study this produced correct code far more often than a strong "test the edges" baseline, held across three model families, and cut false rejections — the gain showing up exactly on the spec-completeness bugs that dominate real one-shot failures (on clean algorithmic problems it neither helps nor hurts).

→ The numbers, the side-by-side runs, and a solved **SWE-bench Lite** issue: [validation-runs/](docs/validation-runs/).

## How it works

```mermaid
flowchart LR
  R([request]) --> SP[specify] --> PL[plan] --> IM[implement] --> TS[test] --> G{review}
  G -- fail · max 2 --> IM
  G -- unsure --> HX[ask the human]
  G -- pass --> BR[branch sdd/slice]
  BR --> HM([human merges])
```

Eight agents, each with one job, handing off through files rather than reaching into each other's work: Orchestrator, Analyst, Architect, Implementer, Tester, Reviewer, Archivist, Auditor.

The review step is the heart of it. The Reviewer reads your standards from source (not the implementer's summary of them) and returns PASS, CONDITIONAL_PASS, or FAIL on a confidence score. It's the same kind of model on both sides, so treat it as a strong check rather than a second human. Your merge is the real final check.

A few things hold this together. Every change cites the spec requirement it satisfies, the standard clause it follows, and an example when one exists — cite-or-don't-ship. Each change is a *slice* whose edits land on a dedicated `sdd/<slice>` branch **in your target's own repo**, not the framework; nothing touches your main branch until you merge, and to undo you just delete the branch (a target with no git repo is handled too — originals are backed up under `work-queue/backups/<slice>/`). Agents never merge or push, `/standards/` is read-only at the hook level, and a shared wiki compounds knowledge across tasks.

→ Deeper design: [ARCHITECTURE.md](ARCHITECTURE.md) · the rules every agent obeys: [the constitution](.throughline/memory/constitution.md).

## Requirements

Close to nothing — Throughline is mostly markdown the model reads, and the engine is the AI tool you already have.

- **git** — for the reversible per-change branches and to read your target's state.
- **One AI coding tool** — any tool in the [table below](#pick-your-tool). That's the engine.
- Everything else ships inside `.throughline/` (commands, runbooks, bash + PowerShell helper scripts). Write-safety hooks need **no extra runtime** (PowerShell on Windows, bash on macOS/Linux; **Python is not required**), and the VS Code dashboard is optional.

Generated tool folders (`.claude/`, `.cursor/`, `.github/agents/`, etc.) are **not** in git — run `tools/install.*` after every fresh clone to generate them from `.throughline/adapters/source/` and wire hooks.

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

`/dev:feature` runs the whole lifecycle from one request. `--micro` (implement → test → review) and `--express` (skip the optional approval pauses) trade thoroughness for speed. You can also run each phase yourself (`/throughline:specify` … `/throughline:implement`), or single commands out of band (`/dev:ideate`, `/dev:analyze`, `/dev:test`, `/dev:review`, `/dev:audit`).

Each is spelled out in your tool's exact syntax in the [runtime guides](docs/runtimes/) and the [building features](docs/04-building-features.md) guide. Every slice also leaves a human-readable entry in the target's own `.throughline/CHANGELOG.md`.

## For teams

A better model makes each agent better; it doesn't fix consistency, audit trails, or trust across a team — that's the part Throughline is for. Your rules plus an independent review step make output consistent; every change links spec → task → rule → result and is recorded; hooks block risky writes and only people merge; and a shared wiki keeps the rules, examples, and decisions.

Does it save tokens? Per task, no — it runs more steps. Over time it pays off like insurance: a little extra on every task, returned on the ones where it catches a bug that would have been expensive to find later. Worth it for code that matters; for throwaway changes, `--micro` or plain chat is the better call.

## Layout

| Folder | What's inside |
|--------|---------------|
| `.throughline/` | The engine: constitution, command runbooks, templates, workflows, and the adapter source of truth (`.throughline/adapters/`) |
| `.github/` · `.claude/` · `.codex/` · `.cursor/` | The per-tool adapters (generated from `.throughline/adapters/source/`), plus hooks (CI lives in `.github/`) |
| `standards/` · `exemplars/` | Your rules and example code, the read-only inputs you write |
| `wiki/` | What the agents remember, plus an append-only log of everything they do |
| `specs/` · `work-queue/` · `review-reports/` | Per-task files and status |
| `targets/` | The list of outside projects the agents work on |
| `tools/dashboard/` | A VS Code extension with a live view of the work queue |
| `docs/` | The user guide, including the per-tool runtime guides |

## More

[User guide](docs/README.md) · [Runtime guides](docs/runtimes/) · [Commands](COMMANDS.md) · [Architecture](ARCHITECTURE.md) · [Status](STATUS.md) · [Contributing](CONTRIBUTING.md) · [Constitution](.throughline/memory/constitution.md)

MIT, see [LICENSE](LICENSE). The standards and examples that ship are starter seeds; swap in your own.
