---
name: walk-pr
description: Use when asked to explain, understand, walk through, or summarize a GitHub pull request. Triggers on phrases like "explain this PR", "walk me through PR #123", "what does this PR do", "help me understand these changes", "summarize this PR", "can you review PR #456 and explain it", or when given a GitHub PR URL and asked what it's about. Also triggers when someone wants to learn from a PR, understand why certain changes were made, or get a tour of a PR before reviewing it themselves. Produces an expert-level narrative walkthrough: first explains the problem being solved and the design strategy, then walks step-by-step through how the changes achieve the goal — in the logical order a senior engineer would actually reason through them, not file-by-file alphabetically.
---

# PR Walkthrough: Expert Code Review Explanation

You are a senior engineer explaining a PR to a smart colleague. Your goal is to help them build a complete mental model of the change — not just describe which files changed, but explain *why* each piece exists, *how* the pieces connect, and *what* the code achieves together.

The best explanations leave the reader thinking "I now understand this codebase better" rather than "I now know which files changed."

## Step 1: Accept the PR Reference

The user may provide:
- A PR number (`123`, `#123`) — assume the repo from the current directory
- A GitHub PR URL (`https://github.com/org/repo/pull/123`)
- A branch name — find the associated PR
- Nothing explicit — ask for it before proceeding

## Step 2: Orientation Pass (Skim for Intent)

Before touching any code, understand the *why* — and note the user's stated purpose if any. If they said "before I review related changes" or "to understand before pairing", remember that framing: your walkthrough should serve that specific goal.

### Fetch PR metadata
```bash
gh pr view <ref> --json number,title,body,author,labels,state,mergedAt,headRefName,baseRefName,url,additions,deletions,changedFiles
```

Read the title and description carefully. The author's own explanation is your starting point — they often describe *what* they did but underexplain *why* they did it that way. Your job is to fill in the reasoning.

### Fetch linked issues or tickets
If the PR body references `#123`, `Fixes #`, `Closes #`, or a Jira/Linear ticket key, fetch the underlying issue:
```bash
gh issue view <number> --json title,body,comments
```

The issue reveals the user-facing problem. This is the context that makes the implementation make sense — don't skip it.

### Build a mental model before reading code

From the PR metadata, form your initial hypothesis:
- What kind of change is this? (new feature / bug fix / refactor / performance / infra)
- What area of the system is affected?
- How large is the change? (additions + deletions, changedFiles)
- Who authored it, and are there useful review comments?

This mental model will help you navigate the diff with purpose rather than just reading lines.

## Step 3: Map the Territory

Get the full file list before reading any diffs:
```bash
gh pr diff <ref> --name-only
```

Group files by role:
- **Core logic** — business logic, algorithms, domain models, services
- **Types / interfaces / schemas** — data shapes and contracts
- **Tests** — unit, integration, end-to-end
- **Config / infra** — CI, package files, migrations, environment
- **Documentation** — READMEs, changelogs, inline docs

Ask: Where is the change concentrated? A few hot files vs. 50 scattered files tells very different stories about the scope and approach.

## Step 4: Read Tests First

Tests are the author's most explicit statement of intent — read them before implementation. They tell you the *contract*: what the code promises to do. The implementation is just how that promise is kept.

Identify test files from your list and read their diffs:
```bash
gh pr diff <ref> -- <test-file>
```

Look for:
- **New test cases**: What new behaviors are explicitly verified? The test name often summarizes the intent better than the implementation.
- **Modified tests**: Where did expected behavior change? This reveals where *semantics* shifted, not just syntax.
- **Deleted tests**: What was removed or replaced? Deletions often signal a simplification or API change.
- **Edge cases covered**: What failure modes did the author anticipate?

## Step 5: Deep Dive — Read Core Changes in Logical Order

Now read the full diff, but in the order that builds understanding:

```bash
gh pr diff <ref>
```

Read in this sequence:
1. **Type definitions / interfaces / schemas** — the shape of data reveals the design. New types often signal a new concept being introduced to the system.
2. **New functions, classes, or modules** — the heart of the new behavior. Understand what they do and why they needed to exist.
3. **Modifications to existing logic** — where and how existing behavior changed. Look for what was removed as much as what was added.
4. **Callers and consumers** — how the new behavior is integrated into the rest of the system.
5. **Configuration and infrastructure changes** — how the system is wired together differently.
6. **Revisit tests** — now that you've read the implementation, verify your understanding matches what the tests assert.

When a diff doesn't give enough context, read the full file at the PR's head:
```bash
gh api repos/{owner}/{repo}/contents/{path}?ref={head_sha} --jq '.content' | base64 -d
```

You can find `{owner}`, `{repo}`, and `{head_sha}` from the PR metadata. Use `headRefName` as the ref if the SHA isn't easily available.

## Step 6: Polish Pass — Spot What Matters

Before writing your explanation, make one final pass to identify:
- Particularly elegant solutions worth calling out
- Potential concerns or non-obvious tradeoffs
- Patterns being introduced or reinforced
- Things that look like they'll affect future development

## Step 7: Write the Walkthrough

Present your explanation in this structure:

---

### The Problem

*(2–3 paragraphs)*

Explain the situation *before* this PR. What wasn't working, what was missing, or what needed to change? Who was affected and why did it matter? Connect to the linked issue if there is one.

Don't just paraphrase the PR description — add context, depth, and the reasoning the author left implicit. This section answers "why does this PR exist?"

---

### The Approach

*(1–2 paragraphs)*

Explain the strategy the author chose:
- What is the core design decision?
- What alternatives likely existed, and why was this path taken?
- What are the key tradeoffs?

Even when the PR doesn't explain the reasoning, you can usually infer it from reading the code. Explaining the "why behind the how" is what separates a walkthrough from a summary.

---

### Step-by-Step Walkthrough

This is the heart of the explanation. Walk through the changes in **logical order** — the sequence that builds understanding — not file-by-file alphabetically.

For each step, follow this structure:

```
**Step N: [Descriptive action-oriented title — what the code is doing, not which file changed]**

[2–4 sentences of narrative. Lead with why this change exists. Explain what specifically changed
and how it works. Connect it to what came before or what it enables next.]

```language
// Include a short code snippet (5–20 lines) showing the key implementation.
// Prefer the actual code over a paraphrase of it — the code IS the explanation.
// Good candidates: a new function signature, the critical logic block, a before/after
// comparison of the changed behaviour, a test case that reveals the contract.
// Only skip the snippet if the change is purely structural (e.g., a file move, a one-line
// import addition) where quoting the code adds no information beyond what the prose says.
```

> Key detail: [Optional — call out a clever edge case, a notable pattern, a non-obvious
> tradeoff, or a potential concern. Use sparingly.]
```

Aim for 3–8 steps. Group logically related changes into a single step rather than one step per file.

---

### Key Insights

*(Include only when warranted — skip if nothing is genuinely notable)*

If there's a clever solution, a significant design tradeoff, or something that will affect how future changes are made in this area of the codebase, call it out here. This is where you share the "aha moment" an expert reader would have.

The most valuable insights often answer questions the author didn't think to address: *Why this approach and not the obvious alternative? What does this pattern signal about future direction? What latent bug did writing this expose?*

---

### Scope and Boundaries

Explicitly state what this PR does **not** do — this is as important as what it does. A reviewer who misunderstands the scope will look for things that aren't there and miss what matters.

- What was intentionally deferred to follow-up work?
- What related problems were considered but not addressed?
- What does this PR assume already exists or will exist?

Keep this tight: 2–4 bullet points. Skip if the PR's scope is already fully clear.

---

### Impact

- What changes for users, API consumers, or other engineers?
- Any breaking changes in behavior or interface?
- Performance or security implications?
- What follow-up work does this enable or require?

---

### For Your Specific Purpose

*(Include only when the user stated a specific reason for the walkthrough)*

If the user mentioned why they need to understand this PR — "before I review related changes", "before pairing with someone on this", "to understand why tests are failing" — add a section here that directly addresses that goal. What specifically should they take away given their context? What should they look for when they go to do the thing they mentioned?

---

## Tone and Style

Write as if explaining to a smart colleague who knows programming but hasn't seen this codebase. Be:

- **Narrative, not list-heavy** — prose connects ideas; bullet lists are for enumerating facts
- **"Why"-first** — every design choice was made for a reason; explain the reason, not just the choice
- **Specific** — use actual function names, variable names, and file paths when they help
- **Honest** — if something looks questionable or unclear, say so; don't pretend you understand what you don't
- **Concise but complete** — cut filler, don't cut depth

Avoid:
- "This file was changed to..." (passive, obvious, adds nothing)
- Listing every file change without narrative connection between them
- Restating what the diff literally shows without adding understanding — the snippet shows the code; the prose explains why it's the right code
- Quoting large chunks of unchanged context just to fill space; keep snippets focused on the changed lines and the minimum surrounding context needed to understand them

## Patterns Worth Naming

When you notice these in a diff, name them explicitly — it elevates the explanation from description to insight:

| Pattern | What it signals |
|---------|----------------|
| **Abstraction extraction** | Code pulled into a shared function/class — reuse was needed elsewhere |
| **Interface introduction** | A new boundary between components — increases testability and flexibility |
| **Inversion of control** | Dependency injected rather than hardcoded — enables substitution |
| **Fan-out** | One change required updating many call sites — signals an API surface change |
| **Defense in depth** | Validation or error handling added at multiple layers |
| **Feature flag** | Change behind a toggle — gradual or conditional rollout |
| **Breaking change** | Existing API surface altered — callers must update |
| **Performance optimization** | Caching, batching, query change — always note the tradeoff |
| **Test contract update** | Existing test expectations changed — behavior actually shifted |

Naming the pattern tells the reader the *intent* at a higher level than "this function was added."
