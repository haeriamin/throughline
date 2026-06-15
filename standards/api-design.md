# API Design Standards
**Standard ID**: STD-002
**Effective Date**: 2026-06-09
**Applies To**: [API]

## Rules

### Rule API-01: Consistent Resource Naming
**Severity**: BLOCKING
**Description**: REST resources are plural nouns, kebab-case paths, no verbs in paths; actions beyond CRUD are sub-resources or explicit RPC-style endpoints documented as such.
**Check**: Paths match `/[a-z0-9-]+(/\{id\})?` segments; no `/getUser`, `/do-thing`.
**Example violation**: `GET /getUserById?id=7`
**Compliant form**: `GET /users/7`

### Rule API-02: Pagination on Collection Endpoints
**Severity**: BLOCKING
**Description**: Every collection endpoint paginates (cursor-based preferred; page/limit acceptable when the target already uses it). Unbounded list responses are forbidden.
**Check**: Collection handlers accept pagination params and return a page envelope (`items` + `next_cursor`/`total`).
**Example violation**: `GET /orders` returning all rows.
**Compliant form**: `GET /orders?cursor=...&limit=50` → `{ "items": [...], "next_cursor": "..." }`

### Rule API-03: Structured Error Responses
**Severity**: BLOCKING
**Description**: Errors return a stable envelope: machine-readable `code`, human `message`, optional `details`; HTTP status matches semantics. Internal stack traces never leak.
**Check**: Non-2xx bodies conform to the envelope; 4xx vs 5xx assignment is semantically correct.

### Rule API-04: Input Validation at the Boundary
**Severity**: BLOCKING
**Description**: All external input is validated (shape + bounds) at the API boundary before reaching domain logic.
**Check**: Each handler validates its params/body via the target's validation idiom (schema validator, typed parser); domain code never re-parses raw input.

### Rule API-05: Versioning and Compatibility
**Severity**: WARNING
**Description**: Breaking changes to a public endpoint require a version bump (path or header per the target's convention) and a deprecation note; additive changes preferred.
**Check**: No removed/renamed response field or tightened input constraint on an existing public endpoint within the same version.
