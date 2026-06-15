---
description: Generate a quality checklist for the active slice at a named gate (requirements, design, implementation, release).
---

## User Input

```text
$ARGUMENTS
```

## Outline

1. Determine the checklist type from arguments (default: `requirements`). Locate the active feature directory.
2. Create `<target>/.throughline/specs/NNN-*/checklists/<type>.md` from `.throughline/templates/checklist-template.md`.
3. Populate with binary-answerable items appropriate to the gate:
   - **requirements**: spec quality (no implementation detail, testable FRs, measurable SCs, bounded scope, assumptions recorded, ≤3 open clarifications).
   - **design**: every contract has an owner task; ADRs cite standards + alternatives; security/failure analysis present (HIGH/CRITICAL); no open questions.
   - **implementation**: Decision Record per task; lint clean; DEV-STATUS annotations all registered; branch/backups verified; no unplanned dependencies.
   - **release**: Reviewer PASS/CONDITIONAL_PASS; flagged items dispositioned; rollback procedure tested; docs updated; human merge sign-off recorded.
4. Run the checklist against the current artifacts; mark each item pass/fail with a one-line evidence note (file + section).
5. Report failures with the lifecycle phase that owns the fix. Append to `<target>/.throughline/wiki/log.md`.

## Rule

Checklists verify; they never modify artifacts. Fixes go through the owning command.
