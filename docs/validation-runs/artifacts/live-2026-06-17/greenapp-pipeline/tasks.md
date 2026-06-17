# Tasks: greenapp / tempconv
**Slice**: 001-greenapp-tempconv | **Date**: 2026-06-17

## Phase 1 — Scaffold

- [ ] T001: Create `tests/__init__.py` (empty file; enables unittest discovery)
- [ ] T002: Create `tests/test_tempconv.py` with a single placeholder test that passes
- [ ] T003: Run `python -m unittest discover -s tests` and verify exit code 0
- [ ] T004: Update `targets/greenapp.yml` with `test_command: "python -m unittest discover -s tests"`

## Phase 2 — Implement

- [ ] T005: Create `tempconv.py` with `c_to_f(celsius)` implementing FR-1, FR-2, FR-3
- [ ] T006: Run test command to confirm placeholder test still passes (no scaffold regression)

## Phase 3 — Test

- [ ] T007: Replace placeholder test with full test suite (all success criteria + reject cases)
- [ ] T008: Run `python -m unittest discover -s tests`; record exit code, pass/fail counts, output

## Phase 4 — Review

- [ ] T009: Reviewer checks all layers; issues verdict; writes review report
