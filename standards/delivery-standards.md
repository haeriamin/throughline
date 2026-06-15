# Delivery & Operability Standards
**Standard ID**: STD-005
**Effective Date**: 2026-06-11
**Applies To**: [All]

## Rules

### Rule DEL-01: Dependency Vulnerability Audit
**Severity**: BLOCKING
**Description**: Before a slice completes, the target's dependency audit tool runs clean of known critical/high vulnerabilities in dependencies the slice added or upgraded (`npm audit`, `pip-audit`, `cargo audit`, `dotnet list package --vulnerable`, per stack).
**Check**: Audit command executed in the test report; no critical/high findings attributable to slice-introduced dependencies.
**Example violation**: Adding a package version with a published critical CVE.
**Compliant form**: Pin a patched version, or escalate with the finding if none exists.

### Rule DEL-02: Static Security Scan When Available
**Severity**: WARNING
**Description**: If the target has a SAST/linter security ruleset configured (semgrep, bandit, eslint-plugin-security, CodeQL), it runs on the slice diff and new findings are addressed or annotated.
**Check**: Scanner output recorded in the test report when a scanner is configured; new findings dispositioned.

### Rule DEL-03: Observability at Boundaries
**Severity**: WARNING
**Description**: New entry points (handlers, jobs, consumers) emit structured logs for start/outcome/failure with correlation context, using the target's existing logging idiom. No print-debugging as logging.
**Check**: Each new entry point logs failures with enough context to diagnose without a debugger.

### Rule DEL-04: CI Runs the Quality Loop
**Severity**: WARNING
**Description**: If the target has CI configured, it executes at least the `test_command` and `lint_command` on pull requests. Slices must not leave CI weaker than they found it.
**Check**: CI config still invokes test + lint after the slice (agents may not edit CI — flag gaps for humans instead, per the Implementer's forbidden operations).

### Rule DEL-05: Performance-Sensitive Paths Are Measured, Not Guessed
**Severity**: INFO
**Description**: When a spec carries a quantitative performance success criterion, the slice includes a measurement (benchmark, timed test, or documented measurement procedure) — never a claim of "should be fast enough".
**Check**: Each performance SC has a corresponding measurement artifact or test.
