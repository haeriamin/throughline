# Spec: tempconv — Temperature Conversion Module
**Slice**: 001-greenapp-tempconv | **Target**: greenapp | **Status**: Approved
**Created**: 2026-06-17 | **Lane**: standard (--express) | **Mode**: greenfield

## Scope

Add a Python module `tempconv.py` to the `greenapp` package (or as a standalone module at the project root). The module provides one public function for converting Celsius temperatures to Fahrenheit.

## Functional Requirements

### FR-1 — Convert Celsius to Fahrenheit
The function `c_to_f(celsius)` must return the Fahrenheit equivalent of the given Celsius value.

Formula: `fahrenheit = celsius * 9 / 5 + 32`

The result must be rounded to 1 decimal place before it is returned.

### FR-2 — Reject non-numeric input
If `celsius` is not a numeric type (not `int` or `float`), the function must raise `TypeError`.

Strings that look like numbers (e.g., `"0"`) are not numeric. A `TypeError` must still be raised for them.

### FR-3 — Accept edge-case numeric values
The function must handle the standard numeric edge cases correctly:
- Absolute zero: `c_to_f(-273.15)` must return `-459.7` (rounded to 1 decimal)
- Zero: `c_to_f(0)` must return `32.0`
- Boiling point: `c_to_f(100)` must return `212.0`

## Out of Scope

- Converting from Fahrenheit to Celsius.
- Kelvin or any other temperature scale.
- IO, persistence, or any network calls.
- A CLI entry point.
- Type annotations (not required by any active standard).

## Success Criteria

1. `c_to_f(0)` returns `32.0`.
2. `c_to_f(100)` returns `212.0`.
3. `c_to_f(-273.15)` returns `-459.7`.
4. `c_to_f("hot")` raises `TypeError`.
5. `c_to_f("0")` raises `TypeError`.
6. All tests pass; no test is skipped or marked xfail.

## Clarifications

None required. The description is unambiguous.

## Notes

- This is the first slice on a new greenfield Python project. The scaffold phase will establish the project layout, test framework, and quality commands before any feature code is written.
- Design is required (greenfield mode per `/dev.feature` §step 5). The user's explicit instruction to run the full pipeline is treated as design approval. This is noted here and in the design artifact.
