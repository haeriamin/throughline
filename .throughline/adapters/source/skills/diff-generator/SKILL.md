---
name: diff-generator
description: Produce a standards-annotated diff for a slice — unified diff hunks paired with their Implementation Decision Records. Invoke with /diff-generator.
---

# Diff Generator Skill

## Purpose
Make every change reviewable in one artifact: what changed, why (spec), under what authority (standard), and modeled on what (exemplar). This is the physical form of "Cite or Don't Ship" (Principle III).

## Algorithm

1. Establish the comparison base:
   - Git target: `git diff <default_branch>...sdd/<slice>` from the target root.
   - Non-git target: compare `<target>/.throughline/work-queue/backups/<slice>/` against current files.
2. Segment the diff by task (using the implementation report's files-changed-per-task mapping).
3. Pair each segment with its Implementation Decision Record; flag any hunk with NO owning record as `UNATTRIBUTED` (automatic review finding).
4. Annotate each segment header with: task id, spec §, standard §, exemplar basis, confidence.

## Output Format

```markdown
# Diff: <slice> (target: <id>, base: <rev>)

## T003 — <task name> (confidence 0.XX)
- Spec: <target>/.throughline/specs/NNN-*/spec.md §FR-2 | Standard: standards/api-design.md §API-02 | Exemplar: exemplars/good/api/...
```diff
@@ -10,6 +10,14 @@ ...
```

## UNATTRIBUTED HUNKS
- <file>:<lines> — no owning Decision Record (review finding)
```

## Rules

- Never regenerate or "clean up" the underlying diff content — annotate it as it is.
- UNATTRIBUTED hunks are findings, not formatting problems.

## Usage Context
Called by: Implementer (end of /dev.implement, feeding the implementation report), Reviewer (Layer 3 walk).
