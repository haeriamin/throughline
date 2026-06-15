# Codex runtime — verification spike (the make-or-break test)

**Goal:** before porting all 8 personas, confirm the single thing that isn't guaranteed — that the
**Orchestrator can autonomously spawn an *isolated* Reviewer subagent**. Everything else (persona
bodies, runbooks, hooks, AGENTS.md) is mechanical translation and reuses the shared brain.

Codex CLI is not installed in the authoring environment, so run this on a machine that has it.
There is **no system Node here** — install Codex via a method that doesn't need it (Homebrew, the
prebuilt binary, or `npm`/`pnpm` on a Node box). The OpenAI key already lives in `~/.sdd_keys.env`.

## 0. Setup
```bash
# install codex (pick one): brew install codex   |   download the release binary   |   npm i -g @openai/codex
codex --version
export OPENAI_API_KEY="$(grep -E '^OPENAI_API_KEY=' ~/.sdd_keys.env | cut -d= -f2-)"   # or: codex login
cd <this framework repo>            # AGENTS.md + .codex/agents/*.toml are picked up from here
codex                               # start an interactive session (or use `codex exec "<prompt>"` headless)
```
Already wired (full adapter): all 8 `.codex/agents/*.toml`, 21 `.codex/prompts/*.md`,
`.codex/hooks.json`, `.codex/config.toml`, `AGENTS.md`. This spike confirms runtime *behaviour*,
not authoring — Tester / Reviewer / Orchestrator are enough to exercise it.

## 1. Sanity: are the agents discovered?
In the session, run `/agents` (or `/agent list`). **PASS** = Orchestrator, Reviewer, Tester all
listed from `.codex/agents/`. If they aren't, the agent dir/format is wrong — fix before continuing.

## 2. Core test: autonomous, isolated delegation
Give the Orchestrator a trivial slice and watch *how* it executes:
```
Act as the Orchestrator. For a throwaway slice, have the Tester author and run one test, then have
the Reviewer gate the result. Do not do the testing or reviewing yourself.
```
Watch the trace (`codex` shows tool calls / spawns; or open the Traces dashboard). Check:

- [ ] **Spawn happens autonomously** — the Orchestrator spawns `Tester`, then `Reviewer`, *without
      you* manually invoking each. (This is the openai/codex#15250 risk: subagent invocation from a
      tool-backed session. If spawning requires *your* explicit command each time, the autonomous
      topology does NOT hold.)
- [ ] **Reviewer runs as a SEPARATE subagent** with its own context — not the Orchestrator or Tester
      reviewing inline. Its `developer_instructions` (independent re-read of `/standards/`) are in force.
- [ ] **Role isolation** — the Reviewer does not edit code; the Tester does not self-certify; the
      Reviewer's verdict is produced independently of the Tester's claims.
- [ ] **`sandbox_mode` holds** — Reviewer/Tester cannot write outside their declared surfaces.

## 3. Verdict
- **All four boxes pass →** topology holds and the adapter (all 8 personas + 22 commands + hooks +
  `AGENTS.md`) is complete. Finish the two remaining wiring items from `.codex/README.md`: register
  each persona's skills via `skills.config` (item 3) and confirm the `apply_patch` hook payload
  (item 2). Then Codex is a fully supported Tier A runtime.
- **Spawning is NOT autonomous (only user-initiated) →** the framework's orchestrator→persona
  autonomy can't run inside one Codex session. Two fallbacks:
  1. **External orchestration shim** — a small driver that invokes `codex exec` once per persona/phase,
     passing artifacts between them (preserves isolation; most faithful; more glue code).
  2. **Sequential single-agent mode** — one Codex agent adopts each persona+runbook in turn. Simplest,
     but the Reviewer is no longer a separate context → **loses the independent-Reviewer gate**
     (constitution Principle V). Only acceptable as an explicitly-labeled degraded mode.

## 4. Record the result
Append the outcome (which boxes passed, the verdict, any #15250 behavior observed) to
`wiki/log.md` and note it in `.codex/README.md` so the runtime's status is tracked like the others.
