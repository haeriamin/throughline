# Standards Summary
**Maintained by**: Archivist | **Last ingest**: 2026-06-15T00:00:00Z
**Sources**: engineering-standards.md (STD-001), api-design.md (STD-002), security-policy.md (STD-003), testing-standards.md (STD-004), delivery-standards.md (STD-005)

> Compiled from `/standards/**` by `/dev.ingest-standards`. Citations are authoritative;
> the Reviewer re-reads source, not this summary.

## STD-001 Engineering (Applies To: All)

| Rule | Severity | Requirement | Tool? | Source |
|------|----------|-------------|-------|--------|
| ENG-01 | WARNING | Single responsibility per module | — | engineering-standards.md §ENG-01 |
| ENG-02 | BLOCKING | Explicit error handling; no swallowed errors | — | engineering-standards.md §ENG-02 |
| ENG-03 | WARNING | No dead or commented-out code | linter dead-code | engineering-standards.md §ENG-03 |
| ENG-04 | WARNING | Project layout follows stack convention | — | engineering-standards.md §ENG-04 |
| ENG-05 | BLOCKING | Dependencies are deliberate (justified) | — | engineering-standards.md §ENG-05 |
| ENG-06 | INFO | Names reveal intent | — | engineering-standards.md §ENG-06 |

## STD-002 API Design (Applies To: API)

| Rule | Severity | Requirement | Tool? | Source |
|------|----------|-------------|-------|--------|
| API-01 | BLOCKING | Consistent resource naming (plural nouns, no verbs) | — | api-design.md §API-01 |
| API-02 | BLOCKING | Pagination on collection endpoints | — | api-design.md §API-02 |
| API-03 | BLOCKING | Structured error responses (code/message envelope) | — | api-design.md §API-03 |
| API-04 | BLOCKING | Input validation at the boundary | — | api-design.md §API-04 |
| API-05 | WARNING | Versioning and compatibility | — | api-design.md §API-05 |

## STD-003 Security (Applies To: All)

| Rule | Severity | Requirement | Tool? | Source |
|------|----------|-------------|-------|--------|
| SEC-01 | BLOCKING | No secrets in source | secret scanner | security-policy.md §SEC-01 |
| SEC-02 | BLOCKING | Parameterized queries only | SAST | security-policy.md §SEC-02 |
| SEC-03 | BLOCKING | Output encoding / injection defense | — | security-policy.md §SEC-03 |
| SEC-04 | WARNING | Least-privilege data exposure | — | security-policy.md §SEC-04 |
| SEC-05 | BLOCKING | Sensitive-domain changes are human-led (CRITICAL) | — | security-policy.md §SEC-05 |

## STD-004 Testing (Applies To: All)

| Rule | Severity | Requirement | Tool? | Source |
|------|----------|-------------|-------|--------|
| TST-01 | BLOCKING | Changed behavior gets coverage | — | testing-standards.md §TST-01 |
| TST-02 | WARNING | Right test layer for the behavior | — | testing-standards.md §TST-02 |
| TST-03 | BLOCKING | Tests are deterministic and isolated | — | testing-standards.md §TST-03 |
| TST-04 | INFO | Behavior-named, AAA-structured | — | testing-standards.md §TST-04 |
| TST-05 | BLOCKING | One test framework per target | — | testing-standards.md §TST-05 |
| TST-06 | BLOCKING | Failing tests are information (never skip-to-green) | — | testing-standards.md §TST-06 |
| TST-07 | BLOCKING | Cover the spec's negative space (test each reject/raise rule) | — | testing-standards.md §TST-07 |
| TST-08 | BLOCKING | Expected values come from the spec, not the code | — | testing-standards.md §TST-08 |

## STD-005 Delivery & Operability (Applies To: All)

| Rule | Severity | Requirement | Tool? | Source |
|------|----------|-------------|-------|--------|
| DEL-01 | BLOCKING | Dependency vulnerability audit | npm/pip/cargo audit | delivery-standards.md §DEL-01 |
| DEL-02 | WARNING | Static security scan when available | SAST | delivery-standards.md §DEL-02 |
| DEL-03 | WARNING | Observability at boundaries | — | delivery-standards.md §DEL-03 |
| DEL-04 | WARNING | CI runs the quality loop | — | delivery-standards.md §DEL-04 |
| DEL-05 | INFO | Performance-sensitive paths are measured | — | delivery-standards.md §DEL-05 |

**Totals**: 29 rules (16 BLOCKING, 9 WARNING, 4 INFO) across 5 standards. No conflicts detected at ingest.
