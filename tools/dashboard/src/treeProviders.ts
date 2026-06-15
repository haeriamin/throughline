import * as vscode from "vscode";
import { FrameworkModel, QueueItem, QueueState, ReportInfo } from "./model";

type ModelSource = () => FrameworkModel | null;

abstract class BaseProvider<T> implements vscode.TreeDataProvider<T> {
  private readonly emitter = new vscode.EventEmitter<T | undefined>();
  readonly onDidChangeTreeData = this.emitter.event;

  constructor(protected readonly getModel: ModelSource) {}

  refresh(): void {
    this.emitter.fire(undefined);
  }

  abstract getTreeItem(element: T): vscode.TreeItem;
  abstract getChildren(element?: T): T[];
}

function openCommand(file: string): vscode.Command {
  return {
    command: "vscode.open",
    title: "Open",
    arguments: [vscode.Uri.file(file)],
  };
}

// ---------- Targets ----------

interface TargetNode {
  label: string;
  description: string;
  tooltip: string;
  file: string;
  icon: vscode.ThemeIcon;
}

export class TargetsProvider extends BaseProvider<TargetNode> {
  getChildren(): TargetNode[] {
    const model = this.getModel();
    if (!model) {
      return [];
    }
    return model.targets().map((t) => ({
      label: t.id,
      description: `${t.status} · ${t.vcs}${t.stack.length ? " · " + t.stack.join(",") : ""}`,
      tooltip: `${t.path}\nclass: ${t.complexityClass}`,
      file: t.file,
      icon: new vscode.ThemeIcon(
        t.status === "active" ? "repo" : "archive",
        t.status === "active" ? undefined : new vscode.ThemeColor("disabledForeground")
      ),
    }));
  }

  getTreeItem(node: TargetNode): vscode.TreeItem {
    const item = new vscode.TreeItem(node.label);
    item.description = node.description;
    item.tooltip = node.tooltip;
    item.iconPath = node.icon;
    item.command = openCommand(node.file);
    return item;
  }
}

// ---------- Slices ----------

interface SliceNode {
  label: string;
  description: string;
  tooltip: string;
  file: string;
  icon: vscode.ThemeIcon;
}

const PHASE_ICONS: Record<string, { icon: string; color?: string }> = {
  "Needs Clarification": { icon: "question", color: "charts.yellow" },
  Specified: { icon: "note" },
  Planned: { icon: "checklist" },
  "Design Draft": { icon: "symbol-structure", color: "charts.yellow" },
  Tasked: { icon: "list-ordered" },
  Implementing: { icon: "tools", color: "charts.blue" },
  Implemented: { icon: "beaker", color: "charts.blue" },
  Done: { icon: "pass-filled", color: "charts.green" },
  Failed: { icon: "error", color: "charts.red" },
};

export class SlicesProvider extends BaseProvider<SliceNode> {
  getChildren(): SliceNode[] {
    const model = this.getModel();
    if (!model) {
      return [];
    }
    return model.slices().map((s) => {
      const progress = s.tasksTotal > 0 ? ` ${s.tasksDone}/${s.tasksTotal}` : "";
      const spec = PHASE_ICONS[s.phase] ?? { icon: "circle-outline" };
      return {
        label: s.id,
        description: `${s.phase}${progress} → ${s.target}`,
        tooltip: `${s.name}\nphase: ${s.phase}${s.verdict ? `\nverdict: ${s.verdict}` : ""}`,
        file: s.specFile,
        icon: new vscode.ThemeIcon(spec.icon, spec.color ? new vscode.ThemeColor(spec.color) : undefined),
      };
    });
  }

  getTreeItem(node: SliceNode): vscode.TreeItem {
    const item = new vscode.TreeItem(node.label);
    item.description = node.description;
    item.tooltip = node.tooltip;
    item.iconPath = node.icon;
    item.command = openCommand(node.file);
    return item;
  }
}

// ---------- Work Queue ----------

type QueueNode =
  | { kind: "state"; state: QueueState; count: number }
  | { kind: "item"; item: QueueItem };

const STATE_ICONS: Record<QueueState, { icon: string; color?: string }> = {
  pending: { icon: "clock" },
  "in-progress": { icon: "sync", color: "charts.blue" },
  completed: { icon: "pass", color: "charts.green" },
  escalated: { icon: "warning", color: "charts.red" },
};

export class QueueProvider extends BaseProvider<QueueNode> {
  getChildren(element?: QueueNode): QueueNode[] {
    const model = this.getModel();
    if (!model) {
      return [];
    }
    const items = model.queue();
    if (!element) {
      return (["escalated", "in-progress", "pending", "completed"] as QueueState[]).map((state) => ({
        kind: "state",
        state,
        count: items.filter((i) => i.state === state).length,
      }));
    }
    if (element.kind === "state") {
      return items
        .filter((i) => i.state === element.state)
        .sort((a, b) => b.modified.getTime() - a.modified.getTime())
        .map((item) => ({ kind: "item", item }));
    }
    return [];
  }

  getTreeItem(node: QueueNode): vscode.TreeItem {
    if (node.kind === "state") {
      const item = new vscode.TreeItem(
        node.state,
        node.count > 0 ? vscode.TreeItemCollapsibleState.Expanded : vscode.TreeItemCollapsibleState.Collapsed
      );
      item.description = String(node.count);
      const spec = STATE_ICONS[node.state];
      item.iconPath = new vscode.ThemeIcon(spec.icon, spec.color ? new vscode.ThemeColor(spec.color) : undefined);
      return item;
    }
    const item = new vscode.TreeItem(node.item.name);
    item.description = node.item.modified.toISOString().slice(0, 10);
    item.command = openCommand(node.item.file);
    item.iconPath = new vscode.ThemeIcon("file");
    return item;
  }
}

// ---------- Reports ----------

type ReportNode =
  | { kind: "group"; target: string; count: number }
  | { kind: "report"; report: ReportInfo };

export class ReportsProvider extends BaseProvider<ReportNode> {
  getChildren(element?: ReportNode): ReportNode[] {
    const model = this.getModel();
    if (!model) {
      return [];
    }
    const reports = model.reports();
    if (!element) {
      const targets = Array.from(new Set(reports.map((r) => r.target))).sort();
      return targets.map((target) => ({
        kind: "group",
        target,
        count: reports.filter((r) => r.target === target).length,
      }));
    }
    if (element.kind === "group") {
      return reports
        .filter((r) => r.target === element.target)
        .map((report) => ({ kind: "report", report }));
    }
    return [];
  }

  getTreeItem(node: ReportNode): vscode.TreeItem {
    if (node.kind === "group") {
      const item = new vscode.TreeItem(
        node.target === "-" ? "(portfolio)" : node.target,
        vscode.TreeItemCollapsibleState.Expanded
      );
      item.description = String(node.count);
      item.iconPath = new vscode.ThemeIcon("folder");
      return item;
    }
    const r = node.report;
    const item = new vscode.TreeItem(r.name);
    const conf = r.confidence !== null ? ` (${r.confidence.toFixed(2)})` : "";
    item.description = r.verdict ? `${r.verdict}${conf}` : r.kind;
    const color =
      r.verdict === "PASS"
        ? "charts.green"
        : r.verdict === "CONDITIONAL_PASS"
          ? "charts.yellow"
          : r.verdict === "FAIL"
            ? "charts.red"
            : undefined;
    item.iconPath = new vscode.ThemeIcon(
      r.kind === "test" ? "beaker" : r.kind === "review" ? "verified" : "graph",
      color ? new vscode.ThemeColor(color) : undefined
    );
    item.command = openCommand(r.file);
    return item;
  }
}
