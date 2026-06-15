# General Engineering Standards
**Standard ID**: STD-001
**Effective Date**: 2026-06-09
**Applies To**: [All]

## Rules

### Rule ENG-01: Single Responsibility per Module
**Severity**: WARNING
**Description**: Each module/class/file owns one cohesive responsibility; mixed concerns (e.g., IO + business logic + formatting in one unit) must be split.
**Check**: A module's exports serve one concern; no module both performs IO and implements domain rules.
**Example violation**: A `UserService` that validates input, queries the database, and renders HTML.
**Compliant form**: `UserValidator`, `UserRepository`, `UserView` as separate units composed at the edge.

### Rule ENG-02: Explicit Error Handling
**Severity**: BLOCKING
**Description**: Errors are handled or propagated explicitly; empty catch blocks and swallowed promise rejections are forbidden.
**Check**: No catch block without (re)throw, structured logging, or a typed fallback; async call chains terminate in a handler.
**Example violation**: `try { save() } catch (e) {}`
**Compliant form**: `try { save() } catch (e) { logger.error("save failed", e); throw new PersistenceError(e); }`

### Rule ENG-03: No Dead or Commented-Out Code
**Severity**: WARNING
**Description**: Unreachable code and commented-out blocks are removed, not shipped. (Framework note: agents annotate with DEV-STATUS instead of deleting when unsure — Principle IV.)
**Check**: No commented-out statement blocks > 3 lines; no unreferenced exports.
**Tool**: The target's linter dead-code/no-unused rules when configured; its findings supersede judgment for this rule.

### Rule ENG-04: Project Layout Follows Stack Convention
**Severity**: WARNING
**Description**: Source, tests, and config follow the ecosystem's canonical layout (e.g., `src/` + `tests/` for Python packages, `src/` + `*.test.ts` co-location or `__tests__/` for Node — pick the target's existing convention).
**Check**: New files land where the target's existing convention puts them.

### Rule ENG-05: Dependencies Are Deliberate
**Severity**: BLOCKING
**Description**: New external dependencies require a named justification (plan/design ADR) — transitive convenience is not justification.
**Check**: Every manifest addition traces to a plan's new-dependency list or an ADR.

### Rule ENG-06: Names Reveal Intent
**Severity**: INFO
**Description**: Identifiers describe purpose, not mechanics or history (`retryBudget`, not `x2` or `newCountFinal`). Follow the target's case convention.
**Check**: No single-letter names outside tight loop indices; no `tmp`/`data2`/`Util` grab-bags.
