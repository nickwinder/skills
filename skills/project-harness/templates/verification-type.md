---
name: {{NAME}}
command: {{COMMAND}}
scope: {{SCOPE}}
worktree-safe: true
---

# {{NAME}}

## What This Verifies
<!-- Describe what category of behavior this verification type checks -->

## When To Use
<!-- List the kinds of changes that should trigger this verification -->
-

## How To Run
```bash
{{COMMAND}}
```

## Success Criteria
<!-- What does passing look like? Exit codes, output patterns, thresholds -->
- Exit code 0
-

## Failure Remediation
<!-- IMPORTANT: Be specific. Agents read this section when the check fails.
     Generic advice ("fix the errors") is not useful. Describe:
     - What the failure output typically looks like
     - Where to look first
     - The most common causes in this codebase
     - The exact fix pattern for those causes -->

## Isolation Requirements
<!-- Describe any per-worktree setup this check needs: env vars, ports,
     databases, running services. If none, write "None — runs without
     any external dependencies." -->
