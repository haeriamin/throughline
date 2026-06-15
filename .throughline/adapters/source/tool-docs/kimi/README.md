# Throughline on Kimi Code (preview adapter)

Generated thin adapter for [Kimi Code CLI](https://github.com/MoonshotAI/kimi-cli). Edit `.throughline/adapters/source/`, then run `tools/convert`.

Kimi merges root `AGENTS.md` with **`.kimi/AGENTS.md`** (this overlay). Do not edit root `AGENTS.md` for Kimi.

| Feature | Path |
|---------|------|
| Instructions overlay | `.kimi/AGENTS.md` |
| Personas | `.kimi/personas/*.md` |
| Lifecycle workflows | `.kimi/workflows/*.md` |
| Hooks | `.kimi/config.toml` (machine-local, from staged template) |

Setup: `bash tools/install.sh --tool kimi` — see [docs/runtimes/kimi.md](../docs/runtimes/kimi.md) and [.kimi/VERIFICATION.md](VERIFICATION.md).
