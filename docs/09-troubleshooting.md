# 9 · Troubleshooting

## "My write was blocked"

Working as designed. `/standards/` and `/exemplars/` are read-only to agents
(Constitution Principle I, enforced by PreToolUse hooks in every runtime). Add files
there yourself, then run the matching ingest command.

## A slash command doesn't appear

- **Claude Code**: commands are `/dev:name` (colon). Restart the session after adding
  command files. Frontmatter must start at byte 0 — a UTF-8 BOM breaks it.
- **Copilot / Cursor**: commands are `/dev.name` (dot). Copilot: open the framework folder or a
  target workspace. Cursor: reload the window after `tools/install --tool cursor`.
- **Codex**: commands live in `~/.codex/prompts/` (global). Re-copy after `tools/convert --tool codex`.
- **Generated adapters**: if you edited `.throughline/adapters/source/`, run `tools/convert` — do not
  hand-edit `.claude/commands/`, `.cursor/commands/`, etc.

## Agent can't edit my target

- **Copilot / Cursor**: open `targets/<id>.code-workspace` — the target must be a workspace folder.
- **Claude Code**: the target path must be in `permissions.additionalDirectories` in
  `.claude/settings.local.json` — `/dev:target register` adds it; re-run
  `/dev:target inspect <id>` to verify.
- **Codex**: add the target path to Codex writable roots (see `/dev:target register` output).

## Hooks not firing / wrong OS

Run the installer or hook wiring for your OS:

```bash
bash tools/install.sh --tool <your-tool>      # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool <your-tool>
# Or hooks only after an OS switch:
bash tools/setup-hooks.sh
powershell -ExecutionPolicy Bypass -File tools\setup-hooks.ps1
```

See `.claude/hooks/README.md`. No Python required. On Windows, use **Git Bash** for the `.sh`
scripts if you prefer bash over PowerShell.

## "Analysis is stale" / fingerprint mismatch

The target changed since `/dev:analyze` ran. Re-run it — plans and reviews refuse to
build on stale maps by design.

## Reviewer keeps FAILing a slice

Read the sub-scores in the review report:

- `test_evidence` low → the test report is missing, stale, or behaviors are uncovered — run `/dev:test`
- `standards_compliance` low → itemized findings list the exact clauses and `file:line`
- `spec_alignment` low → requirements unimplemented or out-of-scope drift

After 2 retries it escalates — answer the escalation's questions via
`/dev:review-escalated` instead of re-running blindly.

## Dashboard says "No framework root found"

Open a workspace containing `.throughline/memory/constitution.md`, or set
`sddDashboard.frameworkRoot` to the framework's absolute path.

## CI failures

| Job step | Meaning |
|----------|---------|
| Adapters in sync | Regenerated adapters differ from committed — run `tools/convert` and commit |
| Skill parity | `.github/skills/` and `.claude/skills/` differ — copy the edited file to the other tree |
| Hook smoke tests | A hook script regressed its block/allow exit codes |
| Core scripts | `create-new-feature.sh` / `check-prerequisites.sh` behavior changed |
| JSON artifacts | A config file no longer parses |

## Wiki feels wrong

`/dev:lint-wiki` pinpoints it: broken links, stale summaries (re-ingest), citation
integrity, scope integrity, log-format violations. Remediation always goes through the
ingest commands or human edits — never hand-patch derived files.

---
[← Customization](08-customization.md) · [Guide index](README.md)
