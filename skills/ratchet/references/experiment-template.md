# Experiment Template

Copy this structure to `docs/ratchet/experiments/NNN-short-description/`.

## Directory Structure

```
NNN-short-description/
├── program.md
├── metrics.md
├── guardrails.md
├── baseline.json
├── result.json      (created after evaluation)
└── decision.md      (created after decision)
```

## program.md

```markdown
# Experiment NNN: [Short Title]

## Frontmatter

| Field | Value |
|-------|-------|
| **id** | NNN |
| **status** | pending |
| **page** | `/page-slug/` |
| **hypothesis** | One sentence: what will improve and why |
| **change_type** | content \| layout \| content-and-layout |
| **branch** | `ratchet/NNN-short-description` |
| **baseline_period_start** | YYYY-MM-DD |
| **baseline_period_end** | YYYY-MM-DD |
| **eval_start_date** | null |
| **started_date** | YYYY-MM-DD |

## Context

**Page metrics (28d baseline):**
- Key metric 1: value
- Key metric 2: value
- Current state of the thing being changed

**Problem:** Why this page was selected and what the data says is wrong. Include specific numbers.

**Non-conflicting with:** List any other running experiments on the same page and explain why they don't overlap.

## Changes

Exact modifications to make. Old value → new value for every field. Specific enough to execute without additional context.

## Rationale

- **Why this change** — reasoning tied to the hypothesis
- **Why this page** — opportunity score, traffic, gap analysis
- **Pattern/precedent** — reference prior experiments or known best practices

## Success Criteria

See `metrics.md` for full evaluation framework.

**Primary goal:** [metric] improves by [threshold]

**Secondary goal:** [metric] must not degrade by >[threshold]
```

## metrics.md

```markdown
# Experiment NNN: Metrics

## Primary Metric

**metric_name** = `calculation formula`

- Source: API/tool name
- Filter: how to isolate this page's data
- Threshold: what counts as success (e.g., +10% relative improvement)

## Secondary Metrics

| Metric | Source | Threshold |
|--------|--------|-----------|
| metric_1 | source | Must not degrade >N% relative |
| metric_2 | source | Must not degrade >N% relative |

## Evaluation

- **Eval period:** N days minimum, extend to M if insufficient data
- **Maximum eval:** N days
- **Minimum data:** N sessions/events for statistical relevance
```

## guardrails.md

```markdown
# Experiment NNN: Guardrails

## Base

Extends: `../../../guardrails/[tier-name].md`

## What CAN change
- Specific field or element 1
- Specific field or element 2

## What CANNOT change
- Field owned by experiment XXX
- Category of changes outside scope
- Anything not explicitly listed above

## Content/Quality Constraints
- Reference to project content rules
- Experiment-specific constraints

## Revert procedure
How to undo: `git revert [commit]` or remove specific frontmatter field.
```

## baseline.json / result.json

```json
{
  "experiment_id": "NNN",
  "page": "/page-slug/",
  "baseline_period": "YYYY-MM-DD to YYYY-MM-DD",
  "metrics": {
    "primary_metric": 0.0,
    "secondary_metric_1": 0.0,
    "secondary_metric_2": 0.0,
    "sessions": 0,
    "note": "Optional context about data availability or caveats"
  }
}
```

## decision.md

```markdown
---
decision: keep | discard | extend
decided_at: YYYY-MM-DD
---

## Metrics Comparison

| Metric | Baseline | Result | Change |
|--------|----------|--------|--------|
| primary_metric | 0.0 | 0.0 | +X% |
| secondary_metric | 0.0 | 0.0 | -X% |

## Rationale

Why this decision was made, referencing the thresholds from metrics.md.

## Action Taken

- Decision: keep/discard
- Commit: [hash]
- Action: merged / `git revert [hash]`
```

## Recording to Ledger

After making a decision, append to `docs/ratchet/results.json`:

```json
{
  "id": "NNN",
  "page": "/page-slug/",
  "hypothesis": "...",
  "metric_target": "primary_metric_name",
  "baseline": 0.0,
  "result": 0.0,
  "change_pct": 0.0,
  "status": "complete|discarded",
  "decision": "keep|discard",
  "started": "YYYY-MM-DD",
  "ended": "YYYY-MM-DD"
}
```
