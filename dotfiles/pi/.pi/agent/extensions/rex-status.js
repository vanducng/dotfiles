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

// Each report waits for the one before it, at most this long, so a quick `working` never lands
// before the `idle` sent ahead of it. pi awaits a run's last report: `pi -p` exits right after
// it, and the script finds pi's pane through pi's own process, so pi must still be running.
const WAIT = 2000;

function report(event) {
  if (!reporting(process.env)) return Promise.resolve();
  return new Promise((resolve) => {
    let child;
    try {
      child = spawn("/usr/bin/python3", [SCRIPT, "pi"], { stdio: ["pipe", "ignore", "ignore"] });
    } catch {
      return resolve();
    }
    const done = () => {
      clearTimeout(timer);
      child.unref();
      resolve();
    };
    const timer = setTimeout(done, WAIT);
    child.on("error", done);
    child.on("exit", done);
    child.stdin.on("error", () => {});
    child.stdin.end(JSON.stringify(event));
  });
}

export default function rexStatus(pi) {
  let last = "";
  let failure;
  let queue = Promise.resolve();
  const send = (event) => (queue = queue.then(() => report(event)));

  pi.on("session_start", async () => {
    send({ hook_event_name: "SessionStart" });
  });

  pi.on("agent_start", async () => {
    last = "";
    failure = undefined;
    send({ hook_event_name: "UserPromptSubmit" });
  });

  pi.on("message_end", async (event) => {
    const message = event?.message;
    if (message?.role !== "assistant") return;
    last = textOf(message) || last;
    if (message.stopReason === "error") failure = message.errorMessage || "the model failed";
  });

  pi.on("agent_settled", async () => send(settled(last, failure)));

  // Without a UI (`pi -p`) the session ends with its one run, whose result should stay up.
  pi.on("session_shutdown", async (_event, ctx) => {
    if (ctx?.hasUI) await send({ hook_event_name: "SessionEnd" });
  });
}
