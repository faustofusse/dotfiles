/**
 * Auto-load AGENTS.md Extension
 *
 * Automatically discovers and loads AGENTS.md / CLAUDE.md files from the
 * directory tree of any file read via the `read` tool. It walks up from the
 * read file's directory to the project root (cwd), collecting context files
 * the same way pi loads them from cwd upward — but triggered on demand when
 * you work in nested directories.
 *
 * Usage:
 *   - Place in `.pi/extensions/auto-load-agents.ts`
 *   - Or `~/.pi/agent/extensions/auto-load-agents.ts` for global use
 *   - No configuration needed
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

interface PendingContext {
	path: string;
	content: string;
}

export default function (pi: ExtensionAPI) {
	const loaded = new Set<string>();
	const pending: PendingContext[] = [];

	function isInsideOrEqual(dir: string, base: string): boolean {
		const rel = path.relative(base, dir);
		return !rel.startsWith("..") && !path.isAbsolute(rel);
	}

	function discoverAgents(filePath: string, cwd: string): PendingContext[] {
		const fileDir = path.dirname(path.resolve(cwd, filePath));
		const cwdResolved = path.resolve(cwd);
		const found: PendingContext[] = [];

		let currentDir = fileDir;
		while (isInsideOrEqual(currentDir, cwdResolved)) {
			for (const name of ["AGENTS.md", "CLAUDE.md"]) {
				const agentPath = path.join(currentDir, name);
				if (fs.existsSync(agentPath) && !loaded.has(agentPath)) {
					try {
						const content = fs.readFileSync(agentPath, "utf-8");
						loaded.add(agentPath);
						found.push({ path: agentPath, content });
					} catch {
						// Ignore unreadable files
					}
				}
			}

			if (currentDir === cwdResolved) break;
			const parent = path.dirname(currentDir);
			if (parent === currentDir) break;
			currentDir = parent;
		}

		return found;
	}

	pi.on("tool_call", async (event, ctx) => {
		if (!isToolCallEventType("read", event)) return;

		const readPath = event.input.path;

		// Skip if reading an agents file directly to avoid self-referencing
		const basename = path.basename(readPath).toLowerCase();
		if (basename === "agents.md" || basename === "claude.md") return;

		const discovered = discoverAgents(readPath, ctx.cwd);
		if (discovered.length === 0) return;

		pending.push(...discovered);

		if (ctx.hasUI) {
			for (const { path: agentPath } of discovered) {
				ctx.ui.notify(
					`Loaded context: ${path.relative(ctx.cwd, agentPath)}`,
					"info",
				);
			}
		}
	});

	pi.on("context", async (event, _ctx) => {
		if (pending.length === 0) return;

		const messages = [...event.messages];

		// Find insertion point after the last existing system message
		let insertIndex = 0;
		for (let i = 0; i < messages.length; i++) {
			if (messages[i].role === "system") {
				insertIndex = i + 1;
			}
		}

		for (const { path: agentPath, content } of pending) {
			messages.splice(insertIndex, 0, {
				role: "system",
				content: `---\nContext from ${path.basename(path.dirname(agentPath))}/${path.basename(agentPath)}:\n\n${content}\n---`,
			});
			insertIndex++;
		}

		pending.length = 0;
		return { messages };
	});
}
