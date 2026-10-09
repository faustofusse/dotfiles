---
name: ticket
description: Use when the user references Jira tickets/issues (e.g. ticket IDs, "jira", searching/creating/updating issues), when the user describes a bug or piece of work that should become a ticket, and for the "start <TICKET>" handoff that moves a ticket to En curso, creates a Herdr worktree, and launches a planning agent there. Uses acli (Atlassian CLI).
---

# Tickets (Jira via acli)

Use the `acli` (Atlassian CLI) tool for all Jira ticket/issue work. The one exception is uploading files (attachments, and evidence images placed in a field). `acli` can't do that, so use the REST API as described in **Upload files** below. Don't use REST for anything else.

## Setup

Check if `acli` is installed (`command -v acli`). If missing, install it:

```
nix profile install nixpkgs#acli
```

## Usage

Do not assume flags or subcommands. Run `acli --help` and `acli jira --help` (and `--help` on any subcommand) to discover current usage before acting, since the CLI may change over time.

Common shapes:

```bash
acli jira workitem view <KEY> --json --fields "key,summary,status,assignee,description,issuetype,priority"
acli jira workitem transition --key <KEY> --status "<Status>" --yes
acli jira workitem search --jql "<JQL>" --json --limit 50
acli jira workitem create --project <KEY> --type <Type> --summary "<summary>" --description-file <file> --parent <EPIC> --json
```

---

# Upload files (REST exception)

`acli` can only list and delete attachments, and `acli jira workitem edit` can't set custom fields. So uploads, and filling a field with uploaded images, go through the Jira REST API.

## Credentials

- Site: take it from `acli jira auth status`.
- Email: from the same `acli jira auth status` output.
- API token: `~/.config/jira/key`, a single bare token. **Never print, cat, echo or grep this file**, and don't pipe it through `sed` to "redact" it. Read it only inside the command that uses it:

```bash
jira_curl() { curl -sS -u "<email>:$(tr -d '\n\r' < ~/.config/jira/key)" "$@"; }
```

If the file is missing, ask the user to create one (id.atlassian.com → Security → API tokens) and `chmod 600` it. Never fall back to the OAuth token stored by `acli`.

## Attach files to a ticket

```bash
jira_curl -X POST -H "X-Atlassian-Token: no-check" \
  -F "file=@a.png" -F "file=@b.png" \
  "https://<site>/rest/api/3/issue/<KEY>/attachments"
```

The response is a JSON array with each attachment's `id`. Verify with `acli jira workitem attachment list --key <KEY>`.

## Put evidence images in a field (e.g. "Evidencia de Testing")

Some workflows require a rich-text field before a transition. In DPIT, moving to "En revisión" requires "Evidencia de Testing". Such fields take text, not files, so the images must be attached first and then embedded in the field:

1. Find the field id (acli doesn't expose field names):
   ```bash
   jira_curl "https://<site>/rest/api/3/field" | python3 -c 'import sys,json; [print(f["id"], f["name"]) for f in json.load(sys.stdin) if "evidencia" in f["name"].lower()]'
   ```
   In DPIT, "Evidencia de Testing" is `customfield_11300`. Don't confuse it with "Evidencia" (`customfield_11266`).
2. Attach the files (see above).
3. Get each attachment's media UUID. It's in the redirect `Location` header of the attachment's content URL:
   ```bash
   jira_curl -o /dev/null -D - "https://<site>/rest/api/3/attachment/content/<attachment-id>" \
     | grep -i '^location:' | grep -oE 'file/[0-9a-f-]{36}' | cut -d/ -f2
   ```
4. Set the field to an ADF doc, with a short caption paragraph before each image:
   ```json
   {"fields": {"customfield_11300": {"type": "doc", "version": 1, "content": [
     {"type": "paragraph", "content": [{"type": "text", "text": "Vendedor: ..."}]},
     {"type": "mediaSingle", "attrs": {"layout": "center", "width": 40},
      "content": [{"type": "media", "attrs": {"type": "file", "id": "<media-uuid>", "collection": ""}}]}
   ]}}}
   ```
   ```bash
   jira_curl -X PUT -H "Content-Type: application/json" --data @field.json \
     -w "HTTP %{http_code}\n" "https://<site>/rest/api/3/issue/<KEY>"
   ```
   Expect `HTTP 204`. Setting the field replaces its previous content.
5. Verify with acli: `acli jira workitem view <KEY> --json --fields customfield_11300`.

Don't post a comment as a substitute for the evidence field unless the user asks for one.

---

# Project config in AGENTS.md

Before creating anything, read the repo's `AGENTS.md` (repo root first, then the nearest one above `$PWD`) **in full** and work out where tickets belong.

There is no required format. Do not look for a `## Jira` heading, a key-value block, or any particular wording. The file is written for humans; read it like one. All of these say the same thing:

```markdown
The epic is DPIT-2980.

Jira: DPIT-2980

Tickets for this repo go under DPIT-2980 (Platform Q3).

El épico de este proyecto es DPIT-2980.

## Jira
- project: DPIT
- epic: DPIT-2980
```

To find candidates fast, then read the surrounding lines to judge what they mean:

```bash
rg -n -i -e '[A-Z][A-Z0-9_]+-[0-9]+' -e 'jira|epic|épico|ticket' AGENTS.md
```

What you need:

- **epic** — the `--parent` value. Any issue key the file presents as the destination for this repo's tickets. A bare key with no other role stated, as in `Jira: DPIT-2980`, is the epic.
- **project** — the `--project` value. If the file does not name one, take the prefix of the epic key: `DPIT-2980` means project `DPIT`. Never ask for something you can derive.
- **type** — default `--type` if the file states one. Otherwise `Task`, or `Bug` when the description clearly describes a defect.

Judgement, not pattern matching. A key that appears as an example, inside changelog prose, or as "see DPIT-1204 for history" is not the epic. If the file names several keys and none is clearly the destination, treat the epic as missing and ask.

If no epic is stated, or the file is ambiguous about which key is the destination, **ask the user and stop**. Do not guess an epic from the repo name and do not create an orphan ticket because the file said nothing. To make the question answerable, list the candidates first:

```bash
acli jira workitem search --jql "project = <KEY> AND type = Epic AND statusCategory != Done" --json --limit 20
```

Once the user answers, offer to record it in `AGENTS.md` so the next run does not ask again. Match the file's existing voice: a one-line sentence such as `The epic is DPIT-2980.` in a fitting section beats bolting on a config block. Write it only if they agree.

---

# Create a ticket from a description

Trigger phrases: "create a ticket for `<description>`", "crea un ticket `<description>`", "abre un issue `<description>`", or a `start` request that carries a description instead of a key.

## Step 1 — Resolve config

Read `AGENTS.md` and work out the epic, project, and type as described above. A missing or ambiguous epic stops the workflow with a question.

## Step 2 — Draft and confirm

Turn the user's description into:

- **summary** — one line, imperative, under ~80 chars. `Fix login redirect loop on SSO return`, not `login bug`.
- **description** — Markdown with what happens, expected behaviour, and any reproduction steps, file paths, or error text the user gave. Do not invent repro steps, stack traces, or affected versions the user never mentioned. If context is thin, keep the ticket thin and say so.
- **type** — from config, or `Bug` when the description is clearly a defect.

Write the description to a file rather than passing it inline, so newlines and quotes survive:

```bash
DESC="${TMPDIR:-/tmp}/jira-new-$(date +%s).md"
```

Show the user the summary, type, project, and parent epic, and wait for a yes. Creating is visible to everyone on the board, so confirm before, not after.

## Step 3 — Create

```bash
acli jira workitem create --project <PROJECT> --type <TYPE> --summary "<summary>" --description-file "$DESC" --parent <EPIC> --json
```

Parse the new key from the JSON. If `--parent` is rejected because the project uses a different hierarchy, report it and ask whether to create without the epic. Do not silently drop the flag.

Report the new key and its URL.

## Step 4 — Hand off, only if asked

If the user asked to *start* the work (not merely to file it), continue into the handoff below using the new key, skipping its Step 1 since you already have the ticket content. Plain "create a ticket" stops here.

---

# Start a ticket (parameterized handoff)

Trigger phrases: "start `<TICKET>`", "empezar `<TICKET>`", "arranca `<TICKET>`", "use ticket skill: `<TICKET>`", or any request to begin work on a ticket key.

## Parameters

| Parameter | How it is read | Default |
|---|---|---|
| `TICKET` | The Jira key in the user's message, matching `[A-Z][A-Z0-9_]+-[0-9]+` (e.g. `FAU-123`). Required, or created first from a description. | — |
| `KIND` | Agent kind if the user names one ("with codex", "usa claude"). | the caller's own kind (see below) |
| `MODEL` | Model if the user names one ("con sonnet"). | Opus 5.5 in the form `KIND` expects (see below) |

When the user does not name a kind, the child runs on the same harness as the caller. Detect it from the environment:

| Caller | Signal | `KIND` | Default `MODEL` |
|---|---|---|---|
| Claude Code | `CLAUDECODE=1` | `claude` | `claude-opus-5-5` |
| pi | `PI_CODING_AGENT=true` (or `AI_AGENT=pi`) | `pi` | `anthropic/claude-opus-5-5` |

```bash
if [ "${CLAUDECODE:-}" = 1 ]; then echo claude
elif [ "${PI_CODING_AGENT:-}" = true ] || [ "${AI_AGENT:-}" = pi ]; then echo pi
else echo unknown; fi
```

If neither signal is present, `herdr pane current` reports the caller pane's `agent`; use that. If it is still unknown, fall back to `pi`.
| `STATUS` | Target status if the user names one. | `En curso` |
| `BASE` | Base ref if the user names one ("desde develop"). | repo default (omit `--base`) |

If no ticket key is present, check whether the message describes work to be done. If it does, run **Create a ticket from a description** first and use the resulting key. If it is neither a key nor a description, ask and stop. Never invent a key.

## Preconditions

```bash
test "${HERDR_ENV:-}" = 1 && command -v acli >/dev/null && git -C "$PWD" rev-parse --show-toplevel
```

All three must pass. Not inside Herdr, no `acli`, or not in a git repo: report which check failed and stop. Do not partially execute this workflow.

## Step 1 — Read the ticket

```bash
acli jira workitem view <TICKET> --json --fields "key,summary,status,assignee,description,issuetype,priority"
```

If this fails (bad key, no auth), stop and report. Everything after this point is irreversible from the user's point of view.

Write a self-contained brief for the child agent, which will start with an empty context in a fresh worktree:

```bash
BRIEF="${TMPDIR:-/tmp}/<TICKET>-brief.md"
```

The brief holds the key, summary, type, priority, status, and the full description as Markdown. The child reads this file; it gets no other context from you.

## Step 2 — Move the ticket to En curso

```bash
acli jira workitem transition --key <TICKET> --status "En curso" --yes
```

If the transition is rejected, the workflow may use a different label. Re-read the current status with `acli jira workitem view <TICKET> --fields status --json`, try the obvious equivalent once (`In Progress`), and if that also fails, report the failure and ask the user which status to use. Do not continue to Step 3 with the ticket untransitioned unless the user says to.

## Step 3 — Create the worktree

Derive a slug from the summary: lowercase, non-alphanumerics to `-`, collapsed, stripped of filler words. Branch is `<ticket-lower>-<slug>` trimmed to ~50 chars, e.g. `dpit-3104-fix-login-redirect`.

Label the workspace with the key **and** a human-readable summary, e.g. `DPIT-3104 fix login redirect`. A bare key is not enough: the sidebar shows several of these at once and `DPIT-3104` alone says nothing about what the tab is doing. Keep it under ~40 chars so it does not get cut off.

```bash
herdr worktree create --cwd "$PWD" --branch <branch> --label "<TICKET> <short summary>" --no-focus
```

Add `--base <BASE>` only when the user specified one. This creates a linked worktree **workspace**, not a tab in the current one.

Parse the JSON response for the new workspace ID and its root pane ID (`.result.workspace.workspace_id`, `.result.root_pane.pane_id`). If those paths are absent, discover the pane with `herdr pane list --workspace <workspace_id>`. Never guess IDs.

Use `--trust-repository` only if the user has already vouched for the repo; it is not a retry for a failed create.

## Step 4 — Launch the planning agent

```bash
# from Claude Code
herdr agent start <slug> --kind claude --pane <root_pane_id> -- --model claude-opus-5-5

# from pi
herdr agent start <slug> --kind pi --pane <root_pane_id> -- --model anthropic/claude-opus-5-5
```

Native agent args go after `--`.

Always qualify the model with its provider for `pi`. A bare `--model opus` is a fuzzy pattern that matches across every provider and happily lands on `amazon-bedrock`'s `us.anthropic.claude-opus-*`, which fails at startup with `No API key found for amazon-bedrock`. The `provider/id` form pins it. Confirm the id exists first:

```bash
pi --list-models 'anthropic/claude-opus'
```

For `--kind claude`, pass the full model name `claude-opus-5-5`. There is no provider ambiguity, and the full name keeps the version fixed where the `opus` alias would follow whatever is latest. Check `<kind> --help` before using any other kind.

Name the agent from the summary slug alone, without the ticket key: `fix-login-redirect`, not `dpit-3104-fix-login-redirect`. The key is already on the workspace label, and dropping it leaves the full 32 chars of `[a-z][a-z0-9_-]{0,31}` for words that describe the work. Trim whole words rather than cutting mid-word.

If `agent start` returns `agent_not_ready`, read the pane and wait for idle before prompting.

`agent start` can report `interactive_ready: true` while the agent is still printing startup output (pi's skill-collision list, for example). A prompt sent then is accepted with exit 0 and silently dropped. So don't trust the exit code. Wait only until the agent picks the prompt up, and not until it finishes. The child plans on its own schedule and the user reviews it directly in its pane, so there is nothing to collect:

```bash
herdr agent prompt <slug> "Read <BRIEF> for the full ticket. You are in a fresh worktree on branch <branch>. Produce an implementation plan only: explore the codebase, identify the files and functions to change, list the steps in order, and call out risks and open questions. Write the plan to docs/plans/<TICKET>.md in this worktree. Do not modify any other file and do not implement the ticket. Stop when the plan is written and wait for the user to review it." \
  --wait --until working --until blocked --timeout 20000
```

If that returns `working`, the prompt landed. `blocked` means the user must handle it in the pane. If it returns `agent_prompt_stalled` or `timeout`, the prompt was dropped or is stuck in the input box:

1. Read the pane: `herdr pane read <root_pane_id> --source visible`.
2. If the prompt text is sitting unsubmitted in the input box, submit it with `herdr pane send-keys <root_pane_id> enter` instead of re-sending, which would duplicate it.
3. If the input box is empty, wait until the startup output has stopped changing (read the pane again), then send the same prompt once more with the same `--wait --until` flags.

Retry once. If it still isn't `working`, say so plainly and give the user the pane ID, since the worktree exists and the ticket is already transitioned.

When starting several tickets, start all agents first and prompt them afterwards. This gives each agent more time to settle, but every prompt still needs the `--wait --until` check.

## Step 5 — Report and stop

Report, then end the turn. Do not close, kill, or clean up your own tab, pane, or workspace: the caller usually lives in a workspace that owns the new worktree group, so `tab close` hits Herdr's `confirm_close` safeguard and there is no scriptable bypass. Leave the caller's terminal to the user.

Report:

- ticket key and summary
- old status → `En curso`
- branch and worktree path
- new workspace ID, agent name, and where the plan will be written
- how to get there: `herdr workspace focus <workspace_id>`

## Rules

- Steps run in order and stop on first failure. A half-done handoff (ticket moved, no worktree) is worse than no handoff; say exactly which steps completed.
- Close nothing. Not your tab, not the worktree workspace you created, and never `herdr workspace close --group`.
- The child plans; it does not implement. Keep that constraint in the prompt.
- One ticket per invocation. For several tickets, run the workflow once per ticket.
- Never create a ticket without an epic you are confident about. Ask instead.
- `AGENTS.md` has no schema. Read it for meaning; never make the user write config in a fixed shape.
- The ticket description holds what the user said, not what you inferred.
