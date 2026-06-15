# Pattern Library
**Maintained by**: Archivist | **Last ingest**: 2026-06-19T03:00:00Z
**Sources**: exemplars/good/api/paginated-endpoint.ts, exemplars/good/python/validated-operation.py, exemplars/anti-patterns/god-service.ts

> Compiled from `/exemplars/**` by `/dev.ingest-exemplars`. PAT ids are stable.

## Pattern: Cursor-Paginated Collection Endpoint
**Pattern ID**: PAT-001
**Class**: REST Pagination
**Exemplars**: [[exemplars/good/api/paginated-endpoint.ts]]
**Anti-patterns**: [[exemplars/anti-patterns/god-service.ts]] (unbounded list + raw dump)
**Standard Basis**: api-design.md §API-02, §API-03, §API-04; engineering-standards.md §ENG-02; security-policy.md §SEC-04
**When to apply**: Any endpoint returning a collection of resources.
**Implementation Steps** (derived from the exemplar):
1. Validate query params at the boundary (`limit` bounded 1–100, optional `cursor`) — API-04.
2. Keep IO behind a reader port/interface so the handler is unit-testable without binding a port.
3. Return a page envelope `{ items, next_cursor }` — never the whole collection (API-02).
4. On bad input, return a structured error envelope `{ code, message, details? }` with the right status (API-03).
5. Expose explicit DTO fields, not raw entities (SEC-04). Propagate unexpected errors, never swallow (ENG-02).
**Confidence typical range**: 0.80–0.95 (strong exemplar, deterministic shape).

## Pattern: Service Decomposition (cautionary)
**Pattern ID**: PAT-002
**Class**: Service Decomposition
**Anti-patterns**: [[exemplars/anti-patterns/god-service.ts]]
**Standard Basis**: engineering-standards.md §ENG-01, §ENG-02; security-policy.md §SEC-01, §SEC-02, §SEC-04; api-design.md §API-02, §API-03, §API-04
**When to apply**: Recognizing/rejecting a single unit that mixes validation, persistence, formatting, transport, and secrets. Split by responsibility; never use the anti-pattern as a basis.
**Confidence typical range**: n/a (recognition only).

## Pattern: Spec-Grounded Input Validation
**Pattern ID**: PAT-003
**Class**: Spec-Grounded Input Validation
**Exemplars**: [[exemplars/good/python/validated-operation.py]]
**Standard Basis**: engineering-standards.md §ENG-01, §ENG-02, §ENG-06; testing-standards.md §TST-07, §TST-08
**When to apply**: Any pure operation that must reject bad inputs before it computes — list each "must reject" rule from the spec and give every rule its own guard.
**Implementation Steps** (derived from the exemplar):
1. Name each rule the input must pass (R1..Rn) up front, then check every rule before doing any work.
2. Check type and range first. Screen out `bool` before the positive-number check, because `bool` is a subclass of `int` — reject 0, negatives, and non-integers (R1).
3. Check that referenced things exist next (the item id is present in the stock map) and raise on a miss (R2).
4. Check domain limits (the amount does not exceed what is available — no oversell) and raise instead of allowing a bad state (R3).
5. On every rejected input, raise `ValueError` with a message that names the rule. Never coerce the value or carry on silently (ENG-02).
6. Copy before you change: build and return a new value; never mutate the caller's argument (R4).
7. Keep one guard per "must reject" rule and pair one rejection test to each guard (TST-07); take expected values from the spec, not the code (TST-08); keep one clear responsibility (ENG-01) and intent-revealing names (ENG-06).
**Confidence typical range**: 0.80–0.95 (small, deterministic, pure operation with an explicit spec).

**Inventory**: 3 exemplars on disk — 2 good (paginated-endpoint.ts, validated-operation.py) + 1 anti-pattern (god-service.ts) — across 3 pattern classes; 3 PAT entries (PAT-001..PAT-003). Every exemplar pair is ingested; no gaps.
