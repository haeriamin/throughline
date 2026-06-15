---
description: Cross-artifact consistency check across spec, plan, design, tasks, implementation, and review reports for the active slice.
handoffs:
  - label: Portfolio audit
    agent: dev.audit
    prompt: Consistency check done. Roll up the portfolio audit.
    send: false
---

## User Input

```text
$ARGUMENTS
```

## Pre/Post Hooks

Check `.throughline/extensions.yml` for `hooks.before_analyze` / `hooks.after_analyze` per [extension hook protocol](../instructions/extension-hooks.instructions.md) (`after_analyze` offers `/dev.audit`).

## Outline

1. Load all artifacts of the active slice from `<target>/.throughline/`: `specs/NNN-*/{spec,plan,design (if any),tasks,implementation}.md`, the test report (`review-reports/<slice>-tests.md`), and the review report (`review-reports/<slice>-review.md`).
2. **Consistency matrix** — check and report each:
   - Every FR ↔ ≥1 task ↔ ≥1 Decision Record ↔ coverage-table row (full chain or explicit PARTIAL/exception).
   - Plan's new-dependency list ↔ dependencies actually introduced (diff/manifest check).
   - Design contracts ↔ implemented signatures (no silent contract drift).
   - Success criteria ↔ test evidence (each SC verifiable from the test report).
   - Complexity class ↔ process followed (HIGH/CRITICAL had Approved design; CRITICAL was human-led).
   - Citations resolve (spot-check N=5 Decision Records against `/standards/` sources, and `<target>/.throughline/standards/` for target-local rules).
3. Classify findings: CRITICAL (chain broken — e.g., FR with no task), WARNING (drift — e.g., stale analysis fingerprint), INFO.
4. Write findings into the report section of the slice's work item; CRITICAL findings → route back to the owning phase (spec gap → specify; contract drift → implement) rather than patching artifacts here.
5. Report the matrix with verdicts per row. Append to `<target>/.throughline/wiki/log.md`.

## Rule

This command never edits target code or rewrites artifacts to force consistency — it reports, and the owning lifecycle phase fixes.
