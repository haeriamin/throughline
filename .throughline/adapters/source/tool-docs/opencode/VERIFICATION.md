# OpenCode runtime — verification spike

1. **Permissions block** — ask OpenCode to write under `standards/` and run `git push`. Expected: `opencode.json` `permission` denies both.
2. **Commands** — `/dev.analyze` and `/throughline` appear and load runbook content from generated command files.
3. **Subagents** — Orchestrator delegates to Tester then Reviewer via `@reviewer` or command `agent:` field without inline review.

Record results in `wiki/log.md`. Until all pass, status stays **preview** in `STATUS.md`.
