// Drives a real Pi session (scripted faux model, temp working directory) with the tool-name-aliases extension loaded.
// Usage: node pi-tool-aliases.check.mjs <pi-coding-agent package dir> <extension file>
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const [pkgDir, extFile] = process.argv.slice(2);
if (!pkgDir || !extFile) { console.error("usage: pi-tool-aliases.check.mjs <pi package dir> <extension file>"); process.exit(2); }
// pi-ai is installed beside pi-coding-agent in the same node_modules/@earendil-works directory.
const fromPkg = rel => pathToFileURL(path.join(path.resolve(pkgDir), rel)).href;
const sdk = await import(fromPkg("dist/index.js"));
const ai = await import(fromPkg("../pi-ai/dist/compat.js"));
const { DEFAULT_ALIASES, loadAliases } = await import(pathToFileURL(path.resolve(extFile)).href);

let pass = 0, fail = 0;
const ok = (name, cond, info = "") => { cond ? pass++ : fail++; console.log(`  ${cond ? "✓" : "✗"} ${name}${cond || !info ? "" : `  (${info})`}`); };
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pi-alias-check-"));
process.on("exit", () => fs.rmSync(tmp, { recursive: true, force: true }));
const work = path.join(tmp, "work"), agentDir = path.join(tmp, "agent");
fs.mkdirSync(work); fs.mkdirSync(agentDir);
fs.writeFileSync(path.join(work, "a.txt"), "original\n");

// What the model is told: tool names in the request, per model call.
const declared = [];
const faux = ai.fauxProvider({ models: [{ id: "scripted" }] });
const call = (name, args, id) => ai.fauxAssistantMessage([ai.fauxToolCall(name, args, { id })], { stopReason: "toolUse" });
const done = () => ai.fauxAssistantMessage("done");
const seeTools = next => ctx => { declared.push(ctx.messages.filter(m => m.role === "system").flatMap(m => (m.toolsAdded || []).map(t => t.name))); return typeof next === "function" ? next(ctx) : next; };

// `env` is set only while the session is created (the extension reads it when it loads), then restored.
async function session(env = {}, withExtension = true) {
  const saved = Object.fromEntries(Object.keys(env).map(k => [k, process.env[k]]));
  Object.assign(process.env, env);
  let session;
  try {
    const loader = new sdk.DefaultResourceLoader({ cwd: work, agentDir, additionalExtensionPaths: withExtension ? [path.resolve(extFile)] : [], noExtensions: true, extensionFactories: [pi => pi.registerProvider(faux.provider)] });
    await loader.reload();
    const modelRuntime = await sdk.ModelRuntime.create({ agentDir });
    ({ session } = await sdk.createAgentSession({ cwd: work, agentDir, modelRuntime, model: faux.getModel(), resourceLoader: loader, sessionManager: sdk.SessionManager.inMemory() }));
    await session.bindExtensions({});
  } finally {
    for (const [k, v] of Object.entries(saved)) v === undefined ? delete process.env[k] : (process.env[k] = v);
  }
  const results = [];
  session.subscribe(e => { if (e.type === "tool_execution_end") results.push({ name: e.toolName, isError: !!e.isError, text: JSON.stringify(e.result ?? "") }); });
  return { session, results };
}

console.log("default alias list");
ok("every default alias maps to a built-in tool and none shadows one", Object.entries(DEFAULT_ALIASES).every(([a, t]) => ["bash", "read", "write", "edit"].includes(t) && !["bash", "read", "write", "edit", "grep", "find", "ls"].includes(a)));
const warned = [];
const merged = loadAliases(path.join(tmp, "missing.json"), m => warned.push(m));
ok("a missing local file leaves the defaults", JSON.stringify(merged) === JSON.stringify(DEFAULT_ALIASES) && warned.length === 0);
fs.writeFileSync(path.join(tmp, "local.json"), JSON.stringify({ site_bash: "bash", write: "bash", odd: "no_such_tool", "bad name": "read" }));
const withLocal = loadAliases(path.join(tmp, "local.json"), m => warned.push(m));
ok("a local file adds valid entries only", withLocal.site_bash === "bash" && !("write" in withLocal) && !("odd" in withLocal) && !("bad name" in withLocal) && warned.length === 3, JSON.stringify([withLocal, warned]));

console.log("a session with the extension");
const { session: s, results } = await session({ PI_TOOL_ALIASES_FILE: path.join(tmp, "local.json") });
faux.setResponses([
  seeTools(call("then_write", { path: "b.txt", content: "via alias\n" }, "c1")),
  seeTools(call("dignity_edit", { path: "a.txt", edits: [{ oldText: "original", newText: "edited" }] }, "c2")),
  seeTools(call("site_bash", { command: "echo from-alias" }, "c3")),
  seeTools(call("totally_unknown_tool", { path: "c.txt", content: "must not exist\n" }, "c4")),
  seeTools(call("then_write", { content: "missing path\n" }, "c5")),
  seeTools(done()),
]);
await s.prompt("go");
await s.agent?.waitForIdle?.();
const byName = n => results.find(r => r.name === n);
ok("an aliased write reaches the real write tool (file exists with the content)", fs.existsSync(path.join(work, "b.txt")) && fs.readFileSync(path.join(work, "b.txt"), "utf8") === "via alias\n" && byName("then_write") && !byName("then_write").isError, JSON.stringify(results.slice(0, 1)));
ok("an aliased edit reaches the real edit tool", fs.readFileSync(path.join(work, "a.txt"), "utf8") === "edited\n" && !byName("dignity_edit")?.isError);
ok("an alias from the local file reaches bash", /from-alias/.test(byName("site_bash")?.text || "") && !byName("site_bash").isError, byName("site_bash")?.text);
ok("an unknown name still fails with 'not found' and does nothing", results.some(r => /not found/.test(r.text) && r.isError) && !fs.existsSync(path.join(work, "c.txt")), JSON.stringify(results.map(r => [r.name, r.isError])));
const bad = [...results].reverse().find(r => r.name === "then_write");
ok("a failing target comes back as an error through the alias", !!bad && bad.isError, JSON.stringify(results.map(r => [r.name, r.isError])));
const first = declared[0] || [];
ok("the real tools are declared to the model", ["read", "bash", "edit", "write"].every(n => first.includes(n)), first.join(","));
ok("no alias name is declared to the model", !first.some(n => n in withLocal), first.join(","));
s.dispose();

ok("the session's env is restored after it is created", process.env.PI_TOOL_ALIASES_FILE === undefined);

console.log("control: the same call without the extension");
const ctl = await session({}, false);
faux.setResponses([seeTools(call("then_write", { path: "ctl.txt", content: "x\n" }, "k1")), seeTools(done())]);
await ctl.session.prompt("go");
ok("without the extension the corrupted name fails and nothing is written", ctl.results.some(r => r.name === "then_write" && r.isError && /not found/.test(r.text)) && !fs.existsSync(path.join(work, "ctl.txt")), JSON.stringify(ctl.results.map(r => [r.name, r.isError])));
ctl.session.dispose();

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
