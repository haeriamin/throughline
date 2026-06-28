# Portfolio Summary

**Auditor**: AuditorAgent
**Scope**: [all targets | target:<id>]
**Generated**: [DATE]
**Dataset**: [N] target(s), [N] completed slice(s), [N] report(s)
**Portfolio verdict**: HEALTHY | AT-RISK | INSUFFICIENT-DATA

> Written by `/dev.audit`. Lives at the framework `audit/` root (portfolio scope; the
> dashboard groups it under the `-` target). Per-slice test and review reports now live under each
> target's `<target>/.throughline/review-reports/`; this roll-up reads across them. A portfolio
> with < 3 slices reports `INSUFFICIENT-DATA` for systemic analysis — that is **not** a clean bill
> of health.

## Outcomes per target

| Target | Slices | PASS | COND | PARTIAL | FAIL | ESCALATED | Mean confidence |
|--------|-------:|-----:|-----:|--------:|-----:|----------:|-----------------|
| [id] | [n] | | | | | | [0.00] [mark *provisional* if self-reviewed] |

## Sub-score means

| Sub-score | Mean | Notes |
|-----------|------|-------|
| test_evidence | [0.00] | |
| standards_compliance | [0.00] | |
| spec_alignment | [0.00] | |

- Retry rate: [x / n  |  n/a (no reports)]
- Escalation rate: [x / n  |  n/a (no reports)]

## Systemic patterns *(each cites ≥ 3 instances)*

- [Pattern name — cite ≥ 3 slice instances]

  _…or, below threshold:_ **Insufficient data for systemic analysis: [N] slice(s).** Single
  occurrences are listed as watch items, not patterns.

## Exemplar gaps

- **Missing** (≥ 3 Decision Records with a "none exists" basis): [class → affected slices] — or _none._
- **Un-ingested** (on disk under `/exemplars/` but absent from `wiki/pattern-library.md`, or cited
  by file path instead of a `PAT-NNN`): [exemplar path → slice] — or _none._

## Re-validation candidates

- [slice — cites a rule changed since the slice completed] — or _none._

## Trends *(omit this section below 2 audit time points)*

- [trend across ≥ 2 audits]
