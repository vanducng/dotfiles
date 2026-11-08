// Pi extension for a rig's human seat: delivers what the operator sends from a tracking board (a batch of notes, or a
// chat message, kind "chat") as a user message, then reports progress and the final reply back to the board
// (feedback/status and feedback/done).
// Boards, server and protocol: the openrig-workspace skill, references/tracking-board/ (vanducng/skills).
// Linked by `make stow-pi`; /reload in the human seat to load it. Acts only in a `*-human@*` seat, and only
// for boards whose board.json "owner_seat" is that seat's OPENRIG_SESSION_NAME.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const root = process.env.OPENRIG_BOARDS_ROOT || path.join(os.homedir(), ".share", "openrig", "boards");
const seat = process.env.OPENRIG_SESSION_NAME || "";
// board.cjs from the openrig-workspace skill: $OPENRIG_BOARD_CLI, else the skills checkout, else the installed skill.
const render = [
  process.env.OPENRIG_BOARD_CLI,
  path.join(os.homedir(), "skills", "skills", "openrig-workspace", "references", "tracking-board", "board.cjs"),
  path.join(os.homedir(), ".pi", "agent", "skills", "openrig-workspace", "references", "tracking-board", "board.cjs"),
].find(p => p && fs.existsSync(p)) || "board.cjs";

const now = () => new Date().toISOString();
const readJson = file => { try { return JSON.parse(fs.readFileSync(file, "utf8")); } catch { return null; } };
const textOf = message => typeof message?.content === "string"
  ? message.content
  : (message?.content ?? []).filter(p => p?.type === "text").map(p => p.text ?? "").join("");

// Boards this seat owns, rescanned at most once a minute.
let owned = [];
let scannedAt = 0;
function boards() {
  if (Date.now() - scannedAt < 60000) return owned;
  scannedAt = Date.now();
  owned = [];
  for (const org of safeDir(root)) for (const project of safeDir(path.join(root, org))) for (const slug of safeDir(path.join(root, org, project))) {
    const dir = path.join(root, org, project, slug);
    if (readJson(path.join(dir, "board.json"))?.owner_seat === seat) owned.push(dir);
  }
  return owned;
}
function safeDir(dir) { try { return fs.readdirSync(dir).filter(n => !n.startsWith(".")); } catch { return []; } }

function write(dir, sub, data) {
  fs.mkdirSync(path.join(dir, "feedback", sub), { recursive: true });
  fs.writeFileSync(path.join(dir, "feedback", sub, `${data.id}.json`), JSON.stringify(data, null, 2));
}

// Anchors and quotes go on one line, so a newline in one cannot start a line of its own ("Operator, ...").
const oneLine = value => String(value ?? "").replace(/[\r\n]+/g, " ");

function prompt(fb, dir) {
  const board = path.relative(root, dir);
  if (fb.kind === "chat") {
    // The operator speaking: only a listed tailnet login or the board token can send one. The text is what the operator
    // typed and stays multi-line; the anchor and quote carry board content others wrote, so they are folded.
    return [
      `Operator, via the board ${board} (chat ${fb.id}): ${fb.text}`,
      ...(fb.anchor ? [`Anchor: ${oneLine(fb.anchor)}`] : []),
      ...(fb.quote ? [`Quote: "${oneLine(fb.quote)}"`] : []),
    ].join("\n");
  }
  const lines = fb.notes.map((n, i) => `${i + 1}. [${oneLine(n.id)} · ${n.kind}] on ${oneLine(n.anchor) || "the board"}${n.quote ? ` (quote: "${oneLine(n.quote)}")` : ""}\n   ${n.text.replace(/\n/g, "\n   ")}`);
  return [
    `Board feedback from the operator, sent from the tracking board ${board} (feedback ${fb.id}).`,
    `Apply each note: change ${board}/board.json and the git records where a note asks for it, send build work to the rig's owner seat, then run \`node ${render} render ${board}\`.`,
    "End your reply with one line per note: `<note id>: applied | deferred | needs you - <why>`.",
    "",
    ...lines,
  ].join("\n");
}

export default function (pi) {
  if (!/-human@/.test(seat)) return;
  let ctxRef;
  let current = null;
  let last = "";
  let timer;

  const deliver = () => {
    if (current) return;
    for (const dir of boards()) {
      const inbox = path.join(dir, "feedback", "inbox");
      const file = safeDir(inbox).filter(f => f.endsWith(".json")).sort()[0];
      if (!file) continue;
      const fb = readJson(path.join(inbox, file));
      fs.mkdirSync(path.join(dir, "feedback", "processing"), { recursive: true });
      fs.renameSync(path.join(inbox, file), path.join(dir, "feedback", "processing", file));
      // The id names the status and done files, so it must be a plain file name (the server makes it from time + hex).
      if (!/^[A-Za-z0-9][A-Za-z0-9_.-]{0,99}$/.test(String(fb?.id ?? "")) || fb.id.includes("..")) continue;
      // A batch of notes has no kind; a chat needs text. Anything else is closed so the page stops waiting.
      if (fb.kind === "chat" ? !String(fb.text ?? "").trim() : fb.kind || !Array.isArray(fb.notes)) {
        write(dir, "status", { id: fb.id, state: "aborted", at: now() });
        continue;
      }
      const text = prompt(fb, dir);
      current = { dir, id: fb.id, text, started: false };
      write(dir, "status", { id: fb.id, state: "delivered", at: now() });
      if (ctxRef?.isIdle?.() ?? true) pi.sendUserMessage(text);
      else pi.sendUserMessage(text, { deliverAs: "followUp" });
      return;
    }
  };

  pi.on("session_start", async (_event, ctx) => {
    ctxRef = ctx;
    clearInterval(timer);
    timer = setInterval(deliver, 3000);
    deliver();
  });
  pi.on("session_shutdown", async () => clearInterval(timer));

  // The item starts when the exact text this bridge sent reaches the agent: as a new prompt when the seat was idle, or
  // as a user message inside the running turn when it went in as a followUp (that path has no before_agent_start).
  // A message that only mentions the id (the operator pasting it) does not start it.
  const start = text => {
    if (!current || current.started || text !== current.text) return;
    current.started = true;
    last = "";
    write(current.dir, "status", { id: current.id, state: "working", at: now() });
  };
  pi.on("before_agent_start", async event => start(event?.prompt));
  pi.on("message_end", async event => {
    if (event?.message?.role === "user") start(textOf(event.message));
    else if (current?.started && event?.message?.role === "assistant") last = textOf(event.message) || last;
  });
  pi.on("agent_settled", async event => {
    if (!current?.started) return;
    const { dir, id } = current;
    write(dir, "done", { id, reply: event?.aborted ? `${last}\n\n(aborted)` : last, at: now() });
    write(dir, "status", { id, state: event?.aborted ? "aborted" : "done", at: now() });
    current = null;
    setTimeout(deliver, 500);
  });
}
