# Phase 5: Test

Run all applicable verification types. All verification runs within your
worktree — never against shared environments.

## Steps

1. **Identify applicable verification types**
   - Read `docs/verification/` to find the types that apply to your change
   - When in doubt, run more rather than fewer

2. **Run each verification type**
   - Follow the `## How To Run` instructions in each verification type file
   - All commands run within your worktree

3. **On failure: read the remediation guidance**
   - Each verification type has a `## Failure Remediation` section
   - Read it before debugging — it contains specific guidance for this project
   - Fix the code, not the test (unless the test expectation is wrong due to
     an intentional behavior change)

4. **Document new patterns** (if any)
   - If you solved a problem that others will face, document it in `docs/patterns/`
   - Use the template at `docs/patterns/_template.md`
   - Commit pattern files as part of this branch

5. **Create ADRs for decisions made during implementation** (if any)
   - If you made a significant architectural decision while implementing,
     create an ADR in `docs/decisions/`
   - Use the template at `docs/decisions/_template.md`
   - Commit ADR files as part of this branch

## Output

All verification passes within the worktree. New patterns and ADRs are
committed. Move to `docs/workflow/6-review.md`.
