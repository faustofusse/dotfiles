/**
 * Auto-update pi packages (extensions) on startup.
 *
 * - Suppresses the built-in "Package Updates Available" banner.
 * - When updates exist, shows a spinner widget ("Updating extensions...")
 *   while running the equivalent of `pi update --extensions`.
 * - Adds `/update-extensions` to check, update, and reload on demand.
 */
import type { ExtensionAPI, ExtensionContext, PackageUpdate } from "@earendil-works/pi-coding-agent";
import { DefaultPackageManager, getAgentDir, SettingsManager } from "@earendil-works/pi-coding-agent";
import { Loader } from "@earendil-works/pi-tui";

const WIDGET_KEY = "auto-update-extensions";
const ORIGINAL_CHECK = Symbol.for("auto-update-extensions.originalCheck");

type PM = InstanceType<typeof DefaultPackageManager>;
type CheckFn = (this: PM) => Promise<PackageUpdate[]>;

// Patch the prototype once so interactive mode's startup check finds nothing
// (no banner). Keep the original for our own use. Survives /reload.
const proto = DefaultPackageManager.prototype as unknown as Record<symbol | string, unknown>;
if (!proto[ORIGINAL_CHECK]) {
	proto[ORIGINAL_CHECK] = proto.checkForAvailableUpdates;
	proto.checkForAvailableUpdates = async () => [];
}
const originalCheck = proto[ORIGINAL_CHECK] as CheckFn;

let running: Promise<string[]> | undefined;

function createPackageManager(cwd: string): PM {
	const agentDir = getAgentDir();
	const pm = new DefaultPackageManager({
		cwd,
		agentDir,
		settingsManager: SettingsManager.create(cwd, agentDir),
	});
	// npm/git normally inherit stdio, which would scribble over the TUI.
	// Route them through the capture spawner and drain the pipes instead.
	const anyPm = pm as any;
	anyPm.spawnCommand = (command: string, args: string[], options?: unknown) => {
		const child = anyPm.spawnCaptureCommand(command, args, options);
		child.stdout?.resume();
		child.stderr?.resume();
		return child;
	};
	return pm;
}

function showSpinner(ctx: ExtensionContext, names: string[]) {
	const label = `Updating extensions... (${names.join(", ")})`;
	ctx.ui.setWidget(WIDGET_KEY, (tui, theme) => {
		const loader = new Loader(
			tui,
			(s) => theme.fg("accent", s),
			(s) => theme.fg("muted", s),
			label,
		);
		return Object.assign(loader, { dispose: () => loader.stop() });
	});
}

/** Returns the display names of updated packages (empty if none). */
async function updateExtensions(ctx: ExtensionContext): Promise<string[]> {
	if (process.env.PI_OFFLINE) return [];
	if (running) return running;

	running = (async () => {
		const pm = createPackageManager(ctx.cwd);
		const updates = await originalCheck.call(pm);
		if (updates.length === 0) return [];

		const names = updates.map((u) => u.displayName);
		if (ctx.hasUI) showSpinner(ctx, names);
		try {
			for (const u of updates) await pm.update(u.source);
		} finally {
			if (ctx.hasUI) ctx.ui.setWidget(WIDGET_KEY, undefined);
		}
		return names;
	})().finally(() => {
		running = undefined;
	});
	return running;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (event, ctx) => {
		if (event.reason !== "startup") return;
		// Fire and forget: don't block startup.
		updateExtensions(ctx).then(
			(names) => {
				if (names.length > 0 && ctx.hasUI) {
					ctx.ui.notify(`Updated extensions: ${names.join(", ")}. Run /reload to apply.`, "info");
				}
			},
			(err) => {
				if (ctx.hasUI) ctx.ui.notify(`Extension update failed: ${err instanceof Error ? err.message : err}`, "error");
			},
		);
	});

	pi.registerCommand("update-extensions", {
		description: "Update all installed pi packages and reload",
		handler: async (_args, ctx) => {
			try {
				const names = await updateExtensions(ctx);
				if (names.length === 0) {
					ctx.ui.notify("Extensions are up to date.", "info");
					return;
				}
				ctx.ui.notify(`Updated extensions: ${names.join(", ")}. Reloading...`, "info");
				await ctx.reload();
			} catch (err) {
				ctx.ui.notify(`Extension update failed: ${err instanceof Error ? err.message : err}`, "error");
			}
		},
	});
}
