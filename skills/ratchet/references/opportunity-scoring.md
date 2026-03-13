# Opportunity Scoring Reference

Guide for configuring page scoring. Use this as a template when writing `docs/ratchet/config/opportunity-scoring.md` for a project.

## Formula

```
opportunity = traffic_weight * (engagement_gap + conversion_gap)
```

This formula is universal. What varies per project is which metrics feed into each gap and how pages are categorized.

## Components

### traffic_weight (0 to 1)
Normalized traffic over a trailing period (typically 28 days).

```
traffic_weight = page_sessions / max_sessions_across_all_pages
```

Pages with zero sessions are excluded from scoring.

### engagement_gap (0 to 1)
How far below top-quartile the page sits on engagement metrics.

```
For each engagement metric:
  gap = max(0, top_quartile_value - page_value) / top_quartile_value

For inverted metrics (lower is better, e.g., bounce rate):
  gap = max(0, page_value - bottom_quartile_value) / (1 - bottom_quartile_value)

engagement_gap = average of applicable metric gaps
```

### conversion_gap (0 to 1)
How far below top-quartile on conversion metrics.

```
For each applicable conversion metric:
  gap = max(0, top_quartile_value - page_value) / top_quartile_value

conversion_gap = average of applicable metric gaps
```

Only score metrics applicable to a given page type — don't penalize pages for metrics they can't have.

## Defining Page Types

Each project needs a page type matrix mapping which metrics apply to which page categories. Not all metrics apply to all pages.

### Example Page Type Matrix

```markdown
| Page Type | Engagement Metrics | Conversion Metrics |
|-----------|-------------------|-------------------|
| Product review | time on page, scroll depth, bounce rate | affiliate click rate, purchase rate |
| Comparison | time on page, scroll depth | affiliate click rate |
| Guide/educational | time on page, scroll depth, bounce rate | email signup rate, lead magnet downloads |
| Landing page | bounce rate | signup rate, purchase rate |
| E-commerce product | time on page | add to cart rate, purchase rate |
| SaaS feature page | time on page, scroll depth | trial signup rate, demo request rate |
| Documentation | time on page, scroll depth | — (excluded from conversion scoring) |
| Static/utility | — (excluded from scoring entirely) | — |
```

### How to Define Your Matrix

1. List all distinct page types on your site
2. For each type, identify which engagement metrics are meaningful
3. For each type, identify what "conversion" means (it varies — affiliate click, signup, purchase, download)
4. Pages with no applicable conversion metrics get scored on engagement only
5. Pages excluded from scoring entirely (404, legal, utility) should be listed so the agent skips them

## Scoring Output

Rank all scored pages by opportunity descending. For the highest-opportunity page:
1. Identify which gap component (engagement or conversion) is larger
2. Within that component, identify which specific metric has the largest gap
3. That metric determines the experiment type

This ensures experiments target the weakest point on the highest-impact page.

## Tips for Writing opportunity-scoring.md

- Start with your page type matrix — this is the most important piece
- List specific metric names matching your `docs/ratchet/metrics/` files
- Consider whether some page types should be weighted differently (e.g., money pages weighted higher)
- Define what "excluded from scoring" means for your site
- If you have seasonal traffic patterns, note them so the agent can account for them
