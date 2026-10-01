#!/bin/bash
# scripts/writer-reviewer.sh

# Complete writer-reviewer implementation
set -e
FEATURE_DESC=$1

if [ -z "$FEATURE_DESC" ]; then
echo "Usage: writer-reviewer.sh '<feature description>'"
exit 1
fi

# The command that runs your tests. The writer may run only this command.
TEST_CMD=${TEST_CMD:-"npm test"}
SESSION_DIR="scratchpads/wr-$(date +%s)"
mkdir -p "$SESSION_DIR"
echo "=== PHASE 1: WRITER ==="

# Writer creates initial implementation
claude -p "You are the WRITER.
TASK: $FEATURE_DESC
Implement this feature following project conventions.
Document your decisions in $SESSION_DIR/writer-notes.md
Include in writer-notes.md:
- Design decisions and rationale
- Assumptions made
- Known limitations
- Areas of uncertainty
Create the implementation files as needed.
Run the tests with: $TEST_CMD" \
--max-turns 20 --max-budget-usd 2 --permission-mode acceptEdits \
--allowedTools "Bash($TEST_CMD:*)"
echo "Writer phase complete."

echo "The reviewer runs as a new Claude instance with no memory of the writer's session."
echo "=== PHASE 2: REVIEWER (Fresh Context) ==="

# CRITICAL: a new Claude instance, with no memory of the writer's session
# It starts from the writer's handover note and the files, and nothing else
claude -p "You are the REVIEWER. You have fresh perspective.
CONTEXT: Another developer implemented a feature. You are reviewing their work.
1. Read $SESSION_DIR/writer-notes.md to understand what was built
2. Examine the implementation files mentioned
3. Write your review to $SESSION_DIR/review-notes.md
Review for:
- Correctness: Does it work as intended?
- Edge cases: What inputs might break it?
- Security: Any vulnerabilities?
- Maintainability: Is the code clear?
- Testing: Is coverage adequate?
Be constructive but thorough. List specific issues with file:line references.
Categorize findings as CRITICAL, IMPORTANT, or SUGGESTION." \
--max-turns 15 --max-budget-usd 2 --permission-mode acceptEdits
echo "Reviewer phase complete."