import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type GitCounts = {
  staged: number;
  modified: number;
  untracked: number;
};

const STATUS_KEY = "git-status";
const POLL_INTERVAL_MS = 2_000;
const GIT_TIMEOUT_MS = 1_500;

function parsePorcelain(output: string): GitCounts {
  const counts: GitCounts = { staged: 0, modified: 0, untracked: 0 };
  const records = output.split("\0");

  for (let index = 0; index < records.length; index++) {
    const record = records[index];
    if (!record || record.length < 3) continue;

    const x = record[0]!;
    const y = record[1]!;

    if (x === "?" && y === "?") {
      counts.untracked++;
      continue;
    }

    if (x !== " ") counts.staged++;
    if (y !== " ") counts.modified++;

    // With -z, rename/copy records are followed by their source path. It is
    // not another status record, so skip it rather than counting it twice.
    if (x === "R" || x === "C" || y === "R" || y === "C") index++;
  }

  return counts;
}

function renderStatus(ctx: ExtensionContext, branch: string, counts: GitCounts): string {
  const { theme } = ctx.ui;
  const parts = [theme.fg("accent", `git: ${branch}`)];

  if (counts.staged > 0) parts.push(theme.fg("success", `+${counts.staged}`));
  if (counts.modified > 0) parts.push(theme.fg("warning", `~${counts.modified}`));
  if (counts.untracked > 0) parts.push(theme.fg("muted", `?${counts.untracked}`));

  return parts.join(" ");
}

export default function (pi: ExtensionAPI) {
  let pollTimer: ReturnType<typeof setInterval> | undefined;
  let refreshing = false;
  let active = false;

  const clear = (ctx: ExtensionContext) => ctx.ui.setStatus(STATUS_KEY, undefined);

  const refresh = async (ctx: ExtensionContext): Promise<void> => {
    if (!active || ctx.mode !== "tui" || refreshing) return;
    refreshing = true;

    try {
      const insideWorkTree = await pi.exec(
        "git",
        ["-C", ctx.cwd, "rev-parse", "--is-inside-work-tree"],
        { timeout: GIT_TIMEOUT_MS },
      );
      if (!active) return;
      if (insideWorkTree.code !== 0 || insideWorkTree.stdout.trim() !== "true") {
        clear(ctx);
        return;
      }

      const [branchResult, statusResult] = await Promise.all([
        pi.exec("git", ["-C", ctx.cwd, "symbolic-ref", "--quiet", "--short", "HEAD"], {
          timeout: GIT_TIMEOUT_MS,
        }),
        pi.exec("git", ["-C", ctx.cwd, "status", "--porcelain=v1", "-z", "--untracked-files=normal"], {
          timeout: GIT_TIMEOUT_MS,
        }),
      ]);

      if (!active) return;
      if (statusResult.code !== 0) {
        clear(ctx);
        return;
      }

      let branch = branchResult.stdout.trim();
      if (branchResult.code !== 0 || !branch) {
        const headResult = await pi.exec("git", ["-C", ctx.cwd, "rev-parse", "--short", "HEAD"], {
          timeout: GIT_TIMEOUT_MS,
        });
        if (!active) return;
        if (headResult.code !== 0 || !headResult.stdout.trim()) {
          clear(ctx);
          return;
        }
        branch = headResult.stdout.trim();
      }

      ctx.ui.setStatus(STATUS_KEY, renderStatus(ctx, branch, parsePorcelain(statusResult.stdout)));
    } catch {
      // Git is intentionally best-effort; the footer stays quiet on failures.
      if (active) clear(ctx);
    } finally {
      refreshing = false;
    }
  };

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    active = true;
    void refresh(ctx);
    pollTimer = setInterval(() => void refresh(ctx), POLL_INTERVAL_MS);
  });

  pi.on("tool_execution_end", (_event, ctx) => {
    void refresh(ctx);
  });

  pi.on("session_shutdown", (_event, ctx) => {
    active = false;
    if (pollTimer) clearInterval(pollTimer);
    pollTimer = undefined;
    clear(ctx);
  });
}
