# Throughline with Codex (preview)

Codex uses the dot syntax: `/dev.analyze`, `/throughline`.

> **Preview.** All the adapter files are in place (`.codex/`), but one runtime behaviour still needs confirming on your machine: whether the Orchestrator can spawn an isolated Reviewer subagent on its own. See [Verifying the runtime](#verifying-the-runtime-preview) below. Until then every command still runs; you may just need to invoke the personas yourself.

## 1. What you need
- The Codex CLI, or the Codex desktop app. On a machine with no Node, grab the prebuilt binary from the [Codex releases](https://github.com/openai/codex/releases) (or use `winget` / `scoop`) rather than `npm i -g`.
- A signed-in Codex: `codex login` (ChatGPT), or an `OPENAI_API_KEY`.
- git.

## 2. One-time setup
```bash
git clone <repo-url> throughline
cd throughline
bash tools/install.sh --tool codex           # Git Bash / macOS / Linux
# Windows (PowerShell):  powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool codex
codex                                        # AGENTS.md + .codex/ assets load from the repo
/hooks                                       # trust the project's write-safety hooks (once)
```

The installer generates `.codex/agents/*.toml` and `.codex/prompts/*.md`, rebuilds `.codex/hooks.json`
for your OS, and needs no Python. Codex reads custom slash commands from `~/.codex/prompts/` (global),
so copy the generated prompts once:

```bash
cp .codex/prompts/*.md ~/.codex/prompts/        # or symlink; start a new session to pick them up
```

What loads from the repo: personas in `.codex/agents/*.toml`, global rules in `AGENTS.md`, hooks in
`.codex/hooks.json`. More detail in [.codex/README.md](../../.codex/README.md).

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
Run Codex from a directory that can reach the target path. Its sandbox governs what it may write, and each persona's `sandbox_mode` keeps the read-only roles read-only.

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

## Notes specific to Codex
- The slash syntax is the dot form: `/dev.analyze`, `/throughline`.
- Personas are `.codex/agents/*.toml`, and their `sandbox_mode` sets the read/write posture.
- Codex has no declarative handoffs, so the Orchestrator names and spawns each persona, and the handoffs are written into the persona text.
- Commands live globally in `~/.codex/prompts/`, so re-copy them whenever you change `.codex/prompts/`.

## Verifying the runtime (preview)
Before you lean on full automation, run the spike in [.codex/VERIFICATION.md](../../.codex/VERIFICATION.md): ask the Orchestrator to have the Tester and then the Reviewer handle a throwaway slice, and watch whether it spawns a separate, isolated Reviewer subagent on its own. If it does, Codex is on par with the other tools. If spawning is only manual, run the personas one at a time (`/dev.test`, then `/dev.review`); the gates still hold, you're just driving the handoffs yourself.

Next: [Building Features](../04-building-features.md) · [Quality Gates](../06-quality-gates.md)
