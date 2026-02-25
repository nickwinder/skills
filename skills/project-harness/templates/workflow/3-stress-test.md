# Phase 3: Stress Test

Validate your design in isolation before writing any code. The goal is to find
flaws while they are still cheap to fix.

## Why Isolation Matters

You have been building context throughout Phase 1 and 2. That context can
blind you to problems — you know why decisions were made, so violations feel
intentional rather than wrong.

A fresh context does not have this bias. It evaluates the design on its own
terms, against the documented rules, without assumptions.

## Steps

1. **Start a fresh session** (`/clear` or open a new conversation)

2. **Load only:**
   - Your design from Phase 2
   - `docs/architecture/constraints.md`
   - `docs/architecture/beliefs.md`
   - Any directly relevant ADRs from `docs/decisions/`

3. **Challenge the design:**
   - Does it violate any constraint?
   - Does it contradict any ADR?
   - Are there edge cases the design does not handle?
   - Would the verification types in `docs/verification/` actually pass with this design?

4. **If flaws are found:** return to `docs/workflow/2-design.md`

5. **If the design holds:** proceed

## Output

Your design has survived independent review. Move to
`docs/workflow/4-implement.md`.
