#!/bin/bash
# Hook: SessionStart
# When a session starts, detect if the project has a harness and provide context.
# Exit 0 always. Stdout is added to Claude's context.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_DIR="$CWD/docs"

if [ ! -d "$DOCS_DIR/verification" ] && [ ! -d "$DOCS_DIR/tasks" ]; then
  exit 0
fi

echo "This project uses a structured harness. Key locations:"

if [ -d "$DOCS_DIR/tasks" ]; then
  BACKLOG=$(grep -rl "status: backlog" "$DOCS_DIR/tasks" 2>/dev/null | wc -l | tr -d ' ')
  IN_PROG=$(grep -rl "status: in-progress" "$DOCS_DIR/tasks" 2>/dev/null | wc -l | tr -d ' ')
  DONE=$(grep -rl "status: done" "$DOCS_DIR/tasks" 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/tasks/ — $BACKLOG backlog, $IN_PROG in-progress, $DONE done"
fi

if [ -d "$DOCS_DIR/verification" ]; then
  VTYPES=$(ls "$DOCS_DIR/verification/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/verification/ — $VTYPES verification type(s) defined"
fi

if [ -d "$DOCS_DIR/design-plans" ]; then
  DESIGNS=$(ls "$DOCS_DIR/design-plans/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  docs/design-plans/ — $DESIGNS design plan(s)"
fi

echo ""
echo "Read AGENTS.md for harness workflow details."
exit 0
