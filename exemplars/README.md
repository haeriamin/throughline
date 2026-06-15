# Exemplars — Curated Reference Code (IMMUTABLE)

Human-curated reference implementations (`good/`) and cautionary specimens (`anti-patterns/`).
Agents read; only humans write (Constitution Principle I — hooks enforce this).

## Curation rules

1. Every code file has a sibling `<name>.meta.md` — files without metadata are skipped at ingest.
2. Keep exemplars small and single-pattern: one file demonstrates one pattern class well.
3. Cite the standard rules the exemplar satisfies (or violates, for anti-patterns) in the metadata.
4. After adding/changing files here, run `/dev.ingest-exemplars` so the pattern library updates.

## Metadata schema

```markdown
# Exemplar: <name>
**Kind**: good | anti-pattern
**Pattern Class**: <e.g., REST Pagination>
**Languages**: [typescript]
**Standard References**: standards/<file>.md §<RULE-ID>
**Complexity**: LOW | MEDIUM | HIGH
**Description**: …
**Tags**: comma, separated, retrieval, tags
```

Tags drive `exemplar-retrieval` ranking — be generous and precise.
