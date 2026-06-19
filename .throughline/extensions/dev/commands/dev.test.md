# /dev.test

**Agent**: Tester
**Reads**: `<target>/.throughline/specs/NNN-*/{spec,plan,tasks}.md`, the implementation report (`<target>/.throughline/specs/NNN-*/implementation.md`), `targets/<id>.yml`, target source (read), `standards/testing-standards.md` + `<target>/.throughline/standards/testing-standards.md` (via skill)
**Writes**: test files at the target (test directories only); `<target>/.throughline/review-reports/<slice>-tests.md`; append to `<target>/.throughline/wiki/log.md`
**Never writes**: non-test target source, `/standards/**`, `/exemplars/**`

## Preconditions

- Implementation report exists for the slice.
- `targets/<id>.yml` has a non-empty `test_command` (else: establish one as the first
  action, via `/dev.target update`, citing `standards/testing-standards.md`).

## Steps

1. **Bootstrap** (Principle II) — work from the slice's analysis + plan + implementation report (bootstrap economy); no need to re-read the full wiki for a slice already analyzed.
2. Map changed behavior: from the implementation report's files-changed list and the
   spec's acceptance scenarios, enumerate behaviors requiring coverage.
3. Use the `test-scaffolder` skill to generate/extend tests per
   `standards/testing-standards.md` (layering, naming, AAA structure). Follow the
   target's existing test framework and layout — never introduce a second framework.
4. Run the full `test_command` from the target root. Capture: exact command, exit code,
   pass/fail/skip counts, duration, and failure output verbatim.
5. If failures are in tests THIS slice added: fix the tests if the implementation is
   correct per spec; if the implementation is wrong, do NOT patch around it — record the
   failure for the Reviewer. Pre-existing failures: record as such, out of scope.
6. Write `<target>/.throughline/review-reports/<slice>-tests.md`:
   ```markdown
   # Test Report: <slice>
   **Target**: <id> | **Date**: ... | **Branch**: sdd/<slice> | **Source hash**: <git rev>
   **Command**: `<test_command>` | **Exit code**: N
   **Results**: X passed / Y failed / Z skipped (W new tests added)
   ## Coverage of changed behavior
   | Behavior (FR/SC) | Test(s) | Status |
   ## Failures (verbatim output)
   ## Pre-existing failures (out of scope)
   ```
7. Append to `<target>/.throughline/wiki/log.md`.

## Exit Criteria

- Test report exists with real execution evidence (command + exit code — never claimed
  results). Every changed behavior has a row in the coverage table (status may be MISSING
  — that honesty is what the Reviewer prices into `test_evidence`).

## Failure Modes

- **Test command cannot run** (broken env) → report with exit code and output; Reviewer
  scores `test_evidence = 0`; do not fake green.
- **Coverage impossible for a behavior** (e.g., needs live external service) → mark
  MISSING with reason; suggest the seam needed; candidate for escalation if BLOCKING.
