# Targets — External Project Registry

One `<id>.yml` per external project, created/maintained via `/dev.target` (Orchestrator).
Template: `.throughline/templates/target-template.yml`.

The framework holds no product code — these entries are the only bridge to where code lives.

`/dev.target register <path>` also generates `<id>.code-workspace` here (multi-root VS Code
workspace: framework + target) for Copilot use, and adds the path to
`permissions.additionalDirectories` in `.claude/settings.local.json` (gitignored,
machine-local) for Claude Code use.

`*.code-workspace` files are user-local conveniences; regenerate freely.
