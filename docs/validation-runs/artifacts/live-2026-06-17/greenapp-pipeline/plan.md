# Plan: greenapp / tempconv
**Slice**: 001-greenapp-tempconv | **Date**: 2026-06-17 | **Analysis confidence**: 0.90

## Summary

Build a minimal Python project scaffold, then add `tempconv.py` with the `c_to_f` function.

## New Dependencies

None. The implementation uses only Python built-ins (`isinstance`, `round`). No new packages will be added to a manifest.

## Architecture Decisions

**ADR-001**: Source file location. Place `tempconv.py` at the project root (flat layout). The project is a simple utility library with one module. A package directory (e.g., `greenapp/tempconv.py`) would add a `__init__.py` import layer for no benefit at this scale. This matches ENG-04 (land files where convention puts them; for a new project, minimal is the convention).

**ADR-002**: Test framework. Use `unittest` (Python stdlib). This keeps the project dependency-free (no `pytest` install required) and is consistent with other Python utility targets in this workspace (pricetag uses `unittest`). Standards require using the existing framework (TST-05); for a new project, this is the lowest-complexity compliant choice.

**ADR-003**: Test command. `python -m unittest discover -s tests`. This is the standard discovery invocation for `unittest` with tests under `tests/`. No config file needed.

## Phase 1 — Scaffold

1. Create `tests/` directory with an empty `__init__.py`.
2. Create a minimal `tests/test_tempconv.py` (one placeholder test that passes).
3. Verify `python -m unittest discover -s tests` exits 0.
4. Update `targets/greenapp.yml` with `test_command`.

## Phase 2 — Implement

5. Create `tempconv.py` with `c_to_f(celsius)` (FR-1, FR-2, FR-3).
6. Run `test_command` to confirm no regressions from scaffold.

## Phase 3 — Test

7. Extend `tests/test_tempconv.py` with full coverage tests (all FRs and edge cases).
8. Run test suite; record evidence.

## Phase 4 — Review

9. Reviewer checks all layers; issues verdict.

## Risk Register

Carried from analysis: RSK-01 (bool subtype), RSK-02 (no test runner — mitigated: stdlib), RSK-03 (no manifest — no audit needed).

## Rollback Procedure

Branch `sdd/tempconv` in `X:/Work/greenapp`. To roll back: `git checkout master && git branch -D sdd/tempconv`. The master branch has no commits yet; the branch contains all scaffold and feature work.

## Plan Confidence

0.90 (analysis confidence; plan adds no new uncertainty).
