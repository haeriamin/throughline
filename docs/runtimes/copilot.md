# Throughline with GitHub Copilot (VS Code)

Copilot uses the dot syntax: `/dev.analyze`, `/throughline`.

## 1. What you need
- VS Code with GitHub Copilot (agent/chat enabled).
- git, for the framework repo and for reversible changes on your targets.

## 2. One-time setup
```bash
git clone <repo-url> throughline
cd throughline
bash tools/install.sh --tool copilot         # Git Bash / macOS / Linux (regenerates .github/ wiring)
# Windows (PowerShell):  powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Tool copilot
```
Open the framework folder in VS Code. The `.github/` assets load on their own: agents in
`.github/agents/`, instructions in `.github/copilot-instructions.md`, and write-safety hooks in
`.github/hooks/hooks.json`. There's no build step. The hooks file already carries a per-OS
`windows` override (PowerShell on Windows, bash on macOS/Linux), so Copilot needs no separate
`setup-hooks` step — the installer just regenerates the adapter from source.

## 3. First run (load the knowledge, once)
In Copilot Chat:
```
/throughline.constitution        # review the framework's law; fill in the Ratified date
/dev.ingest-standards        # compile /standards/ into the wiki
/dev.ingest-exemplars        # compile /exemplars/ into the pattern library
```
The `/standards/` and `/exemplars/` that ship are starter seeds. Swap in your team's own and re-run the ingests.

## 4. Register your code (a "target")
```
/dev.target register path/to/my-app           # existing codebase
/dev.target register path/to/new-app --new     # brand-new project
```
This writes `targets/<id>.yml` and a multi-root workspace, `targets/<id>.code-workspace`. Open that workspace so Copilot can edit the target alongside the framework.

## 5. The five ways to use it

One command for the whole lifecycle:
```
/dev.feature my-app "Add cursor pagination to the orders endpoint"
```
Runs specify, clarify, plan, design (if HIGH), tasks, implement, test, and review, stopping only at the gates. An empty target switches it into greenfield mode, which adds design and scaffold.

Cheaper modes:
```
/dev.feature my-app "Rename the config flag" --micro      # implement, test, review only
/dev.feature my-app "Add a log line" --express             # skip the optional approval pauses
```

Phase by phase, when you want the control:
```
/throughline "Add pagination to orders (target: my-app)"
/throughline.clarify        # answer up to 3 questions
/throughline.plan           # runs /dev.analyze; /dev.design too if HIGH/CRITICAL
/throughline.tasks
/throughline.implement      # chains /dev.implement, /dev.test, /dev.review
```

Single commands, out of band, with no full spec:
```
/dev.ideate "<rough idea>" my-app  # brainstorm options before building (read-only)
/dev.analyze my-app                # understand the codebase
/dev.review <slice-id>             # gate a change: PASS / CONDITIONAL_PASS / FAIL
/dev.test <slice-id>               # write and run tests, record real evidence
/dev.audit                         # portfolio-wide quality roll-up
```

Knowledge only: just step 3, then use the skills ad hoc in chat.

## Notes specific to Copilot
- The slash syntax is the dot form: `/dev.analyze`, `/throughline`.
- Use the generated `<id>.code-workspace`. Without it, Copilot can't reach the target's files.
- Agents hand off to each other through the `handoffs:` declared in `.github/agents/*.agent.md`.
- **Single-agent independence caveat**: by default one model invocation plays every persona, so the
  Implementer and Reviewer are the same agent — the review gate is effectively self-grading, and a
  high confidence (even 1.00) on a small slice reflects traceability discipline, not an independent
  correctness guarantee. The human merge is the real gate; weight PASS/CONDITIONAL_PASS accordingly.
  Delegating phases to separate Copilot subagents narrows this (the Reviewer runs as its own agent)
  but doesn't erase it — they still share a model family.
- The [dashboard extension](../07-dashboard.md) gives you a live view of the work queue.

Next: [Building Features](../04-building-features.md) · [Quality Gates](../06-quality-gates.md)
