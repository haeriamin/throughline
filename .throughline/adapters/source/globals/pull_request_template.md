## What & why

<!-- One or two sentences. Link an issue if one exists. -->

## Checklist (framework rules — CI enforces most of these)

- [ ] Behavior changes live in a **runbook** (`.throughline/extensions/dev/commands/`) or
      instruction file — not in an adapter (`.github/agents`, `.claude/commands`)
- [ ] Skills edited in `.github/skills/` are copied **byte-identical** to `.claude/skills/`
- [ ] New/renamed commands updated in: `extension.yml`, both runtime adapters,
      `COMMANDS.md`, and the doc tables
- [ ] Threshold/formula/principle changes go through `/throughline.constitution`
      (version bump + `wiki/log.md` entry) — never a quiet config edit
- [ ] `cd tools/dashboard && npm ci && npm run compile` passes if TypeScript was touched
- [ ] No machine-specific paths or personal data in committed files
