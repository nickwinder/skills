## Project Harness

This project uses a knowledge-base harness for structured AI-agent development.

### Quick Start

```
# Run:   <HOW_TO_RUN>
# Test:  <HOW_TO_TEST>
# New worktree:
#   git worktree add -b <branch> .worktrees/<branch>
#   then follow docs/architecture/worktree-isolation.md
```

### Knowledge Base

| Path | Purpose |
|------|---------|
| `docs/architecture/constraints.md` | Rules that must not be broken |
| `docs/architecture/beliefs.md` | Why the constraints exist |
| `docs/architecture/worktree-isolation.md` | How to run in an isolated worktree |
| `docs/decisions/` | Architecture Decision Records |
| `docs/patterns/` | Reusable patterns discovered during development |
| `docs/verification/` | How to verify work is correct |
| `docs/backlog/` | Deferred work items noticed incidentally — check here for available cleanup work |

### How We Work

All work follows 6 phases — read `docs/workflow/<phase>.md` for each:

1. **Explore** — load the knowledge base before touching code
2. **Design** — document your approach, validate against constraints
3. **Stress Test** — validate design in a fresh context
4. **Implement** — work in an isolated worktree
5. **Test** — all verification runs within the worktree
6. **Review** — fresh context, diff only, checked against constraints
