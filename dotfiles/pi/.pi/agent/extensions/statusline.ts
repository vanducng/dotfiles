// Footer in the same layout as Claude Code and Grok: pi's state goes through the
// shared agent-statusline script (dotfiles/bin/.local/bin) as a status JSON payload.
import { execFile } from "node:child_process";
import { realpathSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const SCRIPT = join(homedir(), ".local/bin/agent-statusline");
// An OpenRig seat leads its footer with its seat name.
const SEAT = process.env.OPENRIG_SESSION_NAME?.trim() ?? "";

export default async function (pi: ExtensionAPI) {
	// A seat links this file into its own agent dir, which has no lib/. Pi before 1.5.1 resolves a relative import from
	// the link's folder, so the label rule is loaded from this file's real path instead. If that fails, the footer
	// still mounts and shows provider/id as is.
	let modelLabel = (provider: string, id: string) => [provider, id].filter(Boolean).join("/");
	try {
		const real = dirname(realpathSync(fileURLToPath(import.meta.url)));
		({ modelLabel } = await import(pathToFileURL(join(real, "lib", "model-label.js")).href));
	} catch (err) {
		console.error(`statusline: model label rule not loaded, showing provider/id: ${String((err as Error)?.message ?? err).split("\n")[0]}`);
	}
	let ctx: ExtensionContext | undefined;
	let refresh = () => {};

	pi.on("session_start", (_event, startCtx) => {
		ctx = startCtx;
		if (startCtx.mode !== "tui") return;
		startCtx.ui.setFooter((tui, theme, footerData) => {
			let line = "";
			// The first render sets the width and runs the first refresh.
			let width = 0;
			let running = false;
			let again = false;
			let disposed = false;
			let retries = 0;
			let timer: ReturnType<typeof setTimeout> | undefined;
			refresh = () => {
				if (!ctx || disposed) return;
				if (running) {
					again = true;
					return;
				}
				running = true;
				const usage = ctx.getContextUsage();
				const payload = {
					model: { display_name: ctx.model ? modelLabel(ctx.model.provider, ctx.model.id) : undefined },
					effort: { level: pi.getThinkingLevel() },
					context_window: { used_percentage: usage?.percent ?? null },
					workspace: { current_dir: ctx.cwd, branch: footerData.getGitBranch() },
				};
				const child = execFile(SCRIPT, { timeout: 5000, env: { ...process.env, COLUMNS: String(Math.max(20, width - (SEAT ? SEAT.length + 2 : 0))) } }, (err, out) => {
					running = false;
					if (disposed) return;
					if (!err && out.trim() && out.trimEnd() !== line) {
						line = out.trimEnd();
						tui.requestRender();
					}
					// Nothing shown yet and no event may follow (a cold start on a busy machine can time out).
					if (err && !line && retries++ < 3) timer = setTimeout(refresh, 1000);
					if (again) {
						again = false;
						refresh();
					}
				});
				child.stdin?.end(JSON.stringify(payload));
			};
			const unsub = footerData.onBranchChange(refresh);
			return {
				dispose() {
					disposed = true;
					clearTimeout(timer);
					unsub();
				},
				invalidate() {},
				render(w: number): string[] {
					if (w !== width) {
						width = w;
						refresh();
					}
					const statuses = [...footerData.getExtensionStatuses().values()].join("  ");
					const main = line || theme.fg("dim", ctx?.model?.id ?? "");
					const rows = [SEAT ? `${theme.fg("accent", SEAT)}  ${main}` : main];
					if (statuses) rows.push(statuses);
					return rows.map((row) => truncateToWidth(row, w));
				},
			};
		});
	});

	for (const event of ["turn_end", "model_select", "thinking_level_select", "session_compact"] as const) {
		pi.on(event, (_event, eventCtx) => {
			ctx = eventCtx;
			refresh();
		});
	}
}
