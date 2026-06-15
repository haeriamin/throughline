# Contributing

Thanks for improving the framework. Two rules dominate everything else here:

1. **The constitution wins.** `.throughline/memory/constitution.md` overrides every other file.
   Changing thresholds, formula weights, principles, or write boundaries is a constitutional
   amendment (`/throughline.constitution` → human approval → version bump → log entry) — never a
   quiet config edit.
2. **One brain, N adapters.** Substantive procedure lives ONLY in
   `.throughline/extensions/dev/commands/*.md` (runbooks) and
   `.throughline/adapters/source/instructions/*.instructions.md` (protocols). Per-tool wiring is
   **generated** from `.throughline/adapters/source/` by `tools/convert` — do not hand-edit
   `.claude/`, `.codex/`, `.cursor/`, or other generated adapter trees. If your PR puts steps
   into an adapter, it will be asked to move them to the runbook or the source.

## Adding or changing a command

1. Write/edit the runbook: `.throughline/extensions/dev/commands/dev.<name>.md`
   (preconditions, steps, exit criteria, failure modes).
2. Declare it in `.throughline/extensions/dev/extension.yml` (and hook bindings if it joins the lifecycle).
3. Add or edit the source stub: `.throughline/adapters/source/commands/<ns>.<cmd>.command`.
4. For Copilot command agents, edit `.throughline/adapters/source/agents/<ns>.<cmd>.agent.md`
   (canonical agent body for that command).
5. Run `tools/convert` (or `tools/convert.ps1` / `tools/convert.sh`) — it renders the thin
   Copilot prompt pointer, Claude command, Codex prompt, Cursor command, and Tier B rules entries.
6. Do NOT add a per-command Claude subagent — commands adopt one of the 8 persona subagents.
7. Update command tables in `README.md`, `COMMANDS.md`, `ARCHITECTURE.md`.

## Adding or changing a persona

1. Edit metadata in `.throughline/adapters/source/personas/<name>.persona` (tools, sandbox, description).
2. Edit the **canonical behavioral body** in `.throughline/adapters/source/agents/<name>.agent.md`
   (all runtimes derive persona text from this file).
3. Run `tools/convert`. Optional Codex-only fields on the `.persona` file: `codex_sandbox_comment`,
   `codex_note`. Do not hand-edit generated adapter files.

## Editing skills

Edit `.throughline/adapters/source/skills/<name>/SKILL.md`, then run `tools/convert`. The generator
copies skills to `.github/skills/` and `.claude/skills/` byte-identically. CI and `/dev.lint-wiki`
fail if those two generated trees drift apart.

## Tool README / VERIFICATION docs

Runtime guides that ship beside generated adapters (e.g. `.codex/VERIFICATION.md`,
`.cursor/README.md`) live in `.throughline/adapters/source/tool-docs/` and are emitted by
`tools/convert`. Edit the source copy, not the generated file.

## Standards & exemplars

`/standards/` and `/exemplars/` are human-curated seeds. They ship as **replaceable examples** —
teams adopting the framework substitute their own. Contributions here should be broadly
applicable, follow the machine-readable rule format (standards) or the `.meta.md` convention
(exemplars), and avoid stack-specific dogma where a stack-neutral rule exists.

## Hooks & scripts

Hook scripts live in `.throughline/adapters/source/hooks/` and are emitted to `.github/hooks/scripts/`
and `.claude/hooks/`. Every hook/script ships in both shells (`.ps1` + `.sh`) with identical
behavior. CI smoke-tests the bash variants (block/allow exit codes); test PowerShell variants
locally on Windows. Run `tools/setup-hooks` only after `tools/convert` or `tools/install` has
generated the hook scripts.

## Dashboard extension

```bash
cd tools/dashboard && npm ci && npm run compile   # must compile clean under strict TS
```

Zero runtime dependencies is a hard rule — the repo's plain-text artifacts are the only data source.

## Local-only files

Machine-specific state never lands in shared files: target access permissions go in
`.claude/settings.local.json` (gitignored), generated `targets/*.code-workspace` files are
gitignored, and `targets/*.yml` entries contain absolute paths — fine for private team forks,
but don't commit personal target entries to the public repo.

## Fresh clone

Generated adapter folders are gitignored. After clone, run `tools/install.sh` or
`tools/install.ps1` before using any runtime. Until then, root `AGENTS.md`, `CLAUDE.md`, and
`.cursor/rules/` do not exist locally.
