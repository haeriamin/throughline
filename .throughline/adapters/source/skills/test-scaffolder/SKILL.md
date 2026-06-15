---
name: test-scaffolder
description: Generate test skeletons for changed behavior per the target's existing framework and standards/testing-standards.md — correct layer, naming, AAA structure. Invoke with /test-scaffolder.
---

# Test Scaffolder Skill

## Purpose
Turn the changed-behavior list into runnable test skeletons that fit the target's existing test culture — so the Tester spends effort on assertions, not boilerplate archaeology.

## Algorithm

1. Read the target's test layout from the codebase map (`test_layout.framework`, `locations`) — the existing framework is law; never introduce a second one.
2. For each behavior in the coverage list (FR/SC + Given/When/Then from the spec):
   - Choose the layer per `standards/testing-standards.md` (and any target-local `.throughline/standards/testing-standards.md` override): unit (pure logic), integration (wiring/IO), e2e (only where an SC demands it).
   - Locate the conventional test file (create alongside existing patterns: `__tests__/`, `*.spec.ts`, `tests/test_*.py`, …).
   - Emit a skeleton: descriptive behavior-named test, Arrange-Act-Assert sections, the Given/When/Then mapped into them, TODO markers ONLY inside assertions still needing values.
3. Reuse existing fixtures/helpers/builders found in the test layout — duplicating a fixture is a finding.

## Output Format

Per behavior: the file path (created or extended) + the skeleton block, and a summary table `| Behavior | Layer | File | Status (NEW/EXTENDED) |`.

## Rules

- Skeletons must run (red or green) immediately — no syntax-level TODOs.
- Never mark skip/pending to dodge a hard case; a hard case is a MISSING row with a reason.
- Test names describe behavior ("rejects expired token"), not methods ("test_validate_2").

## Usage Context
Called by: Tester (step 3 of /dev.test).
