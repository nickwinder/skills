#!/bin/bash
# Hook: Stop
# Reminds agent to commit knowledge-base additions before ending the session.
# Exit 0 always (reminder only).

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

DOCS_DIR="$CWD/docs"

# Only activate if this project has a harness
if [ ! -d "$DOCS_DIR/decisions" ] && [ ! -d "$DOCS_DIR/patterns" ]; then
  exit 0
fi

# Check for uncommitted files in decisions/ and patterns/ (excluding templates)
UNCOMMITTED=$(git -C "$CWD" status --porcelain "$DOCS_DIR/decisions/" "$DOCS_DIR/patterns/" 2>/dev/null | grep -v "_template.md")

if [ -n "$UNCOMMITTED" ]; then
  echo "Knowledge captured this session has uncommitted files in docs/decisions/ or docs/patterns/."
  echo "Commit these so future agents can use them:"
  echo "$UNCOMMITTED"
fi

exit 0
