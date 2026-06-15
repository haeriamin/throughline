# Code Analysis Instructions
> Loaded by AnalystAgent at runtime. These rules govern ALL analysis work.

---

## Cardinal Rules

1. ❌ NEVER edit target source — analysis is strictly read-only
2. ✅ ALWAYS resolve the target through `targets/<id>.yml` — never analyze unregistered paths
3. ✅ ALWAYS record a source fingerprint (git rev, or file-count + latest mtime) in every report — staleness detection depends on it
4. ❌ NEVER widen a scope silently — an empty scope is a finding, not a prompt to guess
5. ✅ ALWAYS separate pre-existing standards violations from slice scope — they are informational unless the spec includes them

---

## Analysis Procedure

1. **Bootstrap** (Constitution Principle II, full sequence).
2. **Map**: run `codebase-mapper` over the scope → module inventory, entry points, test layout, dependency edges.
3. **Conventions**: detect naming, structure, and error-handling conventions actually used. These bind the Implementer wherever `/standards/` is silent — record them explicitly.
4. **Patterns**: for each implementation need in the spec, run `pattern-matcher` against `wiki/pattern-library.md` (and the active target's `.throughline/wiki/pattern-library.md` delta). Record matched PAT ids AND unmatched needs (exemplar gaps).
5. **Risk**: enumerate risks with likelihood/impact — dependency fan-out, public contract changes, concurrency, data sensitivity.
6. **Classify** complexity per ARCHITECTURE.md §12.1; justify the class against the criteria, not vibes.
7. **Score** analysis confidence: requirements with a clear implementation path / total requirements, discounted for map ambiguity.

## Complexity Criteria (reference)

| Class | Criteria |
|-------|----------|
| LOW | Single module, no contract/schema change, no security surface |
| MEDIUM | 2–5 modules, internal API changes, standard patterns matched |
| HIGH | Cross-cutting, public API/schema change, new dependency, concurrency |
| CRITICAL | Auth/payments/PII, data migrations, production infra |

## Output Contract

The report format in `.throughline/extensions/dev/commands/dev.analyze.md` §Steps is mandatory — all sections, even when a section's honest content is "none found".
