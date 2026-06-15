---
name: compliance-checker
description: Audit a file or diff against the active rules in /standards/ — returns per-rule verdicts with locations, and the standards_compliance ratio used in confidence scoring. Invoke with /compliance-checker.
---

# Compliance Checker Skill

## Purpose
Mechanically grade code against the rule inventory. Produces the `standards_compliance` sub-score (numerator/denominator) that feeds the constitutional confidence formula.

## Algorithm

1. Load rules via `standards-retrieval` filtered to the file's domain/language (ALWAYS from `/standards/` source plus the active target's `.throughline/standards/`, never the wiki — this skill backs the Reviewer's independence rule). A target-local rule overrides the org rule with the same Rule ID (target wins).
2. Determine applicability per rule (Applies To + language + construct presence).
3. For each applicable rule, evaluate it against the file/diff:
   - **If the rule names a `Tool`**: run it; its PASS/FAIL is authoritative (record the command + output). A BLOCKING rule whose tool was not run = FAIL, never assumed-pass.
   - **Otherwise** (prose `Check`): judge PASS / FAIL with `file:line` evidence — flag this verdict as `judgment` so readers know it is non-deterministic.
   - UNVERIFIABLE (needs context not in scope) — counts as FAIL for BLOCKING rules, noted for others
4. Compute `standards_compliance = satisfied / applicable` (BLOCKING and WARNING rules only; INFO is reported but unscored).

## Output Format

```markdown
## Compliance Report: <file-or-diff>

| Rule | Severity | Verdict | Method | Evidence | Source |
|------|----------|---------|--------|----------|--------|
| SEC-02 | BLOCKING | FAIL | tool | semgrep sql-injection @ src/db.ts:18 | standards/security-policy.md §SEC-02 |
| API-01 | BLOCKING | FAIL | judgment | src/routes/user.ts:42 | standards/api-design.md §API-01 |

**standards_compliance = <satisfied>/<applicable> = 0.XX**
**BLOCKING failures: N** (any N>0 → structural fail at review)
**Method column**: `tool` = deterministic, authoritative · `judgment` = LLM-interpreted prose (non-deterministic)
```

## Rules

- Severity comes from the rule, never adjusted ad hoc.
- Cite each rule by its source form — `standards/<file>.md §<RULE-ID>` (org) or `.throughline/standards/<file>.md §<RULE-ID>` (target-local).
- A rule that cannot be evaluated is reported as such — silence is not compliance.

## Usage Context
Called by: Reviewer (Layer 3), Auditor (portfolio sweeps), Analyst (pre-existing-violation inventory, informational).
