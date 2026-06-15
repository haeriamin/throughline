# 7 · The Dashboard

A VS Code extension (`tools/dashboard/`) that renders the framework's state live. No
database, no services — it parses the same markdown the agents write, across the framework
and each registered target's `.throughline/` provenance, and file watchers keep it current.

## Install

```bash
cd tools/dashboard
npm install
npm run compile
npx @vscode/vsce package
code --install-extension sdd-dashboard-0.1.0.vsix
```

For development instead: open `tools/dashboard` in VS Code and press **F5**
(Extension Development Host).

## What you get

**Activity bar — "SDD Dashboard"** (four views):

| View | Shows | Click |
|------|-------|-------|
| Targets | Registered projects, status, stack | Opens `targets/<id>.yml` |
| Slices | Lifecycle phase per slice + task progress (`3/7`) from checkbox parsing | Opens the spec |
| Work Queue | escalated / in-progress / pending / completed items | Opens the work item |
| Reports | Test + review reports grouped by target, verdict-colored | Opens the report |

Sources: each registered target's `<target>/.throughline/{specs,review-reports,work-queue}`
for slices, test + review evidence, and per-target queue records; the framework's live
`work-queue/` (pending / in-progress + the escalated lane), the global `audit/`
portfolio roll-ups, and `wiki/log.md` for recent activity.

**`SDD: Open Dashboard`** (command palette) — a polished webview: KPI cards (targets,
active slices, escalations, pass rate), a verdict-distribution bar, the slice pipeline with
status pills and per-slice task progress, and recent activity. It adapts to your VS Code
theme (light/dark) and matches the editor's native look.

**Status bar** — a persistent SDD item that turns warning-colored with a count whenever
anything sits in the framework's `work-queue/escalated/` lane. Click it to open the dashboard.

## Configuration

| Setting | Default | Purpose |
|---------|---------|---------|
| `sddDashboard.frameworkRoot` | auto | Absolute path to the framework; leave empty to auto-detect the workspace folder containing `.throughline/memory/constitution.md` |
| `sddDashboard.logTail` | 15 | Operations-log entries shown on the dashboard |

Auto-detection means the dashboard works both in the framework repo itself and in the
multi-root `targets/<id>.code-workspace` files that `/dev:target` generates.

---
[← Quality Gates](06-quality-gates.md) · Next: [Customization →](08-customization.md)
