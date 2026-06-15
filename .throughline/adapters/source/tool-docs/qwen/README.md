# Throughline on Qwen Code (preview adapter)

Generated thin adapter for [Qwen Code](https://github.com/QwenLM/qwen-code). Edit `.throughline/adapters/source/`, then run `tools/convert`.

Root `AGENTS.md` is the **Codex** peer. Qwen loads **`QWEN.md`** plus `.qwen/` for Throughline-specific wiring.

| Feature | Path |
|---------|------|
| Context | `QWEN.md`, `.qwen/settings.json` `context.fileName` |
| Subagents | `.qwen/agents/*.md` |
| Slash commands | `.qwen/commands/<ns>/<cmd>.md` → `/ns:cmd` (colon from path) |
| Guards | `.qwen/settings.json` `permissions.deny` |

Setup: `bash tools/install.sh --tool qwen` — see [docs/runtimes/qwen.md](../docs/runtimes/qwen.md) and [.qwen/VERIFICATION.md](VERIFICATION.md).
