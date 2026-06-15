# Cursor runtime — verification spike (the make-or-break test)

**Goal:** confirm the two things that aren't guaranteed for Cursor before we call it "supported" and
turn on hard enforcement. Everything else (persona bodies, runbooks, rules, commands) is mechanical
translation that reuses the shared brain.

Two open questions:
1. **Do the hooks block?** The shared guard scripts in `.github/hooks/scripts/` were written for the
   Claude/Copilot hook protocol (stdin JSON `{tool_name, tool_input}`, block on a non-zero exit).
   Cursor's `preToolUse` / `beforeShellExecution` hooks must deliver a compatible payload and honor a
   blocking exit for the read-only and no-push guards to actually hold. Until this passes, hooks ship
   `failClosed: false` (fail-open) so a mismatch can't lock the session.
2. **Can the Orchestrator spawn an isolated Reviewer subagent on its own?** Same risk as Codex —
   the independent-Reviewer gate (constitution Principle V) needs a separate context, not inline review.

## 0. Setup
```bash
bash tools/install.sh --tool cursor      # or tools/install.ps1 -Tool cursor on Windows
```
Reload the Cursor window. Confirm `.cursor/agents/`, `.cursor/commands/`, `.cursor/rules/throughline.mdc`,
and a live `.cursor/hooks.json` exist.

## 1. Sanity: are the pieces discovered?
- [ ] `/dev.analyze` and `/throughline` appear as slash commands.
- [ ] The eight personas appear as subagents.
- [ ] The project rule (`throughline.mdc`) is active in the session.

## 2. Hook test: does the guard actually block?
With the hooks installed, try the operations the guards must stop. **Watch what happens; do not flip
`failClosed` yet.**

- [ ] **Write guard** — ask the agent to create or edit a file under `standards/` (e.g.
      `standards/scratch.md`). Expected: the `preToolUse` guard blocks it.
- [ ] **Shell guard** — ask the agent to run `echo x > standards/scratch.md` and, separately,
      `git push`. Expected: the `beforeShellExecution` guard blocks both.
- [ ] **Normal work passes** — editing a file under `wiki/` and running `git status` are allowed.
- [ ] **Logging** — after a normal file edit, `wiki/log.md` gets a new entry (the `afterFileEdit` hook).

If the guards block correctly, the scripts speak Cursor's protocol. **Then** edit
`tools/convert.ps1` + `tools/convert.sh` to emit `failClosed: true` for the `preToolUse` and
`beforeShellExecution` entries (the `cursor-json` branch), regenerate, re-run `setup-hooks`, and
re-test. If they don't block, the scripts need a Cursor-shaped input adapter before enforcement can
be turned on — leave `failClosed: false` and treat the guards as advisory for now.

## 3. Delegation test: isolated Reviewer
Give the Orchestrator a throwaway slice:
```
Act as the Orchestrator. For a throwaway slice, have the Tester author and run one test, then have
the Reviewer gate the result. Do not do the testing or reviewing yourself.
```
- [ ] Orchestrator spawns Tester, then Reviewer, without you invoking each by hand.
- [ ] Reviewer runs as a separate subagent with its own context (independent re-read of `/standards/`).
- [ ] Reviewer does not edit code; Tester does not self-certify.

If spawning is only manual, fall back to running the personas one at a time (`/dev.test`, then
`/dev.review`) — the gates still hold, you just drive the handoffs.

## 4. Verdict and record
- **Hooks block AND delegation is autonomous →** flip `failClosed` to true (step 2), mark Cursor
  **supported** in `STATUS.md` and `docs/runtimes/README.md`.
- **Hooks block but delegation is manual →** Cursor is supported with manual handoffs (note it).
- **Hooks don't block →** keep fail-open; Cursor stays **preview** with advisory guards.

Append the outcome (which boxes passed, the verdict) to `wiki/log.md` and note it in
[`.cursor/README.md`](README.md) so the status is tracked like the other runtimes.
