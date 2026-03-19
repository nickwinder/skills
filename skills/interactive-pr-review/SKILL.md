---
name: interactive-pr-review
description: >
  Interactive, multi-phase GitHub PR review with human-in-the-loop triage before posting.
  Use when asked to "do a thorough PR review", "interactive review of PR", "review PR with triage",
  "comprehensive review of PR #N", or any request for a full/deep/structured code review of a PR.
  Also triggers on "review PR and post comments" or "walk through PR findings with me".
  This skill runs specialized review agents in parallel, deduplicates findings across categories,
  presents them to you in configurable batches so you decide what to include, then posts the final
  review as inline GitHub comments — ensuring every finding that goes up has your explicit approval.
---

# Interactive PR Review

A full-cycle, human-in-the-loop PR review: parallel review agents → finding consolidation → interactive triage in batches → post inline GitHub comments.

## Quick reference

| Phase | What happens |
|-------|-------------|
| 0 | Setup: fetch PR metadata, read source files, write scope |
| 1–4 | Run 8 specialized review agents in parallel pairs |
| 5 | Consolidate + deduplicate findings across all agents |
| 6 | **Interactive triage** — present findings in batches, user decides include/skip |
| 7 | Post approved findings as inline GitHub PR comments |

---

## Phase 0: Setup

### Check for existing session

Look for `.full-review/state.json`. If present:
- `status: "in_progress"` → show current phase and ask: resume or start fresh?
- `status: "complete"` → ask: archive and start fresh?

### Fetch PR data

```bash
# Get PR metadata
gh pr view <PR_URL_OR_NUMBER> --json number,title,headRefName,baseRefName,headSha,author,body,url

# Get the diff (for line number mapping later)
gh pr diff <PR_URL_OR_NUMBER>
```

### Read source files from the PR branch

**Important:** Always read files from the PR branch directly, not the local working tree:

```bash
git fetch origin
git show origin/<headRefName>:<path/to/file>
```

For line number mapping, read files with line numbers:
```bash
git show origin/<headRefName>:<path/to/file> | cat -n
```

### Parse flags from the invocation

Look for these optional flags in the user's message:
- `--security-focus` → present Security findings first in triage
- `--performance-critical` → weight performance findings higher
- `--strict-mode` → recommend blocking on any Critical finding
- `--framework <name>` → pass framework context to review agents

### Write `.full-review/00-scope.md`

```markdown
# Review Scope

## PR
- **URL:** <url>
- **Title:** <title>
- **Branch:** <headRefName> → <baseRefName>
- **Author:** <author>
- **Head SHA:** <headSha>

## Files Changed
<list of files with +/- line counts from diff>

## Flags
- Security Focus: yes/no
- Performance Critical: yes/no
- Strict Mode: yes/no
- Framework: <name or auto-detected>
```

Initialize `.full-review/state.json`:
```json
{
  "target": "<PR URL>",
  "status": "in_progress",
  "flags": { "security_focus": false, "performance_critical": false, "strict_mode": false, "framework": null },
  "current_phase": 1,
  "completed_phases": [],
  "files_created": ["00-scope.md"],
  "head_sha": "<headSha>",
  "head_ref": "<headRefName>",
  "owner": "<owner>",
  "repo": "<repo>",
  "pr_number": <number>,
  "batch_size": 5,
  "started_at": "<ISO timestamp>",
  "last_updated": "<ISO timestamp>"
}
```

---

## Phases 1–4: Parallel Review Agents

> **CRITICAL: These agents produce findings documents ONLY.**
> Do NOT post any GitHub PR review, comment, or annotation during phases 1–4.
> Do NOT call `gh pr review`, `gh api .../reviews`, or any GitHub API that writes to the PR.
> The only GitHub write action in this entire skill happens once, in Phase 7, after the user has explicitly approved each finding through interactive triage.

Run each pair of agents concurrently using multiple Task tool calls in the same response. Read `.full-review/00-scope.md` and relevant source files, then pass them as context to each agent.

Every agent prompt must include this instruction verbatim:

> **Output format:** Write your findings as a structured markdown document saved to the specified file. Do NOT post any GitHub comments, reviews, or API calls. Your only job is to produce a findings document.

### Phase 1 (run together)

**1A — Code Quality** (`subagent_type: code-reviewer`)
Prompt: Analyze for complexity, naming, duplication, SOLID violations, error handling, technical debt. For each finding: severity (Critical/High/Medium/Low), file + line, description, fix recommendation. **Output to `.full-review/01-quality-architecture.md` only — do not post to GitHub.**

**1B — Architecture** (`subagent_type: architect-review`)
Prompt: Analyze component boundaries, coupling, dependency direction, API design, design patterns, architectural consistency. Same output format. **Append to `.full-review/01-quality-architecture.md` — do not post to GitHub.**

Save consolidated output to `.full-review/01-quality-architecture.md`.

### Phase 2 (run together)

**2A — Security** (`subagent_type: security-auditor`)
Prompt: OWASP Top 10, input validation, auth/authz, crypto issues, dependency CVEs, config security. Include CWE reference and attack scenario per finding. **Output to `.full-review/02-security-performance.md` only — do not post to GitHub.**

**2B — Performance** (`subagent_type: general-purpose`, role: performance engineer)
Prompt: DB N+1, memory leaks, caching gaps, I/O bottlenecks, race conditions, scalability barriers, missing timeouts. Include estimated impact per finding. **Append to `.full-review/02-security-performance.md` — do not post to GitHub.**

Save to `.full-review/02-security-performance.md`.

### Phase 3 (run together, read prior phase files for context)

**3A — Test Coverage** (`subagent_type: general-purpose`, role: test automation engineer)
Prompt: Untested code paths, test quality, edge cases, security test gaps, performance test gaps. **Output to `.full-review/03-testing-documentation.md` only — do not post to GitHub.**

**3B — Documentation** (`subagent_type: general-purpose`, role: technical writer)
Prompt: Inline doc accuracy, API docs, README completeness, stale content, changelog gaps. **Append to `.full-review/03-testing-documentation.md` — do not post to GitHub.**

Save to `.full-review/03-testing-documentation.md`.

### Phase 4 (run together, read all prior phase files)

**4A — Best Practices** (`subagent_type: general-purpose`, role: framework expert)
Prompt: Language idioms, deprecated APIs, framework patterns, modernization opportunities, dependency hygiene. **Output to `.full-review/04-best-practices.md` only — do not post to GitHub.**

**4B — CI/CD** (`subagent_type: general-purpose`, role: DevOps engineer)
Prompt: Pipeline gates, supply chain risks (action pinning), environment management, secret management, operational observability. **Append to `.full-review/04-best-practices.md` — do not post to GitHub.**

Save to `.full-review/04-best-practices.md`.

---

## Phase 5: Consolidate Findings

Read all four phase files. Produce `.full-review/05-all-findings.md`.

For each finding, assign:
- **Unique ID**: `SEC-1`, `CQ-1`, `AR-1`, `PERF-1`, `TEST-1`, `DOC-1`, `BP-1`, `CI-1` (increment per category)
- **Severity**: Critical / High / Medium / Low
- **Category**: Security, Code Quality, Architecture, Performance, Testing, Documentation, Best Practices, CI/CD
- **File + line**: exact file path and line number from `cat -n` output
- **Title**: short one-liner
- **Description**: clear explanation of the issue
- **Fix**: concrete recommendation, with code snippet where helpful

**Deduplication rule**: If the same underlying issue appears in multiple agent outputs (e.g., "no timeout on fetch" appears in both Security and Performance), merge into one finding. Keep the more severe category as primary. Note the duplicate source IDs.

Show the user a summary table before starting triage:

```
Phase 1–4 review complete.

Findings summary:
- Security:       X critical, Y high, Z medium, W low
- Code Quality:   ...
- Architecture:   ...
- Performance:    ...
- Testing:        ...
- Documentation:  ...
- Best Practices: ...
- CI/CD:          ...
Total: N findings

Batch size is 5 by default. You can change it at any time (e.g. "batch in 3s").
Ready to start triage? Type "go" or specify a batch size.
```

If `--security-focus` flag is set, begin with Security findings regardless of category order.

---

## Phase 6: Interactive Triage

This is the heart of the skill. Present findings in batches. The user decides what goes into the PR review.

### Presenting each batch

For each finding in the batch, present:

```
[ID | Severity | Category] Title
File: path/to/file.ts:LINE

WHAT: <plain English explanation of what the issue is — assume user is seeing it fresh>

WHY IT MATTERS: <concrete consequence if not fixed>

FIX: <specific recommendation>
<code snippet if helpful>

Recommendation: Include / Skip / Already covered
```

After the batch, ask:
```
Decisions for [IDs in this batch]? (e.g. "include all", "skip SEC-3", "include CQ-1 but reframe as X")
```

### Handling user responses

Accepted forms:
- `include` / `include all` → mark all in batch as included
- `skip` / `skip it` / `skip all` → mark all as skipped
- `include SEC-1, skip SEC-2` → per-finding decisions
- `include but reframe as <X>` → mark included, note the reframing
- `already covered` → mark as "Already covered" (won't be posted)
- `batch in N` → change batch size going forward
- `skip all` for a whole category → skip remaining findings in that category

**Duplicate detection**: If a finding covers the same code issue as an already-included finding, pre-mark it "Already covered" and note the ID it duplicates. Show it briefly in the batch but don't require an explicit decision.

**Research requests**: If the user asks to check something (e.g. "how does the MCP SDK handle this?"), use WebSearch or `mcp__plugin_context7_context7__query-docs` to look it up inline. Incorporate the answer into the finding's recommendation before moving on.

### State tracking

Maintain a running tally visible to the user:
```
Triage progress: 15/42 reviewed | 8 included | 6 skipped | 1 already covered
```

After all findings are triaged, show the complete included list:

```
Triage complete.

Included findings (N total):
| ID | Severity | Category | Title | File:Line |
|----|----------|----------|-------|-----------|
...

Ready to post these as a PR review? (yes / adjust first)
```

---

## Phase 7: Post PR Review

### Get confirmation

Show the included list and ask for the main review message tone. Default main message:
> "I've gone through the PR in detail. [Summary of key themes]. Happy to discuss any of these — once addressed, ping me and I'll spin up the new code for manual testing."

If the findings include Critical/High items, default event is `REQUEST_CHANGES`. Otherwise `COMMENT`. User can override.

### Map findings to diff lines

For each included finding, verify the line number is valid for the diff:
- **New files**: all lines are valid
- **Modified files**: only lines present in the diff as `+` (added) lines are valid for inline comments

If a finding's line is not in the diff (e.g. it's in unchanged context), use the nearest added line above it, or omit the inline comment and mention it in the main review body.

To get the head SHA for the commit_id field:
```bash
gh pr view <number> --json headSha --jq '.headSha'
```

### Build review JSON

Write to `/tmp/pr-review-<pr_number>.json` to avoid shell escaping issues:

```json
{
  "commit_id": "<headSha>",
  "body": "<main review message>",
  "event": "REQUEST_CHANGES",
  "comments": [
    {
      "path": "src/auth/nutrient-oauth.ts",
      "line": 261,
      "side": "RIGHT",
      "body": "**[SEC-1 | Critical] XSS via unescaped `error_description` in OAuth callback**\n\n<explanation>\n\n```ts\n// Fix:\nconst safe = description.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');\nres.end(`<p>${safe}</p>`);\n```"
    }
  ]
}
```

Format each inline comment body as:
```
**[ID | Severity] Title**

<explanation of the issue>

<fix recommendation with code if applicable>
```

### Post the review

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --input /tmp/pr-review-<pr_number>.json
```

### Finish

```
PR review posted successfully.
URL: <pr_url>

Posted N inline comments. Review event: REQUEST_CHANGES.

.full-review/ artifacts:
  00-scope.md          — PR scope and files
  01-quality-architecture.md
  02-security-performance.md
  03-testing-documentation.md
  04-best-practices.md
  05-all-findings.md   — all findings with IDs
  state.json           — session state (status: complete)
```

Update `state.json` with `"status": "complete"`.

---

## Important implementation details

| Topic | Guidance |
|-------|----------|
| Reading files | Always `git show origin/<branch>:<file>` — never rely on local working tree |
| Line numbers | `git show origin/<branch>:<file> \| cat -n` for exact line mapping |
| Large diffs | If diff exceeds ~50KB, read files individually rather than using `gh pr diff` |
| JSON payload | Write to `/tmp/pr-review-<N>.json` and use `--input` — don't inline large JSON in shell |
| Inline comment lines | Only lines in the diff are valid; use nearest `+` line for findings in unchanged context |
| `side` field | Always `"RIGHT"` for inline comments on the PR diff |
| Multiple reviews | If a prior review exists, the new one is additive — no need to dismiss the old one |
| Resuming sessions | Always check `state.json` first; completed phases can be skipped |
| Batch size | Default 5, user can change mid-session; respect it immediately |

## Common mistakes

| Mistake | Fix |
|---------|-----|
| **Posting a GitHub review during phases 1–4** | **Never call `gh pr review` or `gh api .../reviews` until Phase 7. Agents write markdown files only.** |
| Using local file paths instead of `git show origin/<branch>:...` | Always fetch from the PR branch |
| Posting inline comments on lines not in the diff | Check diff output first; fall back to main review body |
| Shell escaping failures on large JSON | Write JSON to a temp file, use `--input` |
| Presenting findings without enough context | Always include WHAT / WHY IT MATTERS / FIX sections |
| Skipping duplicate detection | Check each finding against already-included list before presenting |
| Continuing after user says "skip" | Honor skip decisions immediately, no argument |
| Letting a sub-agent "helpfully" post its own review | Every agent prompt must explicitly say: do not post to GitHub |
