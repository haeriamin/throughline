# Testing Standards
**Standard ID**: STD-004
**Effective Date**: 2026-06-15
**Applies To**: [All]

## Rules

### Rule TST-01: Changed Behavior Gets Coverage
**Severity**: BLOCKING
**Description**: Every behavior added or modified by a slice has at least one automated test exercising it. (This feeds `test_evidence` in the constitutional confidence formula.)
**Check**: The slice's coverage table has no MISSING row without a recorded reason.

### Rule TST-02: Right Layer for the Behavior
**Severity**: WARNING
**Description**: Pure logic → unit tests; component wiring/IO → integration tests; user-visible success criteria → end-to-end only where the SC demands it. Don't e2e what a unit test proves.
**Check**: Test layer matches the behavior's nature; no business-rule assertions living only in e2e suites.

### Rule TST-03: Tests Are Deterministic and Isolated
**Severity**: BLOCKING
**Description**: No reliance on wall-clock timing, execution order, shared mutable state, or live external services. External boundaries are faked/stubbed at the seam.
**Check**: Suite passes repeatedly and in any order; no network calls in unit tests.

### Rule TST-04: Behavior-Named, AAA-Structured
**Severity**: INFO
**Description**: Test names state the behavior ("rejects expired token"), bodies follow Arrange-Act-Assert with one behavioral focus each.
**Check**: No `test1`/`testMethodX` names; no multi-behavior mega-tests.

### Rule TST-05: One Test Framework per Target
**Severity**: BLOCKING
**Description**: Extend the target's existing test framework and layout; introducing a parallel framework requires an ADR.
**Check**: New test files use the framework and location conventions already present in the target.

### Rule TST-06: Failing Tests Are Information
**Severity**: BLOCKING
**Description**: Never delete, skip-mark, or loosen a failing test to make a suite green. Failures are recorded in the test report and routed to review.
**Check**: No new `skip`/`xfail`/commented assertions on tests related to the slice.

### Rule TST-07: Cover the Specification's Negative Space
**Severity**: BLOCKING
**Description**: Derive tests rule-by-rule from the enumerated specification, not only from the happy path. In particular, every rule that says an input must be rejected (raise / error / refuse) gets a test asserting that rejection. Free-form or "test the edges" prompting reliably skips these non-obvious invalid-input rules, and they are exactly where one-shot code most often fails. *Evidence: deriving one test per spec rule lifts final correctness by +38 points over an equally-informed edge-prompted baseline and catches the validation defects that baseline misses, replicated across three model families (project research track). The value concentrates on negative space: on a public benchmark of well-specified algorithmic problems (HumanEval+, judged by EvalPlus's own oracle across five model families), where inputs are assumed valid and the few bugs are pure logic, grounded and free-form tests detect equally — so this rule pays off precisely where the spec has invalid-input/edge rules to enumerate, and is neutral where it does not.*
**Check**: Each "must reject / must raise" rule in the cited spec maps to at least one test exercising it; the slice's tests are not happy-path only.

### Rule TST-08: Expected Values Come From the Spec, Not the Code
**Severity**: BLOCKING
**Description**: A test's expected output is justified by a specification rule, never read off the implementation under test. A tester that infers expectations from the candidate code certifies the bug as intended behaviour; one that invents expectations beyond the spec raises false alarms on correct code. *Evidence: grounding the tester in the spec gave 0% false alarms versus 33% for an ungrounded edge-tester that hallucinated out-of-spec expectations (project research track).*
**Check**: Each expected value traces to the rule it comes from; no expected value is copied from the implementation, and no assertion goes beyond what the spec states.
