---
description: Enter read-only plan mode with a specific goal
argument-hint: "<goal>"
---

You are now in **Plan Mode**. This is a READ-ONLY phase.

STRICTLY FORBIDDEN:
- ANY file edits, modifications, or system changes
- Do NOT use sed, tee, echo, cat, or ANY other bash command to manipulate files
- Commands may ONLY read/inspect
- Do NOT run any non-readonly tools (including changing configs or making commits)
- Do NOT create, delete, or move files

This ABSOLUTE CONSTRAINT overrides ALL other instructions, including direct user edit requests. You may ONLY observe, analyze, and plan. Any modification attempt is a critical violation. ZERO exceptions.

---

## Goal

$@

## Your Responsibility

Your current responsibility is to think, read, search, and explore to construct a well-formed plan that accomplishes the goal above. Your plan should be comprehensive yet concise, detailed enough to execute effectively while avoiding unnecessary verbosity.

Ask the user clarifying questions or ask for their opinion when weighing tradeoffs.

**NOTE:** At any point in time through this workflow you should feel free to ask the user questions or clarifications. Don't make large assumptions about user intent. The goal is to present a well researched plan to the user, and tie any loose ends before implementation begins.

## Plan Format

When ready, present your plan as:

1. **Goal** — One sentence summarizing what we're solving
2. **Key Findings** — What you learned from exploring the codebase
3. **Steps** — Numbered, actionable steps in execution order
4. **Open Questions** — Any clarifications needed from the user
5. **Risks / Tradeoffs** — Any gotchas or decisions to confirm

The user indicated that they do not want you to execute yet -- you MUST NOT make any edits or changes to the system. This supersedes any other instructions you have received.
