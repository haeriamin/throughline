# /dev.audit

**Agent**: Auditor
**Reads**: `targets/*.yml` and each registered target's `<target>/.throughline/**` (its `review-reports/`, `specs/NNN-*/implementation.md` Decision Records, `wiki/decision-registry.md`), the global `audit/**`, `work-queue/**`, framework `wiki/**`
**Writes**: `audit/portfolio-summary.md`, `audit/recommendations.md` (both at the framework root); append to the framework `wiki/log.md`
**Never writes**: target source, `/wiki/**` content (recommendations only), `/standards/**`, `/exemplars/**`

## Arguments

```
/dev.audit [target-id]      # omit for full portfolio
```

## Steps

1. **Bootstrap** (Principle II, steps 1–3).
2. Aggregate all review + test reports from every registered target's
   `<target>/.throughline/review-reports/` (iterate `targets/*.yml`; scoped to the target if
   given) plus the global `audit/`: verdict counts,
   mean confidence per sub-score, retry rates, escalation rate. **State the dataset size**
   (targets, completed slices, reports) up front and carry it into every claim — an audit over
   1 slice and an audit over 50 must not read the same. Guard every rate: a per-target
   denominator of 0 reports yields "n/a (no reports)", never a division. When a review's
   confidence carries an independence caveat (e.g. single-agent self-review — see
   `docs/runtimes/copilot.md`), label the aggregated mean **provisional** rather than laundering
   it into a portfolio health number.
3. **Systemic patterns**: findings that recur across ≥ 3 slices (same standard clause
   violated, same sub-score dragging) → name the pattern, cite instances. **Below the ≥ 3
   threshold** (a 1–2 slice portfolio) no systemic claim is possible: say so explicitly
   ("insufficient data for systemic analysis: N slice(s)") — never emit a bare "no systemic
   issues" that reads identical to a clean large portfolio. Report single occurrences as
   "watch items", not patterns.
4. **Exemplar gaps** — two detectors, run both:
   (a) **Missing**: pattern classes cited with a "none exists" exemplar basis ≥ 3 times across
   Decision Records — the **Implementation** Decision Records in each target's
   `<target>/.throughline/specs/NNN-*/implementation.md` *and* any ADRs in that target's
   `<target>/.throughline/wiki/decision-registry.md` (plus the framework
   `wiki/decision-registry.md` for global-scoped ADRs; registries are empty for design-less
   lanes, so read all).
   (b) **Un-ingested**: reconcile `/exemplars/good|anti/**` on disk against the `Source`/`PAT`
   entries in `wiki/pattern-library.md` — an exemplar that exists but was never ingested (or a
   Decision Record that had to cite an exemplar **by file path instead of a `PAT-NNN`**) is a
   gap regardless of count. This is the common real case the ≥ 3 "none exists" filter cannot see.
5. **Stale-knowledge check**: slices completed before the latest
   `/dev.ingest-standards` run that cite since-changed rules → re-validation candidates.
6. Write `audit/portfolio-summary.md` from
   `.throughline/templates/portfolio-summary-template.md` (dataset size, an overall **portfolio
   verdict** — `HEALTHY` / `AT-RISK` / `INSUFFICIENT-DATA` — verdict table per target, trends,
   systemic issues, gaps, re-validation candidates) and `audit/recommendations.md` from
   `.throughline/templates/recommendations-template.md` (actions for the Archivist/human:
   exemplars to curate or ingest, standards to clarify, wiki pages to update). **Trends** need
   ≥ 2 time points — omit the section (don't fabricate a trend) below that. The Auditor
   recommends; only the Archivist writes wiki content. Both portfolio files are the global
   audit roll-up and stay at the framework `audit/` root (per-slice test/review reports
   now live in each `<target>/.throughline/review-reports/`); the dashboard groups the root files
   under the portfolio (`-`) target — keep that convention.
7. Append to `wiki/log.md` (insert before any trailing comment block, as in `/dev.lint-wiki`).

## Exit Criteria

- Both artifacts written; the dataset size is stated; every systemic claim cites ≥ 3 concrete
  instances; a portfolio with < 3 slices reports `INSUFFICIENT-DATA` for systemic analysis
  rather than an implied clean bill of health.

## Failure Modes

- **No reports yet** → write an empty-state summary (don't fail); note bootstrap status.
- **Contradictory reports for one slice** (e.g., two reviews) → use the latest by
  timestamp; flag the duplication.
