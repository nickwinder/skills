# Phase 6: Review

Code review happens in a fresh context. The reviewer has no memory of
implementation decisions — only the knowledge base and the diff.

## Why a Fresh Context

The implementer accumulated context across Phases 1–5. That context shapes
what they see as obvious, intentional, or acceptable. A reviewer starting
fresh will catch things the implementer cannot, because the implementer's
mental model is already anchored to their design.

The knowledge base is the shared contract. The reviewer does not need the
implementation history — only the rules and the diff.

## For the Reviewer

1. **Start a fresh session** (`/clear` or open a new conversation)

2. **Load the knowledge base:**
   - `AGENTS.md` — project orientation
   - `docs/architecture/constraints.md` — the rules
   - `docs/architecture/beliefs.md` — the why

3. **Read the diff**

4. **Review against constraints:**
   - Does any change violate a constraint in `docs/architecture/constraints.md`?
   - Are new dependencies flowing in the wrong direction?
   - Do naming conventions follow the patterns in `docs/patterns/`?
   - Are new verification types `worktree-safe: true`?

5. **Check knowledge capture:**
   - Were new patterns documented in `docs/patterns/`?
   - Were significant decisions documented in `docs/decisions/`?

6. **Report findings** — reference the specific constraint or belief violated,
   not just a description of what looks wrong. This gives the implementer
   exact guidance for fixing rather than re-interpreting.

## Output

Review complete. Findings reported with constraint references.
