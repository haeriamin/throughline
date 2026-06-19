# /dev.lint-wiki

**Agent**: Archivist (read-only mode)
**Reads**: `wiki/**`, `/standards/**`, `/exemplars/**`, `.github/skills/**`, `.claude/skills/**`, `work-queue/**`, `targets/**`, `specs/**`
**Writes**: stdout report; optional `wiki/_lint-report.md`; append to `wiki/log.md`
**Never writes**: any other path

## Checks

1. **Broken links**: every `[[...]]` and relative link in `wiki/**` resolves.
2. **Orphan pages**: wiki pages unreachable from `wiki/index.md`.
3. **Stale standards summary**: any `/standards/*.md` whose **git last-commit time**
   (`git log -1 --format=%cI -- <file>`) is after the last `wiki/standards-summary.md`
   ingest timestamp. Use git time, **not** filesystem mtime — git does not preserve mtime, so
   on a fresh clone every file's mtime is the checkout time (an mtime test then fires for
   everything, or for nothing if the clone pre-dates a hard-coded ingest date). Also flag if
   the summary header's ingest timestamp disagrees with its `dev.ingest-standards` row in
   `wiki/log.md`.
4. **Stale pattern library**: the same git-last-commit-time test for any `/exemplars/**`
   file vs the `wiki/pattern-library.md` ingest timestamp (not mtime), plus the same
   header-vs-log timestamp reconciliation.
5. **Citation integrity**: every Standard Basis in `wiki/pattern-library.md` resolves to
   a rule present in `wiki/standards-summary.md`.
6. **Log integrity**: `wiki/log.md` entries are chronologically ordered and parse
   (timestamp | agent | command | target | verdict | summary | artifacts). Each named
   artifact resolves on disk at its current location — report a dangling reference as INFO
   (an append-only log legitimately names a path later moved, e.g. a work item that advanced
   from `in-progress/` to `completed/`), not as an error.
7. **Skill parity (`.github` ↔ `.claude`)**: `.github/skills/<name>/SKILL.md` is byte-identical
   to `.claude/skills/<name>/SKILL.md` for every skill. Canonical source:
   `.throughline/adapters/source/skills/<name>/SKILL.md` — if parity fails, re-run `tools/convert`.
8. **Exception registry hygiene**: no PENDING-HUMAN entry older than 30 days without a
   log reference.
9. **Scope integrity**: every `**Scope**: target:<id>` on a concept page references a
   registered target (`targets/<id>.yml` exists); scope values other than `global` or
   `target:<id>` are flagged; pages describing a single target's internals without a
   target scope are flagged as WARNING (likely mis-scoped global).
10. **Knowledge completeness (inventory)**: every file under `/exemplars/good/**` and
    `/exemplars/anti-patterns/**` is represented in `wiki/pattern-library.md` (as a `Source`
    or a `PAT-NNN`), and every rule id in `/standards/*.md` appears in
    `wiki/standards-summary.md`. An exemplar on disk with no pattern entry is a WARNING
    ("un-ingested exemplar — re-run `/dev.ingest-exemplars`"); summary prose that contradicts
    disk (e.g. a literal "gaps: none" or an "N exemplars" count that disagrees with the file
    count) is a WARNING. This catches drift a bumped-but-not-re-ingested timestamp would hide.
11. **Work-queue hygiene**: every phase report `work-queue/in-progress/<slice>-*.md` whose
    work item has moved to `work-queue/completed/` or `escalated/` is flagged WARNING
    ("stranded phase report — archive or move it with the slice"); every `in-progress/` work
    item has a matching `specs/<slice>/` (or an inline micro-lane spec). No other command owns
    work-queue hygiene.

## Steps

1. Run all checks; collect findings as `| Check | Severity | Location | Detail |`.
   **Severity vocabulary**: `BLOCKING` (broken link, parse failure, skill-parity break — the
   wiki is internally inconsistent), `WARNING` (staleness, un-ingested exemplar, stranded
   phase report, header/log timestamp mismatch — action needed, not yet broken), `INFO`
   (advisory, e.g. a dangling append-only log reference).
2. Print the table, then an **overall verdict**: `CLEAN` (no findings), `DIRTY` (≥1 WARNING,
   0 BLOCKING), or `BROKEN` (≥1 BLOCKING). If `--write` was passed, also write
   `wiki/_lint-report.md`.
3. Append a one-line summary to `wiki/log.md` (counts per severity). Insert the row at the end
   of the log **table**, before any trailing HTML-comment/template block — a naive
   end-of-file append lands after that block and breaks the table.

## Exit Criteria

- All checks executed; findings reported with exact locations.

## Failure Modes

- This command never mutates content to "fix" findings — remediation goes through
  `/dev.ingest-standards`, `/dev.ingest-exemplars`, or human edits.
