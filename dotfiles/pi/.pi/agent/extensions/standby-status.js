import { execFile } from "node:child_process";

const POLL_MS = 4000;
const STATUS_KEY = "standby";
const ACTIVE = new Set(["working", "blocked"]);

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

function listAgents() {
	return new Promise((resolve) => {
		execFile("herdr", ["agent", "list"], { timeout: 2000 }, (err, stdout) => {
			if (err || !stdout) {
				resolve([]);
				return;
			}
			try {
				resolve(parseAgentList(stdout));
			} catch {
				resolve([]);
			}
		});
	});
}

export default function standbyStatus(pi) {
	let local = "idle";
	let last = "";
	let timer;
	let ctxRef;

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

	async function refresh(ctx = ctxRef) {
		if (!ctx?.hasUI) return;
		if (!inHerdr() || local === "working") {
			paint(ctx, "");
			return;
		}
		const names = siblingCrews(await listAgents(), process.env.HERDR_PANE_ID);
		paint(ctx, formatLabel(names));
	}

	function start(ctx) {
		ctxRef = ctx;
		if (timer || !inHerdr()) return;
		timer = setInterval(() => {
			void refresh();
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
			await refresh(ctx);
		},
	});
}

export { formatLabel, parseAgentList, siblingCrews };
