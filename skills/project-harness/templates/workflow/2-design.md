# Phase 2: Design

Document your approach before writing code. A design that fails a constraint
check here costs nothing to fix. A design flaw discovered during implementation
costs significantly more.

## Steps

1. **Write down your approach**
   - Describe what you intend to build and why
   - Include: what changes, what stays the same, what the interfaces look like
   - This does not need to be long — a few paragraphs is enough

2. **Validate against constraints**
   - Check every constraint in `docs/architecture/constraints.md`
   - If your design would violate a constraint: change the design, or draft an
     ADR in `docs/decisions/` documenting the exception and your reasoning

3. **Check for ADR contradictions**
   - Review `docs/decisions/` for decisions affecting this area
   - If your design contradicts a prior decision: either align with the decision
     or create a superseding ADR

4. **Draft an ADR if making a significant decision**
   - Use the template at `docs/decisions/_template.md`
   - A decision is significant if it sets a precedent, chooses between
     meaningfully different approaches, or would surprise a future agent

## Output

You have a documented design that passes constraint and ADR checks.
Move to `docs/workflow/3-stress-test.md`.
