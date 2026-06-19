# Feature Specification: [FEATURE NAME]

**Slice ID**: [NNN-short-name]
**Target**: [target-id from targets/ — REQUIRED; register first via /dev.target]
**Created**: [DATE]
**Status**: Draft
**Input**: "[verbatim user description]"

> This spec lives at `<target>/.throughline/specs/[NNN-short-name]/spec.md`. Slice numbers are
> per target — each target's `.throughline/specs/` starts at `001`.

## User Scenarios & Testing *(mandatory)*

### Primary User Story
[Plain-language story: who needs what and why]

### Acceptance Scenarios
1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

### Edge Cases
- What happens when [boundary condition]?
- How does the system handle [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST [specific, testable capability]
- **FR-002**: System MUST [specific, testable capability]
- **FR-003**: Users MUST be able to [key interaction]

*Mark genuinely ambiguous points (max 3): [NEEDS CLARIFICATION: specific question]*

### Non-Functional Requirements *(include only if relevant)*
- **NFR-001**: [performance / security / accessibility / compatibility requirement]

### Key Entities *(include only if data is involved)*
- **[Entity]**: [what it represents, key attributes, relationships]

## Success Criteria *(mandatory)*

Measurable, technology-agnostic, user-focused:

- **SC-001**: [e.g., "Users can complete X in under N minutes"]
- **SC-002**: [e.g., "Zero regressions in the existing test suite"]

## Scope & Boundaries *(mandatory)*

### In Scope
- [...]

### Out of Scope
- [...]

### Dependencies
- [other slices, external services, human decisions]

### Assumptions
- [reasonable defaults adopted; document each]

## Complexity Classification *(set by /dev.analyze, confirmed in plan)*

**Class**: [LOW | MEDIUM | HIGH | CRITICAL]
**Rationale**: [criteria from ARCHITECTURE.md §12.1]
