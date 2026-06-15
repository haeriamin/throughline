# Exemplar: paginated-endpoint
**Kind**: good
**Pattern Class**: REST Pagination
**Languages**: [typescript]
**Standard References**: standards/api-design.md §API-02, standards/api-design.md §API-03, standards/api-design.md §API-04, standards/engineering-standards.md §ENG-02, standards/security-policy.md §SEC-04
**Complexity**: LOW
**Description**: Cursor-paginated collection endpoint with boundary validation, a structured
error envelope, explicit DTO field selection, and error propagation to middleware. The
`OrderReader` port keeps IO behind an interface so the handler stays unit-testable.
**Tags**: rest, api, pagination, cursor, validation, zod, express, error-envelope, dto, typescript
