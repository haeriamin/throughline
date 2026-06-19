import * as fs from "fs";
import * as path from "path";
import * as vscode from "vscode";

export interface TargetInfo {
  id: string;
  path: string;
  throughlineDir: string;
  vcs: string;
  stack: string[];
  status: string;
  complexityClass: string;
  file: string;
}

export type SlicePhase =
  | "Needs Clarification"
  | "Specified"
  | "Planned"
  | "Design Draft"
  | "Tasked"
  | "Implementing"
  | "Implemented"
  | "Done"
  | "Failed";

export interface SliceInfo {
  id: string;
  name: string;
  target: string;
  phase: SlicePhase;
  tasksDone: number;
  tasksTotal: number;
  verdict: string | null;
  dir: string;
  specFile: string;
}

export type QueueState = "pending" | "in-progress" | "completed" | "escalated";

export interface QueueItem {
  name: string;
  state: QueueState;
  file: string;
  modified: Date;
}

export interface ReportInfo {
  target: string;
  name: string;
  kind: "review" | "test" | "portfolio" | "other";
  verdict: string | null;
  confidence: number | null;
  file: string;
}

export interface LogEntry {
  timestamp: string;
  agent: string;
  command: string;
  target: string;
  verdict: string;
  summary: string;
}

export interface FrameworkStats {
  targets: number;
  activeTargets: number;
  slices: number;
  activeSlices: number;
  escalated: number;
  verdicts: { pass: number; conditional: number; fail: number; pending: number };
}

/** One consistent read of the whole framework state — each artifact parsed exactly once. */
export interface Snapshot {
  targets: TargetInfo[];
  slices: SliceInfo[];
  queue: QueueItem[];
  reports: ReportInfo[];
  log: LogEntry[];
  stats: FrameworkStats;
}

const QUEUE_STATES: QueueState[] = ["pending", "in-progress", "completed", "escalated"];

function safeRead(file: string): string | null {
  try {
    return fs.readFileSync(file, "utf8");
  } catch {
    return null;
  }
}

function listFiles(dir: string, ext?: string): string[] {
  try {
    return fs
      .readdirSync(dir, { withFileTypes: true })
      .filter((e) => e.isFile() && !e.name.startsWith(".") && (!ext || e.name.endsWith(ext)))
      .map((e) => path.join(dir, e.name));
  } catch {
    return [];
  }
}

/** Minimal flat `key: value` YAML reader — enough for targets/<id>.yml. */
function readFlatYaml(file: string): Record<string, string> {
  const out: Record<string, string> = {};
  const text = safeRead(file);
  if (!text) {
    return out;
  }
  for (const line of text.split(/\r?\n/)) {
    const m = /^([a-z_]+):\s*(.*)$/.exec(line);
    if (!m) {
      continue;
    }
    let value = m[2].trim();
    if (value.startsWith('"') || value.startsWith("'")) {
      // Quoted scalar (single or double): take content up to the matching closing
      // quote (drops any trailing # comment).
      const q = value[0];
      const end = value.indexOf(q, 1);
      value = end >= 0 ? value.slice(1, end) : value.slice(1);
    } else {
      // Unquoted scalar: strip a trailing " # comment" (YAML comments start at whitespace + #).
      value = value.replace(/\s+#.*$/, "").trim();
    }
    out[m[1]] = value;
  }
  return out;
}

export class FrameworkModel {
  constructor(public readonly root: string) {}

  static resolveRoot(): string | null {
    const configured = vscode.workspace
      .getConfiguration("sddDashboard")
      .get<string>("frameworkRoot", "")
      .trim();
    if (configured && fs.existsSync(path.join(configured, ".throughline", "memory", "constitution.md"))) {
      return configured;
    }
    for (const folder of vscode.workspace.workspaceFolders ?? []) {
      const candidate = folder.uri.fsPath;
      if (fs.existsSync(path.join(candidate, ".throughline", "memory", "constitution.md"))) {
        return candidate;
      }
    }
    return null;
  }

  targets(): TargetInfo[] {
    return listFiles(path.join(this.root, "targets"), ".yml")
      .filter((f) => !f.endsWith("TEMPLATE.yml"))
      .map((f) => {
        const y = readFlatYaml(f);
        return {
          id: y["id"] ?? path.basename(f, ".yml"),
          path: y["path"] ?? "",
          throughlineDir: y["throughline_dir"] ?? ".throughline",
          vcs: y["vcs"] ?? "?",
          stack: (y["stack"] ?? "").replace(/[\[\]]/g, "").split(",").map((s) => s.trim()).filter(Boolean),
          status: y["status"] ?? "active",
          complexityClass: y["complexity_class"] ?? "MEDIUM",
          file: f,
        };
      });
  }

  /** Absolute path to a target's SDD provenance home (<target>/.throughline). */
  private targetThroughline(t: TargetInfo): string {
    const base = path.isAbsolute(t.path) ? t.path : path.join(this.root, t.path);
    return path.join(base, t.throughlineDir || ".throughline");
  }

  /** Absolute .throughline provenance homes for every registered target (for file watching). */
  targetThroughlineDirs(): string[] {
    return this.targets().map((t) => this.targetThroughline(t));
  }

  slices(): SliceInfo[] {
    return this.buildSlices(this.reports());
  }

  private buildSlices(reports: ReportInfo[]): SliceInfo[] {
    // Slices live under each registered target's <target>/.throughline/specs/.
    const out: SliceInfo[] = [];
    for (const t of this.targets()) {
      const specsDir = path.join(this.targetThroughline(t), "specs");
      let dirs: string[] = [];
      try {
        dirs = fs
          .readdirSync(specsDir, { withFileTypes: true })
          .filter((e) => e.isDirectory() && /^\d{3}-/.test(e.name))
          .map((e) => path.join(specsDir, e.name));
      } catch {
        continue;
      }
      for (const dir of dirs) {
        out.push(this.readSlice(dir, reports, t.id));
      }
    }
    return out;
  }

  private readSlice(dir: string, reports: ReportInfo[], targetId: string): SliceInfo {
    const id = path.basename(dir);
    const specFile = path.join(dir, "spec.md");
    const spec = safeRead(specFile) ?? "";
    const targetMatch = /\*\*Target\*\*:\s*([^\s[\]]+)/.exec(spec);
    const target = targetMatch ? targetMatch[1].trim() : targetId;

    const hasPlan = fs.existsSync(path.join(dir, "plan.md"));
    const hasTasks = fs.existsSync(path.join(dir, "tasks.md"));
    const design = safeRead(path.join(dir, "design.md"));

    let tasksDone = 0;
    let tasksTotal = 0;
    const tasksText = safeRead(path.join(dir, "tasks.md"));
    if (tasksText) {
      tasksTotal = (tasksText.match(/^\s*-\s*\[[ xX]\]/gm) ?? []).length;
      tasksDone = (tasksText.match(/^\s*-\s*\[[xX]\]/gm) ?? []).length;
    }

    // Match this slice's own review reports by exact name AND target, so two targets that each
    // have a same-numbered slice (e.g. 001-*) never cross-attribute each other's verdicts.
    const sliceReports = reports.filter(
      (r) => r.kind === "review" && r.name === `${id}-review` && (target === "?" || r.target === target)
    );
    const verdict = sliceReports.length > 0 ? sliceReports[sliceReports.length - 1].verdict : null;

    let phase: SlicePhase;
    if (verdict === "PASS" || verdict === "CONDITIONAL_PASS") {
      phase = "Done";
    } else if (verdict === "FAIL") {
      phase = "Failed";
    } else if (hasTasks && tasksTotal > 0 && tasksDone === tasksTotal) {
      phase = "Implemented";
    } else if (hasTasks && tasksDone > 0) {
      phase = "Implementing";
    } else if (hasTasks) {
      phase = "Tasked";
    } else if (design && !/\*\*Status\*\*:\s*.*Approved/.test(design)) {
      phase = "Design Draft";
    } else if (hasPlan) {
      phase = "Planned";
    } else if (spec.includes("[NEEDS CLARIFICATION")) {
      phase = "Needs Clarification";
    } else {
      phase = "Specified";
    }

    const nameMatch = /^#\s*Feature Specification:\s*(.+)$/m.exec(spec);
    return {
      id,
      name: nameMatch ? nameMatch[1].trim() : id,
      target,
      phase,
      tasksDone,
      tasksTotal,
      verdict,
      dir,
      specFile,
    };
  }

  queue(): QueueItem[] {
    const items: QueueItem[] = [];
    const add = (f: string, state: QueueState) => {
      let modified = new Date(0);
      try {
        modified = fs.statSync(f).mtime;
      } catch {
        /* keep epoch */
      }
      items.push({ name: path.basename(f, ".md"), state, file: f, modified });
    };
    // Global live lanes (cross-target orchestration); completed is per-target.
    for (const state of QUEUE_STATES) {
      if (state === "completed") {
        continue;
      }
      for (const f of listFiles(path.join(this.root, "work-queue", state), ".md")) {
        add(f, state);
      }
    }
    // Per-target durable done records.
    for (const t of this.targets()) {
      for (const f of listFiles(path.join(this.targetThroughline(t), "work-queue", "completed"), ".md")) {
        add(f, "completed");
      }
    }
    return items;
  }

  reports(): ReportInfo[] {
    const out: ReportInfo[] = [];
    // Framework: the global audit roll-up at audit/ root (portfolio scope = "-").
    for (const f of listFiles(path.join(this.root, "audit"), ".md")) {
      out.push(this.readReport(f, "-"));
    }
    // Per-target: per-slice test/review reports under <target>/.throughline/review-reports/.
    for (const t of this.targets()) {
      for (const f of listFiles(path.join(this.targetThroughline(t), "review-reports"), ".md")) {
        out.push(this.readReport(f, t.id));
      }
    }
    return out;
  }

  private readReport(file: string, target: string): ReportInfo {
    const name = path.basename(file, ".md");
    const text = safeRead(file) ?? "";
    let kind: ReportInfo["kind"] = "other";
    if (name.endsWith("-review")) {
      kind = "review";
    } else if (name.endsWith("-tests")) {
      kind = "test";
    } else if (name.includes("portfolio") || name.includes("recommendations")) {
      kind = "portfolio";
    }
    const verdictMatch = /\b(CONDITIONAL_PASS|PASS|FAIL)\b/.exec(text);
    // Exclude '=' from the gap so the verdict line ("confidence 0.96") wins over the
    // formula line ("confidence = 0.40\u00b7..."), regardless of their order in the report.
    const confMatch = /confidence[^0-9=]*(0\.\d{1,2}|1\.0+)/i.exec(text);
    return {
      target,
      name,
      kind,
      verdict: verdictMatch ? verdictMatch[1] : null,
      confidence: confMatch ? parseFloat(confMatch[1]) : null,
      file,
    };
  }

  logTail(n: number): LogEntry[] {
    // Merge the framework log (framework-level events) with each target's
    // <target>/.throughline/wiki/log.md (that target's slice events), newest first.
    const texts: string[] = [];
    const fw = safeRead(path.join(this.root, "wiki", "log.md"));
    if (fw) {
      texts.push(fw);
    }
    for (const t of this.targets()) {
      const tl = safeRead(path.join(this.targetThroughline(t), "wiki", "log.md"));
      if (tl) {
        texts.push(tl);
      }
    }
    const entries = texts
      .join("\n")
      .split(/\r?\n/)
      .filter((l) => /^\|\s*\d{4}-\d{2}-\d{2}T/.test(l))
      .map((row) => {
        // Strip the leading/trailing table pipes first, then split. Columns:
        // ts | agent | command | target | verdict | summary | artifacts
        const cells = row
          .replace(/^\s*\|/, "")
          .replace(/\|\s*$/, "")
          .split("|")
          .map((c) => c.trim());
        // A literal pipe inside summary/artifacts only shifts the trailing columns, so keep the
        // five fixed leading fields and re-join any overflow into summary (artifacts is dropped).
        return {
          timestamp: cells[0] ?? "",
          agent: cells[1] ?? "",
          command: cells[2] ?? "",
          target: cells[3] ?? "",
          verdict: cells[4] ?? "",
          summary: cells.length > 6 ? cells.slice(5, cells.length - 1).join(" | ") : (cells[5] ?? ""),
        };
      });
    entries.sort((a, b) => a.timestamp.localeCompare(b.timestamp));
    return entries.slice(-n).reverse();
  }

  stats(): FrameworkStats {
    return this.snapshot(0).stats;
  }

  snapshot(logTailN: number): Snapshot {
    const targets = this.targets();
    const reports = this.reports();
    const slices = this.buildSlices(reports);
    const queue = this.queue();
    const log = logTailN > 0 ? this.logTail(logTailN) : [];

    const verdicts = { pass: 0, conditional: 0, fail: 0, pending: 0 };
    for (const r of reports) {
      if (r.kind !== "review") {
        continue;
      }
      if (r.verdict === "PASS") {
        verdicts.pass++;
      } else if (r.verdict === "CONDITIONAL_PASS") {
        verdicts.conditional++;
      } else if (r.verdict === "FAIL") {
        verdicts.fail++;
      } else {
        verdicts.pending++;
      }
    }

    const stats: FrameworkStats = {
      targets: targets.length,
      activeTargets: targets.filter((t) => t.status === "active").length,
      slices: slices.length,
      activeSlices: slices.filter((s) => s.phase !== "Done").length,
      escalated: queue.filter((q) => q.state === "escalated").length,
      verdicts,
    };
    return { targets, slices, queue, reports, log, stats };
  }
}
