#!/bin/bash
# Hook: Stop
# When the agent finishes responding, check if there are in-progress tasks
# in docs/tasks/ that may have been forgotten.
# Exit 0 always (reminder only, never blocks).

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_TASKS_DIR="$CWD/docs/tasks"

if [ ! -d "$DOCS_TASKS_DIR" ]; then
  exit 0
fi

# Find tasks with status: in-progress
IN_PROGRESS=$(grep -rl "status: in-progress" "$DOCS_TASKS_DIR" 2>/dev/null)

if [ -n "$IN_PROGRESS" ]; then
  COUNT=$(echo "$IN_PROGRESS" | wc -l | tr -d ' ')
  echo "There are $COUNT task(s) in docs/tasks/ with status: in-progress. If work is complete, update their frontmatter to done after running verification."
fi

exit 0
