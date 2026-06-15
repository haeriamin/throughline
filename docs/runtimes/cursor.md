# Throughline with Cursor (preview)

Cursor uses the dot syntax: `/dev.analyze`, `/throughline`.

> **Preview.** The adapter files are generated and in place (`.cursor/`), but two runtime behaviours
> still need confirming on your machine: whether the guard hooks actually block, and whether the
> Orchestrator can spawn an isolated Reviewer subagent on its own. See
> [Verifying the runtime](#verifying-the-runtime-preview). Until then the hooks run fail-open
> (advisory) and you may need to invoke some personas yourself; every command still works.

## 1. What you need
- Cursor (recent version, with subagents, custom slash commands, and hooks).
- git.

## 2. One-time setup
```bash
git clone <repo-url> throughline
cd throughline
```
Generate the Cursor adapter and wire its hooks for your OS in one step:
```bash
bash tools/install.sh --tool cursor              # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool cursor   # Windows PowerShell
```
Then reload the Cursor window so it re-reads `.cursor/`. What loads: the personas in
`.cursor/agents/*.md`, the commands in `.cursor/commands/*.md`, the project rule
`.cursor/rules/throughline.mdc`, and the per-OS `.cursor/hooks.json`. More detail in
[.cursor/README.md](../../.cursor/README.md).

> The hooks install **fail-open** on purpose (a fail-closed hook pointing at a script that can't run
> would lock your session). The read-only and no-push guards are also written into the project rule,
> so they're instructed regardless. Turn on hard enforcement after the spike in
> [.cursor/VERIFICATION.md](../../.cursor/VERIFICATION.md) passes.

## 3. First run (load the knowledge, once)
```
/throughline.constitution        # review the framework's law; fill in the Ratified date
/dev.ingest-standards        # compile /standards/ into the wiki
/dev.ingest-exemplars        # compile /exemplars/ into the pattern library
```

## 4. Register your code (a "target")
```
/dev.target register path/to/my-app           # existing codebase
/dev.target register path/to/new-app --new     # brand-new project
```
`register` also generates `targets/<id>.code-workspace`, which lists both the framework and your
target as folders. Open that workspace so Cursor can read and write the target.

## 5. The five ways to use it

One command for the whole lifecycle:
```
/dev.feature my-app "Add cursor pagination to the orders endpoint"
```

Cheaper modes:
```
/dev.feature my-app "Rename the config flag" --micro      # implement, test, review only
/dev.feature my-app "Add a log line" --express             # skip the optional approval pauses
```

Phase by phase, when you want the control:
```
/throughline "Add pagination to orders (target: my-app)"
/throughline.clarify
/throughline.plan
/throughline.tasks
/throughline.implement
```

Single commands, out of band, with no full spec:
```
/dev.ideate "<rough idea>" my-app
/dev.analyze my-app
/dev.review <slice-id>
/dev.test <slice-id>
/dev.audit
```

Knowledge only: just step 3, then use the skills ad hoc.

## Notes specific to Cursor
- The slash syntax is the dot form: `/dev.analyze`, `/throughline`.
- Personas are `.cursor/agents/*.md`; the read-only roles carry `readonly: true`.
- `.cursor/hooks.json` is machine-local (gitignored) and re-wired per-OS by `tools/setup-hooks`; the
  committed source is the staged template under `.throughline/adapters/generated/cursor/`.
- Don't hand-edit anything in `.cursor/` — it's generated. Edit `.throughline/adapters/source/` and run
  `tools/convert`.

## Verifying the runtime (preview)
Run the spike in [.cursor/VERIFICATION.md](../../.cursor/VERIFICATION.md): confirm the guard hooks
block writes to `/standards/` and `git push`, and that the Orchestrator spawns a separate, isolated
Reviewer. If the hooks block, flip them to fail-closed for hard enforcement; if delegation is manual,
run the personas one at a time (`/dev.test`, then `/dev.review`) — the gates still hold.

Next: [Building Features](../04-building-features.md) · [Quality Gates](../06-quality-gates.md)
