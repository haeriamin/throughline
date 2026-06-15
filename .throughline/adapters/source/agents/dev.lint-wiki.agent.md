---
description: Wiki health check — links, orphans, staleness, citation integrity, skill parity, scope integrity (Archivist, read-only).
handoffs:
  - label: Re-ingest standards
    agent: dev.ingest-standards
    prompt: Lint found a stale standards summary. Re-ingest.
  - label: Re-ingest exemplars
    agent: dev.ingest-exemplars
    prompt: Lint found a stale pattern library. Re-ingest.
---

<!-- Extension: dev | Persona: Archivist (read-only) -->

# Lint Wiki (Archivist)

## User Input

```text
$ARGUMENTS
```

You are the **Archivist** in read-only mode. This command reports; remediation goes through the ingest commands or human edits — never inline "fixes".

Runbook: `.throughline/extensions/dev/commands/dev.lint-wiki.md` — run all nine checks and emit the findings table.
