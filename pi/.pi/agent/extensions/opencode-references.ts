/**
 * OpenCode References Extension
 *
 * Looks for an `opencode.jsonc` file (walking up from the session's cwd)
 * and reads its `references` map:
 *
 *   {
 *     "$schema": "https://opencode.ai/config.json",
 *     "references": {
 *       "api": {
 *         "path": "../api",
 *         "description": "This is the api."
 *       },
 *       "openwa-source": {
 *         "repository": "rmyndharis/OpenWA",
 *         "description": "Use for OpenWA integrations."
 *       }
 *     }
 *   }
 *
 * Each reference entry has either:
 *   - "path": a local path (supports "~/" and relative paths, resolved
 *     relative to the directory containing opencode.jsonc)
 *   - "repository": an "owner/repo" shorthand for an external git repo
 *     that is not checked out locally
 *
 * Found references are summarized and injected into the system prompt so
 * the agent knows what related projects exist and where to find them,
 * without having to be told manually every session.
 *
 * Usage:
 * 1. This file lives in ~/.pi/agent/extensions/ (global) so it applies to
 *    every project. Copy it to a project's .pi/extensions/ instead to
 *    scope it to one repo.
 * 2. Add an opencode.jsonc with a "references" block to any project root.
 * 3. Use /references to reprint the discovered references at any time.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const CONFIG_FILENAME = "opencode.jsonc";

interface RawReference {
	path?: string;
	repository?: string;
	description?: string;
}

interface ResolvedReference {
	name: string;
	description?: string;
	repository?: string;
	rawPath?: string;
	resolvedPath?: string;
	exists?: boolean;
}

/**
 * Strip // and /* *​/ comments and trailing commas from JSONC text so it
 * can be parsed with JSON.parse. Skips comment-like sequences inside
 * string literals.
 */
function stripJsonc(input: string): string {
	let out = "";
	let inString = false;
	let stringQuote = "";
	let inLineComment = false;
	let inBlockComment = false;

	for (let i = 0; i < input.length; i++) {
		const c = input[i];
		const next = input[i + 1];

		if (inLineComment) {
			if (c === "\n") {
				inLineComment = false;
				out += c;
			}
			continue;
		}

		if (inBlockComment) {
			if (c === "*" && next === "/") {
				inBlockComment = false;
				i++;
			}
			continue;
		}

		if (inString) {
			out += c;
			if (c === "\\") {
				// preserve escaped char verbatim
				out += next ?? "";
				i++;
				continue;
			}
			if (c === stringQuote) {
				inString = false;
			}
			continue;
		}

		if (c === '"' || c === "'") {
			inString = true;
			stringQuote = c;
			out += c;
			continue;
		}

		if (c === "/" && next === "/") {
			inLineComment = true;
			i++;
			continue;
		}

		if (c === "/" && next === "*") {
			inBlockComment = true;
			i++;
			continue;
		}

		out += c;
	}

	// Remove trailing commas before } or ]
	out = out.replace(/,(\s*[}\]])/g, "$1");

	return out;
}

function parseJsonc(text: string): unknown {
	return JSON.parse(stripJsonc(text));
}

/** Walk up from `startDir` looking for the nearest opencode.jsonc. */
function findConfigFile(startDir: string): string | undefined {
	let dir = startDir;
	while (true) {
		const candidate = path.join(dir, CONFIG_FILENAME);
		if (fs.existsSync(candidate)) {
			return candidate;
		}
		const parent = path.dirname(dir);
		if (parent === dir) {
			return undefined;
		}
		dir = parent;
	}
}

function expandHome(p: string): string {
	if (p === "~") return os.homedir();
	if (p.startsWith("~/")) return path.join(os.homedir(), p.slice(2));
	return p;
}

function loadReferences(configPath: string): ResolvedReference[] {
	const configDir = path.dirname(configPath);
	const text = fs.readFileSync(configPath, "utf8");
	const data = parseJsonc(text) as { references?: Record<string, RawReference> };

	const refs = data.references ?? {};
	const resolved: ResolvedReference[] = [];

	for (const [name, ref] of Object.entries(refs)) {
		if (ref.repository) {
			resolved.push({
				name,
				description: ref.description,
				repository: ref.repository,
			});
			continue;
		}

		if (ref.path) {
			const expanded = expandHome(ref.path);
			const resolvedPath = path.isAbsolute(expanded) ? expanded : path.resolve(configDir, expanded);
			resolved.push({
				name,
				description: ref.description,
				rawPath: ref.path,
				resolvedPath,
				exists: fs.existsSync(resolvedPath),
			});
			continue;
		}

		resolved.push({ name, description: ref.description });
	}

	return resolved;
}

function formatReferencesSection(configPath: string, refs: ResolvedReference[]): string {
	const lines = refs.map((ref) => {
		if (ref.repository) {
			const desc = ref.description ? ` — ${ref.description}` : "";
			return `- **${ref.name}** (external repo: \`${ref.repository}\`, not checked out locally)${desc}`;
		}

		const desc = ref.description ? ` — ${ref.description}` : "";
		const missing = ref.exists === false ? " (path not found on disk)" : "";
		return `- **${ref.name}**: \`${ref.resolvedPath}\`${missing}${desc}`;
	});

	return `

## Project References (from ${configPath})

This project declares related repositories/directories in ${CONFIG_FILENAME}. Use the read/grep/find/ls tools to explore them when a task involves cross-repo context (e.g. checking an API contract, shared infra config, or a sibling app). Do not assume write access unless the user asks for changes there.

${lines.join("\n")}
`;
}

export default function openCodeReferencesExtension(pi: ExtensionAPI) {
	let configPath: string | undefined;
	let references: ResolvedReference[] = [];
	let loadError: string | undefined;

	function reload(cwd: string) {
		configPath = undefined;
		references = [];
		loadError = undefined;

		const found = findConfigFile(cwd);
		if (!found) return;

		try {
			configPath = found;
			references = loadReferences(found);
		} catch (err) {
			loadError = err instanceof Error ? err.message : String(err);
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		reload(ctx.cwd);

		if (loadError) {
			ctx.ui.notify(`Failed to parse ${CONFIG_FILENAME}: ${loadError}`, "warning");
		} else if (configPath && references.length > 0) {
			ctx.ui.notify(`Loaded ${references.length} reference(s) from ${path.relative(ctx.cwd, configPath) || CONFIG_FILENAME}`, "info");
		}
	});

	pi.on("before_agent_start", async (event) => {
		if (!configPath || references.length === 0) {
			return undefined;
		}

		return {
			systemPrompt: event.systemPrompt + formatReferencesSection(configPath, references),
		};
	});

	pi.registerCommand("references", {
		description: "Show references declared in this project's opencode.jsonc",
		handler: async (_args, ctx) => {
			reload(ctx.cwd);

			if (loadError) {
				ctx.ui.notify(`Failed to parse ${CONFIG_FILENAME}: ${loadError}`, "error");
				return;
			}

			if (!configPath) {
				ctx.ui.notify(`No ${CONFIG_FILENAME} found from ${ctx.cwd} upward.`, "warning");
				return;
			}

			if (references.length === 0) {
				ctx.ui.notify(`${configPath} has no references.`, "info");
				return;
			}

			pi.sendMessage({
				customType: "opencode-references",
				content: formatReferencesSection(configPath, references).trim(),
				display: true,
				details: { configPath, references },
			});
		},
	});
}
