/**
 * Interrupt Command Extension
 *
 * Adds `/interrupt` command that emulates the double-escape behaviour,
 * aborting the current agent operation. Useful when you cannot press
 * escape (e.g., over a remote connection, on a phone keyboard, etc.).
 *
 * Usage:
 * 1. Place in ~/.pi/agent/extensions/
 * 2. Run /reload or restart pi
 * 3. Type /interrupt to abort the current agent turn
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function interruptExtension(pi: ExtensionAPI) {
	pi.registerCommand("interrupt", {
		description: "Abort the current agent operation (like pressing Escape)",
		handler: async (_args, ctx) => {
			if (ctx.isIdle()) {
				ctx.ui.notify("Nothing to interrupt — agent is idle", "info");
				return;
			}

			ctx.ui.notify("Interrupting agent...", "warning");
			ctx.abort();
		},
	});
}
