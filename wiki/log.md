# Operations Log
**Append-only** (Constitution Principle VII). Never edit or delete past entries.
Format: `| ISO-8601 timestamp | agent | command | target | verdict | summary | artifacts |`

| Timestamp | Agent | Command | Target | Verdict | Summary | Artifacts |
|-----------|-------|---------|--------|---------|---------|-----------|
| 2026-06-09T00:00:00Z | human | bootstrap | - | - | Framework scaffolded; seed standards STD-001..005 and exemplars curated | README.md |
| 2026-06-11T00:00:00Z | human | throughline.constitution | - | - | Amendment 0.1.1 (PATCH): Principle II adds target-scoped wiki concept pages; lint-wiki check 9 added | .throughline/memory/constitution.md |
| 2026-06-11T00:00:01Z | human | throughline.constitution | - | - | Amendment 0.1.2 (PATCH): Principle V epistemic-status clause; Principle VII log-coverage clause; validate-bash-safety hooks added both runtimes | .throughline/memory/constitution.md |
| 2026-06-11T12:30:00Z | Archivist | dev.ingest-standards | - | - | Ingested 27 rules across STD-001..005 into standards-summary | wiki/standards-summary.md |
| 2026-06-11T12:30:05Z | Archivist | dev.ingest-exemplars | - | - | Ingested PAT-001 (REST Pagination), PAT-002 (Service Decomposition) | wiki/pattern-library.md |
| 2026-06-13T00:00:00Z | human | throughline.constitution | - | - | Amendment 0.1.3 (PATCH): Principle II bootstrap-economy clause — amortize wiki reads within a slice; Reviewer/Archivist exempt | .throughline/memory/constitution.md |
| 2026-06-13T00:00:02Z | human | throughline.constitution | - | - | Amendment 0.2.0 (MINOR): new Output Language section — all artifacts written for people must use plain, simple English; Reviewer enforces as a structural check | .throughline/memory/constitution.md |
| 2026-06-15T00:00:00Z | human | edit-standard | STD-004 | - | Added TST-07 (cover the spec's negative space: one test per reject/raise rule) and TST-08 (expected values come from the spec, not the code), grounded in the spec-derived-testing research track | standards/testing-standards.md |
| 2026-06-15T00:00:05Z | Archivist | dev.ingest-standards | - | - | Re-ingested STD-004: 29 rules total (16 BLOCKING, 9 WARNING, 4 INFO) across STD-001..005 | wiki/standards-summary.md |
| 2026-06-19T03:00:00Z | Archivist | dev.ingest-exemplars | - | - | Re-ingested all 3 exemplars; added PAT-003 (Spec-Grounded Input Validation) from exemplars/good/python/validated-operation.py; refreshed Sources and inventory (3 exemplars, 3 pattern classes, PAT-001..003); cleared the stale "2 exemplars / gaps: none". Standard Basis ENG-01/02/06 + TST-07/08 resolve in standards-summary. | wiki/pattern-library.md |
| 2026-06-19T04:00:00Z | human | throughline.constitution | - | - | Amendment 0.3.0 (MINOR): target-side SDD provenance — a slice's specs/reports/work-queue record + target-local standards/exemplars live under <target>/.throughline/ on the slice branch; operations log + registries split framework-global vs per-target; 7 principles preserved. Contract in ARCHITECTURE.md §3/§4/§11.7. | .throughline/memory/constitution.md, ARCHITECTURE.md |
| 2026-06-19T05:00:00Z | human | throughline.constitution | - | - | Amendment 0.3.1 (PATCH): renamed framework audit roll-up dir /review-reports/ → /audit/ (disambiguates from per-target <target>/.throughline/review-reports/); write-boundary table + Auditor scope updated; no semantic change. | .throughline/memory/constitution.md, ARCHITECTURE.md |

<!-- Validation runs (greenfield + feature slices on external demo targets) were executed
     during development; their full audit trails live target-side with each run's own target
     repo, not in this framework. So this log ships as the framework's own seed history —
     the state a new user has right after the first ingest. -->
