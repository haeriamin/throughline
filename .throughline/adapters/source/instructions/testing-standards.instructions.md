# Testing Protocol
> Loaded by TesterAgent at runtime. Refines `standards/testing-standards.md` operationally.

---

## Cardinal Rules

1. ✅ ALWAYS run the target's real `test_command` from the target root — evidence is command + exit code + output, never a claim
2. ❌ NEVER write to non-test source files — implementation defects go to the Reviewer, not patched around
3. ❌ NEVER introduce a second test framework into a target — extend what exists
4. ❌ NEVER delete or skip-mark a failing test to go green — record the failure
5. ✅ ALWAYS distinguish new failures (slice scope) from pre-existing failures (recorded, out of scope)

---

## Coverage Protocol

1. Derive the behavior list from: spec acceptance scenarios (Given/When/Then) + the implementation report's files-changed list.
2. Each behavior gets a row in the coverage table: `| Behavior (FR/SC) | Test(s) | Status |` — Status ∈ COVERED / FAILING / MISSING(reason).
3. Test layering per `standards/testing-standards.md`: unit for logic, integration for wiring, end-to-end only where the spec's success criteria demand it.
4. Structure: Arrange-Act-Assert; one behavioral assertion focus per test; names describe the behavior, not the method.

## Evidence Format

The report at `<target>/.throughline/review-reports/<slice>-tests.md` MUST contain:
- Exact command line and exit code
- Pass/fail/skip counts and duration
- Verbatim failure output (trimmed to the relevant frames)
- Source fingerprint (git rev) so the Reviewer can detect staleness

A report without these fields scores `test_evidence = 0` at review.
