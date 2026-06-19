---
name: standards-retrieval
description: Locate and structure rule content from /standards/ documents for a given topic, file type, or task. Returns rules with severity, check, and precise §-citations. Invoke with /standards-retrieval.
---

# Standards Retrieval Skill

## Purpose
Turn "what do the standards say about X?" into a structured, citable answer drawn ONLY from standards source files — framework `/standards/**` plus the active target's `.throughline/standards/**`. This is the constitutional alternative to model-trained convention knowledge (Principle II.5).

## Algorithm

1. Identify the query facets: domain (API / Services / Frontend / Data / All), language, concern (naming, security, error handling, testing, performance, layout).
2. List `/standards/*.md` (framework) and the active target's `.throughline/standards/*.md`; filter by each doc's `**Applies To**` header against the domain facet.
3. Within matching docs, scan `### Rule <ID>:` blocks; select rules whose name, description, or check text matches the concern facets.
4. For each selected rule, extract: Rule ID, Severity (BLOCKING/WARNING/INFO), Description, Check, Compliant form.
5. Rank: BLOCKING first, then WARNING, then INFO; exact-facet matches before fuzzy.

## Output Format

```markdown
## Standards for: [query]

| Rule | Severity | Requirement | Check | Source |
|------|----------|-------------|-------|--------|
| API-01 | BLOCKING | ... | ... | standards/api-design.md §API-01 |

### Not covered
- [facets with NO matching rule — say so explicitly; absence of a rule is a finding, not license to improvise]
```

## Rules

- Source citations use the `standards/<file>.md §<RULE-ID>` form (or `.throughline/standards/<file>.md §<RULE-ID>` for a target-local rule) — these go verbatim into Decision Records (Principle III).
- Precedence: a target-local rule overrides the org rule with the same Rule ID (target wins); cite the target-local source for it.
- Never paraphrase a rule's Check into something stricter or looser — quote or summarize faithfully.
- Conflicting rules across docs → return BOTH with a CONFLICT marker (Archivist escalation path).

## Usage Context
Called by: Archivist (ingest), Implementer (per task), Reviewer (independent re-verification — always against source, never the wiki).
