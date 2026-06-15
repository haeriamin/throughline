# Kimi Code runtime — verification spike

1. **Hooks block** — with `.kimi/config.toml` installed, try writes to `standards/` and `git push`. Expected: `PreToolUse` hooks block (exit code 2).
2. **Context** — `.kimi/AGENTS.md` appears in `${KIMI_AGENTS_MD}` / project instructions.
3. **Delegation** — Orchestrator uses the Agent tool to run Tester then Reviewer without inline review.

Hook matchers (`WriteFile|StrReplaceFile`, `Shell|Bash`) are best-effort until confirmed. Record results in `wiki/log.md`.
