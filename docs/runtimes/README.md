# Runtimes: bring your own tool

Throughline is one framework ("one brain") behind many thin adapters. The process, rules, agents, and knowledge are shared and don't depend on which tool you run; each tool just wires them in its own way. Pick whichever one you already use. The commands are the same across every tool, and the main difference is the slash punctuation.

Every adapter is generated from a single source of truth (`.throughline/adapters/source/`) by `tools/convert`. You don't hand-edit adapter files — you pick your tools with the installer:

```bash
# macOS / Linux                          # Windows (Git Bash — from repo root)
bash tools/install.sh                     "C:\Program Files\Git\bin\bash.exe" tools/install.sh
bash tools/install.sh --list              ... --list
bash tools/install.sh --tool cursor       ... --tool cursor
```

The installer generates the chosen tool's adapter and wires its hooks for your OS.

## Enforcement tiers

Tools differ in how much of the constitution they can *enforce* (not just be told). That's the tier:

| Tier | What it means | Tools |
|------|---------------|-------|
| **A — enforced** | Blocking hooks back the guarantees: writes to `/standards/` + `/exemplars/` are blocked, `git push`/merge is blocked, and `wiki/log.md` is appended automatically. | Claude Code, GitHub Copilot (VS Code + CLI), Codex, Cursor, Antigravity, OpenCode, Qwen Code, Kimi Code |
| **B — rules-only** | No hooks and no subagents. The same rules are *instructed* in a rules file but not enforced — you honor them yourself. Good for editing; use a Tier A tool when the guarantees matter. | Aider, Windsurf |

| Tool | Slash syntax | Tier | Status | Reach for it if… |
|------|--------------|------|--------|------------------|
| **GitHub Copilot** (VS Code) | `/dev.analyze` (dot) | A | Supported | You live in VS Code |
| **GitHub Copilot CLI** | agents (no slash cmds) | A | Preview | You want Copilot in the terminal |
| **Claude Code** | `/dev:analyze` (colon) | A | Supported | You want a terminal-native agent |
| **Codex** | `/dev.analyze` (dot) | A | Preview | You're on OpenAI Codex |
| **Cursor** | `/dev.analyze` (dot) | A | Preview | You work in Cursor |
| **Antigravity** | `/dev.analyze` (dot) | A | Preview | Google Antigravity agent IDE |
| **OpenCode** | `/dev.analyze` (dot) | A | Preview | OpenCode terminal agent |
| **Qwen Code** | `/dev:analyze` (colon form) | A | Preview | Qwen Code CLI |
| **Kimi Code** | `/dev.analyze` (dot, workflows) | A | Preview | Kimi Code CLI |
| **Aider** | n/a (rules file) | B | Rules-only | You drive Aider and accept advisory guards |
| **Windsurf** | n/a (rules file) | B | Rules-only | You work in Windsurf and accept advisory guards |

Step-by-step guide for each:

- [Copilot](copilot.md)
- [GitHub Copilot CLI](copilot-cli.md) (preview; reuses `.github/`, guard enforcement advisory until verified)
- [Claude Code](claude-code.md)
- [Codex](codex.md) (preview, with one runtime behaviour still to verify; see the page)
- [Cursor](cursor.md) (preview; hooks ship fail-open until the verification spike passes)
- [Antigravity](antigravity.md) (preview; hook matchers are best-effort until verified)
- [OpenCode](opencode.md) (preview; declarative permissions until verified)
- [Qwen Code](qwen.md) (preview; settings permissions until verified)
- [Kimi Code](kimi.md) (preview; hook matchers are best-effort until verified)

## The five ways to use it

Every tool supports the same five workflows. They only differ in setup and syntax, and each tool's guide shows them in that tool's exact commands. Here's the shape of them:

1. **One command for the whole lifecycle.** `dev.feature <target> "<desc>"` runs specify, clarify, plan, design (if needed), tasks, scaffold (for greenfield), implement, test, and review, stopping only at the real gates.
2. **Cheaper modes.** `--express` skips the optional approval pauses; `--micro` drops to implement, test, review for a genuinely small change.
3. **Phase by phase.** Drive the lifecycle yourself with `dev.throughline`, `clarify`, `plan`, `tasks`, `implement`, adding `dev.design` or `dev.scaffold` when they apply.
4. **Single commands.** Run `dev.analyze`, `dev.test`, `dev.review`, or `dev.audit` against a target without a full spec.
5. **Knowledge only.** Ingest your standards and examples with `dev.ingest-standards` / `dev.ingest-exemplars`, then call the skills ad hoc.

## Shared concepts

Read these once and they apply on any tool:

- **Targets.** Your code lives at external paths you register; the framework holds only process and knowledge. See [Managing Targets](../03-targets.md).
- **The lifecycle and the one command.** See [Building Features](../04-building-features.md).
- **Gates and the human merge.** Every change is tested, independently reviewed, and merged only by you. See [Quality Gates](../06-quality-gates.md).
- **Every command on one page.** See [COMMANDS.md](../../COMMANDS.md).

Whichever tool you pick, the agents never merge or push. That stays your call. On a Tier B tool that rule is advisory — the tool can't block it — so it's on you.

## Adding another tool

Adapters are generated, so adding a tool is mostly data, not code. See [`.throughline/adapters/README.md`](../../.throughline/adapters/README.md): add one `*.profile`, run `tools/convert`, and the personas, commands, hooks, and rules render in that tool's format from the shared source.
