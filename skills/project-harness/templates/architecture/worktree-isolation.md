# Worktree Isolation

All work happens in isolated git worktrees. Every agent must be able to run
the full project — servers, tests, builds — without affecting any other agent
working in a different worktree.

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

## Port Allocation

Each worktree needs unique ports. Use index-based allocation:

```
BASE_PORT=<your base port, e.g. 4000>
WORKTREE_INDEX=<0 for main, 1 for first worktree, 2 for second, ...>

APP_PORT  = BASE_PORT + (WORKTREE_INDEX × 10) + 0
DB_PORT   = BASE_PORT + (WORKTREE_INDEX × 10) + 1
CACHE_PORT = BASE_PORT + (WORKTREE_INDEX × 10) + 2
```

Document the BASE_PORT your project uses here: `BASE_PORT=____`

## Database Isolation

Name databases by worktree index or branch name:

```
main worktree:    myapp_db_0   (or myapp_db_main)
first worktree:   myapp_db_1   (or myapp_db_<branch>)
second worktree:  myapp_db_2
```

If using Docker: use a per-worktree `COMPOSE_PROJECT_NAME` so volumes and
containers are namespaced and don't collide.

## Environment Configuration

Commit a `.env.template` with placeholder values. Each worktree generates its
own `.env` from the template. The `.env` file is gitignored.

`.env.template` example:
```
APP_PORT={{APP_PORT}}
DATABASE_URL=postgresql://user:pass@localhost:{{DB_PORT}}/myapp_{{WORKTREE_INDEX}}
COMPOSE_PROJECT_NAME=myapp-{{WORKTREE_NAME}}
```

A setup script (or manual step) substitutes `{{...}}` values based on the
worktree index before first use.

## Verification Requirement

Every verification type in `docs/verification/` must declare `worktree-safe: true`
in its frontmatter. If a check requires shared infrastructure (e.g. a shared
staging database), document the isolation strategy in its
`## Isolation Requirements` section.
