# Validation run — SWE-bench Lite `pytest-dev__pytest-11143`

**Date:** 2026-06-16 · **Target:** [pytest](https://github.com/pytest-dev/pytest) @ base `6995257cf`
· **Mode:** `/dev.feature --micro` (Implementer → Tester → independent Reviewer)
· **Outcome:** ✅ **SOLVED** — the hidden benchmark test passes; no regressions.

## TL;DR

Throughline was pointed at a **real, unsolved-by-it GitHub issue** from a famous project
(pytest), given **only the bug report** (never the benchmark's hidden test). Its grounded
build→test loop produced a **one-line root-cause fix** that makes the benchmark's gold
`FAIL_TO_PASS` test pass and leaves the affected suite green (**115 passed, 1 skipped**). The
Tester independently went **beyond** the gold test — covering `int`, `float`, *and* `complex`
leading constants plus two regression guards — which is exactly the spec-completeness coverage
the framework is built to add.

## The ticket (what the agents saw)

A pytest user reported: collecting a test file whose **first expression is a number** crashes with

```
TypeError: argument of type 'int' is not iterable
```

The agents received the raw bug report only (`pytest-11143-issue.txt`). They did **not** see the
benchmark's gold patch or its hidden test.

## Setup

- Cloned pytest at the instance base commit into an isolated venv; registered it as a Throughline
  target (`targets/pytest.yml`); created the slice branch `sdd/fix-rewrite-leading-number`.
- Ran the three `--micro` phases as **separate, role-scoped agents** (same model tier, independent
  contexts), driven through the runbooks.

## Phase 1 — Implementer (grounded fix)

Found the root cause unaided: `AssertionRewriter.run` treats the first expression as a docstring
when it's any `ast.Constant` — but `ast.Constant` covers *every* literal (ints, floats, bytes,
`None`…). A leading `0` becomes `doc = 0`, then `is_rewrite_disabled` does
`"PYTEST_DONT_REWRITE" in 0` → `TypeError`.

```diff
# src/_pytest/assertion/rewrite.py  (AssertionRewriter.run)
                 expect_docstring
                 and isinstance(item, ast.Expr)
                 and isinstance(item.value, ast.Constant)
+                and isinstance(item.value.value, str)  # ticket: pytest-11143 leading-number-as-docstring
             ):
                 doc = item.value.value
```

One line, idiomatic, with a cited Decision Record. (This is the same guard the project's own gold
patch uses — reached from the ticket alone.)

## Phase 2 — Tester (evidence, generalized)

Wrote `testing/test_issue11143_leading_number.py` (5 tests, pytest's own `pytester` style) and
proved meaningfulness with a real **red → green**:

| Test (leading expression) | fix absent | fix present |
|---|---|---|
| `0` (int) | ❌ `TypeError: … 'int' …` | ✅ |
| `3.14` (float) | ❌ `TypeError: … 'float' …` | ✅ |
| `1j` (complex) | ❌ `TypeError: … 'complex' …` | ✅ |
| real `"""docstring"""` still works | ✅ | ✅ |
| `PYTEST_DONT_REWRITE` in a string still honoured | ✅ | ✅ |

`fix absent → 3 failed, 2 passed` (exit 1); `fix present → 5 passed` (exit 0).

## Objective score (the hidden benchmark oracle)

Applied the instance's gold `test_patch` and ran it against Throughline's fix:

```
FAIL_TO_PASS  testing/test_assertrewrite.py::TestIssue11140::test_constant_not_picked_as_module_docstring
              → 1 passed
regression    testing/test_assertrewrite.py  → 115 passed, 1 skipped
```

**SWE-bench Lite `pytest-11143`: resolved.**

## Phase 3 — independent Reviewer

A fresh agent that wrote none of the code or tests re-verified everything itself:

- new test → **5 passed**; `git stash` the fix → the ticket's `TypeError` reproduced (red);
  `git stash pop` → pass again.
- regression `testing/test_assertrewrite.py` → **114 passed, 1 skipped**; combined → 119 passed.
- extra edge-case probing it added on its own (`None`, `True`, `False`, `b'bytes'`) → all handled.

**Verdict: PASS · confidence 0.903** — spec_alignment 0.95, test_evidence 0.95,
standards_compliance 0.85. **No defects found.** Honest deductions: the fix adds no docstring /
CHANGELOG note (acceptable for a one-line fix). It even pinpointed the exact failing path
(`is_rewrite_disabled` doing `"PYTEST_DONT_REWRITE" in <int>`).

## Honest caveats

- **Hand-driven, not the native host runtime.** The personas ran as faithful, role-separated
  subagents driven through the runbooks — but outside a host that auto-loads `.claude/`/hooks, so
  the write-guard hooks weren't actively enforcing (the agents respected the constraints by
  instruction). The key property — Implementer, Tester, and Reviewer as **separate contexts** — was
  preserved.
- **Models used.** Implementer and Tester ran on the medium tier (Sonnet); the Reviewer ran on a
  *lighter* model (Haiku) after an API capacity spike forced the swap. So this run is a
  different-context **and** different-model check — but with a weaker reviewer than ideal. A
  reviewer at least as strong as the builder is the intended configuration.
- **One instance, `--micro` mode.** A single, small, well-scoped fix — not a benchmark sweep. The
  next step is several instances (incl. larger ones) for a real distribution.

## Takeaway

On a real issue from a well-known project, scored by the issue's own hidden test, Throughline's
grounded build→test loop produced a **correct, regression-free, root-cause** fix, and the Tester
independently broadened coverage beyond the benchmark's single case. That is the framework working
as intended on a recognized benchmark — the first concrete, objective evidence beyond the original
3-task A/B.
