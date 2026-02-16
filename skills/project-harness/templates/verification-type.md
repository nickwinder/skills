---
name: {{NAME}}
command: {{COMMAND}}
scope: {{SCOPE}}
manual: false
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

## Failure Response
<!-- What should an agent do when this verification fails? -->
Read the failure output. Fix the code, not the test (unless the test expectation is wrong due to an intentional behavior change).
