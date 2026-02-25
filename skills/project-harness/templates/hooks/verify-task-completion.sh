#!/bin/bash
# Hook: TaskCompleted
# Reminds agent to verify work and capture knowledge before marking complete.
# Exit 0 always (reminder only).

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_DIR="$CWD/docs"

# Only activate if this project has a harness
if [ ! -d "$DOCS_DIR/verification" ] && [ ! -d "$DOCS_DIR/architecture" ]; then
  exit 0
fi

echo "Before marking this complete:"
echo "  1. Run applicable verification types from docs/verification/ within your worktree"
echo "  2. If you discovered a reusable pattern, document it in docs/patterns/"
echo "  3. If you made a significant architectural decision, create an ADR in docs/decisions/"
echo "  4. If you noticed something out of scope that needs fixing, drop a file in docs/backlog/"
exit 0
