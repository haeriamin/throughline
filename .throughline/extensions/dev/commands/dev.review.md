# /dev.review

**Agent**: Reviewer
**Reads**: `<target>/.throughline/specs/NNN-*/{spec,plan,design,tasks}.md`, the implementation report (`<target>/.throughline/specs/NNN-*/implementation.md`), the test report (`<target>/.throughline/review-reports/<slice>-tests.md`), target diff (branch vs base), `/standards/**` and `<target>/.throughline/standards/**` DIRECTLY (not wiki summaries), `/exemplars/**` and `<target>/.throughline/exemplars/**` for cited bases
**Writes**: `<target>/.throughline/review-reports/<slice>-review.md`; on PASS/CONDITIONAL_PASS, the durable done record `<target>/.throughline/work-queue/completed/<slice>.md` (copied from the global live work item, which is then cleared); append to `<target>/.throughline/wiki/log.md`
**Never writes**: target source, `/standards/**`, `/exemplars/**`, `wiki/**` content (framework or target) except the applicable log

## Preconditions

- Implementation report exists.
- **Fresh test report exists** (`<target>/.throughline/review-reports/<slice>-tests.md` with a
  source hash matching the current branch state). Missing/stale → invoke `/dev.test` first;
  if it cannot run, proceed with `test_evidence = 0`.

## Steps

1. **Bootstrap** (Principle II — full sequence).
2. **Independence rule**: re-read every cited standard clause from its source (`/standards/` or,
   for a target-local rule, `<target>/.throughline/standards/`) and every cited exemplar from
   `/exemplars/` or `<target>/.throughline/exemplars/` — never trust the wiki summary or
   the Implementer's paraphrase (this is the framework's defense against summary drift).
3. **Layer 1 — Structural**: lint state, naming conventions, file organization,
   forbidden constructs, no merge-conflict markers, no stray debug output, every
   `DEV-STATUS: PARTIAL` annotation has a matching exception-registry
   (`<target>/.throughline/wiki/exception-registry.md`)/escalation entry.
4. **Layer 2 — Behavioral**: test report verdicts; changed-behavior coverage table;
   regression status of pre-existing suites.
5. **Layer 3 — Standards compliance**: run `compliance-checker` over the diff; verify
   each Decision Record's citations are real AND apposite (the clause actually mandates
   or permits the change made).
6. Score (Principle V — fixed formula):
   ```
   confidence = 0.40·test_evidence + 0.35·standards_compliance + 0.25·spec_alignment
   ```
   - test_evidence: changed behaviors covered by passing tests / changed behaviors (0 if no valid report)
   - standards_compliance: applicable clauses satisfied / applicable clauses
   - spec_alignment: in-scope FRs demonstrably satisfied / in-scope FRs
7. Verdict: PASS ≥ 0.85 | CONDITIONAL_PASS 0.70–0.84 | FAIL < 0.70 or any Layer-1 fail.
8. Write `<target>/.throughline/review-reports/<slice>-review.md`: verdict, the three sub-scores
   with their numerators/denominators, itemized findings (each with file:line + standard
   clause), retry guidance on FAIL, flagged items on CONDITIONAL_PASS.
9. Append to `<target>/.throughline/wiki/log.md`.
10. Routing: FAIL → back to `/dev.implement` with the findings (max 2 retries, then
    `/dev.review-escalated`). PASS/CONDITIONAL_PASS → Orchestrator copies the final work item
    to `<target>/.throughline/work-queue/completed/<slice>.md` (the durable done record) and
    clears the global live work item from `work-queue/in-progress/`; merging/pushing remains a
    human action (Principle VI).

## Exit Criteria

- Review report exists with verdict, scores, and itemized, cited findings.

## Failure Modes

- **Citation fraud** (Decision Record cites a clause that doesn't exist or doesn't apply)
  → automatic FAIL regardless of score (Principle III), finding marked CITATION-INVALID.
- **Diff unavailable** (branch state lost) → FAIL with reconstruction guidance.
