# Antigravity runtime — verification spike (the make-or-break test)

**Goal:** confirm hook enforcement and persona delegation on Antigravity before we call it
"supported". Everything else (persona bodies, runbooks, rules, command rule files) is mechanical
translation from the shared brain.

Two open questions:

1. **Do the hooks block?** The shared guard scripts in `.github/hooks/scripts/` expect stdin JSON
   with `{tool_name, tool_input}` and block on a non-zero exit. Antigravity's `PreToolUse` hooks
   must deliver a compatible payload for the matchers in `.agents/hooks.json` (`write_file|edit_file|create_file`,
   `run_command`). Until this passes, treat guards as advisory even though they are wired.
2. **Can the Orchestrator delegate to isolated personas?** The independent-Reviewer gate
   (constitution Principle V) needs separate contexts for Tester and Reviewer, not inline review.

## 0. Setup

```bash
bash tools/install.sh --tool antigravity      # or tools/install.ps1 -Tool antigravity on Windows
```

Confirm `GEMINI.md`, `.agent/rules/throughline.md`, `.agent/rules/commands/`, `.agents/personas/`,
and a live `.agents/hooks.json` exist. Open the repo in Antigravity.

## 1. Sanity: are the pieces discovered?

- [ ] `GEMINI.md` appears in project context (non-negotiables visible).
- [ ] Command rules under `.agent/rules/commands/` are discoverable (e.g. `dev.review.md`).
- [ ] The eight personas under `.agents/personas/` are available for adoption.

## 2. Hook test: does the guard actually block?

Try the operations the guards must stop. **Record what happens; do not assume matchers are correct.**

- [ ] **Write guard** — ask the agent to create or edit a file under `standards/` (e.g.
      `standards/scratch.md`). Expected: a `PreToolUse` hook blocks it.
- [ ] **Shell guard** — ask the agent to run `echo x > standards/scratch.md` and, separately,
      `git push`. Expected: the `run_command` matcher blocks both.
- [ ] **Normal work passes** — editing a file under `wiki/` and running `git status` are allowed.
- [ ] **Logging** — after a normal file edit, `wiki/log.md` gets a new entry (a `PostToolUse` hook).

If matchers are wrong, update the `antigravity-json` branch in `tools/convert.ps1` and
`tools/convert.sh`, regenerate, re-run `setup-hooks`, and re-test.

## 3. Delegation test: isolated Reviewer

Give the Orchestrator a throwaway slice:

```
Act as the Orchestrator. For a throwaway slice, have the Tester author and run one test, then have
the Reviewer gate the result. Do not do the testing or reviewing yourself.
```

- [ ] Orchestrator adopts Tester, then Reviewer, without you invoking each by hand.
- [ ] Reviewer runs with its own context (independent re-read of `/standards/`).
- [ ] Reviewer does not edit code; Tester does not self-certify.

If spawning is only manual, fall back to running personas one at a time — the gates still hold,
you just drive the handoffs.

## 4. Verdict and record

- **Hooks block AND delegation works →** mark Antigravity **supported** in `STATUS.md` and
  `docs/runtimes/README.md`.
- **Hooks block but delegation is manual →** supported with manual handoffs (note it).
- **Hooks don't block →** stay **preview**; guards remain instructed via `GEMINI.md`.

Append the outcome to `wiki/log.md` and note it in [`.agents/README.md`](README.md).
