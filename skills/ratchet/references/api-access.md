# API Access Reference

Guide for configuring analytics data sources. Use this as a template when writing `docs/ratchet/config/api-access.md` for a project.

## Structure

Each data source section should include:
1. **Service name** and what it provides
2. **Authentication** method and credentials
3. **Example queries** showing how to pull the metrics defined in `docs/ratchet/metrics/`

## Example: GA4 Data API

```markdown
## GA4 Data API

**Property ID:** `YOUR_PROPERTY_ID`
**API Endpoint:** `https://analyticsdata.googleapis.com/v1beta/properties/YOUR_PROPERTY_ID:runReport`

### Authentication
\```bash
TOKEN=$(gcloud auth application-default print-access-token --quota-project=YOUR_PROJECT)
\```

### Pageviews and engagement by page (last 7 days)
\```bash
curl -s -X POST \
  "https://analyticsdata.googleapis.com/v1beta/properties/YOUR_PROPERTY_ID:runReport" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dateRanges": [{"startDate": "7daysAgo", "endDate": "yesterday"}],
    "dimensions": [{"name": "pagePath"}],
    "metrics": [
      {"name": "sessions"},
      {"name": "averageSessionDuration"},
      {"name": "bounceRate"},
      {"name": "screenPageViews"}
    ],
    "dimensionFilter": {
      "filter": {
        "fieldName": "sessionDefaultChannelGroup",
        "stringFilter": {"value": "Organic Search"}
      }
    },
    "orderBys": [{"metric": {"metricName": "sessions"}, "desc": true}],
    "limit": 50
  }'
\```

### Custom event counts
\```bash
curl -s -X POST \
  "https://analyticsdata.googleapis.com/v1beta/properties/YOUR_PROPERTY_ID:runReport" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dateRanges": [{"startDate": "7daysAgo", "endDate": "yesterday"}],
    "dimensions": [
      {"name": "eventName"},
      {"name": "pagePath"}
    ],
    "metrics": [{"name": "eventCount"}],
    "dimensionFilter": {
      "filter": {
        "fieldName": "eventName",
        "inListFilter": {
          "values": ["your_event_1", "your_event_2"]
        }
      }
    },
    "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": true}],
    "limit": 200
  }'
\```
```

## Example: Google Search Console API

```markdown
## Google Search Console API

**Site URL:** `https://your-site.com/`
**API Endpoint:** `https://www.googleapis.com/webmasters/v3/sites/https%3A%2F%2Fyour-site.com%2F/searchAnalytics/query`

### Authentication
Same gcloud credentials as GA4.

### Impressions, clicks, CTR, position by page (last 7 days)
\```bash
curl -s -X POST \
  "https://www.googleapis.com/webmasters/v3/sites/https%3A%2F%2Fyour-site.com%2F/searchAnalytics/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "startDate": "YYYY-MM-DD",
    "endDate": "YYYY-MM-DD",
    "dimensions": ["page"],
    "rowLimit": 100
  }'
\```

Note: Search Console data typically lags 2-3 days.
```

## Example: Plausible Analytics API

```markdown
## Plausible Analytics API

**Site ID:** `your-site.com`
**API Endpoint:** `https://plausible.io/api/v2/query`

### Authentication
\```bash
TOKEN="your-plausible-api-key"
\```

### Pageviews by page (last 7 days)
\```bash
curl -s -X POST \
  "https://plausible.io/api/v2/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "site_id": "your-site.com",
    "metrics": ["visitors", "pageviews", "bounce_rate", "visit_duration"],
    "date_range": "7d",
    "dimensions": ["event:page"]
  }'
\```
```

## Tips for Writing api-access.md

- Include one section per data source
- Show example queries for every metric type you plan to track
- Include authentication steps that can be copy-pasted
- Note any data lag (e.g., Search Console lags 2-3 days)
- If a metric comes from a third-party tool (email platform, CRM), document how to access it or reference another skill that handles it
