# Security Policy
**Standard ID**: STD-003
**Effective Date**: 2026-06-09
**Applies To**: [All]

## Rules

### Rule SEC-01: No Secrets in Source
**Severity**: BLOCKING
**Description**: Credentials, API keys, tokens, and connection strings never appear in source, config committed to VCS, or logs. Use the target's secret mechanism (env vars, vault).
**Check**: No string matching key/token/password patterns with literal values; `.env` files gitignored.
**Tool**: Secret scanner when the target has one (gitleaks, trufflehog, detect-secrets); its findings supersede judgment for this rule.
**Example violation**: `const API_KEY = "sk-live-abc123";`
**Compliant form**: `const API_KEY = process.env.API_KEY;` (+ documented in deployment notes)

### Rule SEC-02: Parameterized Queries Only
**Severity**: BLOCKING
**Description**: SQL/NoSQL queries use parameter binding or a query builder/ORM; string-concatenated queries with external input are forbidden.
**Check**: No query construction via string interpolation of request-derived values.
**Tool**: SAST rule when configured (semgrep `sql-injection`, CodeQL, bandit B608); its findings supersede judgment for this rule.

### Rule SEC-03: Output Encoding / Injection Defense
**Severity**: BLOCKING
**Description**: User-controlled data is encoded for its sink (HTML, shell, path, header). `eval`/dynamic code execution on external input is forbidden.
**Check**: Template engines auto-escape or call sites encode explicitly; no `eval`, `exec`, `child_process` with unsanitized input.

### Rule SEC-04: Least-Privilege Data Exposure
**Severity**: WARNING
**Description**: Responses expose only fields the consumer needs; internal ids, flags, and PII require explicit allowlisting per endpoint.
**Check**: Serialization uses explicit field selection (DTO/serializer), not raw entity dumps.

### Rule SEC-05: Sensitive-Domain Changes Are Human-Led
**Severity**: BLOCKING
**Description**: Changes touching authentication, authorization, payments, cryptography, or PII handling are CRITICAL complexity class — agents assist, humans lead and approve (Constitution §Agent Boundaries).
**Check**: Slice analysis classifies these domains CRITICAL; design.md exists, marked human-led.
