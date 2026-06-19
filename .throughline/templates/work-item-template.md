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

> Created by /dev.feature step 0 in the global `work-queue/pending/`, moved to `in-progress/` as
> phases start. The live file name is target-qualified — `<target>-[NNN-short-name].md` — so the
> shared queue stays unambiguous across targets. At slice close a durable copy is written to
> `<target>/.throughline/work-queue/completed/[NNN-short-name].md` and the global live item is
> cleared; an escalated slice stays in the global `work-queue/escalated/` lane.
> `/dev.lint-wiki` check 11 flags a closed slice whose live item was never cleared (no durable
> target-side copy).

## Branch

- Target branch: `sdd/[NNN-short-name]` (never the default branch; never pushed/merged by an agent)

## Inline spec *(micro lane only — replaces the target-side `specs/` folder)*

[One paragraph: scope, the single functional requirement, success criteria, out-of-scope.
Used only when Lane = micro; standard/deep lanes use
`<target>/.throughline/specs/[NNN-short-name]/spec.md` instead.]

## Phase artifacts

| Phase | Artifact | Done |
|-------|----------|:----:|
| Spec | <target>/.throughline/specs/[NNN-short-name]/spec.md | [ ] |
| Plan | <target>/.throughline/specs/[NNN-short-name]/plan.md | [ ] |
| Design | <target>/.throughline/specs/[NNN-short-name]/design.md (HIGH/greenfield only) | [ ] |
| Tasks | <target>/.throughline/specs/[NNN-short-name]/tasks.md | [ ] |
| Analysis | <target>/.throughline/specs/[NNN-short-name]/analysis.md | [ ] |
| Implementation | <target>/.throughline/specs/[NNN-short-name]/implementation.md | [ ] |
| Tests | <target>/.throughline/review-reports/[NNN-short-name]-tests.md | [ ] |
| Review | <target>/.throughline/review-reports/[NNN-short-name]-review.md | [ ] |

## Outcome

- **Verdict**: [PASS | CONDITIONAL_PASS | PARTIAL | FAIL | ESCALATED] (confidence [0.00])
- **Notes**: [retry count, escalation, flagged items if CONDITIONAL_PASS, merge note]
