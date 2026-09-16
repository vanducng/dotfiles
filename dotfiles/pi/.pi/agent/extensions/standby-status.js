import { execFile } from "node:child_process";

const POLL_MS = 4000;
const STATUS_KEY = "standby";
const ACTIVE = new Set(["working", "blocked"]);
const SETTLED = new Set(["idle", "done"]);
const CAPTAIN_LABELS = new Set(["firstmate:coordinator", "firstmate:launcher"]);

function siblingCrews(agents, paneId) {
	const names = [];
	for (const agent of agents) {
		if (!agent || agent.pane_id === paneId) continue;
		if (!ACTIVE.has(agent.agent_status)) continue;
		names.push(agent.name || agent.pane_id);
	}
	return names;
}

function formatLabel(names) {
	if (names.length === 0) return "";
	const shown = names.slice(0, 3);
	const extra = names.length - shown.length;
	const list = shown.join(", ") + (extra > 0 ? ` +${extra}` : "");
	return `standby · ${list}`;
}

function parseAgentList(stdout) {
	const data = JSON.parse(stdout);
	return data?.result?.agents ?? [];
}

function statusMap(agents, paneId) {
	const map = {};
	for (const agent of agents) {
		if (!agent || agent.pane_id === paneId) continue;
		const key = agent.name || agent.pane_id;
		if (!key) continue;
		map[key] = agent.agent_status;
	}
	return map;
}

function crewTransitions(prev, next) {
	const settled = [];
	const blocked = [];
	for (const [name, status] of Object.entries(next)) {
		const was = prev[name];
		if (ACTIVE.has(was) && SETTLED.has(status)) settled.push(name);
		if (was !== "blocked" && status === "blocked") blocked.push(name);
	}
	return { settled, blocked };
}

function wakeMessage(settled, blocked) {
	const bits = [];
	if (settled.length) bits.push(`settled: ${settled.join(", ")}`);
	if (blocked.length) bits.push(`needs attention: ${blocked.join(", ")}`);
	if (!bits.length) return "";
	return `Crew ${bits.join("; ")}. Inspect that pane checkpoint/result and continue. Idle UI is not success.`;
}

function parsePaneLabel(stdout) {
	const data = JSON.parse(stdout);
	return data?.result?.pane?.label || "";
}

function runHerdr(args) {
	return new Promise((resolve) => {
		execFile("herdr", args, { timeout: 2000 }, (err, stdout) => {
			if (err || !stdout) {
				resolve("");
				return;
			}
			resolve(stdout);
		});
	});
}

async function listAgents() {
	const stdout = await runHerdr(["agent", "list"]);
	if (!stdout) return [];
	try {
		return parseAgentList(stdout);
	} catch {
		return [];
	}
}

export default function standbyStatus(pi) {
	let local = "idle";
	let last = "";
	let timer;
	let ctxRef;
	let prevMap;
	let captain = process.env.FIRSTMATE_ROLE === "captain";
	let captainResolved = process.env.FIRSTMATE_ROLE === "captain";

	function inHerdr() {
		return process.env.HERDR_ENV === "1" && !!process.env.HERDR_PANE_ID;
	}

	function paint(ctx, label) {
		if (!ctx?.hasUI) return;
		if (label === last) return;
		last = label;
		if (!label) {
			ctx.ui.setStatus(STATUS_KEY, undefined);
			return;
		}
		const theme = ctx.ui.theme;
		ctx.ui.setStatus(STATUS_KEY, theme.fg("accent", label));
	}

	async function resolveCaptain() {
		if (captainResolved) return captain;
		const stdout = await runHerdr(["pane", "get", process.env.HERDR_PANE_ID]);
		if (stdout) {
			try {
				captain = CAPTAIN_LABELS.has(parsePaneLabel(stdout));
			} catch {
				captain = false;
			}
		}
		captainResolved = true;
		return captain;
	}

	function notifyDesktop(text) {
		execFile(
			"herdr",
			["notification", "show", "Crew update", "--body", text, "--sound", "done"],
			{ timeout: 2000 },
			() => {},
		);
	}

	function wake(settled, blocked) {
		const text = wakeMessage(settled, blocked);
		if (!text) return;
		notifyDesktop(text);
		try {
			if (local === "working") {
				pi.sendUserMessage(text, { deliverAs: "followUp" });
			} else {
				pi.sendUserMessage(text);
			}
		} catch {
			// next poll retries only on a new transition
		}
	}

	async function refresh(ctx = ctxRef) {
		if (!inHerdr()) {
			if (ctx?.hasUI) paint(ctx, "");
			return;
		}
		const agents = await listAgents();
		const paneId = process.env.HERDR_PANE_ID;
		const nextMap = statusMap(agents, paneId);
		if (prevMap && (await resolveCaptain())) {
			const { settled, blocked } = crewTransitions(prevMap, nextMap);
			if (settled.length || blocked.length) wake(settled, blocked);
		}
		prevMap = nextMap;
		if (!ctx?.hasUI) return;
		if (local === "working") {
			paint(ctx, "");
			return;
		}
		paint(ctx, formatLabel(siblingCrews(agents, paneId)));
	}

	function start(ctx) {
		ctxRef = ctx;
		if (timer || !inHerdr()) return;
		let inflight = false;
		timer = setInterval(() => {
			if (inflight) return;
			inflight = true;
			void refresh().finally(() => {
				inflight = false;
			});
		}, POLL_MS);
		timer.unref?.();
		void refresh(ctx);
	}

	function stop() {
		if (timer) {
			clearInterval(timer);
			timer = undefined;
		}
		if (ctxRef?.hasUI) paint(ctxRef, "");
		ctxRef = undefined;
		last = "";
		prevMap = undefined;
	}

	pi.on("session_start", async (_event, ctx) => {
		local = "idle";
		start(ctx);
	});

	pi.on("agent_start", async (_event, ctx) => {
		local = "working";
		ctxRef = ctx;
		paint(ctx, "");
	});

	pi.on("agent_settled", async (_event, ctx) => {
		local = "idle";
		ctxRef = ctx;
		void refresh(ctx);
	});

	pi.on("session_shutdown", async () => {
		stop();
	});

	pi.registerCommand("standby", {
		description: "Show whether this session is waiting on Herdr crews",
		handler: async (_args, ctx) => {
			if (!inHerdr()) {
				ctx.ui.notify("Not in Herdr. No crew standby.", "info");
				return;
			}
			const names = siblingCrews(await listAgents(), process.env.HERDR_PANE_ID);
			const label = formatLabel(names);
			ctx.ui.notify(label || "Idle. No working crews.", "info");
			paint(ctx, label);
		},
	});
}

export {
	crewTransitions,
	formatLabel,
	parseAgentList,
	parsePaneLabel,
	siblingCrews,
	statusMap,
	wakeMessage,
};
