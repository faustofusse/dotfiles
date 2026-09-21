---
name: subagents
description: "Run subagents as Herdr tabs (windows) in the current workspace: create a tab, start an agent in its root pane, prompt it, read the result, close the tab. Use when asked to delegate, parallelize, or spawn a subagent/worker/reviewer and HERDR_ENV=1. For other Herdr inspection or control, use the herdr skill."
---

# Subagents via Herdr tabs

A subagent is a tab in the caller's workspace. Create it, use it, close it. Nothing persists after the task.

Requires Herdr:

```bash
test "${HERDR_ENV:-}" = 1
```

If that fails, do the work yourself. Do not control Herdr from outside Herdr.

## Spawn

Create a tab in the caller's workspace, inherit the cwd, leave focus alone:

```bash
herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label reviewer --no-focus
```

The response carries `.result.tab.tab_id` and `.result.root_pane.pane_id`. Read both from JSON; never guess IDs. Keep the tab label and the agent name the same so the user can see who is doing what.

Start the agent in the root pane:

```bash
herdr agent start reviewer --kind pi --pane <root_pane_id>
```

Kinds: `pi`, `claude`, `codex`, `gemini`, and others listed by `herdr agent`. Default to `pi` unless the user asks for another. Pass agent flags after `--`.

If `agent start` returns `agent_not_ready`, the agent is up but blocked; `herdr agent read <name>` and wait for idle before prompting.

## Delegate

One self-contained prompt per subagent. The child shares the filesystem, not your context.

```bash
herdr agent prompt reviewer "Review the diff on this branch. Report only actionable findings." --wait --timeout 300000
```

`--wait` returns on the first settled `idle`, `done`, or `blocked`. For several subagents, create and prompt them all without `--wait`, then wait on each:

```bash
herdr agent wait reviewer --timeout 300000
```

## Collect

```bash
herdr agent read reviewer --source recent-unwrapped --lines 200
```

If the transcript is truncated because the agent uses the alternate screen, ask it to write the full answer to a file under `$TMPDIR` and reply with the path, then read the file.

If a wait returns `blocked`, read the tab and ask the user before answering an approval prompt. Do not resend a prompt after a timeout without reading first.

## Clean up

Close every tab you created as soon as its output is collected:

```bash
herdr tab close <tab_id>
```

Track the tab IDs you spawned and close them even when the task fails or you abandon it. Report what the subagents found; leave no tabs behind.

## Rules

- Tabs in the caller's workspace, same cwd. No new workspaces or worktrees unless the user asks.
- Never close a tab, pane, or workspace you did not create. Never run `herdr server stop`.
- One writer per directory: parallel subagents that edit the same files will collide. Split by file or give them read-only review work.
- Keep the fanout small (two or three tabs).
