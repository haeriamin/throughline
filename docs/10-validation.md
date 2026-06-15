# 10 · Test It on Your Own Work

The framework's value is just a claim until you measure it on real tasks. Use this before you
trust it for anything important, and to decide if the extra steps are worth it for *your* work.

## Why bother

The promise is "more checks → fewer bugs, a full record, an acceptable cost." None of that is
proven for your codebase. A few hours of measuring turns a guess into a decision.

## The side-by-side test

Pick **8–10 real tasks** of different sizes from your backlog. Build each one twice, on
throwaway branches:

- **Plain** — plain Copilot or Claude Code, the way you normally work.
- **Framework** — `/dev:feature <target> "<task>"`.

For each task, write down:

| What to measure | How |
|-----------------|-----|
| Time taken | Note start and stop times |
| Token cost | The tool's usage screen, or your API dashboard |
| Times you stepped in | Count how often you had to correct, answer, or redirect |
| Bugs found while reading the change | Bugs you or a teammate spot in the diff |
| Bugs found by tests | Failures the test run catches |
| Bugs that got through | Bugs found *after* you would have merged — the most important number |
| Rules followed | Check 5 rules per task: were they followed? |

## Reading the result

- **Worth it** if "bugs that got through" and broken rules drop enough to pay for the extra
  time and tokens — for *that kind of task*. It usually is not worth it for tiny changes (use
  `--micro` or plain there), and usually is worth it for big or sensitive ones. You are looking
  for where the line crosses.
- **Adjust, don't drop it**, if the results are close: relax the limits (a one-file
  constitution change), move more rules to real tool checks (`Tool:`), add examples for the
  patterns you hit, and measure again.

## Test the "it builds up over time" claim

Run 3 or more similar projects one after another. Between them, add examples and record your
decisions (`/dev:ingest-exemplars`, `/dev:review-escalated`). Track how often you had to step
in, per project. A falling number means it is building up as promised. A flat number means
your examples are not paying off yet — which is also useful to know.

## Share what you find

If you share your results — even "not worth it for X" — open an issue or PR. Real numbers from
real tasks are the most useful thing you can give this project. It is the evidence the
framework does not have yet.

---
[← Troubleshooting](09-troubleshooting.md) · [Guide index](README.md)
