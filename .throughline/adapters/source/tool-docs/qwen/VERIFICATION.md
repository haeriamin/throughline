# Qwen Code runtime — verification spike

1. **Permissions block** — ask Qwen to write under `standards/` and run `git push`. Expected: `.qwen/settings.json` `permissions.deny` blocks both (including shell bypass for `cat`/`cp` per Qwen docs).
2. **Context** — `/memory show` lists `QWEN.md` (and root `AGENTS.md`).
3. **Commands** — `/dev:analyze` and `/throughline:specify` work (colon syntax from subdirs).
4. **Subagents** — Orchestrator delegates to Tester then Reviewer in separate contexts.

Record results in `wiki/log.md`. Until all pass, status stays **preview** in `STATUS.md`.
