# What to use Throughline for

A better model makes each agent smarter; it doesn't make the work *trustworthy*. Throughline turns one request into a change that is:

- **Tested** — a real test that fails before the change and passes after, run for real, with the output recorded.
- **Independently reviewed** — a separate reviewer re-reads *your* standards from source and gates the change (PASS / CONDITIONAL_PASS / FAIL), so "the tests pass" isn't the whole story.
- **Recorded** — every change cites the spec rule and the standard it followed, and leaves a plain-English entry in your codebase's own changelog.
- **Reversible** — work lands on a branch *you* merge. Nothing merges itself; risky surfaces (auth, payments, schemas, personal data) escalate to you automatically.
- **Held to your rules** — your standards and examples, not the model's defaults.

If a task doesn't need those, don't reach for it. The rule of thumb:

> **A change goes through Throughline. A question goes to plain chat.**

*Commands below use the Claude Code colon form (`/dev:feature`), the default across these docs. On GitHub Copilot or Codex, swap the colon for a dot (`/dev.feature`). Same commands, same behavior.*

## Contents

1. [Explore an idea before you build](#1-explore-an-idea-before-you-build) — `/dev:ideate`
2. [Build a feature](#2-build-a-feature) — `/dev:feature`
3. [Fix a bug](#3-fix-a-bug) — `/dev:feature --micro`
4. [Start a new project](#4-start-a-new-project) — `/dev:feature` on a `--new` target
5. [Understand an area before you change it](#5-understand-an-area-before-you-change-it) — `/dev:analyze`
6. [Review a change someone already made](#6-review-a-change-someone-already-made) — `/dev:review`
7. [Audit quality across your projects](#7-audit-quality-across-your-projects) — `/dev:audit`
8. [Bring in your own standards and examples](#8-bring-in-your-own-standards-and-examples) — `/dev:ingest-*`

Then: [when to just use plain chat](#when-to-just-use-plain-chat) · [what it leaves in your codebase](#what-throughline-leaves-in-your-codebase) · [when not to use it](#when-not-to-use-it).

The first five are the everyday path — roughly the order you meet them on a real task: think, build or fix, learn the code, get a second opinion. The last three set up and maintain the framework around them.

---

## 1. Explore an idea before you build

**When:** you have a rough idea and want to think it through *with* the framework before committing to a spec.

```
/dev:ideate "let users save a cart and come back to it later" my-app
```

It's read-only and conversational: it lays out a few genuinely different approaches with their trade-offs and risks, grounds them in how your code actually works, asks the questions that would change your mind, and recommends a direction. It writes an ideation note and **stops at a recommendation — no spec, no branch, no code**. When you've chosen, kick off the real lifecycle with `/dev:feature` (case 2). Think of it as thinking out loud, except the notes are kept and the options respect your standards.

## 2. Build a feature

**When:** you want to add or change real behavior. The headline case.

```
/dev:target register path/to/my-app
/dev:feature my-app "Add cursor pagination to the orders endpoint"
```

It specs the change, plans it, writes it on a branch, tests it, and has an independent reviewer gate it before it's done — then hands you a branch to merge. Anything touching a contract, schema, auth, payments, or personal data raises the bar automatically (a design review, or human-led for CRITICAL). *Workflow: `dev-feature`.*

## 3. Fix a bug

**When:** the change is small and contained. A bug fix runs through the same command — add `--micro` to skip the spec/plan paperwork and keep the part that matters (implement → test → review):

```
/dev:feature my-app "Fix: pagination returns the wrong rows when page is negative" --micro
```

The Implementer fixes it on a branch, the Tester writes a test that **fails before the fix and passes after**, and the Reviewer checks it independently. You get evidence and a record of *why* it changed, not just a patch. Drop `--micro` when the fix is large or risky enough to deserve a full spec and plan. *Workflow: `dev-bugfix`.*

## 4. Start a new project

**When:** you're building something from scratch. Register an empty path with `--new` and the same one command builds it greenfield (it adds a design step and scaffolds the skeleton first):

```
/dev:target register path/to/new-app --new
/dev:feature new-app "A CLI tool that converts CSV to Parquet"
```

*Workflow: `dev-greenfield`.*

## 5. Understand an area before you change it

**When:** you're about to work in unfamiliar code and want to start from how it really works, not a guess.

```
/dev:analyze my-app src/billing
```

The Analyst maps it for you — the modules, the conventions it actually follows, where the complexity is — and writes a grounded report (with a fingerprint of the source it read) that the rest of the pipeline builds on. You can also call the `codebase-mapper` or `pattern-matcher` skills directly for a one-off. *Workflow: `dev-explore`.*

## 6. Review a change someone already made

**When:** you want a second opinion on a change — an agent's or a teammate's — without running the whole lifecycle.

```
/dev:review <slice-id>
```

The Reviewer re-reads your standards from source, checks the change against them, and returns PASS / CONDITIONAL_PASS / FAIL with cited findings. *Workflow: `dev-review`.*

## 7. Audit quality across your projects

**When:** you have a few targets and want the bird's-eye view. The Auditor rolls up the review and test reports, spots recurring problems, and flags gaps in your examples:

```
/dev:audit
```

## 8. Bring in your own standards and examples

**When:** you want changes held to *your* team's rules. The `/standards/` and `/exemplars/` that ship are starter seeds — replace them with yours and re-ingest, and every later change is checked against them:

```
# drop your files into /standards/ and /exemplars/, then:
/dev:ingest-standards
/dev:ingest-exemplars
```

---

## When to just use plain chat

"What does this function do?", "why is this designed this way?", "walk me through this flow" — these are **questions, not changes**. They don't need a test, a review, or a record, so the framework would only add ceremony. Ask your AI tool in plain chat. Reach for `/dev:analyze` (case 5) only when the question is really "help me understand this so I can change it safely."

## What Throughline leaves in your codebase

Every slice that changes a target writes a human-readable entry to **`.throughline/CHANGELOG.md` inside that target** — newest first, with what changed, the files touched, the spec and standards it cited, and the final review verdict. It's written on the `sdd/<slice>` branch, so it merges atomically with the change and travels with your code even if it's ever separated from the framework. Turn it off per target with `changelog: off` in `targets/<id>.yml`.

## When not to use it

Skip the framework for throwaway scripts, one-line tweaks with no contract or security surface, and plain questions. The overhead is real and only pays off when a clear record and a strong review matter. For the small stuff, use `--micro`, the single commands, or just plain chat.

---

See also: [Building Features](04-building-features.md) · [Quality Gates](06-quality-gates.md) · [Commands](../COMMANDS.md)
