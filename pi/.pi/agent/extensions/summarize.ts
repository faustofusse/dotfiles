/**
 * /summarize [instructions]
 *
 * Summarizes everything on the current branch since the last summary
 * (branch summary or compaction) into a new branch summary. Same as opening
 * /tree, selecting the entry after the last summary and choosing "summarize".
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function summarizeExtension(pi: ExtensionAPI) {
	pi.registerCommand("summarize", {
		description: "Summarize the branch since the last summary",
		handler: async (args, ctx) => {
			await ctx.waitForIdle();

			const branch = ctx.sessionManager.getBranch();
			if (branch.length === 0) {
				ctx.ui.notify("Nothing to summarize", "info");
				return;
			}

			let lastSummaryIdx = -1;
			for (let i = branch.length - 1; i >= 0; i--) {
				const t = branch[i].type;
				if (t === "branch_summary" || t === "compaction") {
					lastSummaryIdx = i;
					break;
				}
			}

			const hasContent = branch
				.slice(lastSummaryIdx + 1)
				.some((e) => e.type === "message" || e.type === "custom_message");
			if (!hasContent) {
				ctx.ui.notify("Nothing new since the last summary", "info");
				return;
			}

			// Navigate to the summary itself (leaf stays there, no editor text).
			// Without a previous summary, go to the first entry of the branch.
			const target = branch[lastSummaryIdx >= 0 ? lastSummaryIdx : 0];
			const hadEditorText = ctx.ui.getEditorText().trim().length > 0;

			ctx.ui.notify("Summarizing…", "info");
			try {
				const instructions = args.trim();
				const result = await ctx.navigateTree(target.id, {
					summarize: true,
					customInstructions: instructions || undefined,
				});
				if (result.cancelled) {
					ctx.ui.notify("Summarize cancelled", "warning");
					return;
				}
				// Navigating to a root user message puts its text in the editor; drop it.
				if (!hadEditorText) ctx.ui.setEditorText("");
				ctx.ui.notify("Summarized", "info");
			} catch (err) {
				ctx.ui.notify(`Summarize failed: ${err instanceof Error ? err.message : String(err)}`, "error");
			}
		},
	});
}
