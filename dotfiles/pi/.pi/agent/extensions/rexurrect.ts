import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const bin = join(homedir(), ".cargo/bin/rexurrect");

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    const file = ctx.sessionManager.getSessionFile();
    // Subagents run pi in print/json mode inside the same block and must not claim it.
    if (!process.env.REX_BLOCK || ctx.mode !== "tui" || !file) return;
    execFile(bin, ["report", "pi", file], () => {}).unref();
  });
}
