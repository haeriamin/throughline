---
name: pattern-matcher
description: Given an implementation need or code construct, find the closest matching pattern in wiki/pattern-library.md and return the recommendation with confidence score and best exemplar. Invoke with /pattern-matcher.
---

# Pattern Matcher Skill

## Purpose
Translate "I need cursor-based pagination on this endpoint" into "apply PAT-007 with this exemplar at this confidence level."

## Algorithm

1. Read `wiki/pattern-library.md` and the active target's `.throughline/wiki/pattern-library.md` delta — load all pattern entries (a target entry overrides the global entry for the same need).
2. Score each pattern against the target need:

### Scoring Dimensions

**Structural Match (weight 0.50)** — does the pattern's "When to apply" condition match?
- Exact construct/need match → 1.0
- Same class, different subtype → 0.6–0.8
- Related but not identical → 0.3–0.5
- No structural relation → 0.0

**Class Match (weight 0.30)** — same pattern class → 1.0; related → 0.5; different → 0.0.

**Standards Alignment (weight 0.20)** — pattern's standard refs cover the rules applying to this need: all → 1.0; partial → 0.5; none → 0.0.

`pattern_match_score = 0.50·structural + 0.30·class + 0.20·standards`

3. Select top-3; for the best, pick the highest-relevance exemplar from the pattern's list (via `exemplar-retrieval` scoring).

## Output Format

```markdown
## Pattern Match Results for: [need]

### Best Match
- **Pattern**: PAT-XXX — [name]
- **Pattern match score**: 0.XX
- **Best exemplar**: exemplars/good/<path> (relevance 0.XX)
- **Standard basis**: standards/<file>.md §<RULE-ID> — [rule]
- **Implementation steps**: [from the pattern entry]

### Alternatives (for retry scenarios)
- PAT-YYY — [name] (0.XX)

### UNMATCHED (if best score < 0.60)
- Best candidate: PAT-XXX at 0.XX — below threshold
- Recommended action: minimal compliant implementation + exemplar-gap flag (Auditor concern)
```

## Confidence Threshold
- ≥ 0.80 → strong match, apply
- 0.60–0.79 → acceptable, apply with explicit annotation in the Decision Record
- < 0.60 → UNMATCHED — do not force the pattern

## Usage Context
Called by: Analyst (pattern mapping in analysis reports), Implementer (per task; also returns full implementation steps).
