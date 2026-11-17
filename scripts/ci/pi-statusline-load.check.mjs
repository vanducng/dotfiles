// Loads the statusline extension the way an OpenRig seat does: a symlinked statusline.ts in an agent dir with no lib/
// beside it, through Pi's own extension loader. Then it renders the footer and checks the model label.
// Usage: node pi-statusline-load.check.mjs <pi-coding-agent package dir> <statusline.ts>
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const [pkgDir, extFile] = process.argv.slice(2);
if (!pkgDir || !extFile) { console.error("usage: pi-statusline-load.check.mjs <pi package dir> <statusline.ts>"); process.exit(2); }

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "pi-statusline-check-"));
process.on("exit", () => fs.rmSync(tmp, { recursive: true, force: true }));
// A stand-in agent-statusline that prints the label it was given.
const bin = path.join(tmp, "home", ".local", "bin");
fs.mkdirSync(bin, { recursive: true });
fs.writeFileSync(path.join(bin, "agent-statusline"), "#!/bin/sh\nsed -E 's/.*\"display_name\":\"([^\"]*)\".*/\\1/'\n", { mode: 0o755 });
process.env.HOME = path.join(tmp, "home");
delete process.env.OPENRIG_SESSION_NAME;
const version = JSON.parse(fs.readFileSync(path.join(pkgDir, "package.json"), "utf8")).version;
const sdk = await import(pathToFileURL(path.join(path.resolve(pkgDir), "dist/index.js")).href);
let fail = 0;
const ok = (name, cond, info = "") => { if (!cond) fail++; console.log(`  ${cond ? "✓" : "✗"} ${name}${cond || !info ? "" : `  (${info})`}`); };

// Links `target` as statusline.ts in a fresh agent dir, loads it with Pi's loader, renders the footer.
async function check(name, target, want) {
	const agentDir = fs.mkdtempSync(path.join(tmp, "agent-"));
	fs.mkdirSync(path.join(agentDir, "extensions"));
	fs.symlinkSync(target, path.join(agentDir, "extensions", "statusline.ts"));
	const loaded = await sdk.discoverAndLoadExtensions([], tmp, agentDir);
	ok(`Pi ${version} loads ${name}`, loaded.errors.length === 0 && loaded.extensions.length === 1, JSON.stringify(loaded.errors));
	const start = loaded.extensions[0]?.handlers.get("session_start")?.[0];
	if (!start) return ok(`Pi ${version} ${name} registers session_start`, false);
	// Pi binds the runtime actions when a session starts; the footer reads only the thinking level.
	loaded.runtime.getThinkingLevel = () => "high";
	let footer;
	await start({}, {
		mode: "tui",
		cwd: tmp,
		model: { provider: "cpa", id: "acme/claude-opus-5-5" },
		getContextUsage: () => ({ percent: 1 }),
		ui: { setFooter: (f) => { footer = f; } },
	});
	let rendered;
	const done = new Promise((resolve) => { rendered = resolve; });
	const comp = footer(
		{ requestRender: () => rendered() },
		{ fg: (_c, s) => s },
		{ getGitBranch: () => null, onBranchChange: () => () => {}, getExtensionStatuses: () => new Map() },
	);
	comp.render(80);
	const timeout = new Promise((resolve) => setTimeout(() => resolve("timeout"), 5000));
	const why = await Promise.race([done, timeout]);
	const line = comp.render(80)[0];
	comp.dispose();
	ok(`Pi ${version} ${name}: footer shows ${want}`, why !== "timeout" && line === want, line);
}

await check("the symlinked statusline.ts", path.resolve(extFile), "cpa/acme/opus-5.5");
// The label rule can't load (its real dir has no lib/): the footer still mounts, with provider/id as is.
const lone = path.join(tmp, "lone");
fs.mkdirSync(lone);
fs.copyFileSync(extFile, path.join(lone, "statusline.ts"));
await check("statusline.ts without lib/", path.join(lone, "statusline.ts"), "cpa/acme/claude-opus-5-5");
console.log(fail ? `pi statusline load (Pi ${version}): ${fail} failed` : `pi statusline load (Pi ${version}): ok`);
process.exit(fail ? 1 : 0);
