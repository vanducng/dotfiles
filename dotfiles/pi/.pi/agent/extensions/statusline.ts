// Footer in the same layout as Claude Code and Grok: pi's state goes through the
// shared agent-statusline script (dotfiles/bin/.local/bin) as a status JSON payload.
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const SCRIPT = join(homedir(), ".local/bin/agent-statusline");

export default function (pi: ExtensionAPI) {
	let ctx: ExtensionContext | undefined;
	let refresh = () => {};

	pi.on("session_start", (_event, startCtx) => {
		ctx = startCtx;
		if (startCtx.mode !== "tui") return;
		startCtx.ui.setFooter((tui, theme, footerData) => {
			let line = "";
			let width = 80;
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
					model: { display_name: ctx.model?.name ?? ctx.model?.id },
					effort: { level: pi.getThinkingLevel() },
					context_window: { used_percentage: usage?.percent ?? null },
					workspace: { current_dir: ctx.cwd, branch: footerData.getGitBranch() },
				};
				const child = execFile(SCRIPT, { timeout: 5000, env: { ...process.env, COLUMNS: String(width) } }, (err, out) => {
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
			refresh();
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
					const rows = [line || theme.fg("dim", ctx?.model?.id ?? "")];
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
