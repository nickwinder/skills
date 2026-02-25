# Core Beliefs

The philosophy behind our architecture. Understanding the *why* helps you
make good trade-off decisions when constraints conflict or when you encounter
a situation the constraints don't explicitly cover.

---

## Example: Unidirectional Dependencies

> **Remove or replace this example with your own beliefs.**

**We believe:** Code should be structured so that any layer can be understood,
tested, and refactored without needing to understand the layers above it.

**Why:** Circular dependencies make code impossible to reason about in isolation.
When an agent loads context for a domain function, it should not need to also
load the UI layer to understand what the function does.

**Trade-offs we accept:** Some convenience patterns (e.g. a domain object that
knows how to render itself) are forbidden. We accept the extra indirection.

---

## [Add your first belief here]

Describe:
- What you believe
- Why you believe it (the problem it solves)
- The trade-offs you consciously accept
