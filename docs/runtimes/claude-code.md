# Throughline with Claude Code

Claude Code uses the colon syntax: `/dev:analyze`, `/throughline:specify`.

## 1. What you need
- Claude Code (CLI or desktop).
- git, for the framework repo and for reversible changes on your targets.

## 2. One-time setup
```bash
git clone <repo-url> throughline
cd throughline
bash tools/install.sh --tool claude          # Git Bash / macOS / Linux
# Windows (PowerShell):  powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool claude
claude                                       # CLAUDE.md and .claude/ assets load automatically
```

The installer generates `.claude/agents/` and `.claude/commands/` from the shared source and wires
write-safety hooks into `.claude/settings.local.json` (machine-local, gitignored) — PowerShell on
Windows, bash on macOS/Linux. No Python required. The read-only guard on `/standards/` and
`/exemplars/` is declarative in `.claude/settings.json` and is already on before install.

Adapter files are generated — edit `.throughline/adapters/source/`, then run `tools/convert` (or
re-run `tools/install`). Do not hand-edit `.claude/agents/` or `.claude/commands/`.

## 3. First run (load the knowledge, once)
```
/throughline:constitution        # review the framework's law; fill in the Ratified date
/dev:ingest-standards        # compile /standards/ into the wiki
/dev:ingest-exemplars        # compile /exemplars/ into the pattern library
```
The `/standards/` and `/exemplars/` that ship are starter seeds. Swap in your team's own and re-run the ingests.

## 4. Register your code (a "target")
```
/dev:target register path/to/my-app           # existing codebase
/dev:target register path/to/new-app --new     # brand-new project
```
This writes `targets/<id>.yml` and grants Claude Code access to that external path through `.claude/settings.local.json` (the `additionalDirectories` setting, which is machine-local and gitignored). There's no separate workspace to open; Claude Code edits the registered path directly.

## 5. The five ways to use it

One command for the whole lifecycle:
```
/dev:feature my-app "Add cursor pagination to the orders endpoint"
```
Runs specify, clarify, plan, design (if HIGH), tasks, implement, test, and review, stopping only at the gates. An empty target switches it into greenfield mode, which adds design and scaffold.

Cheaper modes:
```
/dev:feature my-app "Rename the config flag" --micro      # implement, test, review only
/dev:feature my-app "Add a log line" --express             # skip the optional approval pauses
```

Phase by phase, when you want the control:
```
/throughline:specify "Add pagination to orders (target: my-app)"
/throughline:clarify        # answer up to 3 questions
/throughline:plan           # runs /dev:analyze; /dev:design too if HIGH/CRITICAL
/throughline:tasks
/dev:implement      # chains /dev:implement, /dev:test, /dev:review
```

Single commands, out of band, with no full spec:
```
/dev:ideate "<rough idea>" my-app  # brainstorm options before building (read-only)
/dev:analyze my-app                # understand the codebase
/dev:review <slice-id>             # gate a change: PASS / CONDITIONAL_PASS / FAIL
/dev:test <slice-id>               # write and run tests, record real evidence
/dev:audit                         # portfolio-wide quality roll-up
```

Knowledge only: just step 3, then use the skills ad hoc.

## Notes specific to Claude Code
- The slash syntax is the colon form: `/dev:analyze`, `/throughline:specify`.
- The Orchestrator hands each phase to a subagent (Analyst, Implementer, Tester, Reviewer, and so on) through the Agent tool, which is what keeps the Reviewer in an independent context.
- Target access is per-machine (it lives in `.claude/settings.local.json`), so re-register on a new machine.

Next: [Building Features](../04-building-features.md) · [Quality Gates](../06-quality-gates.md)
