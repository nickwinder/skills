# Worktree Isolation

Every worktree must be able to build, lint, test, and run the project in
complete isolation. No worktree may depend on state produced by another.

## Why

Parallel agents share a git history but must not share runtime state. If two
agents share a port, a database, or a test environment, one agent's work can
corrupt another's results. Isolation makes parallel work safe.

## Creating a Worktree

```bash
git worktree add .worktrees/<branch-name> <branch-name>
# or for a new branch:
git worktree add -b <branch-name> .worktrees/<branch-name>
```

All worktrees go in `.worktrees/`. Add this to `.gitignore`:
```
.worktrees/
```

## Build, Lint, and Test Isolation

Most verification commands (build, lint, typecheck, unit tests) operate purely
on source files and need no special isolation — they work correctly in any
worktree by default.

Document any exceptions here — for example, if the build writes to a shared
output directory, or tests read from a shared fixture store.

## Runtime Isolation

If the project runs servers or connects to databases, each worktree needs its
own runtime environment to avoid collisions.

### Port Isolation

If the project runs a dev server or other services, document the ports used and
how to make them unique per worktree. A common strategy is index-based
allocation:

```
WORKTREE_INDEX=<0 for main, 1 for first worktree, 2 for second, ...>
PORT = BASE_PORT + (WORKTREE_INDEX × 10)
```

If no servers are involved, write: "Not applicable — no servers to isolate."

### Database Isolation

If the project uses a database, document how to namespace it per worktree
(e.g. separate database names, separate Docker volumes, or separate
`COMPOSE_PROJECT_NAME` values).

If no database is involved, write: "Not applicable — no database to isolate."

### Shared Services

Some external services may be shared across worktrees (e.g. a backend API that
all worktrees connect to). List these here and note that they do not need
per-worktree isolation.

## Environment Configuration

If the project uses `.env` files, each worktree needs its own copy with the
correct ports and database URLs. Document the setup process here.

## Verification Requirement

Every verification type in `docs/verification/` must declare `worktree-safe: true`
in its frontmatter. If a check requires shared infrastructure, document the
isolation strategy in its `## Isolation Requirements` section.
