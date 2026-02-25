#!/bin/bash
# Hook: SessionStart
# Detects if the project has a knowledge-base harness and reports its state.
# Exit 0 always. Stdout is added to Claude's context.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_DIR="$CWD/docs"
ARCH_DIR="$DOCS_DIR/architecture"

if [ ! -d "$ARCH_DIR" ] && [ ! -d "$DOCS_DIR/verification" ]; then
  exit 0
fi

echo "This project uses a knowledge-base harness."
echo ""

# Report architecture docs
if [ -d "$ARCH_DIR" ]; then
  CONSTRAINTS_LINES=0
  BELIEFS_LINES=0

  if [ -f "$ARCH_DIR/constraints.md" ]; then
    CONSTRAINTS_LINES=$(wc -l < "$ARCH_DIR/constraints.md" | tr -d ' ')
  fi
  if [ -f "$ARCH_DIR/beliefs.md" ]; then
    BELIEFS_LINES=$(wc -l < "$ARCH_DIR/beliefs.md" | tr -d ' ')
  fi

  # Threshold: >10 lines suggests the file has been populated beyond the stub
  CONSTRAINTS_STATUS="stub"
  BELIEFS_STATUS="stub"
  [ "$CONSTRAINTS_LINES" -gt 10 ] && CONSTRAINTS_STATUS="populated"
  [ "$BELIEFS_LINES" -gt 10 ] && BELIEFS_STATUS="populated"

  echo "  docs/architecture/constraints.md — $CONSTRAINTS_STATUS"
  echo "  docs/architecture/beliefs.md     — $BELIEFS_STATUS"
fi

# Count ADRs (excluding _template.md)
if [ -d "$DOCS_DIR/decisions" ]; then
  ADRS=$(find "$DOCS_DIR/decisions" -name "*.md" ! -name "_template.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/decisions/  — $ADRS ADR(s)"
fi

# Count patterns (excluding _template.md)
if [ -d "$DOCS_DIR/patterns" ]; then
  PATTERNS=$(find "$DOCS_DIR/patterns" -name "*.md" ! -name "_template.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/patterns/   — $PATTERNS pattern(s)"
fi

# Count verification types
if [ -d "$DOCS_DIR/verification" ]; then
  VTYPES=$(find "$DOCS_DIR/verification" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/verification/ — $VTYPES verification type(s)"
fi

# Count open backlog items (excluding _template.md)
if [ -d "$DOCS_DIR/backlog" ]; then
  OPEN=$(grep -rl "status: open" "$DOCS_DIR/backlog" 2>/dev/null | grep -v "_template.md" | wc -l | tr -d ' ')
  if [ "$OPEN" -gt 0 ]; then
    echo "  docs/backlog/      — $OPEN open item(s) awaiting attention"
  fi
fi

echo ""
echo "Read AGENTS.md to orient. Start work at docs/workflow/1-explore.md."
exit 0
