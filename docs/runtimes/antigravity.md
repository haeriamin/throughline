# Throughline with Antigravity (preview)

Antigravity uses the dot syntax in docs: `/dev.analyze`, `/throughline`. There is no native
slash-command folder — lifecycle phases are invoked by name or via the command rules in
`.agent/rules/commands/`.

> **Preview.** The adapter files are generated and in place (`GEMINI.md`, `.agent/rules/`,
> `.agents/`), but hook matchers and persona delegation still need confirming on your machine. See
> [Verifying the runtime](#verifying-the-runtime-preview). Until then, guards are **instructed** in
> `GEMINI.md` and **enforced only if hooks fire correctly**.

## 1. What you need

- Google Antigravity (recent version, with rules, personas, and hooks support).
- git.

## 2. One-time setup

```bash
git clone <repo-url> throughline
cd throughline
```

Generate the Antigravity adapter and wire its hooks for your OS:

```bash
bash tools/install.sh --tool antigravity              # Git Bash / macOS / Linux
powershell -ExecutionPolicy Bypass -File tools/install.ps1 -Tool antigravity   # Windows PowerShell
```

Open this repo in Antigravity. What loads:

- **`GEMINI.md`** — Antigravity-specific project instructions (takes precedence over root `AGENTS.md`).
- **`.agent/rules/throughline.md`** — global non-negotiables for the rules panel.
- **`.agent/rules/commands/*.md`** — one rule per lifecycle command, each pointing at its runbook.
- **`.agents/personas/*.md`** — the eight Throughline personas.
- **`.agents/hooks.json`** — per-OS guard hooks (machine-local, gitignored).

More detail in [.agents/README.md](../../.agents/README.md).

> Root `AGENTS.md` is the Codex adapter — do not edit it for Antigravity. Use `GEMINI.md` instead.

## 3. First run (load the knowledge, once)

Ask Antigravity to follow these phases (or open the matching files under `.agent/rules/commands/`):

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

`register` also generates `targets/<id>.code-workspace`. Open that workspace (or add the target
folder in Antigravity) so the agent can read and write the target path.

## 5. The five ways to use it

One command for the whole lifecycle:

```
/dev.feature my-app "Add pagination to the orders endpoint"
```

Cheaper modes:

```
/dev.feature my-app "Rename the config flag" --micro      # implement, test, review only
/dev.feature my-app "Add a log line" --express             # skip optional approval pauses
```

Phase by phase:

```
/throughline "Add pagination to orders (target: my-app)"
/throughline.clarify
/throughline.plan
/throughline.tasks
/throughline.implement
```

Single commands:

```
/dev.ideate "<rough idea>" my-app
/dev.analyze my-app
/dev.review <slice-id>
/dev.test <slice-id>
/dev.audit
```

Knowledge only:

```
/dev.ingest-standards
/dev.ingest-exemplars
```

## Verifying the runtime (preview)

Before relying on hook enforcement, run the spike in
[`.agents/VERIFICATION.md`](../../.agents/VERIFICATION.md). It checks:

1. Whether `PreToolUse` hooks block writes to `/standards/` and `/exemplars/` and shell bypasses.
2. Whether the Orchestrator can delegate to Tester and Reviewer in separate contexts.

Until the spike passes, honor the non-negotiables yourself even if a hook misfires.
