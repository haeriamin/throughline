---
name: exemplar-retrieval
description: Find the top-N most relevant curated exemplars (and anti-patterns) for a pattern class or implementation need, ranked by tag/class/stack overlap. Invoke with /exemplar-retrieval.
---

# Exemplar Retrieval Skill

## Purpose
Surface the best curated reference implementations for the task at hand. Exemplars are the framework's transformation memory — ranked retrieval here is what compounds knowledge across projects.

## Algorithm

1. Parse the need: pattern class (e.g., "REST Pagination"), language(s), tags.
2. Inventory `/exemplars/good/**` and `/exemplars/anti-patterns/**` (framework) plus the active target's `.throughline/exemplars/**` via their `.meta.md` files (skip code files lacking metadata; report them). A target-local exemplar of the same class is ranked alongside the org ones.
3. Score each exemplar:

### Scoring Dimensions
**Pattern Class match (weight 0.45)** — same class 1.0; related class 0.5; unrelated 0.0.
**Tag overlap (weight 0.30)** — |query tags ∩ exemplar tags| / |query tags|.
**Language/stack match (weight 0.25)** — same language 1.0; same paradigm 0.6; different 0.2.

`relevance = 0.45·class + 0.30·tags + 0.25·stack`

4. Return top-N (default 3) good exemplars + any anti-pattern of the same class (anti-patterns are warnings, not templates).

## Output Format

```markdown
## Exemplars for: [need]

### Top matches
1. exemplars/good/<path> — relevance 0.XX
   - Class: ... | Tags: ... | Standard refs: standards/<file>.md §<RULE-ID>
2. ...

### Anti-patterns to avoid
- exemplars/anti-patterns/<path> — [what it demonstrates going wrong]

### GAP (if best relevance < 0.60)
- Best candidate: <path> at 0.XX — below threshold
- Recommended action: cite "none exists" in the Decision Record; flag the gap for the Auditor
```

## Rules

- Relevance < 0.60 → report a GAP; never stretch a weak exemplar into a basis (Principle III demands apposite citations).
- Cite each exemplar by its source form — `exemplars/<path>` (org) or `.throughline/exemplars/<path>` (target-local).
- `example_similarity` used in confidence scoring = the relevance of the exemplar actually cited.

## Usage Context
Called by: Analyst (pattern mapping), Implementer (per task, top-3), Reviewer (verifying cited bases are apposite).
