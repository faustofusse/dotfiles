/**
 * Makes the "Working" status label lowercase.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function lowercaseWorking(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setWorkingMessage("working");
	});
}
