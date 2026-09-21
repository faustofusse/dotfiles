import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execFile } from "node:child_process";
import { homedir } from "node:os";

function collapseCwd(cwd: string): string {
	const home = homedir();
	if (cwd === home) return "~";
	if (cwd.startsWith(home + "/")) return "~" + cwd.slice(home.length);
	return cwd;
}

type Notifier = (title: string, body: string) => void;

function getNotifier(): Notifier | null {
	switch (process.platform) {
		case "darwin":
			return (title, body) => {
				const script = `display notification "${body.replace(/"/g, '\\"')}" with title "${title.replace(/"/g, '\\"')}"`;
				execFile("osascript", ["-e", script], (err) => {
					if (err) console.error("[notify] osascript failed:", err.message);
				});
			};
		case "linux":
			return (title, body) => {
				const escapedTitle = title.replace(/"/g, '\\"');
				const escapedBody = body.replace(/"/g, '\\"');
				execFile("dunstify", ["-u", "normal", "-t", "7000", escapedTitle, escapedBody], (err) => {
					if (err) console.error("[notify] dunstify failed:", err.message);
				});
			};
		default:
			return null;
	}
}

export default function (pi: ExtensionAPI) {
	const notify = getNotifier();
	if (!notify) return;

	pi.on("agent_end", async (_event, ctx) => {
		const sessionName = ctx.sessionManager.getSessionFile()
			? "Pi"
			: "Pi (ephemeral)";

		const shortCwd = collapseCwd(ctx.cwd);
		const body = `done \u00b7 ${shortCwd}`;

		notify(sessionName, body);
	});
}
