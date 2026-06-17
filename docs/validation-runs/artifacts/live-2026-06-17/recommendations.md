# Recommendations
**Auditor** | **Run date**: 2026-06-17 | **Scope**: full portfolio
**Audience**: Archivist, human maintainers
**Source**: review-reports/portfolio-summary.md (same audit run)

These are recommendations only. The Auditor does not write wiki content, exemplars, or standards. All items below require human or Archivist action.

---

## R-001 Curate a Python input-validation exemplar (HIGH)

**Gap**: GAP-001 from portfolio-summary.md §4.
**Pattern class**: Pure Python function with typed input validation (guard clause raising `TypeError` or `ValueError`).
**Instances without exemplar**:
1. `work-queue/in-progress/greenapp-tempconv-analysis.md` — "no exemplar covers a pure Python arithmetic function with type guard"
2. `work-queue/in-progress/greenapp-tempconv-implementation.md` — "Exemplar basis: none exists — Python project scaffold"
3. `work-queue/in-progress/pricetag-full-analysis.md` — "No exemplar covers this [pure-Python conditional guard]"

**Recommended action**: Place a curated exemplar under `exemplars/good/python/` (e.g., `input-validation-function.py`). The exemplar should show:
- A function that validates its arguments before computing
- `isinstance` check raising `TypeError` for wrong type
- Range or constraint check raising `ValueError` for out-of-range values
- One test class with one method per edge case (TST-04, TST-07 compliant)
- Expected values derived from the spec or a formula, not from the implementation (TST-08)

After placing the file, run `/dev.ingest-exemplars` to register it as PAT-003 in the pattern library.

**Benefit**: Future slices in the same pattern class (all three current targets fit this shape) will start with a higher exemplar confidence and cleaner TST-07/TST-08 citations.

---

## R-002 Add pricetag review reports to review-reports/ (MEDIUM)

**Finding**: Two completed pricetag slices — `discounted-total` and `reject-percent-gt-100` — have no files under `review-reports/pricetag/`. Their verdicts and confidence scores exist only in `wiki/log.md`.

**Affected log entries**:
- 2026-06-17T00:00:00Z — `dev.feature --express` pricetag PASS 1.00 (discounted-total)
- 2026-06-17T12:50:00Z — `dev.feature --micro` pricetag PASS 1.00 (reject-percent-gt-100)

**Recommended action**: Ask the Orchestrator or Reviewer to write formal review reports for these slices retrospectively, or confirm in the log that the inline micro-lane review supersedes a dedicated report. If the micro lane intentionally skips separate report files, update the runbook (`dev.audit.md` and `dev.feature.md`) to say so explicitly so future audits know where to look.

---

## R-003 Register ADRs in the decision-registry (LOW)

**Finding**: The decision-registry (`wiki/decision-registry.md`) table is empty. Three ADRs (ADR-001 through ADR-003) were recorded in `specs/001-greenapp-tempconv/plan.md` but never registered centrally.

**Recommended action**: Ask the Archivist to add the three greenapp-tempconv ADRs to `wiki/decision-registry.md`. Going forward, the Architect or Orchestrator should register each ADR at plan time, not only inside the slice's plan.md.

---

## R-004 Consider adding CI and a linter to at least one target (LOW)

**Finding**: All three targets have no CI and no linter. DEL-04 and DEL-02 are consistently N/A across the portfolio. This is not a standards violation, but it is a portfolio-wide infrastructure gap.

**Recommended action**: This is a human infrastructure decision, not an agent action. Consider adding a minimal CI workflow (e.g., GitHub Actions) and a linter (e.g., `flake8` or `ruff`) to at least one target as a pilot. Once configured, a future `/dev.ingest-standards` or target update can set `lint_command` in the target's `.yml` file. This would allow DEL-02 and DEL-04 to be substantively satisfied rather than vacuously N/A.

---

## R-005 Resolve the pricetag / user-auth clarification questions (HIGH)

**Finding**: Slice 001-pricetag-user-auth is paused at the clarify step. Three questions are open in `specs/001-pricetag-user-auth/spec.md`:
- Q1: Authentication surface (CLI, API, or standalone library)
- Q2: Persistence backend (flat file, SQLite, in-memory)
- Q3: Stdlib-only or third-party hashing library allowed

**Recommended action**: Human answers all three questions. After clarification, the pipeline resumes at the plan step. The slice is CRITICAL (SEC-05); the human must also lead and approve the design before implementation proceeds. No agent action is possible until the human responds.

---

## R-006 Consider a Python scaffold exemplar for greenfield projects (WATCH)

**Finding**: The "Python project scaffold" pattern (flat layout, unittest, discover command) appeared in 2 decision record entries for the greenapp-tempconv slice. It has not yet reached the ≥ 3 instance threshold for a listed exemplar gap.

**Recommended action**: Watch this pattern. If one more greenfield Python slice is created without an exemplar, it will cross the threshold. Proactively curating a scaffold exemplar under `exemplars/good/python/project-scaffold/` before that point would prevent the gap from forming.

---

## R-007 Clarify micro-lane artifact requirements in the runbook (LOW)

**Finding**: The micro-lane pipeline (used for pricetag slices) appears to produce fewer artifacts than the standard lane. Specifically, it does not always produce dedicated files under `review-reports/<target>/`. This created an artifact trail gap that the Auditor had to resolve using `wiki/log.md` as the authoritative source.

**Recommended action**: Clarify in `dev.feature.md` or a micro-lane section of the runbook whether micro-lane slices are expected to write to `review-reports/<target>/` or whether the log entry alone is sufficient. If the log is sufficient, document this so future Auditor runs know the expected artifact shape for micro-lane slices.
