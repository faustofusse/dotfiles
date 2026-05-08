import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execFile } from "node:child_process";
import { homedir } from "node:os";

function isMacOS(): boolean {
	return process.platform === "darwin";
}

function collapseCwd(cwd: string): string {
	const home = homedir();
	if (cwd === home) return "~";
	if (cwd.startsWith(home + "/")) return "~" + cwd.slice(home.length);
	return cwd;
}

function sendMacOSNotification(title: string, body: string): void {
	const script = `display notification "${body.replace(/"/g, '\\"')}" with title "${title.replace(/"/g, '\\"')}"`;
	execFile("osascript", ["-e", script], (err) => {
		if (err) {
			console.error("[macos-notify] failed to send notification:", err.message);
		}
	});
}

export default function (pi: ExtensionAPI) {
	if (!isMacOS()) {
		return;
	}

	pi.on("agent_end", async (_event, ctx) => {
		const sessionName = ctx.sessionManager.getSessionFile()
			? "Pi"
			: "Pi (ephemeral)";

		const shortCwd = collapseCwd(ctx.cwd);
		const body = `done · ${shortCwd}`;

		sendMacOSNotification(sessionName, body);
	});
}
