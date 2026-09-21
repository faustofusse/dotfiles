---
name: jira
description: Use when the user references Jira tickets/issues (e.g. ticket IDs, "jira", searching/creating/updating issues). Indicates the agent should use the acli (Atlassian CLI) tool.
---
# Jira (acli)

Use the `acli` (Atlassian CLI) tool for any Jira ticket/issue work.

## Setup

Check if `acli` is installed (`command -v acli`). If missing, install it:

```
nix profile install nixpkgs#acli
```

## Usage

Do not assume flags or subcommands. Run `acli --help` and `acli jira --help` (and `--help` on any subcommand) to discover current usage before acting, since the CLI may change over time.
