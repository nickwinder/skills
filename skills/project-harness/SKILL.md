---
name: project-harness
description: Use when setting up a new project for structured AI-agent development - scaffolds a knowledge-base harness with architecture docs, workflow phases, ADRs, patterns, and verification types with worktree isolation
user-invocable: true
---

# Project Harness

Scaffold a project with a knowledge-base harness for AI-agent development. The harness codifies institutional knowledge — architectural rules, the reasoning behind them, prior decisions, and discovered patterns — so agents can work effectively across sessions, worktrees, and context boundaries.

## Overview

The harness is a convention-over-configuration filesystem of committed documents. Agents discover it by reading directory contents. No manifest files, no custom formats.

**Core principle:** Committed artifacts persist institutional knowledge for future agents. Work tracking is handled by the agent's native tools (TodoWrite, TaskCreate). The harness is not a project management system.

**Isolation principle:** All execution — tests, builds, servers — must run self-contained within a git worktree. No agent may depend on shared ports, shared databases, or shared environments.

**Committed artifact areas:**

| Directory | Purpose |
|-----------|---------|
| `docs/architecture/` | Constraints (the rules) and beliefs (the why), plus worktree isolation guide |
| `docs/backlog/` | Deferred work items noticed incidentally during other tasks |
| `docs/decisions/` | Architecture Decision Records — significant decisions with rationale |
| `docs/patterns/` | Reusable solutions discovered during development |
| `docs/verification/` | How to verify work is correct, with failure remediation |
| `docs/workflow/` | Six-phase working methodology — how agents use the knowledge base |

## Scaffolding Steps

When the user invokes this skill, execute the following steps in the target project directory.

### Step 1: Create directory structure

```
docs/
├── architecture/
├── backlog/
├── decisions/
├── patterns/
├── verification/
└── workflow/
```

Create all six directories. Add a `.gitkeep` in each empty directory so git tracks them.

Also copy the backlog item template:

```bash
cp ~/.claude/skills/project-harness/templates/backlog/_template.md docs/backlog/
```

### Step 2: Update .gitignore

Append to the project's `.gitignore`:

```
# Worktrees are local working copies — not committed
.worktrees/
```

If `.gitignore` already contains this entry, skip.

### Step 3: Inject harness section into AGENTS.md

Read the template from `~/.claude/skills/project-harness/templates/agents-harness-section.md` and append it to the project's `AGENTS.md`. If `AGENTS.md` doesn't exist, create it with this section.

Before appending, check if AGENTS.md already contains a "## Project Harness" section. If so, replace it rather than duplicating.

Ask the user for their project's run command and test command so the Quick Start block in AGENTS.md can be filled in (rather than left as placeholders).

### Step 4: Set up hooks

Copy hook scripts from `~/.claude/skills/project-harness/templates/hooks/` into the project's `.claude/hooks/` directory:

```bash
mkdir -p .claude/hooks
cp ~/.claude/skills/project-harness/templates/hooks/verify-task-completion.sh .claude/hooks/
cp ~/.claude/skills/project-harness/templates/hooks/check-stale-knowledge.sh .claude/hooks/
cp ~/.claude/skills/project-harness/templates/hooks/harness-session-start.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Then merge the hook configuration from `~/.claude/skills/project-harness/templates/hooks/settings-hooks.json` into the project's `.claude/settings.json`. If the file exists, merge the `hooks` key without overwriting existing hooks. If it doesn't exist, create it.

### Step 5: Create architecture documents

Copy from `~/.claude/skills/project-harness/templates/architecture/` to `docs/architecture/`:

```bash
cp ~/.claude/skills/project-harness/templates/architecture/constraints.md docs/architecture/
cp ~/.claude/skills/project-harness/templates/architecture/beliefs.md docs/architecture/
cp ~/.claude/skills/project-harness/templates/architecture/worktree-isolation.md docs/architecture/
```

These files are rich templates with worked examples. Tell the user:
- `constraints.md` and `beliefs.md` contain example content to illustrate the format — they should replace the examples with their own constraints and beliefs before starting work
- `worktree-isolation.md` describes the isolation requirement and patterns — they should fill in the `BASE_PORT` and adapt the examples to their stack

### Step 6: Create decision and pattern templates

Copy templates into the empty directories:

```bash
cp ~/.claude/skills/project-harness/templates/decisions/_template.md docs/decisions/
cp ~/.claude/skills/project-harness/templates/patterns/_template.md docs/patterns/
```

These are ADR and pattern format templates. Agents use them when documenting decisions and patterns discovered during development.

### Step 7: Create workflow docs

Copy all six workflow phase documents:

```bash
cp ~/.claude/skills/project-harness/templates/workflow/1-explore.md docs/workflow/
cp ~/.claude/skills/project-harness/templates/workflow/2-design.md docs/workflow/
cp ~/.claude/skills/project-harness/templates/workflow/3-stress-test.md docs/workflow/
cp ~/.claude/skills/project-harness/templates/workflow/4-implement.md docs/workflow/
cp ~/.claude/skills/project-harness/templates/workflow/5-test.md docs/workflow/
cp ~/.claude/skills/project-harness/templates/workflow/6-review.md docs/workflow/
```

These documents are technology-agnostic. They do not need to be modified.

### Step 8: Discover and create verification types

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
- The command that would run it
- The config file or directory that indicates it exists

Then ask the user to confirm, modify, or add to the list using AskUserQuestion. The user may want to rename types, change commands, or add types that weren't auto-detected (e.g., manual-review).

For each confirmed type, copy the template from `~/.claude/skills/project-harness/templates/verification-type.md` and fill in the name, command, and scope. Pre-populate "When To Use" and "Success Criteria" based on what was discovered. Leave "Failure Remediation" and "Isolation Requirements" for the user to fill in — these are project-specific and cannot be auto-populated.

### Step 9: Confirm setup

List what was created. Remind the user of the two things they must do before starting work:

1. **Populate `docs/architecture/`** — replace the example content in `constraints.md` and `beliefs.md` with their project's actual rules and beliefs. Fill in `BASE_PORT` in `worktree-isolation.md` and adapt the isolation patterns to their stack.

2. **Fill in verification remediation** — for each verification type in `docs/verification/`, complete the `## Failure Remediation` section with specific guidance for this project. This is the most valuable thing an agent can read when a check fails.

## Artifact Formats

### Architecture Documents

**`docs/architecture/constraints.md`** — Rules that must not be broken. Each constraint names the rule, gives a concrete violation example, and optionally references the belief that explains why.

**`docs/architecture/beliefs.md`** — The philosophy behind the constraints. Each belief names what is believed, explains why, and states the trade-offs consciously accepted.

**`docs/architecture/worktree-isolation.md`** — How to run this project in an isolated worktree: port allocation formula, database namespacing, environment variable setup.

### Architecture Decision Records

Files in `docs/decisions/`. Use the `_template.md` format:

```markdown
---
date: YYYY-MM-DD
status: proposed | accepted | deprecated | superseded
---
# ADR: [Title]
## Context
## Decision
## Consequences
## Alternatives Considered
```

An ADR is created when making a significant decision: one that sets a precedent, chooses between meaningfully different approaches, or would surprise a future agent working in this area.

### Patterns

Files in `docs/patterns/`. Use the `_template.md` format:

```markdown
---
discovered: YYYY-MM-DD
---
# Pattern: [Name]
## Problem
## Solution
## Example
## When Not To Use
```

A pattern is documented when a solution to a recurring problem is found during implementation. Only document patterns that were actually used — not speculative patterns.

### Backlog Items

Files in `docs/backlog/`. One file per deferred observation. Use the `_template.md` format:

```markdown
---
status: open
area: src/path/to/file.rs
discovered: YYYY-MM-DD
---

# [Short imperative title]

## What Was Noticed
## Location
## Suggested Action
```

A backlog item is created when an agent notices something out of scope for its current task — a code smell, a refactoring opportunity, a latent bug — and cannot address it without derailing. The agent drops a file and continues. A future agent doing a cleanup pass picks it up.

**Status values:** `open` → `in-progress` → `done`. The session-start hook reports the count of `open` items.

### Verification Types

Files in `docs/verification/`. One file per type. The `worktree-safe: true` frontmatter field is required — every verification type must run self-contained within a worktree.

The `## Failure Remediation` section is the most important part. It is read by agents when the check fails. Be specific: describe what the failure output looks like, where to look first, the most common causes in this codebase, and the exact fix pattern.

### Workflow Docs

Files in `docs/workflow/`. These are read-only instructions for agents. They do not get project-specific content — they describe the universal six-phase process that the harness enforces.

## Hooks

Three hooks enforce knowledge-base discipline:

| Hook | Event | Purpose |
|------|-------|---------|
| `harness-session-start.sh` | SessionStart | Reports knowledge-base state (populated vs stub docs, ADR/pattern/verification counts, open backlog items) |
| `verify-task-completion.sh` | TaskCompleted | Reminds to verify within the worktree, capture new patterns/decisions, and drop backlog items for out-of-scope observations |
| `check-stale-knowledge.sh` | Stop | Alerts if docs/decisions/ or docs/patterns/ have uncommitted files |

Hooks live in `.claude/hooks/` and are configured in `.claude/settings.json`.
