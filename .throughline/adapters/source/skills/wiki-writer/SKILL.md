---
name: wiki-writer
description: Create or update wiki pages in the standard format — frontmatter, sources, stable ids, index linkage, log entry. Invoke with /wiki-writer.
---

# Wiki Writer Skill

## Purpose
Keep the agent-maintained knowledge base structurally uniform so retrieval skills and the lint command can rely on its shape.

## Page Format

```markdown
# <Title>
**Page ID**: <stable-kebab-slug>
**Scope**: global | target:<id>
**Maintained by**: Archivist
**Last updated**: YYYY-MM-DD
**Sources**: standards/<file>.md §<RULE-ID>; exemplars/<path>; <target>/.throughline/specs/NNN-*/...

<body — facts with citations; link related pages as [[wiki/concepts/<slug>]]>
```

## Algorithm

1. Pick the wiki home: global pages live in the framework `wiki/`; pages about one target's internals live in that target's `.throughline/wiki/`. Check the matching `index.md` for an existing page covering the topic — update it rather than duplicating.
2. Write/update the page preserving its Page ID (ids are stable forever).
3. Every factual claim carries a source citation; claims without sources don't go in the wiki.
4. Add/refresh the index entry (one line: link + hook) — `wiki/index.md` for a global page, `<target>/.throughline/wiki/index.md` for a target-scoped page.
5. Append a log entry (timestamp, agent, page, action, summary) — the framework `wiki/log.md` for a global write, `<target>/.throughline/wiki/log.md` for a target-scoped write.

## Rules

- Only the Archivist persona may invoke this skill for content writes (constitution §Write-Boundary Invariants); Orchestrator/Auditor use it solely to FORMAT recommendation artifacts outside `/wiki/`.
- Wiki content is derived — on any conflict with `/standards/` or `/exemplars/` (or the target's `.throughline/standards|exemplars`, which override the org seeds for that target), the source wins and the page gets fixed, not the source.
- **Scope** (Constitution Principle II): pages describing one target's internals (its auth flow, its module layout, its quirks) MUST be scoped `target:<id>` and live in that target's `.throughline/wiki/`; reusable engineering knowledge stays `global` in the framework `wiki/` (the default when the field is omitted). Readers ignore pages scoped to a different target. A `target:<id>` scope must reference a registered target.

## Usage Context
Called by: Archivist (ingest, concepts, registries), Orchestrator (exception-registry recording during /dev.review-escalated), Auditor (recommendation formatting).
