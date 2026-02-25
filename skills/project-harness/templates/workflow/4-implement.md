# Phase 4: Implement

All implementation happens in an isolated worktree. Your worktree is your
private workspace — you can start servers, run builds, and create databases
without affecting any other agent.

## Steps

1. **Create a worktree**
   ```bash
   git worktree add -b <branch-name> .worktrees/<branch-name>
   ```

2. **Boot the environment**
   - Follow `docs/architecture/worktree-isolation.md` to configure ports,
     databases, and environment variables for your worktree
   - All servers, databases, and services must run on your worktree's allocated
     resources — never on shared or hardcoded ports

3. **Implement**
   - Follow your design from Phase 2
   - Reference `docs/patterns/` for established solutions
   - Keep `docs/architecture/constraints.md` open — check as you go

4. **Note new patterns**
   - If you solve a problem in a way that others will likely face again,
     note it for documentation in Phase 5
   - Do not document speculative patterns — only document what you actually used

## Constraint

Every command you run — builds, tests, migrations, server starts — must run
within this worktree. If a command requires shared infrastructure that cannot
be isolated, stop and update `docs/architecture/worktree-isolation.md` with
the isolation strategy before continuing.

## Output

Implementation is complete within your worktree. Move to
`docs/workflow/5-test.md`.
