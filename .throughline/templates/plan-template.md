# Implementation Plan: [FEATURE NAME]

**Slice ID**: [NNN-short-name]
**Target**: [target-id]
**Spec**: [link to spec.md]
**Analysis**: [link to <target>/.throughline/specs/[NNN-short-name]/analysis.md — produced by /dev.analyze]
**Design**: [link to design.md, or "n/a — LOW/MEDIUM complexity"]
**Created**: [DATE]

## Constitution Check *(mandatory — gate before proceeding)*

- [ ] Bootstrap sequence completed (Principle II)
- [ ] Target registered and readable (`targets/<id>.yml`)
- [ ] No writes planned to `/standards/` or `/exemplars/` (Principle I)
- [ ] Rollback strategy defined (Principle VI): [branch `sdd/<slice>` | backups]
- [ ] Complexity class confirmed: [LOW | MEDIUM | HIGH | CRITICAL]
- [ ] HIGH/CRITICAL → `design.md` exists and is human-approved

## Technical Context

**Stack**: [from targets/<id>.yml + analysis]
**Affected Modules**: [from analysis report]
**Existing Conventions**: [detected by codebase-mapper — follow these]
**New Dependencies**: [explicit list; empty unless justified — Implementer may not add others]

## Approach

[Narrative: how the requirements map onto the codebase. Reference analysis findings,
matched patterns (PAT-NNN), and standard clauses that constrain the approach.]

### Pattern & Standards Map

| Requirement | Pattern | Exemplar | Standard clause |
|-------------|---------|----------|-----------------|
| FR-001 | PAT-NNN / none | exemplars/... / none | standards/<file>.md §<RULE-ID> |

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [...] | L/M/H | L/M/H | [...] |

## Verification Strategy

**Test command**: [from targets/<id>.yml]
**New tests required**: [behaviors that must gain coverage]
**Regression surface**: [existing suites that must stay green]

## Phase Outline

1. [contracts/interfaces first]
2. [core logic]
3. [integration]
4. [tests hardening]
5. [docs]

## Confidence Estimate

**Planning confidence**: 0.XX — [basis: pattern coverage, exemplar availability, analysis confidence]
Below 0.70 → STOP and escalate (Principle V), do not proceed to /throughline.tasks.
