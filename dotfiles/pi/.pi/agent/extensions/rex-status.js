// Reports pi's status to Rex through rex-agent-status, as the Claude Code and Codex hooks do:
// working while it runs, done with its final message when it settles, error when the model
// fails. Each pi event becomes the hook JSON that script already reads.
import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

const SCRIPT = join(homedir(), ".local/bin/rex-agent-status");

// The same gate as the Claude Code and Codex hooks: inside tmux or a Rex pane.
export function reporting(env) {
  return Boolean(env.TMUX || env.REX_BLOCK || /^(tmux|screen)/.test(env.TERM ?? ""));
}

export function textOf(message) {
  return (message?.content ?? [])
    .filter((part) => part?.type === "text")
    .map((part) => part.text ?? "")
    .join("");
}

// What agent_settled reports: the run's last assistant text, or the model's error.
export function settled(last, failure) {
  return failure
    ? { hook_event_name: "StopFailure", last_assistant_message: failure }
    : { hook_event_name: "Stop", last_assistant_message: last };
}

function report(event) {
  if (!reporting(process.env)) return;
  try {
    const child = spawn("/usr/bin/python3", [SCRIPT, "pi"], { stdio: ["pipe", "ignore", "ignore"] });
    child.on("error", () => {});
    child.stdin.on("error", () => {});
    child.stdin.end(JSON.stringify(event));
    child.unref();
  } catch {}
}

export default function rexStatus(pi) {
  let last = "";
  let failure;

  pi.on("session_start", async () => report({ hook_event_name: "SessionStart" }));

  pi.on("agent_start", async () => {
    last = "";
    failure = undefined;
    report({ hook_event_name: "UserPromptSubmit" });
  });

  pi.on("message_end", async (event) => {
    const message = event?.message;
    if (message?.role !== "assistant") return;
    last = textOf(message) || last;
    if (message.stopReason === "error") failure = message.errorMessage || "the model failed";
  });

  pi.on("agent_settled", async () => report(settled(last, failure)));

  pi.on("session_shutdown", async () => report({ hook_event_name: "SessionEnd" }));
}
