---
name: codebase-mapper
description: Structural scan of a target codebase scope producing a normalized module inventory (JSON) — modules, entry points, dependencies, test layout, conventions, hotspots. Invoke with /codebase-mapper.
---

# Codebase Mapper Skill

## Purpose
Give the Analyst and Architect a normalized, machine-comparable picture of a target before anything is planned. The map's fingerprint also powers staleness detection across the pipeline.

## Algorithm

1. Resolve the target root from `targets/<id>.yml`; constrain to the requested scope (glob/dir) — never widen silently.
2. Identify the build system + manifests (`package.json`, `pyproject.toml`, `go.mod`, `*.csproj`, `Cargo.toml`, `pom.xml`, …).
3. Walk source files (respect `.gitignore`); per module record path, language, exports, imports, LOC.
4. Detect: entry points, test framework + locations, external dependencies (manifest-declared vs actually imported), conventions (naming case, directory pattern, error-handling idiom), hotspots (high fan-in, very large files, mixed concerns).
5. Compute the source fingerprint: `git rev-parse HEAD` if git, else file count + latest mtime.

## Output Schema

```json
{
  "target": "my-app",
  "fingerprint": "abc1234 | files:412 mtime:2026-06-09T10:11:12Z",
  "modules": [{"path": "", "language": "", "exports": [], "imports": [], "loc": 0}],
  "entry_points": [],
  "test_layout": {"framework": "", "locations": []},
  "build_system": "",
  "external_dependencies": [],
  "conventions_detected": {"naming": "", "structure": "", "error_handling": ""},
  "hotspots": [{"path": "", "reason": ""}]
}
```

## Rules

- Read-only, always.
- Unknown language/edge constructs → list under `hotspots` with reason "unparsed", never omit.
- Conventions are reported as observed facts ("camelCase in 94% of identifiers"), not judgments.

## Usage Context
Called by: Analyst (step 2 of every analysis), Architect (design grounding). The fingerprint is quoted in analysis reports, test reports, and review staleness checks.
