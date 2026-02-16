#!/bin/bash
# Hook: TaskCompleted
# Reads the completed task's verified-by field and reminds the agent
# to run verification before marking done.
# Exit 2 = block completion, Exit 0 = allow

INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject // empty')
TASK_DESCRIPTION=$(echo "$INPUT" | jq -r '.task_description // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_TASKS_DIR="$CWD/docs/tasks"

# If no harness tasks directory, allow completion silently
if [ ! -d "$DOCS_TASKS_DIR" ]; then
  exit 0
fi

# Search for task files with verified-by fields that haven't been checked
# This is a lightweight reminder — the agent-type hook below does the real enforcement
echo "Reminder: If this task has a corresponding file in docs/tasks/, ensure its verified-by checks have been run and its frontmatter status is updated to done."
exit 0
