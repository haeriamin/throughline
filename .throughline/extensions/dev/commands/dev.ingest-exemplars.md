# /dev.ingest-exemplars

**Agent**: Archivist
**Reads**: `/exemplars/**`, `wiki/**` (with a `[target-id]`: also `<target>/.throughline/exemplars/**` and `<target>/.throughline/wiki/**`)
**Writes**: global mode → `wiki/pattern-library.md`, `wiki/concepts/*`, `wiki/index.md`; target mode (`[target-id]`) → the target delta under `<target>/.throughline/wiki/` (never the global wiki); append to `wiki/log.md` (framework)
**Never writes**: `/exemplars/**`, `/standards/**` (framework or any target's `.throughline/exemplars|standards`)

## Arguments

```
/dev.ingest-exemplars [target-id]      # omit for the org exemplars
```

Without a target, this compiles the org `/exemplars/` into the global wiki (behavior unchanged).
With a `target-id`, it compiles **only** that target's local `<target>/.throughline/exemplars/**`
into a delta under `<target>/.throughline/wiki/` (target patterns override org by pattern class);
the global wiki is untouched.

## Preconditions

- Every exemplar code file has a sibling `.meta.md` (Kind, Pattern Class, Languages,
  Standard References, Complexity, Description, Tags). Missing metadata → that exemplar
  is skipped and reported; never invent metadata. (Target mode applies the same check to
  `<target>/.throughline/exemplars/**`.)

## Steps

1. **Bootstrap** (Principle II, steps 1–3).
2. Inventory `/exemplars/good/**` and `/exemplars/anti-patterns/**` (code + `.meta.md` pairs)
   (target mode: `<target>/.throughline/exemplars/good/**` and `.../anti-patterns/**`).
3. Group by **Pattern Class**. For each class, create/refresh an entry in `wiki/pattern-library.md`
   (target mode: the target delta `<target>/.throughline/wiki/pattern-library.md`, with the
   `Exemplars`/`Anti-patterns`/`Standard Basis` paths pointing at the target-local
   `.throughline/exemplars` and `.throughline/standards`):
   ```markdown
   ## Pattern: <Name>
   **Pattern ID**: PAT-NNN          ← stable; never renumber existing entries
   **Class**: <Pattern Class>
   **Exemplars**: [[exemplars/good/...]] (1+)
   **Anti-patterns**: [[exemplars/anti-patterns/...]] (0+)
   **Standard Basis**: standards/<file>.md §<RULE-ID>
   **When to apply**: …
   **Implementation Steps**: …       ← derived ONLY from the exemplar content
   **Confidence typical range**: 0.XX–0.XX
   ```
4. Verify every `Standard References` citation resolves to a real rule in
   `wiki/standards-summary.md` (target mode: the target delta
   `<target>/.throughline/wiki/standards-summary.md`, falling back to the org summary); broken
   citations → flag, don't drop.
5. Update `wiki/index.md` (target mode: `<target>/.throughline/wiki/index.md`). Append to the
   framework `wiki/log.md` (patterns added/updated, exemplars skipped).

## Exit Criteria

- Every valid exemplar pair is reachable from exactly one pattern entry.
- No pattern entry lacks a Standard Basis.

## Failure Modes

- **Code file without `.meta.md`** → skip + report (human must add metadata).
- **Two classes claim the same exemplar** → keep first, flag for human in the log.
