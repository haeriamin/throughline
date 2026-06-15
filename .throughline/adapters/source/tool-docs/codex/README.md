# Codex CLI runtime adapter

A **generated** thin adapter for OpenAI Codex, peer to `.claude/` (Claude Code), `.github/`
(Copilot), and `.cursor/`. Canonical content — runbooks, instructions, standards, specs, wiki — is
runtime-neutral and reused unchanged. This folder is rendered by `tools/convert` from
`.throughline/adapters/source/`; edit the source and regenerate, do not hand-edit these files.

## What's here
| Piece | Location | Notes |
|---|---|---|
| 8 personas | `.codex/agents/*.toml` | `developer_instructions` = shared persona body; `sandbox_mode` from source |
| 22 commands | `.codex/prompts/*.md` | `/dev.*` + `/dev.*`; install into `~/.codex/prompts/` |
| Global rules | `../AGENTS.md` | peer to `CLAUDE.md` / `.cursor/rules/throughline.mdc` |
| Hooks | `.codex/hooks.json` | per-OS wiring via `tools/setup-hooks` (called by `tools/install`) |
| Config | `.codex/config.toml` | project-doc + fallback pointers |
| Spike | `.codex/VERIFICATION.md` | confirm spawning + `apply_patch` hook payload before "supported" |

## Install & use
```bash
bash tools/install.sh --tool codex              # Git Bash / macOS / Linux
# Windows: powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool codex

codex --version
export OPENAI_API_KEY=...                       # or: codex login
cd <this repo>
codex                                           # AGENTS.md + .codex/ load from the repo
/hooks                                          # trust project hooks (once)
cp .codex/prompts/*.md ~/.codex/prompts/        # slash commands are global in Codex
```

Then drive it like the other Tier A tools: `/dev.feature <target> "<desc>"`, `/dev.analyze`,
`/throughline`, etc. (dot syntax).

## Mapping (framework concept → Codex)
| Framework | Claude Code | Copilot | Codex |
|---|---|---|---|
| Persona | `.claude/agents/<p>.md` | `.github/agents/<p>.agent.md` | `.codex/agents/<p>.toml` |
| Global rules | `CLAUDE.md` | `.github/copilot-instructions.md` | `AGENTS.md` |
| Command | `.claude/commands/**/<cmd>.md` | `.github/agents/<cmd>.agent.md` + prompt | `.codex/prompts/<ns>.<cmd>.md` |
| Hooks | `.claude/settings.local.json` | `.github/hooks/hooks.json` | `.codex/hooks.json` |
| Agent-to-agent | subagents | `handoffs:` | explicit spawn (no declarative graph) |

## Status
**Preview.** Adapter files are generated and in place. Two runtime behaviours still need confirming
on your machine — see `.codex/VERIFICATION.md` (autonomous isolated Reviewer spawning, and
`apply_patch` hook payload). Until then every command runs; you may invoke personas manually.
