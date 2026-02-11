---
name: acceptance-criteria
description: Use when defining product requirements, creating feature specifications, or establishing contracts between stakeholders - creates verification-agnostic acceptance criteria in Gherkin format with multi-modal verification support and contradiction analysis
---

# Acceptance Criteria

## Overview

Create acceptance criteria as **verification-agnostic contracts** using Gherkin format, analyzable for contradictions, and verifiable through multiple approaches (unit tests, e2e tests, agentic workflows, human QA).

Acceptance criteria are NOT documentation you write after building. They are contracts you define BEFORE implementation that specify what "done" and "correct" mean.

## When to Use

**Use when:**
- Starting a new feature (BEFORE implementation)
- Defining product requirements with stakeholders
- Creating contracts between business and engineering
- Need to verify through multiple approaches (tests, agents, humans)
- Multiple teams/people need shared understanding

**Don't use for:**
- Technical specifications of internal implementation
- API documentation (use OpenAPI/schema docs)
- Architecture decisions (use ADRs)
- Code that's already written (you're too late)

## Core Principle

**Acceptance criteria are executable contracts that:**
1. Define WHAT must be true (not HOW to implement)
2. Can be verified through ANY appropriate means
3. Serve as living documentation (always current)
4. Can be analyzed for contradictions
5. Are readable by all stakeholders (business, eng, QA)

## Folder Structure

Feature files live in a dedicated directory:

```
acceptance-criteria/
├── features/
│   ├── feature-name.feature          # Gherkin scenarios
│   └── another-feature.feature
```

Tests live wherever they already exist in your project. Reference them in `.feature` files using project-relative paths:

```gherkin
Verification Methods:
  Unit Tests:
    - src/auth/__tests__/session.test.ts::validateSessionIds
  E2E Tests:
    - tests/e2e/auth/authorization.test.ts::enforceSessionClaims
```

Agentic workflows and manual QA checklists can optionally live under `acceptance-criteria/agentic-workflows/` and `acceptance-criteria/manual-qa/` if they don't have a natural home elsewhere.

## Gherkin Format

Use Gherkin syntax for all acceptance criteria:

```gherkin
Feature: Document Annotation UI
  As a user
  I want to add comments to documents
  So that I can collaborate with my team

  Background:
    Given the system has user accounts configured
    And the annotation service is running

  @critical @ui @collaboration
  Scenario: Add comment to document paragraph
    Given I have document "contract.pdf" open
    And I am viewing page 2
    When I select paragraph starting with "Payment Terms"
    And I click "Add Comment" button
    And I enter comment "Needs legal review"
    And I click "Save"
    Then comment should appear in sidebar
    And comment icon should appear next to paragraph
    And comment should be visible to other team members

  Verification Methods:
    Unit Tests:
      - src/comments/__tests__/comment-service.test.ts::createComment
      - src/comments/__tests__/comment-service.test.ts::linkCommentToText
    E2E Tests:
      - tests/e2e/annotations/comment-flow.test.ts::addCommentToDocument
    Agentic Workflow:
      - acceptance-criteria/agentic-workflows/comment-workflow-demo.ts
    Manual QA:
      - REQUIRED: Visual verification of UI placement
      - REQUIRED: Test on multiple screen sizes

  Acceptance:
    - ALL unit tests pass
    - AND (E2E test passes OR agentic workflow produces valid demonstration)
    - AND manual QA approval for visual design

  @error-handling
  Scenario: Reject comment on read-only document
    Given I have a read-only document open
    When I attempt to add a comment
    Then I should see error "Comments are disabled for read-only documents"
    And no comment should be created

  Verification Methods:
    Unit Tests:
      - src/comments/__tests__/comment-service.test.ts::rejectReadOnlyComment
    E2E Tests:
      - tests/e2e/annotations/comment-flow.test.ts::readOnlyRejection
```

**Format rules:**
- `Feature:` = high-level capability
- `Background:` = shared preconditions for all scenarios
- `Scenario:` = specific behavior
- `Given/When/Then/And` = conditions, action, outcomes
- `@tags` = categorization (priority, area, type)
- `Verification Methods:` = how to prove compliance (project-relative paths)
- `Acceptance:` = logical combination of verification methods

## Verification Methods

Each scenario specifies HOW it can be verified:

| Method | When to Use | Evidence |
|--------|-------------|----------|
| **Unit Tests** | Pure logic, calculations, validations | Test pass/fail |
| **E2E Tests** | Full workflows, integrations | Test pass/fail |
| **Agentic Workflows** | Complex UIs, multi-step processes | Agent demonstration |
| **Manual QA** | Visual design, UX, accessibility | Human approval with screenshots |

### Acceptance Logic

Define clear acceptance conditions using boolean operators:

- `ALL` = every verification must pass
- `AND` = both conditions required
- `OR` = either condition sufficient
- `(...)` = grouping for precedence

## Workflow

1. **Create feature files FIRST** - Write scenarios in Gherkin format with verification methods specified BEFORE any code.
2. **Review with stakeholders** - Share `.feature` files with product managers, engineers, QA, and customers/users. Refine until all agree.
3. **Analyze for contradictions** - Detect and resolve conflicting requirements across scenarios (see below).
4. **Implement verification** - Add tests to the project's existing test locations. Reference the acceptance criterion in the test description so the link is traceable.
5. **Verify compliance** - Run verification methods and check acceptance conditions.

## Contradiction Analysis

As acceptance criteria grow, contradictions emerge:
- Scenario A requires X, Scenario B forbids X
- Performance target conflicts with functionality requirement
- Security constraint contradicts usability requirement

### Detection Approach

Based on [ALICE research](https://link.springer.com/article/10.1007/s10515-024-00452-x):

1. **Extract conditionals**: Parse Given/When/Then into logical statements
2. **Identify conflicts**: Use LLM to detect semantic contradictions
3. **Validate with logic**: Apply formal logic to confirm
4. **Report with severity**: Critical/Important/Minor

### Example Contradiction

```gherkin
# Feature: document-upload.feature
Scenario: Upload processes synchronously
  When I upload a document
  Then I should receive document ID immediately

# Feature: document-processing.feature
Scenario: Upload queues for async processing
  When I upload a document
  Then the document should be queued for processing
```

**Contradiction**: Can't be both synchronous (immediate ID) and asynchronous (queued).

**Resolution**: Clarify that ID is immediate but PROCESSING is async:

```gherkin
Scenario: Upload returns ID immediately, processes async
  When I upload a document
  Then I should receive document ID immediately
  And the document should be queued for content processing
  And processing should complete within 30 seconds
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing criteria after code | Write BEFORE implementation |
| Using imperative language | Use declarative (what, not how) |
| Mixing implementation details | Keep focused on behavior |
| No verification methods specified | Always specify how to verify |
| Single verification method only | Use multiple where appropriate |
| No contradiction analysis | Analyze before implementation |
| Treating as static docs | Update when requirements change |
| Not reviewing with stakeholders | Always get agreement first |
| Using bare filenames in verification methods | Use project-relative paths (e.g., `src/auth/__tests__/session.test.ts::createSession`) |

## Quick Reference

**File naming:**
- `features/kebab-case-name.feature`
- Tag with `@priority` `@area` `@type`

**Gherkin keywords:**
- `Feature:` - High-level capability
- `Background:` - Shared preconditions
- `Scenario:` - Specific behavior
- `Given` - Preconditions
- `When` - Action
- `Then` - Expected outcome
- `And` - Additional conditions/outcomes

**Verification methods:**
- Unit Tests - Pure logic
- E2E Tests - Full workflows
- Agentic Workflows - Complex UI
- Manual QA - Human judgment

**Acceptance logic:**
- `ALL` - Every verification passes
- `AND` - Both required
- `OR` - Either sufficient

**Workflow:**
1. Create `.feature` files FIRST
2. Review with stakeholders
3. Analyze contradictions
4. Implement verification
5. Verify compliance
