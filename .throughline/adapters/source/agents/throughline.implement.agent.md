---
description: Execute the tasked slice through the Implementer → Tester → Reviewer pipeline with constitutional gates.
handoffs:
  - label: Cross-artifact analysis
    agent: throughline.analyze
    prompt: Implementation reviewed. Run the consistency check.
    send: true
  - label: Triage escalations
    agent: dev.review-escalated
    prompt: The slice escalated. Present the escalation artifacts for human decision.
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Pre/Post Hooks

Check `.throughline/extensions.yml` for `hooks.before_implement` / `hooks.after_implement` per [extension hook protocol](../instructions/extension-hooks.instructions.md). In this framework `after_implement` → `/dev.review` is **mandatory** — the slice is not complete without a Reviewer verdict.

## Outline

1. Verify prerequisites: `check-prerequisites -Phase implement` (spec + plan + tasks; design Approved for HIGH/CRITICAL).
2. **Bootstrap** (Principle II — full sequence). Verify reversibility setup (Principle VI): git target → branch `sdd/<slice>` created from the default branch; non-git → `<target>/.throughline/work-queue/backups/<slice>/` staged.
3. Move/create the global live work item in `work-queue/in-progress/` (status: IN_PROGRESS; id `<target>-<slice>`).
4. **Execute** `/dev.implement` — the Implementer works through `tasks.md` in order, one Decision Record per task, per [implementation rules](../instructions/implementation-rules.instructions.md).
5. **Test** `/dev.test` — the Tester produces the evidence report.
6. **Review** (mandatory after_implement hook) `/dev.review`:
   - PASS → copy the final work item to `<target>/.throughline/work-queue/completed/<slice>.md` and clear the global live item; report flagged items: none.
   - CONDITIONAL_PASS → same, with the flagged-items list; request human spot-check.
   - FAIL → return findings to `/dev.implement`; **max 2 retry cycles**, then `/dev.review-escalated` (Principle V).
7. **Constitution verification** (Governance): confirm artifacts against every principle before reporting completion.
8. Report: verdict, confidence with sub-scores, files changed, branch name + rollback procedure, PARTIAL/escalation count, `<target>/.throughline/wiki/log.md` entries appended. **Never merge or push** — present the branch for human merge.
