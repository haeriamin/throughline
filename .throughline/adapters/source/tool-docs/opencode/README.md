# Throughline on OpenCode (preview adapter)

Generated thin adapter for [OpenCode](https://opencode.ai/). Edit `.throughline/adapters/source/`, then run `tools/convert`.

Root `AGENTS.md` is the **Codex** peer. OpenCode loads `.opencode/throughline.md` via `opencode.json` `instructions` instead.

| Feature | Path |
|---------|------|
| Instructions | `opencode.json` → `.opencode/throughline.md` |
| Subagents | `.opencode/agents/*.md` |
| Slash commands | `.opencode/commands/*.md` |
| Guards | `opencode.json` `permission` (declarative) |

Setup: `bash tools/install.sh --tool opencode` — see [docs/runtimes/opencode.md](../docs/runtimes/opencode.md) and [.opencode/VERIFICATION.md](VERIFICATION.md).
