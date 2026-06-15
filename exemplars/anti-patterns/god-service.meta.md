# Exemplar: god-service
**Kind**: anti-pattern
**Pattern Class**: Service Decomposition
**Languages**: [typescript]
**Standard References**: standards/engineering-standards.md §ENG-01, standards/engineering-standards.md §ENG-02, standards/api-design.md §API-02, standards/api-design.md §API-03, standards/api-design.md §API-04, standards/security-policy.md §SEC-01, standards/security-policy.md §SEC-02, standards/security-policy.md §SEC-04
**Complexity**: LOW
**Description**: A single class owning validation, persistence, formatting, transport, and
secrets — nine annotated violations. Use to recognize the smell and to justify decomposition
findings in reviews; never as an implementation basis.
**Tags**: anti-pattern, god-object, service, sql-injection, secrets, error-swallowing, decomposition, typescript
