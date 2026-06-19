# Work Item: [NNN-short-name]

**Slice ID**: [NNN-short-name]
**Target**: [target-id from targets/]
**Status**: PENDING | IN-PROGRESS | COMPLETED | ESCALATED
**Lane**: micro | standard | deep
**Mode**: feature | greenfield
**Complexity**: LOW | MEDIUM | HIGH | CRITICAL
**Created**: [DATE]
**Updated**: [DATE]
**Input**: "[verbatim user description]"

> Created by /dev.feature step 0 in `work-queue/pending/`, moved to `in-progress/` as phases
> start, then to `completed/` or `escalated/` at close. File name is `[NNN-short-name].md`.
> `/dev.lint-wiki` check 11 flags phase reports left in `in-progress/` after this item moves.

## Branch

- Target branch: `sdd/[NNN-short-name]` (never the default branch; never pushed/merged by an agent)

## Inline spec *(micro lane only — replaces the `specs/` folder)*

[One paragraph: scope, the single functional requirement, success criteria, out-of-scope.
Used only when Lane = micro; standard/deep lanes use `specs/[NNN-short-name]/spec.md` instead.]

## Phase artifacts

| Phase | Artifact | Done |
|-------|----------|:----:|
| Spec | specs/[NNN-short-name]/spec.md | [ ] |
| Plan | specs/[NNN-short-name]/plan.md | [ ] |
| Design | specs/[NNN-short-name]/design.md (HIGH/greenfield only) | [ ] |
| Tasks | specs/[NNN-short-name]/tasks.md | [ ] |
| Analysis | work-queue/in-progress/[NNN-short-name]-analysis.md | [ ] |
| Implementation | work-queue/in-progress/[NNN-short-name]-implementation.md | [ ] |
| Tests | review-reports/[target]/[NNN-short-name]-tests.md | [ ] |
| Review | review-reports/[target]/[NNN-short-name]-review.md | [ ] |

## Outcome

- **Verdict**: [PASS | CONDITIONAL_PASS | PARTIAL | FAIL | ESCALATED] (confidence [0.00])
- **Notes**: [retry count, escalation, flagged items if CONDITIONAL_PASS, merge note]
