# Agent Skills

A collection of agent skills for Claude Code, Cursor, Gemini CLI, Codex, and other compatible agents.

## Installation

### From GitHub (recommended)

```bash
npx skills add nickwinder/skills
```

Install specific skills only:

```bash
npx skills add nickwinder/skills --skill walk-pr --skill interactive-pr-review
```

Install for a specific agent:

```bash
npx skills add nickwinder/skills -a claude-code
```

### From npm

```bash
npx skills add @nickwinder/skills
```

## Skills

| Skill | Description |
|-------|-------------|
| **acceptance-criteria** | Create verification-agnostic acceptance criteria in Gherkin format with contradiction analysis |
| **interactive-pr-review** | Multi-phase PR review with parallel specialized agents and human-in-the-loop triage |
| **project-harness** | Scaffold a knowledge-base harness for AI-agent development with architecture docs, workflows, and verification |
| **ratchet** | Autonomous measure-change-measure optimization loop for data-driven keep/discard decisions |
| **walk-pr** | Expert-level narrative walkthrough of a GitHub pull request |

## License

MIT
