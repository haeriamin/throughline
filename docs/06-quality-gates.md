# 6 · Quality Gates

How the framework decides a piece of work is done — and what happens when it is not.

## Test proof (the Tester)

"The tests pass" is never just a claim. It is a report: the exact command, the exit code,
how many passed and failed, the real failure output, and a table that maps each changed
behavior to its test (covered / failing / missing, with a reason). It is saved at
`<target>/.throughline/review-reports/<slice>-tests.md`. If the report is missing or out of date, the
test score is **0** — no benefit of the doubt.

## The review (the Reviewer)

Three layers, in order:

1. **Structure** — clean lint, follows conventions, no leftover conflict markers or debug
   output, every "needs work" note recorded, and the writing is plain English. *Any failure
   here means FAIL, whatever the score.*
2. **Behavior** — the test report's results; no new failures in tests that passed before.
3. **Rules** — every change's cited rule is re-read from the source in `/standards/` (never
   from the wiki) and checked that it really applies. A made-up or wrong citation is an
   automatic FAIL.

The score and the result:

```
score = 0.40 × test proof + 0.35 × rules followed + 0.25 × matches the spec

PASS ≥ 0.85 · CONDITIONAL PASS 0.70–0.84 · FAIL below 0.70 or any structure failure
```

Each part of the score is shown as a fraction (for example, `rules followed = 11/12 = 0.92`)
so you can see exactly what pulled it down.

## The retry loop

On FAIL, the review lists each problem (with the `file:line` and the rule) and sends it back
to the Implementer. **At most 2 retries**, then it goes to a human. The loop cannot run forever.

## Asking the human (`/dev:review-escalated`)

When an agent is not confident enough, it writes a short escalation report under the target's
`<target>/.throughline/work-queue/escalated/`: what is done, what is blocked, the exact
question(s) for you, the options with their trade-offs, and its suggestion (the live escalated
queue item the dashboard counts stays in the framework's `work-queue/escalated/`). You decide.
The Archivist saves your decision (as `EXC-NNN`) so it is reused next time, and the work
continues from there. Asking the human is the system working as intended, not failing.

## Undo and merging

- Git projects: all work is on a branch `sdd/<slice>` — to undo, delete the branch.
- Non-git projects: the originals are saved in `<target>/.throughline/work-queue/backups/<slice>/` — to undo, put them back.
- Every report says exactly how to undo its change.
- **You always do the merge.** A PASS gives you a branch; no agent ever merges it.
- The change also lands in `<target>/.throughline/CHANGELOG.md` on the same branch — what changed, the files, the cited spec/standards, and the verdict — so the record merges with the code and stays with the codebase.

---
[← The Knowledge Base](05-knowledge-base.md) · Next: [The Dashboard →](07-dashboard.md)
