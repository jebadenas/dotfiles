/**
 * herdr-fork-split
 *
 * When you /fork (or /clone) a pi session while running inside a HERDR pane,
 * this extension:
 *   1. Moves the current pane (now running the new fork) into a NEW tab.
 *   2. Splits that pane to the right.
 *   3. Resumes the parent session you forked from in the new split pane.
 *
 * Result: the fork and the session it was forked from sit side-by-side in a
 * fresh tab, so you can compare them.
 *
 * Requires: running inside HERDR (HERDR_ENV=1) with the `herdr` CLI on PATH.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const HERDR_BIN = "/opt/homebrew/bin/herdr";
// The `pi` binary used to resume the parent session in the new pane.
const PI_BIN = "pi";

function insideHerdr(): boolean {
  return process.env.HERDR_ENV === "1" && !!process.env.HERDR_PANE_ID;
}

function shortId(sessionFile: string | undefined): string {
  if (!sessionFile) return "session";
  const base = sessionFile.split("/").pop() ?? sessionFile;
  // Session filenames look like: <timestamp>_<uuid>.jsonl — grab the uuid head.
  const uuid = base.replace(/\.jsonl$/, "").split("_").pop() ?? base;
  return uuid.slice(0, 8);
}

/** Pull a pane_id out of whatever JSON shape `herdr` returns. */
function parsePaneId(stdout: string): string | undefined {
  try {
    const json = JSON.parse(stdout);
    const fromResult = json?.result?.pane?.pane_id ?? json?.result?.pane_id ?? json?.pane?.pane_id;
    if (typeof fromResult === "string") return fromResult;
  } catch {
    // fall through to regex
  }
  const match = stdout.match(/"pane_id"\s*:\s*"([^"]+)"/);
  return match?.[1];
}

export default function (pi: ExtensionAPI) {
  const handleFork = async (
    event: { reason?: string; previousSessionFile?: string },
    ctx: ExtensionContext,
  ): Promise<void> => {
    if (event.reason !== "fork") return;
    if (!insideHerdr()) return;

    const paneId = process.env.HERDR_PANE_ID!;
    const parentFile = event.previousSessionFile;
    if (!parentFile) return;

    const cwd = ctx.cwd;
    const forkLabel = `fork:${shortId(ctx.sessionManager.getSessionFile())}`;

    try {
      // 1. Move the current (fork) pane into a new tab.
      const move = await pi.exec(
        HERDR_BIN,
        ["pane", "move", paneId, "--new-tab", "--label", forkLabel, "--focus"],
        { timeout: 5_000 },
      );
      if (move.code !== 0) {
        ctx.ui.notify(`herdr fork-split: move failed: ${move.stderr.trim()}`, "warning");
        return;
      }

      // 2. Split the fork pane to the right to host the parent session.
      const split = await pi.exec(
        HERDR_BIN,
        ["pane", "split", "--pane", paneId, "--direction", "right", "--cwd", cwd, "--no-focus"],
        { timeout: 5_000 },
      );
      if (split.code !== 0) {
        ctx.ui.notify(`herdr fork-split: split failed: ${split.stderr.trim()}`, "warning");
        return;
      }

      const parentPaneId = parsePaneId(split.stdout);
      if (!parentPaneId) {
        ctx.ui.notify("herdr fork-split: could not resolve new pane id", "warning");
        return;
      }

      // 3. Resume the parent session in the new pane.
      const run = await pi.exec(
        HERDR_BIN,
        ["pane", "run", parentPaneId, PI_BIN, "--session", parentFile],
        { timeout: 5_000 },
      );
      if (run.code !== 0) {
        ctx.ui.notify(`herdr fork-split: launch parent failed: ${run.stderr.trim()}`, "warning");
        return;
      }

      ctx.ui.notify(`herdr fork-split: parent (${shortId(parentFile)}) opened beside fork`, "info");
    } catch (err) {
      ctx.ui.notify(`herdr fork-split error: ${(err as Error).message}`, "warning");
    }
  };

  pi.on("session_start", (event, ctx) => {
    void handleFork(event as { reason?: string; previousSessionFile?: string }, ctx);
  });
}
