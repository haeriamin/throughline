# Design: greenapp / tempconv
**Slice**: 001-greenapp-tempconv | **Date**: 2026-06-17 | **Status**: Approved (user's explicit pipeline instruction treated as approval; noted per `/dev.feature` §step 5)

## Project Layout

```
X:/Work/greenapp/
  tempconv.py          # domain module — sole source file
  tests/
    __init__.py        # empty; marks tests/ as a package for unittest discovery
    test_tempconv.py   # test suite
```

This is a flat layout. The module lives at the project root, not inside a sub-package. This is the minimal layout for a single-module Python utility.

## Module Design: tempconv.py

Public API: one function.

```
c_to_f(celsius) -> float
```

- Parameter: `celsius` — expected to be `int` or `float`.
- Returns: `float` — the Fahrenheit equivalent, rounded to 1 decimal place.
- Raises: `TypeError` — if `celsius` is not `int` or `float`.

### Implementation Shape

```
def c_to_f(celsius):
    if not isinstance(celsius, (int, float)):
        raise TypeError(...)
    return round(celsius * 9 / 5 + 32, 1)
```

Notes:
- `bool` is a subclass of `int` in Python, so `isinstance(True, int)` is `True`. Booleans pass the type check. The spec does not mention booleans, so this is correct behavior. See RSK-01 in the analysis.
- No imports needed. All operations are built-in.

## Test Design: tests/test_tempconv.py

One test class: `TestCToF(unittest.TestCase)`.

Test methods (one behavior per method — TST-04):
- `test_freezing_point` — `c_to_f(0)` returns `32.0`
- `test_boiling_point` — `c_to_f(100)` returns `212.0`
- `test_absolute_zero` — `c_to_f(-273.15)` returns `-459.7`
- `test_rejects_string` — `c_to_f("hot")` raises `TypeError`
- `test_rejects_numeric_string` — `c_to_f("0")` raises `TypeError`
- `test_rejects_none` — `c_to_f(None)` raises `TypeError`
- `test_rejects_list` — `c_to_f([0])` raises `TypeError`

Each expected value is derived from the spec or the formula, not from the implementation (TST-08).

## Standards Mapping

| Standard Clause | Application |
|----------------|-------------|
| ENG-01 | `tempconv.py` does only one thing: temperature conversion. No IO mixed in. |
| ENG-04 | Files land in the layout described here (new convention for new project). |
| TST-02 | Business rules are tested at the unit level. |
| TST-03 | Suite is deterministic; no network calls. |
| TST-04 | One behavior per test method; descriptive names. |
| TST-07 | Each "must raise" rule (FR-2) maps to multiple tests. |
| TST-08 | Expected values come from formula / spec constants, not the implementation. |

## ADR Index

- ADR-001: Flat layout (see plan.md)
- ADR-002: `unittest` framework (see plan.md)
- ADR-003: `python -m unittest discover -s tests` (see plan.md)
