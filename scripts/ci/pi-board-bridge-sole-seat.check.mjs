// Drives a real Pi session (scripted faux model) as a seat that is not a human seat: the bridge serves a board only when
// the board's owner_seat names this seat and the seat's rig has no human seat (`rig ps`, here a stub on PATH).
// Usage: node pi-board-bridge-sole-seat.check.mjs <pi-coding-agent package dir> <extension file>
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const [pkgDir, extFile] = process.argv.slice(2);
if (!pkgDir || !extFile) { console.error("usage: pi-board-bridge-sole-seat.check.mjs <pi package dir> <extension file>"); process.exit(2); }
const fromPkg = rel => pathToFileURL(path.join(path.resolve(pkgDir), rel)).href;
const sdk = await import(fromPkg("dist/index.js"));
const ai = await import(fromPkg("../pi-ai/dist/compat.js"));

let pass = 0, fail = 0;
const ok = (name, cond, info = "") => { cond ? pass++ : fail++; console.log(`  ${cond ? "✓" : "✗"} ${name}${cond || !info ? "" : `  (${info})`}`); };
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pi-board-bridge-sole-"));
process.on("exit", () => fs.rmSync(tmp, { recursive: true, force: true }));
const work = path.join(tmp, "work"), agentDir = path.join(tmp, "agent"), root = path.join(tmp, "boards"), bin = path.join(tmp, "bin");
const SEAT = "research-writer@demo";
const mine = "org/project/mine", other = "org/project/other";
for (const d of [work, agentDir, bin]) fs.mkdirSync(d, { recursive: true });
for (const [board, owner] of [[mine, SEAT], [other, "research-reviewer@demo"]]) {
  fs.mkdirSync(path.join(root, board, "feedback", "inbox"), { recursive: true });
  fs.writeFileSync(path.join(root, board, "board.json"), JSON.stringify({ title: board, owner_seat: owner }));
}
const cli = path.join(tmp, "board.cjs");
fs.writeFileSync(cli, "");

// The stub `rig`: prints nodes.json for `rig ps --nodes --json --rig demo`, or fails when fail.flag exists. Each call is logged.
const nodes = path.join(tmp, "nodes.json"), flag = path.join(tmp, "fail.flag"), calls = path.join(tmp, "calls.log");
fs.writeFileSync(path.join(bin, "rig"), `#!/bin/sh\necho "$*" >> "${calls}"\n[ -e "${flag}" ] && exit 1\ncat "${nodes}"\n`, { mode: 0o755 });
const rigOf = (...seats) => fs.writeFileSync(nodes, JSON.stringify(seats.map(s => ({ canonicalSessionName: s, rigName: "demo" }))));
rigOf(SEAT, "research-reviewer@demo");

const rigCalls = () => { try { return fs.readFileSync(calls, "utf8"); } catch { return ""; } };
const readJson = f => { try { return JSON.parse(fs.readFileSync(f, "utf8")); } catch { return null; } };
const fb = (board, sub, id) => readJson(path.join(root, board, "feedback", sub, `${id}.json`));
const inInbox = (board, id) => fs.existsSync(path.join(root, board, "feedback", "inbox", `${id}.json`));
const queue = (board, id, text) => fs.writeFileSync(path.join(root, board, "feedback", "inbox", `${id}.json`), JSON.stringify({ id, board, received_at: "2026-11-12T01:00:00Z", kind: "chat", text }));
const sleep = ms => new Promise(r => setTimeout(r, ms));
async function until(cond, ms = 10000) { const end = Date.now() + ms; while (Date.now() < end) { if (cond()) return true; await sleep(100); } return false; }
// A change to the rig counts from the first `rig ps` read that starts after it (a poll may still use the last read).
const reads = () => rigCalls().split("\n").filter(Boolean).length;
// A "nothing delivered" window counts only after the bridge has read the rig at least once since the last change.
async function reread() { const n = reads(); const read = await until(() => reads() > n); await sleep(300); return read; }

const seen = [];
const faux = ai.fauxProvider({ models: [{ id: "scripted" }] });
const textOf = m => typeof m.content === "string" ? m.content : (m.content || []).filter(p => p.type === "text").map(p => p.text).join("");
const reply = text => ctx => { seen.push(textOf([...ctx.messages].reverse().find(m => m.role === "user") || {})); return ai.fauxAssistantMessage(text); };

// PATH stays set: the bridge runs `rig` whenever it rechecks the rig, not only at load.
process.env.PATH = `${bin}${path.delimiter}${process.env.PATH}`;
Object.assign(process.env, { OPENRIG_BOARDS_ROOT: root, OPENRIG_SESSION_NAME: SEAT, OPENRIG_BOARD_CLI: cli, OPENRIG_BOARD_RIG_CHECK_MS: "300" });
const loader = new sdk.DefaultResourceLoader({ cwd: work, agentDir, additionalExtensionPaths: [path.resolve(extFile)], noExtensions: true, extensionFactories: [pi => pi.registerProvider(faux.provider)] });
await loader.reload();
const modelRuntime = await sdk.ModelRuntime.create({ agentDir });
const { session } = await sdk.createAgentSession({ cwd: work, agentDir, modelRuntime, model: faux.getModel(), resourceLoader: loader, sessionManager: sdk.SessionManager.inMemory() });

const first = "2026-11-12T01-00-00-000Z-aaaaaa", others = "2026-11-12T01-00-01-000Z-bbbbbb";
queue(mine, first, "bridge check: please reply ok");
queue(other, others, "for the other seat");
faux.setResponses([reply("ok")]);
// Pane notices: notify is recorded, the other UI calls are no-ops (Pi copies the object's own keys).
const notices = [];
const noop = () => undefined;
const ui = { notify: text => notices.push(String(text)), setStatus: noop, setWidget: noop, setTitle: noop, setEditorText: noop };
await session.bindExtensions({ uiContext: ui });

console.log("the only seat of a rig with no human seat, on a board it owns");
ok("its board's item is delivered and answered", await until(() => fb(mine, "done", first)?.reply === "ok"), JSON.stringify(fb(mine, "status", first)));
ok("it ends as done and stays in processing/", fb(mine, "status", first)?.state === "done" && fb(mine, "processing", first)?.kind === "chat");
ok("the rig was read with rig ps for this seat's rig", rigCalls().split("\n")[0] === "ps --nodes --json --rig demo", rigCalls());
ok("the rig is read again before the other board's window", await reread());
await sleep(700);
ok("a board owned by another seat is never served", inInbox(other, others) && !fb(other, "status", others) && seen.length === 1, String(seen.length));

console.log("the rig gains a human seat");
rigOf(SEAT, "research-reviewer@demo", "ops-human@demo");
ok("the rig is read again after it gains a human seat", await reread());
const second = "2026-11-12T01-00-02-000Z-cccccc";
queue(mine, second, "now the human seat owns the bridge");
await sleep(2500);
ok("nothing is delivered while the rig has a human seat", inInbox(mine, second) && !fb(mine, "status", second) && seen.length === 1, String(seen.length));

console.log("rig cannot be read");
fs.writeFileSync(flag, "");
rigOf(SEAT);
ok("the rig is read again after the failure starts", await reread());
await reread(); // a second failing read: the notice must not repeat
await sleep(2000);
ok("nothing is delivered when rig ps fails (fail closed)", inInbox(mine, second) && seen.length === 1, String(seen.length));
const failNotes = notices.filter(n => n.includes("cannot read rig demo"));
ok("the pane gets one notice for the failure streak, with the reason and no output", failNotes.length === 1 && failNotes[0].includes("rig ps exited 1") && !failNotes[0].includes("canonicalSessionName"), JSON.stringify(notices));

console.log("the rig is back to no human seat");
fs.rmSync(flag);
faux.setResponses([reply("ok again")]);
ok("the waiting item is delivered and answered", await until(() => fb(mine, "done", second)?.reply === "ok again"), JSON.stringify(fb(mine, "status", second)));
ok("the other seat's board is still untouched", inInbox(other, others));
ok("no further notice once the rig reads again", notices.filter(n => n.includes("cannot read rig")).length === 1, JSON.stringify(notices));

session.dispose();
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
