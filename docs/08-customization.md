# 8 · Customization

The framework is data-driven: most customization is editing markdown, not code.

## Tune the knowledge (most common)

Replace or extend `/standards/` and `/exemplars/`, then re-run the ingests. That's it —
the process layer is stack-agnostic; the knowledge layer is yours.

## Amend the constitution

Thresholds, formula weights, principles, and write boundaries live in
`.throughline/memory/constitution.md` and **only** there — config files quoting them are
mirrors. To change one:

```bash
/throughline:constitution "Lower the PASS threshold to 0.80"
```

The agent drafts the diff, waits for your explicit approval, bumps the version
(MAJOR/MINOR/PATCH), updates the mirrors, and logs the amendment. Solo developers
relaxing the gates: this is the supported path.

## Add a command

1. Runbook (the procedure): `.throughline/extensions/dev/commands/dev.<name>.md`
2. Declare it: `.throughline/extensions/dev/extension.yml`
3. Copilot: `.github/agents/dev.<name>.agent.md` (thin) + `.github/prompts/dev.<name>.prompt.md` (3 lines)
4. Claude: `.claude/commands/dev/<name>.md` (thin)
5. Add a row to `COMMANDS.md`

Golden rule: **procedure lives in the runbook; adapters point at it.** Don't add a
per-command Claude subagent — commands adopt one of the 8 personas
(see ARCHITECTURE §14 for why).

## Add or edit a skill

Edit `.github/skills/<name>/SKILL.md`, copy it byte-identical to
`.claude/skills/<name>/SKILL.md`. CI and `/dev:lint-wiki` both fail on drift.

## Runtime config

Copy `.throughline/extensions/dev/config-template.yml` → repo-root `dev-config.yml` for
overrides (retries, parallelism, branch prefix). Confidence numbers are constitutional —
not configurable here.

## File-type cheat sheet

| File | Role |
|------|------|
| `.throughline/memory/constitution.md` | Supreme law |
| `.throughline/extensions/dev/commands/*.md` | Command runbooks (canonical procedure) |
| `.throughline/templates/*.md` | Artifact templates (spec, plan, design, tasks, checklist, target) |
| `.throughline/workflows/<id>/workflow.yml` | Multi-step orchestration definitions |
| `.github/agents/*.agent.md` / `.claude/agents/*.md` | Copilot agents / Claude persona subagents |
| `.github/prompts/*.prompt.md` / `.claude/commands/**` | Slash entry points |
| `.github/instructions/*.instructions.md` | Persona protocols (runtime-neutral) |
| `.github/skills/` ≡ `.claude/skills/` | Reusable capability modules (byte-identical) |
| `.github/hooks/hooks.json` / `.claude/settings.json` | Write-boundary + logging hooks |

## Token-economy rules (keep it cheap)

- `CLAUDE.md` and `copilot-instructions.md` are loaded on **every** interaction — keep
  them to non-negotiables and pointers; never add tables the runtimes auto-surface.
- Everything else is pay-per-use: runbooks load when a command runs, skills when invoked.
- Repetition across files is reserved for constitutional invariants; everything else has
  one home.

---
[← The Dashboard](07-dashboard.md) · Next: [Troubleshooting →](09-troubleshooting.md)
