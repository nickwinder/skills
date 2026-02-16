## Project Harness

This project uses a structured harness for tracking design, tasks, and verification.

### Directory Layout

| Directory | Committed | Purpose |
|-----------|-----------|---------|
| `docs/design-plans/` | Yes | Design specifications (static, immutable after approval) |
| `docs/tasks/` | Yes | Work items with lifecycle state in frontmatter |
| `docs/verification/` | Yes | One file per verification type the project supports |
| `docs/implementation-plans/` | No (.gitignored) | Ephemeral phase-by-phase working documents |

### Task Lifecycle

Tasks in `docs/tasks/` track all work. Each task has YAML frontmatter:

```yaml
---
status: backlog | in-progress | done
design: YYYY-MM-DD-design-plan-name  # optional, links to design plan
created: YYYY-MM-DD
verified-by:
  - verification-type-name
  - another-type
---
```

**Status values:** `backlog` (not started) -> `in-progress` (actively being worked) -> `done` (all verification passed)

A design plan is considered complete when all tasks referencing it are `done`.

### Verification

Before marking a task `done`, read each file listed in the task's `verified-by` field from `docs/verification/`. Each file documents what to run, what success looks like, and what to do on failure.

### Working With This Harness

**Starting work:**
1. Check `docs/tasks/` for `backlog` or `in-progress` items
2. Read the linked design plan for context
3. Read `docs/verification/` to understand available verification types

**During work:**
1. Update task status to `in-progress` in its frontmatter
2. Implementation plans go in `docs/implementation-plans/` (not committed)

**Completing work:**
1. Run all verification types listed in the task's `verified-by` field
2. Confirm all pass
3. Update task status to `done` in its frontmatter
