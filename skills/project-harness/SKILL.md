---
name: project-harness
description: Use when setting up a new project for structured AI-agent development - scaffolds docs directory with design plans, tasks, verification types, and hooks for lifecycle tracking
user-invocable: true
---

# Project Harness

Scaffold a project with structured directories for design plans, tasks, verification types, and implementation plans. The harness enables AI agents to track work lifecycle, discover verification capabilities, and maintain project state across sessions.

## Overview

The harness is a convention-over-configuration filesystem structure. No manifest files or custom config formats. Agents discover the harness by reading directory contents and YAML frontmatter in markdown files.

**Three committed artifact types:**
- **Design plans** — static specifications of what to build
- **Tasks** — work items with lifecycle state (the single source of truth for progress)
- **Verification types** — documentation of how to verify work is correct

**One ephemeral artifact type:**
- **Implementation plans** — detailed phase-by-phase working documents (.gitignored)

## Scaffolding Steps

When the user invokes this skill, execute the following steps in the target project directory.

### Step 1: Create directory structure

```
docs/
├── design-plans/          # committed
├── tasks/                 # committed
├── verification/          # committed
└── implementation-plans/  # .gitignored
```

Create all four directories. Add a `.gitkeep` in each empty directory so git tracks them.

### Step 2: Add implementation-plans to .gitignore

Append to the project's `.gitignore`:

```
# Implementation plans are ephemeral working documents
docs/implementation-plans/
```

If `.gitignore` already contains this entry, skip.

### Step 3: Inject harness section into AGENTS.md

Read the template from `~/.claude/skills/project-harness/templates/agents-harness-section.md` and append it to the project's `AGENTS.md`. If `AGENTS.md` doesn't exist, create it with this section.

Before appending, check if AGENTS.md already contains a "## Project Harness" section. If so, replace it rather than duplicating.

### Step 4: Set up hooks

Copy hook scripts from `~/.claude/skills/project-harness/templates/hooks/` into the project's `.claude/hooks/` directory:

```bash
mkdir -p .claude/hooks
cp ~/.claude/skills/project-harness/templates/hooks/verify-task-completion.sh .claude/hooks/
cp ~/.claude/skills/project-harness/templates/hooks/check-stale-tasks.sh .claude/hooks/
cp ~/.claude/skills/project-harness/templates/hooks/harness-session-start.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Then merge the hook configuration from `~/.claude/skills/project-harness/templates/hooks/settings-hooks.json` into the project's `.claude/settings.json`. If the file exists, merge the `hooks` key without overwriting existing hooks. If it doesn't exist, create it.

### Step 5: Discover and create verification types

**Auto-discover first.** Inspect the project to find existing verification capabilities before asking the user. Check these sources:

**Package manager scripts:**
- `package.json` scripts (look for `test`, `lint`, `typecheck`, `build`, `e2e`, etc.)
- `Makefile` targets
- `pyproject.toml` scripts
- `Cargo.toml`

**Config files that indicate capabilities:**
- `vitest.config.*`, `jest.config.*` → unit-tests
- `playwright.config.*`, `cypress.config.*` → e2e-browser
- `tsconfig.json` → typecheck
- `.eslintrc.*`, `eslint.config.*`, `ruff.toml`, `.ruff.toml` → lint
- `vite.config.*`, `webpack.config.*`, `rollup.config.*` → build

**Test directories:**
- `tests/unit/`, `tests/integration/`, `tests/e2e/`, `__tests__/`
- `test/`, `spec/`

**Present findings to the user.** List each discovered verification type with:
- The detected name
- The command that would run it (from package.json scripts or config inference)
- The config file or directory that indicates it exists

Then ask the user to confirm, modify, or add to the list using AskUserQuestion. The user may want to rename types, change commands, or add types that weren't auto-detected (e.g., manual-review).

For each confirmed type, copy the template from `~/.claude/skills/project-harness/templates/verification-type.md` and fill in the name, command, and scope. Pre-populate the "When To Use" and "Success Criteria" sections based on what was discovered (e.g., if coverage thresholds are configured, include them).

### Step 6: Confirm setup

List what was created and remind the user:
- Design plans go in `docs/design-plans/YYYY-MM-DD-{name}.md`
- Tasks go in `docs/tasks/{name}.md` — use the template at `~/.claude/skills/project-harness/templates/task.md`
- Implementation plans go in `docs/implementation-plans/` and are not committed
- Verification types are in `docs/verification/` and agents read them to know how to verify work

## Artifact Formats

### Design Plans

Static specifications. No frontmatter status — lifecycle is derived from tasks.

```markdown
# Feature Name

## Summary
What and why.

## Acceptance Criteria

### AC1: Description
Details of what must be true.
- **Verified by:** unit-tests, e2e-browser

### AC2: Description
...
```

Design plans reference verification types in their acceptance criteria. This tells agents which checks prove the AC is met.

### Tasks

The single source of truth for work lifecycle.

```yaml
---
status: backlog | in-progress | done
design: YYYY-MM-DD-design-plan-name
created: YYYY-MM-DD
verified-by:
  - unit-tests
  - e2e-browser
---
```

**Status values:**
- `backlog` — identified, not started
- `in-progress` — actively being worked on
- `done` — all verification types in `verified-by` have passed

A design plan is complete when every task referencing it has status `done`.

### Verification Types

One file per type in `docs/verification/`. Each documents what it checks, when to use it, how to run it, and what success looks like. See the template at `~/.claude/skills/project-harness/templates/verification-type.md`.

### Implementation Plans

Ephemeral. Phase-by-phase working documents in `docs/implementation-plans/YYYY-MM-DD-{name}/`. These contain exact code, line numbers, and step-by-step instructions. They are .gitignored because they go stale immediately after implementation.

## Hooks

Three hooks are installed to enforce the workflow:

| Hook | Event | Purpose |
|------|-------|---------|
| `harness-session-start.sh` | SessionStart | Detects harness, reports task counts to give agents immediate context |
| `verify-task-completion.sh` | TaskCompleted | Reminds agent to run verification before marking tasks done |
| `check-stale-tasks.sh` | Stop | Alerts if in-progress tasks were left incomplete when agent stops |

Hooks live in `.claude/hooks/` and are configured in `.claude/settings.json`.
