# What to use Throughline for

Throughline earns its overhead on changes you want tested, reviewed, and recorded. It isn't the right tool for everything, and the quickest way to get value is to match the task to the right command, or to skip the framework when plain chat would do.

The rule of thumb: **a change goes through Throughline; a question goes to plain chat.**

Commands below use the dot form (`/dev.feature`), which is what Copilot and Codex use. On Claude Code, swap the dot for a colon (`/dev:feature`).

Each task here is backed by a named workflow under [`.specify/workflows/`](../.specify/workflows/) — that YAML is the source of truth for the steps and gates; the commands below are just how you invoke them. The map: build a feature → `dev-feature`, fix a bug → `dev-bugfix`, understand an area → `dev-explore`, review a change → `dev-review`, new project → `dev-greenfield`.

## Build a feature

The headline case. Describe what you want and let the lifecycle run.

```
/dev.target register path/to/my-app
/dev.feature my-app "Add cursor pagination to the orders endpoint"
```

It specs the change, plans it, writes it on a branch, tests it, and has an independent reviewer gate it before it's done. You do the merge. For anything touching a contract, schema, auth, payments, or personal data, it raises the bar automatically (design review, or human-led for CRITICAL).

## Fix a bug

A bug fix is just a small change, so it runs through the same command. For a contained fix, add `--micro` to skip the spec and plan paperwork and keep the part that matters (implement, test, review):

```
/dev.feature my-app "Fix: pagination returns the wrong rows when page is negative" --micro
```

The Implementer fixes it on a branch, the Tester writes a test that fails before the fix and passes after, and the Reviewer checks it independently. You get a real test as evidence and a record of why it changed, not just a patch.

This is exactly what the [SWE-bench validation run](validation-runs/2026-06-16-swebench-pytest-11143.md) did on a real pytest issue: from the bug report alone, the fix passed the benchmark's own hidden test with no regressions.

Use the full command (no `--micro`) when the fix is larger or risky enough to deserve a spec and plan.

## Understand an area before you change it

When you're about to work in unfamiliar code, `/dev.analyze` maps it for you: the modules, the conventions it actually follows, where the complexity is, plus a fingerprint of the source it read.

```
/dev.analyze my-app src/billing
```

The Analyst writes a grounded report (in `work-queue/`) that the rest of the pipeline then builds on, so your change starts from how the code really works rather than a guess. You can also call the `codebase-mapper` or `pattern-matcher` skills directly for a one-off.

## Just explain something, or ask a quick question

Here's where to *not* use the framework. "What does this function do?", "why is this designed this way?", "walk me through this flow", these are questions, not changes. They don't need a test, a review, or a record, so the framework would only add ceremony.

For those, ask your AI tool in plain chat (Copilot, Claude Code, or Codex). Reach for `/dev.analyze` only when the question is really "help me understand this so I can change it safely."

## Review a change someone already made

You can run the gate on its own, without the rest of the lifecycle:

```
/dev.review <slice-id>
```

The Reviewer re-reads your standards from source, checks the change against them, and returns PASS, CONDITIONAL_PASS, or FAIL with cited findings. Useful as a second opinion on an agent's (or a teammate's) work.

## Start a new project

Register an empty path with `--new` and the same one command builds it greenfield (it adds a design step and scaffolds the skeleton first):

```
/dev.target register path/to/new-app --new
/dev.feature new-app "A CLI tool that converts CSV to Parquet"
```

## Check quality across projects

Once you have a few targets, the Auditor rolls up the review and test reports, spots recurring problems, and flags gaps in your examples:

```
/dev.audit
```

## Bring in your own standards and examples

The `/standards/` and `/exemplars/` that ship are starter seeds. Replace them with your team's and re-ingest, and every later change is held to your rules:

```
# drop your files into /standards/ and /exemplars/, then:
/dev.ingest-standards
/dev.ingest-exemplars
```

## When not to use it

Skip the framework for throwaway scripts, one-line tweaks with no contract or security surface, and plain questions. The overhead is real and only pays off when a clear record and a strong review matter. For the small stuff, use `--micro`, the single commands, or just plain chat.

See also: [Building Features](04-building-features.md) · [Quality Gates](06-quality-gates.md) · [Commands](../COMMANDS.md)
