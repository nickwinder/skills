# Phase 1: Explore

Before writing any code or making any plan, load the knowledge base.

## Steps

1. **Read the rules**
   - `docs/architecture/constraints.md` — what must never be broken
   - `docs/architecture/beliefs.md` — why the rules exist

2. **Check prior decisions**
   - Scan `docs/decisions/` for ADRs relevant to the area you're working in
   - Prior decisions are binding; if you disagree with one, create a new ADR
     rather than silently working around it

3. **Find existing patterns**
   - Search `docs/patterns/` for solutions to problems similar to yours
   - Reuse a documented pattern rather than inventing a new one

4. **Understand verification**
   - Read the verification types in `docs/verification/` that apply to your change
   - Knowing how your work will be verified shapes how you design it

5. **Read the isolation requirements**
   - `docs/architecture/worktree-isolation.md` — how to run this project in isolation
   - You will need this in Phase 4

## Output

You should now have enough context to design your change. Move to
`docs/workflow/2-design.md`.
