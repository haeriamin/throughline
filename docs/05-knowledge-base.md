# 5 · The Knowledge Base

Three parts: **sources** you write, a **wiki** the agents keep, and **records** the work
produces. The wiki is what makes each new project a little easier than the last.

## Sources (read-only — humans only)

Hooks stop agents from writing here (Constitution Principle I). Only people change these.

### `/standards/` — your engineering rules

A simple, fixed format, one rule at a time:

```markdown
### Rule API-02: Pagination on Collection Endpoints
**Severity**: BLOCKING | WARNING | INFO
**Description**: ...
**Check**: ...
**Example violation**: ...
**Compliant form**: ...
```

Rules are referred to everywhere as `standards/<file>.md §<RULE-ID>` (for example, `§API-02`).
The rules that ship are starter files — replace them with your team's own.

### `/exemplars/` — example code to copy from

Good code (`good/`) and bad code to avoid (`anti-patterns/`). Each code file needs a partner
`.meta.md` file (its type, language, the rules it shows, and tags). A code file with no
`.meta.md` is skipped — the framework never guesses. Tags help the agents find the right example.

## Loading the sources in

After you change anything in the sources, run:

```bash
/dev:ingest-standards    # rebuilds the rules summary; flags past work that used a changed rule
/dev:ingest-exemplars    # rebuilds the example list
```

## The wiki

| File | What it holds |
|------|---------------|
| `standards-summary.md` | A short list of all the rules (the cheap thing agents read each task) |
| `pattern-library.md` | Patterns built from the examples |
| `decision-registry.md` | A list of the big design decisions across tasks |
| `exception-registry.md` | Your decisions from the "ask the human" step, so they are reused |
| `concepts/*` | Topic notes the Archivist writes |
| `log.md` | A running log of everything the agents do |

**Many projects, one wiki**: the wiki is shared across projects on purpose — that is how
knowledge builds up. A note about one project's inner workings is marked `Scope: target:<id>`
and is ignored when working on other projects. One firm rule: if two projects must not share
knowledge (for example, different clients), give each its **own copy of the framework** — do
not rely on the scope mark, because the shared lists and log would still mix them.

## Keeping it healthy

```bash
/dev:lint-wiki    # checks for broken links, stale summaries, bad citations, and more
```

The Auditor (`/dev:audit`) points out **missing examples** — a kind of code the agents needed
3+ times but have no good example for. Adding that example (then re-loading) raises the
confidence on the next task that needs it.

One rule to remember: the wiki is just a handy copy. The Reviewer always re-checks rules
against the real source in `/standards/`. So if the wiki falls out of date, it can cost some
speed, never correctness.

---
[← Building Features](04-building-features.md) · Next: [Quality Gates →](06-quality-gates.md)
