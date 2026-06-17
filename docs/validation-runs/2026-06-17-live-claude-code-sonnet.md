# Validation run — every command, live in Claude Code on Sonnet (2026-06-17)

This run drove the framework as a real end user would: a genuine `claude` CLI session in
PowerShell on Windows, model **Sonnet** (`claude-sonnet-4-6`), rooted in the framework repo so
the real hooks, subagents, and slash commands were all in play. Unlike the
[2026-06-17 dogfood](2026-06-17-dogfood-cartkit.md) (which used stand-in subagents), nothing here
was simulated — each `/dev:*` command ran in its own headless session
(`claude -p --model sonnet --permission-mode bypassPermissions`), with the prompt piped via stdin
and a per-call `--max-budget-usd` cap.

Targets created for the run: **pricetag** (git, existing code, seeded R2 bug), **greenapp**
(greenfield, `--new`), **plainlib** (no VCS).

## Every command, and what happened

| # | Command (live session) | Result | Cost | Time |
|---|---|---|---|---|
| 1 | `/dev:target register X:\Work\pricetag` | Wrote `targets/pricetag.yml` + workspace, updated `settings.local.json`, logged. Left `test_command` empty (no manifest — didn't guess). | $0.23 | 80s |
| 2 | `/dev:target update … test_command=…` + `/dev:target list` | Field updated; registry table printed. | $0.13 | 29s |
| 3 | `/dev:ingest-standards` + `/dev:ingest-exemplars` | Rewrote `wiki/standards-summary.md` (self-corrected rule counts) and `wiki/pattern-library.md`. | $0.49 | 213s |
| 4 | `/dev:analyze pricetag` | Grounded report; found the R2 bug **and** the missing test; confidence 0.79. | $0.31 | 161s |
| 5 | `/dev:feature pricetag "…R2…" --micro` | Real Implementer→Tester→Reviewer subagents. Branch `sdd/…`, fix + 2 R2 tests, 6/6 green, **PASS 1.00**. | $0.42 | 136s |
| 6 | `/dev:feature pricetag "add password auth + store credentials"` | Built spec, **halted at the Clarify gate**, and **pre-flagged SEC-05 / CRITICAL** (auth+credentials) → design handed to the human. Did not implement. | $0.44 | 197s |
| 7 | `/dev:feature pricetag "discounted_total(…)" --express` | Auto-routed to micro (met criteria), built it, 14/14 green, **PASS 1.00**, refused to merge (Principle VI). | $0.42 | 142s |
| 8 | `/dev:target register X:\Work\greenapp --new` + `/dev:feature …` | `--new` created + git-initialized the project; **full pipeline** spec→plan→**design**→tasks→scaffold→implement→test→review; 11/11 green, **PASS 1.00**. | $1.37 | 498s |
| 9 | register `X:\Work\plainlib` (no VCS) + `/dev:feature … --micro` | Registered `vcs: none`; fix + 2 tests, 4/4 green, **PASS 1.00**; reversibility via **`work-queue/backups/…/calc.py`** (the pre-change original), not a branch. | $1.00 | 420s |
| 10 | `/dev:audit` | Portfolio roll-up across 3 targets; retry 0 / escalation 0; surfaced GAP-001 (below). | $0.56 | 210s |
| — | hook-block checks (×2) | Write to `standards/` **blocked**; `git push` evasion found, fixed, **re-confirmed blocked** live. | $0.12 | — |

Total ≈ **$6.1** across the run.

## What this confirms (the gaps the simulated run couldn't close)

- **Hooks fire in a real session.** The PostToolUse logger auto-appended `| hook | Write | … file written` rows to `wiki/log.md`, and the PreToolUse guard blocked a write to `standards/`. Neither happened in the stand-in-subagent dogfood.
- **Real subagent dispatch.** `/dev:feature` spawned Implementer/Tester/Reviewer as genuine subagents on Sonnet, with the independent review gate returning a scored verdict.
- **Human-in-the-loop gates actually halt** headless (Clarify paused and asked), and the **CRITICAL** classification fires for auth/credentials and hands design to the human.
- **Both reversibility modes**: `sdd/<slice>` branch for git targets, `work-queue/backups/` for non-git.
- **Full pipeline phases** (plan, design, tasks, scaffold) all produced real artifacts in greenfield mode (preserved under [`artifacts/live-2026-06-17/`](artifacts/live-2026-06-17/)).

## Findings, and what was fixed

1. **Guard-evasion bug (fixed).** `git -C <dir> push` and `git -c k=v push` slipped past the
   bash-safety hook — its regex only matched `push`/`merge` immediately after `git`. A real
   session ran `git -C X:/Work/pricetag push` unblocked. Fixed in all four guard files
   (`.sh`/`.ps1` × `.claude`/`.github`) to allow intervening options between `git` and the
   subcommand, and to treat any non-word char (incl. the JSON `"`) as the trailing boundary.
   Verified: `git push`, `git -C … push`, `git -c … push`, `git merge` all blocked;
   `git commit -m "…push…"`, `git status`, `git log --grep=merge` all allowed. Re-confirmed live.
2. **No Python exemplar (GAP-001, fixed).** The audit found both shipped exemplars are
   TypeScript, so every Python target had nothing to cite. Added
   `exemplars/good/python/validated-operation.py` (+ `.meta.md`) — a spec-grounded
   input-validation pattern citing ENG-01/02/06 and TST-07/08.
3. **Micro-lane artifact trail (noted).** Some micro slices recorded their verdict only in
   `wiki/log.md` with no file under `review-reports/<target>/`. Left as-is for now (the audit
   flags it); a future runbook note could make micro-lane report files explicitly optional.

## Method notes / honest limits

- `--permission-mode bypassPermissions` was used so permission prompts didn't interfere; the
  **hooks still run** in that mode, which is what we wanted to exercise. PowerShell 5.1 mangles
  native-arg quoting, so prompts were piped via **stdin** (a leading `-m`/`-v` inside an arg was
  being parsed as a CLI flag otherwise).
- This was Claude Code only. Codex's autonomous-subagent spawn (the reason Codex is "preview")
  and a real macOS/Linux run remain unverified — they need those environments.
