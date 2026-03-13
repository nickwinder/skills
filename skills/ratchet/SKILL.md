---
name: ratchet
description: Autonomous optimization loop — measures metrics, scores pages by opportunity, runs experiments, and makes data-driven keep/discard decisions. Use when running the optimization cycle, checking experiment status, or after deploying changes to evaluate impact. Use PROACTIVELY when the user mentions optimization, A/B testing, experiments, metrics review, or site performance.
argument-hint: [run|status|init]
---

# Ratchet

Autonomous measure → change → measure → keep/discard optimization loop, inspired by [karpathy/ratchet](https://github.com/karpathy/ratchet).

The core idea: make a small, isolated change, measure its impact against a baseline, and keep it only if the data supports the hypothesis. Everything else gets reverted. Over time, the site accumulates only proven improvements.

## When to Use

- Optimization cycle: `/ratchet` or `/ratchet run`
- Check experiment status: `/ratchet status`
- After deploying changes to evaluate their impact
- When the user asks about site performance, metrics, or A/B testing

## The Loop

```
1. Pull metrics        → Get current data from all configured sources
2. Evaluate running    → Check experiments past their eval window
3. Keep/discard        → Apply thresholds from each experiment's metrics.md
4. Score pages         → Rank by opportunity (see docs/ratchet/config/opportunity-scoring.md)
5. Propose experiment  → Target highest-opportunity page, weakest metric layer
6. Execute change      → Auto-approve or propose-and-wait per autonomy rules
7. Merge to main       → Deploy via normal CI/CD pipeline
```

### `/ratchet status` — Quick Report

1. List running experiments and days remaining
2. Show last 5 keep/discard decisions from the results ledger
3. Pull current metrics for top 5 opportunity pages
4. Show funnel summary across all configured metric layers

## Experiment Format

Every experiment is self-contained in its own directory. This format is the heart of the system — it makes experiments reproducible, reviewable, and revertable.

```
docs/ratchet/experiments/NNN-short-description/
├── program.md      # Hypothesis, context, exact changes, rationale
├── metrics.md      # What to measure, thresholds for success/failure
├── guardrails.md   # What can and cannot change (prevents side-effects)
├── baseline.json   # Pre-change metric snapshot
├── result.json     # Post-change metric snapshot (created after eval)
└── decision.md     # Keep/discard rationale (created after decision)
```

### Why This Structure Matters

- **program.md** forces you to articulate a hypothesis *before* making a change. No hypothesis, no experiment. It also records the exact changes made, so anyone can understand and reproduce the experiment later.
- **metrics.md** defines success criteria *before* seeing results. This prevents post-hoc rationalization ("well, X went down but Y went up so it's fine").
- **guardrails.md** scopes the blast radius. When multiple experiments run on the same page, guardrails prevent conflicts by declaring which fields each experiment owns.
- **baseline.json** is the pre-change snapshot you compare against. Without a recorded baseline, there's no experiment — just a change.
- **result.json** and **decision.md** close the loop. The decision references the metrics and thresholds declared upfront.

### Experiment Numbering
- 3-digit zero-padded IDs: 001, 002, 003...
- Check `docs/ratchet/results.json` for the last used ID
- Directory name: `NNN-short-kebab-description`

### Experiment Lifecycle
1. `pending` — directory created, change not yet made
2. `running` — change merged to main, measurement in progress
3. `evaluating` — eval period complete, pulling result metrics
4. `complete` — decision made, kept
5. `discarded` — decision made, reverted

## Writing program.md

The program.md uses a markdown table for structured frontmatter fields, followed by narrative sections.

### Frontmatter Table

| Field | Purpose |
|-------|---------|
| **id** | 3-digit experiment number |
| **status** | Current lifecycle stage |
| **page** | URL path of the page being changed |
| **hypothesis** | One sentence: what will improve and why |
| **change_type** | Scope of changes (maps to guardrail tier) |
| **branch** | Git branch name for the changes |
| **baseline_period_start** | Start of baseline measurement window |
| **baseline_period_end** | End of baseline measurement window |
| **eval_start_date** | When post-change measurement begins |
| **started_date** | When the experiment was created |

### Body Sections

**Context** — Current page metrics, what the problem is, why this page was selected. Include specific numbers from the baseline. If this experiment coexists with others on the same page, note which experiments and why they don't conflict.

**Changes** — The exact modifications to make. Be specific enough that someone could execute this without any additional context. Include old value → new value for every field being changed.

**Rationale** — Why this specific change should improve the target metric. Reference patterns from past experiments, industry knowledge, or data from the baseline analysis.

**Success Criteria** — Brief summary pointing to metrics.md, plus the primary and secondary goals stated plainly.

## Writing metrics.md

### Primary Metric
One metric that the experiment aims to improve. Include:
- Exact metric name and calculation formula
- Data source and how to query it
- Threshold for success (e.g., "+10% relative improvement")

### Secondary Metrics
Metrics that must not degrade. These are guardrails on the *data* side, complementing the *change* guardrails in guardrails.md.

| Metric | Source | Threshold |
|--------|--------|-----------|
| metric_name | data_source | Must not degrade >N% relative |

### Evaluation Window
- Minimum eval period (typically 7 days)
- Extension rules for low-traffic pages
- Maximum eval period (typically 21 days)

## Writing guardrails.md

Guardrails prevent experiments from having unintended side-effects and from conflicting with each other.

### Structure

**Base** — Reference the applicable guardrail tier from `docs/ratchet/guardrails/`. Tiers are defined per-project and scope what categories of changes are permitted.

**What CAN change** — Enumerate the specific fields/elements this experiment modifies. Be explicit — "seoTitle field in frontmatter" not "metadata".

**What CANNOT change** — Explicitly list what's off-limits, especially fields owned by other running experiments on the same page.

**Content/Quality Constraints** — Reference any project-level content rules that apply.

**Revert procedure** — How to undo this experiment (typically `git revert` of the experiment commit).

### Conflict Prevention

Before launching an experiment, check all running experiments' guardrails.md files for the same page. Two experiments conflict if they modify the same field or element. Non-conflicting examples:
- Experiment A changes seoTitle, Experiment B changes CTA badge text
- Experiment A adds internal links to body, Experiment B changes quiz variant in frontmatter

Conflicting examples:
- Both change seoTitle
- One changes body copy in a section where the other adds links

## baseline.json and result.json

```json
{
  "experiment_id": "NNN",
  "page": "/page-slug/",
  "baseline_period": "YYYY-MM-DD to YYYY-MM-DD",
  "metrics": {
    "primary_metric_name": 0.0,
    "secondary_metric_1": 0.0,
    "secondary_metric_2": 0.0,
    "context_metric": 0
  }
}
```

Keep it flat and simple. The metric names should match what's declared in metrics.md. Context metrics (like session count) help verify the eval window had sufficient data.

## decision.md

Written after evaluation. Contains:

**Metrics Comparison** — Table with Metric, Baseline, Result, Change columns.

**Rationale** — Why this decision was made, referencing the success criteria from metrics.md.

**Action Taken** — Merged/reverted commit hash.

Frontmatter:
```yaml
---
decision: keep | discard | extend
decided_at: YYYY-MM-DD
---
```

## Results Ledger

After every decision, append to `docs/ratchet/results.json`:

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

## Keep/Discard Rules

These are defaults. Individual experiments can override thresholds in their metrics.md, but the structure stays the same.

| Condition | Decision |
|-----------|----------|
| Primary metric improved beyond stated threshold | **Keep** |
| Primary metric flat or worse after eval period | **Discard** (git revert) |
| Insufficient data in eval window | **Extend** (wait another eval period, up to max) |
| Any secondary metric degraded beyond its threshold | **Discard** |
| Max eval period elapsed with insufficient data | **Discard** (insufficient data) |

## Agent Autonomy

Not all changes carry the same risk. The skill distinguishes between changes the agent can make autonomously and changes that need user approval.

### Auto-approve (no confirmation needed)
- Text-only metadata changes (titles, descriptions)
- CTA or button copy changes
- Internal link additions within existing content
- Section reordering within posts
- Affiliate button text/placement adjustments

### Propose-and-wait (user approves first)
- Widget/component positioning or configuration changes
- New component placement
- Page structure or navigation changes
- Any change to code files

Projects should document their own autonomy boundaries — these are starting defaults.

## Hard Constraints

- Multiple experiments may run on the same page if they target **non-conflicting changes**. Always check running experiments' `guardrails.md` for overlap before launching a new one.
- All changes via git commits on dedicated experiment branches
- All copy changes must comply with project content constraints
- No fabricated claims, opinions, or data
- Revert via `git revert` on main, not branch deletion

## Opportunity Scoring

Read `docs/ratchet/config/opportunity-scoring.md` for the project's page types and metric weights. The general pattern:

```
opportunity = traffic_weight * (engagement_gap + conversion_gap)
```

Where gaps measure how far below top-quartile performance a page sits. High-traffic pages with large gaps are the best targets because even small improvements compound across many sessions.

The scoring output identifies:
1. Which pages have the most room to improve
2. Which metric layer (engagement vs conversion) is weakest
3. Which specific metric to target with the next experiment

## Error Handling

- **API error**: Retry once. If still failing, skip that metric layer and note in experiment log.
- **Data lag**: Use data up to 3 days before today for sources with reporting delays.
- **Traffic anomaly** (>2x normal from non-organic): Flag in log, exclude anomalous days. If >50% of eval days affected, extend.
- **Unavailable data source**: Proceed on available layers only and note which layers are missing.

## Project Setup — `/ratchet init`

Ratchet is project-agnostic. All project-specific configuration lives in the project repo, not the skill. Run `/ratchet init` to set up a new project, or the skill will detect missing config and start init automatically on first `/ratchet` run.

### Init Flow

**Step 1 — Analytics sources:**
Ask what analytics platform the project uses (GA4, Plausible, Fathom, Search Console, etc.). Collect endpoints, property IDs, and auth methods. Use `references/api-access.md` as a guide for the structure. Write the result to `docs/ratchet/config/api-access.md`.

**Step 2 — Page types and scoring:**
Ask what kinds of pages the site has and what conversion means for each type. Use `references/opportunity-scoring.md` as a guide for the page type matrix and scoring formula. Write the result to `docs/ratchet/config/opportunity-scoring.md`.

**Step 3 — Content constraints:**
Ask if the project has content rules the agent should follow (e.g., voice guidelines, no fabricated claims). If yes, record the path so guardrails can reference it. If no, skip.

**Step 4 — Scaffold the full tree:**

```
docs/ratchet/
├── config/
│   ├── api-access.md              # Project's analytics endpoints and auth
│   └── opportunity-scoring.md     # Project's page types and metric weights
├── metrics/
│   ├── example-engagement.md      # Example engagement metric (edit or replace)
│   └── example-conversion.md      # Example conversion metric (edit or replace)
├── guardrails/
│   ├── content-only.md            # Starter tier: text-only changes
│   ├── content-and-layout.md      # Starter tier: text + layout changes
│   └── structural.md             # Starter tier: any change
├── experiments/                   # Empty, ready for first experiment
└── results.json                   # Empty array []
```

Use `references/experiment-template.md` as a guide when creating experiment files.

### Auto-detection

Before running the loop, check for `docs/ratchet/config/api-access.md`. If missing, start init. This ensures the skill never runs against unconfigured data sources.

### Skill References vs Project Config

| Location | Purpose |
|----------|---------|
| `references/api-access.md` | **Guide:** how to structure API config, with annotated examples |
| `references/opportunity-scoring.md` | **Guide:** scoring formula + how to define page types |
| `references/experiment-template.md` | **Guide:** boilerplate structure for new experiments |
| `docs/ratchet/config/` | **Project config:** actual endpoints, credentials, page types |
| `docs/ratchet/metrics/` | **Project data:** metric definitions for this project |
| `docs/ratchet/guardrails/` | **Project data:** guardrail tiers for this project |
| `docs/ratchet/results.json` | **Project data:** historical experiment results ledger |
| `docs/ratchet/experiments/` | **Project data:** all experiment directories |
