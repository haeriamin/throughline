import * as vscode from "vscode";
import { FrameworkModel } from "./model";

type Tone = "green" | "amber" | "red" | "blue" | "neutral";

const ICONS = {
  mark: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 18.5 L11 13 L15.1 9.6"/><circle cx="4.5" cy="18.5" r="1.4" fill="currentColor" stroke="none"/><circle cx="11" cy="13" r="1.4" fill="currentColor" stroke="none"/><circle cx="18" cy="7.5" r="3.4"/><path d="M16.4 7.7 L17.6 8.9 L19.9 6.2" stroke-width="1.5"/></svg>`,
  target: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4"/><circle cx="12" cy="12" r="0.6" fill="currentColor"/></svg>`,
  layers: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l9 5-9 5-9-5 9-5z"/><path d="M3 13l9 5 9-5"/></svg>`,
  alert: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4l9 16H3l9-16z"/><path d="M12 10v4M12 17.5v.5"/></svg>`,
  check: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5"/><path d="M8.5 12.5l2.5 2.5 4.5-5"/></svg>`,
  refresh: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 11a8 8 0 1 0-.6 4"/><path d="M20 4v5h-5"/></svg>`,
  inbox: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M4 13l2.5-7h11L20 13v5H4v-5z"/><path d="M4 13h4l1.5 2.5h5L16 13h4"/></svg>`,
};

// CSP nonce for the single inline <script>; regenerated on every render.
function getNonce(): string {
  let text = "";
  const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  for (let i = 0; i < 32; i++) {
    text += possible.charAt(Math.floor(Math.random() * possible.length));
  }
  return text;
}

export class DashboardPanel {
  private static current: DashboardPanel | undefined;
  private readonly panel: vscode.WebviewPanel;
  private readonly disposables: vscode.Disposable[] = [];

  static show(getModel: () => FrameworkModel | null, extensionUri: vscode.Uri): void {
    if (DashboardPanel.current) {
      DashboardPanel.current.panel.reveal();
      DashboardPanel.current.update(getModel());
      return;
    }
    const panel = vscode.window.createWebviewPanel("sddDashboard", "Throughline Dashboard", vscode.ViewColumn.One, {
      enableScripts: true,
    });
    panel.iconPath = vscode.Uri.joinPath(extensionUri, "media", "icon-color.svg");
    DashboardPanel.current = new DashboardPanel(panel, getModel);
  }

  static refreshIfOpen(model: FrameworkModel | null): void {
    DashboardPanel.current?.update(model);
  }

  private constructor(panel: vscode.WebviewPanel, getModel: () => FrameworkModel | null) {
    this.panel = panel;
    this.panel.onDidDispose(() => this.dispose(), null, this.disposables);
    this.panel.webview.onDidReceiveMessage(
      (msg: { command: string; file?: string }) => {
        if (msg.command === "refresh") {
          this.update(getModel());
        } else if (msg.command === "open" && msg.file) {
          void vscode.commands.executeCommand("vscode.open", vscode.Uri.file(msg.file));
        }
      },
      null,
      this.disposables
    );
    this.update(getModel());
  }

  private dispose(): void {
    DashboardPanel.current = undefined;
    for (const d of this.disposables) {
      d.dispose();
    }
  }

  private update(model: FrameworkModel | null): void {
    this.panel.webview.html = model ? this.render(model) : this.renderEmpty();
  }

  private shell(body: string, nonce: string): string {
    const csp = [
      `default-src 'none'`,
      `img-src ${this.panel.webview.cspSource} https: data:`,
      `style-src ${this.panel.webview.cspSource} 'unsafe-inline'`,
      `script-src 'nonce-${nonce}'`,
    ].join("; ");
    return `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="${csp}">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>${STYLES}</style></head><body><div class="wrap">${body}</div></body></html>`;
  }

  private renderEmpty(): string {
    return this.shell(`
      <div class="topbar">
        <div class="brand"><div class="mark">${ICONS.mark}</div>
          <div><h1>Throughline Dashboard</h1><div class="sub">no framework detected</div></div></div>
      </div>
      <div class="panel"><div class="empty">${ICONS.inbox}
        <div>No framework root found.</div>
        <div class="empty-hint">Open the folder containing <code>.throughline/memory/constitution.md</code>,
        or set <code>sddDashboard.frameworkRoot</code>.</div></div></div>`, getNonce());
  }

  private render(model: FrameworkModel): string {
    const nonce = getNonce();
    const logTailSize = vscode.workspace.getConfiguration("sddDashboard").get<number>("logTail", 15);
    const { stats, slices, queue, log } = model.snapshot(logTailSize);
    const escalated = queue.filter((q) => q.state === "escalated");

    const v = stats.verdicts;
    const reviewed = v.pass + v.conditional + v.fail;
    const vTotal = Math.max(1, reviewed + v.pending);
    const pct = (n: number) => ((n / vTotal) * 100).toFixed(1);
    const passRate = reviewed > 0 ? Math.round((v.pass / reviewed) * 100) + "%" : "—";

    const esc = (s: string) =>
      s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    const attr = (f: string) => esc(f).replace(/\\/g, "\\\\");

    const phaseTone = (p: string): Tone =>
      p === "Done" ? "green"
        : p === "Failed" ? "red"
          : p === "Needs Clarification" || p === "Design Draft" ? "amber"
            : p === "Implementing" || p === "Implemented" ? "blue"
              : "neutral";
    const verdictTone = (vd: string | null): Tone =>
      vd === "PASS" ? "green" : vd === "CONDITIONAL_PASS" ? "amber" : vd === "FAIL" ? "red" : "neutral";
    const pill = (text: string, tone: Tone) => `<span class="pill ${tone}">${esc(text)}</span>`;

    const kpi = (icon: string, num: string, lbl: string, tone: Tone = "neutral") =>
      `<div class="kpi tone-${tone}"><div class="ico">${icon}</div>
        <div class="num">${esc(num)}</div><div class="lbl">${esc(lbl)}</div></div>`;

    const progress = (done: number, total: number) =>
      total > 0
        ? `<div class="progress"><div class="track"><div class="fill" style="width:${Math.round((done / total) * 100)}%"></div></div><span class="txt">${done}/${total}</span></div>`
        : `<span class="txt">—</span>`;

    const sliceRows = slices
      .map(
        (s) => `<tr class="link" data-file="${attr(s.specFile)}">
          <td class="mono">${esc(s.id)}</td>
          <td>${esc(s.target)}</td>
          <td>${pill(s.phase, phaseTone(s.phase))}</td>
          <td>${progress(s.tasksDone, s.tasksTotal)}</td>
          <td>${s.verdict ? pill(s.verdict, verdictTone(s.verdict)) : '<span class="txt">—</span>'}</td></tr>`
      )
      .join("");

    const escRows = escalated
      .map(
        (q) => `<tr class="link" data-file="${attr(q.file)}">
          <td>${esc(q.name)}</td>
          <td class="dim mono">${esc(q.modified.toISOString().slice(0, 16).replace("T", " "))}</td></tr>`
      )
      .join("");

    const logRows = log
      .map(
        (l) => `<tr>
          <td class="dim mono">${esc(l.timestamp).slice(0, 16).replace("T", " ")}</td>
          <td>${esc(l.agent)}</td>
          <td class="mono">${esc(l.command)}</td>
          <td>${esc(l.target)}</td>
          <td>${l.verdict && l.verdict !== "-" ? pill(l.verdict, verdictTone(l.verdict)) : ""}</td>
          <td class="summary">${esc(l.summary)}</td></tr>`
      )
      .join("");

    const emptyRow = (msg: string) => `<div class="empty">${ICONS.inbox}<div>${esc(msg)}</div></div>`;

    const section = (title: string, count: string, content: string) => `
      <div class="section">
        <div class="section-head"><h2>${esc(title)}</h2><span class="count">${esc(count)}</span></div>
        <div class="panel">${content}</div>
      </div>`;

    return this.shell(`
      <div class="topbar">
        <div class="brand"><div class="mark">${ICONS.mark}</div>
          <div><h1>Throughline</h1><div class="sub mono">${esc(model.root)}</div></div></div>
        <button class="btn" id="refresh">${ICONS.refresh}<span>Refresh</span></button>
      </div>

      <div class="kpis">
        ${kpi(ICONS.target, String(stats.targets), `Targets · ${stats.activeTargets} active`)}
        ${kpi(ICONS.layers, String(stats.slices), `Slices · ${stats.activeSlices} active`, "blue")}
        ${kpi(ICONS.alert, String(stats.escalated), "Escalations", stats.escalated > 0 ? "red" : "neutral")}
        ${kpi(ICONS.check, passRate, `Pass rate · ${reviewed} reviews`, reviewed > 0 ? "green" : "neutral")}
      </div>

      <div class="section">
        <div class="section-head"><h2>Verdict distribution</h2></div>
        <div class="panel dist-panel">
          <div class="bar">
            <span class="green" style="width:${pct(v.pass)}%"></span>
            <span class="amber" style="width:${pct(v.conditional)}%"></span>
            <span class="red" style="width:${pct(v.fail)}%"></span>
            <span class="pend" style="width:${pct(v.pending)}%"></span>
          </div>
          <div class="legend">
            <span class="dot green">PASS ${v.pass}</span>
            <span class="dot amber">CONDITIONAL ${v.conditional}</span>
            <span class="dot red">FAIL ${v.fail}</span>
            <span class="dot neutral">pending ${v.pending}</span>
          </div>
        </div>
      </div>

      ${section(
        "Slice pipeline",
        slices.length ? `${slices.length} slices` : "",
        slices.length
          ? `<table><thead><tr><th>Slice</th><th>Target</th><th>Phase</th><th>Tasks</th><th>Verdict</th></tr></thead><tbody>${sliceRows}</tbody></table>`
          : emptyRow("No slices yet — run /throughline to begin.")
      )}

      ${section(
        "Escalations",
        escalated.length ? `${escalated.length} open` : "",
        escalated.length
          ? `<table><thead><tr><th>Item</th><th>Since</th></tr></thead><tbody>${escRows}</tbody></table>`
          : emptyRow("None — the queue is healthy.")
      )}

      ${section(
        "Recent activity",
        "",
        log.length
          ? `<table><thead><tr><th>When</th><th>Agent</th><th>Command</th><th>Target</th><th>Verdict</th><th>Summary</th></tr></thead><tbody>${logRows}</tbody></table>`
          : emptyRow("No operations logged yet.")
      )}

      <script nonce="${nonce}">
        const api = acquireVsCodeApi();
        document.getElementById("refresh").addEventListener("click", () => api.postMessage({ command: "refresh" }));
        for (const row of document.querySelectorAll("tr.link")) {
          row.addEventListener("click", () => api.postMessage({ command: "open", file: row.dataset.file }));
        }
      </script>`, nonce);
  }
}

const STYLES = `
:root {
  --s1:4px; --s2:8px; --s3:12px; --s4:16px; --s5:24px; --s6:32px;
  --r:10px; --r-sm:7px; --r-pill:999px;
  --border: color-mix(in srgb, var(--vscode-foreground) 13%, transparent);
  --border-soft: color-mix(in srgb, var(--vscode-foreground) 8%, transparent);
  --surface: color-mix(in srgb, var(--vscode-foreground) 3%, var(--vscode-editor-background));
  --surface-hover: color-mix(in srgb, var(--vscode-foreground) 6.5%, var(--vscode-editor-background));
  --head-bg: color-mix(in srgb, var(--vscode-foreground) 2.5%, transparent);
  --muted: color-mix(in srgb, var(--vscode-foreground) 62%, transparent);
  --faint: color-mix(in srgb, var(--vscode-foreground) 42%, transparent);
  --accent: var(--vscode-textLink-foreground, #4493f8);
  --green: var(--vscode-charts-green, #3fb950);
  --amber: var(--vscode-charts-yellow, #d29922);
  --red: var(--vscode-charts-red, #f85149);
  --blue: var(--vscode-charts-blue, #4493f8);
}
* { box-sizing: border-box; }
body { margin:0; padding:0; font-family: var(--vscode-font-family); font-size:13px; line-height:1.5;
  color: var(--vscode-foreground); background: var(--vscode-editor-background); -webkit-font-smoothing: antialiased; }
.wrap { max-width:1080px; margin:0 auto; padding: var(--s6) var(--s6) 64px; }
.mono { font-family: var(--vscode-editor-font-family, ui-monospace, "SF Mono", Menlo, monospace); }

.topbar { display:flex; align-items:center; justify-content:space-between; gap: var(--s4); margin-bottom: var(--s6); }
.brand { display:flex; align-items:center; gap: var(--s3); min-width:0; }
.mark { width:34px; height:34px; flex:none; border-radius:9px; display:grid; place-items:center;
  background: color-mix(in srgb, var(--accent) 15%, transparent); color: var(--accent); }
.mark svg { width:19px; height:19px; }
.brand h1 { margin:0; font-size:15px; font-weight:600; letter-spacing:-0.01em; }
.brand .sub { font-size:11px; color: var(--faint); margin-top:2px; max-width:560px;
  overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.btn { display:inline-flex; align-items:center; gap:6px; flex:none; font:inherit; font-size:12px; font-weight:500;
  color: var(--vscode-foreground); background: var(--surface); border:1px solid var(--border);
  border-radius: var(--r-sm); padding:6px 12px; cursor:pointer; transition: background .12s, border-color .12s; }
.btn svg { width:14px; height:14px; }
.btn:hover { background: var(--surface-hover); border-color: color-mix(in srgb, var(--vscode-foreground) 24%, transparent); }
.btn:active { transform: translateY(0.5px); }

.kpis { display:grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: var(--s3); margin-bottom: var(--s5); }
.kpi { background: var(--surface); border:1px solid var(--border-soft); border-radius: var(--r); padding: var(--s4);
  transition: border-color .12s; }
.kpi:hover { border-color: var(--border); }
.kpi .ico { width:18px; height:18px; color: var(--faint); }
.kpi .num { font-size:27px; font-weight:650; letter-spacing:-0.02em; line-height:1; margin-top: var(--s4); }
.kpi .lbl { font-size:11px; text-transform:uppercase; letter-spacing:.05em; color: var(--muted); margin-top:7px; }
.kpi.tone-green .ico { color: var(--green); } .kpi.tone-green .num { color: var(--green); }
.kpi.tone-blue .ico  { color: var(--blue); }
.kpi.tone-red .ico   { color: var(--red); }  .kpi.tone-red .num { color: var(--red); }

.section { margin-top: var(--s6); }
.section-head { display:flex; align-items:baseline; justify-content:space-between; margin-bottom: var(--s3); padding:0 2px; }
.section-head h2 { margin:0; font-size:11px; font-weight:600; text-transform:uppercase; letter-spacing:.08em; color: var(--muted); }
.section-head .count { font-size:11px; color: var(--faint); }
.panel { background: var(--surface); border:1px solid var(--border-soft); border-radius: var(--r); overflow:hidden; }

.dist-panel { padding: var(--s5); display:flex; flex-direction:column; gap: var(--s4); }
.bar { display:flex; height:10px; border-radius: var(--r-pill); overflow:hidden; background: var(--border-soft); }
.bar span { height:100%; transition: width .35s ease; }
.bar .green { background: var(--green); } .bar .amber { background: var(--amber); }
.bar .red { background: var(--red); } .bar .pend { background: color-mix(in srgb, var(--vscode-foreground) 14%, transparent); }
.legend { display:flex; flex-wrap:wrap; gap: var(--s5); font-size:11.5px; }
.legend .dot { display:inline-flex; align-items:center; gap:7px; color: var(--muted); }
.legend .dot::before { content:""; width:8px; height:8px; border-radius:2.5px; background: currentColor; }
.legend .green::before { background: var(--green); } .legend .amber::before { background: var(--amber); }
.legend .red::before { background: var(--red); } .legend .neutral::before { background: var(--faint); }

table { border-collapse: collapse; width:100%; font-size:12.5px; }
thead th { text-align:left; font-weight:500; font-size:10.5px; text-transform:uppercase; letter-spacing:.05em;
  color: var(--faint); padding:11px var(--s4); background: var(--head-bg); border-bottom:1px solid var(--border-soft); }
tbody td { padding:11px var(--s4); border-bottom:1px solid var(--border-soft); vertical-align:middle; }
tbody tr:last-child td { border-bottom:none; }
tr.link { cursor:pointer; transition: background .1s; }
tr.link:hover { background: var(--surface-hover); }
td.dim { color: var(--faint); white-space:nowrap; }
td.summary { color: var(--muted); }
.txt { color: var(--faint); font-size:11.5px; }

.pill { display:inline-flex; align-items:center; gap:6px; font-size:11px; font-weight:500; padding:3px 9px 3px 8px;
  border-radius: var(--r-pill); border:1px solid transparent; white-space:nowrap; }
.pill::before { content:""; width:6px; height:6px; border-radius:50%; background: currentColor; }
.pill.green { color: var(--green); background: color-mix(in srgb, var(--green) 13%, transparent); border-color: color-mix(in srgb, var(--green) 26%, transparent); }
.pill.amber { color: var(--amber); background: color-mix(in srgb, var(--amber) 13%, transparent); border-color: color-mix(in srgb, var(--amber) 26%, transparent); }
.pill.red { color: var(--red); background: color-mix(in srgb, var(--red) 13%, transparent); border-color: color-mix(in srgb, var(--red) 26%, transparent); }
.pill.blue { color: var(--blue); background: color-mix(in srgb, var(--blue) 13%, transparent); border-color: color-mix(in srgb, var(--blue) 26%, transparent); }
.pill.neutral { color: var(--muted); background: color-mix(in srgb, var(--vscode-foreground) 8%, transparent); border-color: var(--border-soft); }
.pill.neutral::before { opacity:.6; }

.progress { display:inline-flex; align-items:center; gap:9px; }
.progress .track { width:56px; height:5px; border-radius:3px; background: var(--border-soft); overflow:hidden; }
.progress .fill { height:100%; background: var(--blue); border-radius:3px; transition: width .35s ease; }
.progress .txt { font-size:11px; color: var(--faint); }

.empty { display:flex; flex-direction:column; align-items:center; gap:10px; padding: var(--s6) var(--s4);
  color: var(--faint); text-align:center; }
.empty svg { width:26px; height:26px; opacity:.55; }
.empty-hint { font-size:11.5px; }
.empty code, .empty-hint code { font-family: var(--vscode-editor-font-family, monospace); font-size:11px;
  background: color-mix(in srgb, var(--vscode-foreground) 8%, transparent); padding:1px 5px; border-radius:4px; }
`;
