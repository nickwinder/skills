# Architecture Constraints

Rules that must not be broken. When a change would violate a constraint,
either redesign the change or create an ADR in `docs/decisions/` documenting
the exception, the reasoning, and any mitigations.

---

## Example: Dependency Direction

> **Remove or replace this example with your own constraints.**

Dependencies flow in one direction only. Lower layers must not import from higher layers.

Layer order (each layer may depend on layers below it, never above):

```
UI
└── Services
    └── Domain
        └── Infrastructure
```

**Violation example:** A `Domain` function importing from `Services` = ❌
**Correct pattern:** A `Services` function calling a `Domain` function = ✅

**Why this rule exists:** See `docs/architecture/beliefs.md` → "Unidirectional Dependencies"

---

## [Add your first constraint here]

Describe the rule clearly. Include:
- What is forbidden
- A concrete violation example
- A reference to the belief that explains why (optional)
