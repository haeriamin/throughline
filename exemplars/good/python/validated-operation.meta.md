# Exemplar: validated-operation
**Kind**: good
**Pattern Class**: Spec-Grounded Input Validation
**Languages**: [python]
**Standard References**: standards/engineering-standards.md §ENG-01, standards/engineering-standards.md §ENG-02, standards/engineering-standards.md §ENG-06, standards/testing-standards.md §TST-07, standards/testing-standards.md §TST-08
**Complexity**: LOW
**Description**: A pure Python operation that validates each input against an explicit
specification rule before computing, raising `ValueError` on every rejected input
(never coercing or proceeding silently) and returning a new value without mutating its
arguments. One guard per "must reject" rule — the negative-space discipline (TST-07) —
with explicit error propagation (ENG-02), a single clear responsibility (ENG-01), and
intent-revealing names (ENG-06). Tests pair one rejection test to each guard.
**Tags**: python, validation, negative-space, value-error, immutability, pure-function, spec-grounded
