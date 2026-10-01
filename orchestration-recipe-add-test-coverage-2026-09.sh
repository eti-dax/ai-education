#!/bin/bash
# orchestration-recipe-add-test-coverage-2026-09.sh
#
# Writer-reviewer pattern, adapted to loop over a list of items instead of a
# single feature. Each item is one documented test-coverage gap in
# src/main/java/calculator/Calculator.java (see FINAL_REPORT.md / workers/*.md
# for where these gaps came from). For each item: a writer instance adds the
# missing test(s) and runs the suite; a fresh reviewer instance (no memory of
# the writer's session) checks the result. Every claude -p call is retried
# with backoff and logged as one NDJSON line to the audit log.
#
# Usage: ./orchestration-recipe-add-test-coverage-2026-09.sh [ITEM_COUNT]
#   ITEM_COUNT - how many items (from the front of the list below) to run.
#                Defaults to all items. Use 5 for the small run.
set -u

TEST_CMD=${TEST_CMD:-"gradle test"}
MAX_ATTEMPTS=3
RUN_ID="run-$(date +%s)"
SESSION_ROOT="scratchpads/$RUN_ID"
AUDIT_LOG="$SESSION_ROOT/audit-log.ndjson"
mkdir -p "$SESSION_ROOT"

# id::description of the test-coverage gap the writer must close.
FULL_ITEMS=(
  "divide-basic::Calculator.divide has zero test coverage today. Add a JUnit 5 test in src/test/java/calculator/CalculatorTest.java verifying the basic/normal case, e.g. divide(6, 3) == 2."
  "divide-by-zero::Calculator.divide(a, 0) throws ArithmeticException (divide by zero) and this is untested. Add a JUnit 5 test asserting the exception is thrown, e.g. via assertThrows(ArithmeticException.class, ...)."
  "divide-int-min-overflow::Integer.MIN_VALUE / -1 silently overflows back to Integer.MIN_VALUE instead of throwing, and this case is untested. Add a JUnit 5 test asserting calculator.divide(Integer.MIN_VALUE, -1) == Integer.MIN_VALUE, and a short comment documenting the overflow."
  "divide-negative-operands::Negative-operand combinations for divide (e.g. divide(-6,3), divide(6,-3), divide(-6,-3)) are untested. Add JUnit 5 tests covering these cases."
  "add-negative-overflow::Calculator.add has no tests for negative numbers or integer overflow (e.g. Integer.MAX_VALUE + 1 wraps to Integer.MIN_VALUE). Add JUnit 5 tests covering a negative-number case and the overflow case."
  "subtract-negative-underflow::Calculator.subtract has no tests for negative numbers or integer underflow (e.g. Integer.MIN_VALUE - 1 wraps to Integer.MAX_VALUE). Add JUnit 5 tests covering a negative-number case and the underflow case."
  "multiply-negative-overflow::Calculator.multiply has no tests for negative-number combinations or integer overflow (e.g. Integer.MAX_VALUE * 2). Add JUnit 5 tests covering a negative-number case and the overflow case."
  "multiply-zero::Calculator.multiply has no test asserting multiply(x, 0) == 0. Add a JUnit 5 test covering the zero-operand case."
)

ITEM_COUNT=${1:-${#FULL_ITEMS[@]}}
if ! [[ "$ITEM_COUNT" =~ ^[0-9]+$ ]] || [[ "$ITEM_COUNT" -lt 1 ]]; then
  echo "Usage: $0 [ITEM_COUNT]  (ITEM_COUNT must be a positive integer, got: $ITEM_COUNT)" >&2
  exit 1
fi
if [[ "$ITEM_COUNT" -gt ${#FULL_ITEMS[@]} ]]; then
  ITEM_COUNT=${#FULL_ITEMS[@]}
fi
ITEMS=("${FULL_ITEMS[@]:0:$ITEM_COUNT}")

echo "Run $RUN_ID: ${#ITEMS[@]}/${#FULL_ITEMS[@]} item(s). Session dir: $SESSION_ROOT"

# audit_line PHASE ITEM_ID ATTEMPT EXIT_CODE SUCCESS FINAL RESULT_JSON_OR_TEXT
audit_line() {
  local phase="$1" item_id="$2" attempt="$3" exit_code="$4" success="$5" final="$6" raw="$7"
  local result_json
  if ! result_json=$(printf '%s' "$raw" | jq -c . 2>/dev/null); then
    result_json=$(printf '%s' "$raw" | jq -Rs .)
  fi
  jq -nc \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg item "$item_id" \
    --arg phase "$phase" \
    --argjson attempt "$attempt" \
    --argjson max_attempts "$MAX_ATTEMPTS" \
    --argjson exit_code "$exit_code" \
    --argjson success "$success" \
    --argjson final "$final" \
    --argjson result "$result_json" \
    '{timestamp:$ts,item:$item,phase:$phase,attempt:$attempt,max_attempts:$max_attempts,exit_code:$exit_code,success:$success,final:$final,result:$result}' \
    >> "$AUDIT_LOG"
}

# run_claude_with_retry PHASE ITEM_ID ALLOWED_TOOLS DISALLOWED_TOOLS MAX_TURNS MAX_BUDGET PROMPT
# Prints the final claude JSON result on stdout. Returns 0 on success, 1 if all attempts failed.
run_claude_with_retry() {
  local phase="$1" item_id="$2" allowed_tools="$3" disallowed_tools="$4" max_turns="$5" max_budget="$6" prompt="$7"
  local attempt=1 result exit_code is_error success final

  while (( attempt <= MAX_ATTEMPTS )); do
    result=$(claude -p "$prompt" \
      --output-format json \
      --max-turns "$max_turns" \
      --max-budget-usd "$max_budget" \
      --permission-mode acceptEdits \
      --allowedTools "$allowed_tools" \
      --disallowedTools "$disallowed_tools" \
      2>>"$SESSION_ROOT/stderr.log")
    exit_code=$?
    is_error=$(printf '%s' "$result" | jq -r 'if type == "object" then (if .is_error == null then true else .is_error end) else true end' 2>/dev/null)
    [[ "$is_error" == "false" && "$exit_code" -eq 0 ]] && success=true || success=false

    final=false
    [[ "$success" == true || "$attempt" -eq "$MAX_ATTEMPTS" ]] && final=true

    audit_line "$phase" "$item_id" "$attempt" "$exit_code" "$success" "$final" "$result"

    if [[ "$success" == true ]]; then
      printf '%s' "$result"
      return 0
    fi

    if [[ "$attempt" -lt "$MAX_ATTEMPTS" ]]; then
      local backoff=$(( 2 ** attempt ))
      echo "  [$item_id/$phase] attempt $attempt failed, retrying in ${backoff}s..." >&2
      sleep "$backoff"
    fi
    attempt=$(( attempt + 1 ))
  done

  printf '%s' "$result"
  return 1
}

for entry in "${ITEMS[@]}"; do
  item_id="${entry%%::*}"
  item_desc="${entry#*::}"
  item_dir="$SESSION_ROOT/item-$item_id"
  mkdir -p "$item_dir"

  echo "=== ITEM: $item_id ==="
  echo "--- PHASE 1: WRITER ---"

  writer_prompt="You are the WRITER.
TASK: $item_desc
Implement this test coverage change following the project's existing test conventions in src/test/java/calculator/CalculatorTest.java.
Document your decisions in $item_dir/writer-notes.md, including:
- Design decisions and rationale
- Assumptions made
- Known limitations
- Areas of uncertainty
Run the tests with: $TEST_CMD"

  writer_result=$(run_claude_with_retry "writer" "$item_id" \
    "Bash(gradle test *) Edit Write Read" "" \
    20 1 "$writer_prompt")
  writer_status=$?
  echo "$writer_result" > "$item_dir/writer-result.json"

  if [[ "$writer_status" -ne 0 ]]; then
    echo "Writer phase failed for $item_id after $MAX_ATTEMPTS attempts; skipping reviewer phase." >&2
    continue
  fi
  echo "Writer phase complete for $item_id."

  echo "--- PHASE 2: REVIEWER (fresh context) ---"
  reviewer_prompt="You are the REVIEWER. You have a fresh perspective and no memory of the writer's session.
CONTEXT: Another developer just added test coverage for one gap in calculator.Calculator.
1. Read $item_dir/writer-notes.md to understand what was built.
2. Examine src/test/java/calculator/CalculatorTest.java and src/main/java/calculator/Calculator.java.
3. Re-run the tests with: $TEST_CMD
4. Write your review to $item_dir/review-notes.md.
Review for:
- Correctness: Does the new test actually verify the intended behavior?
- Edge cases: Is anything about this specific gap still untested?
- Maintainability: Is the test clear and consistent with the existing style?
Be constructive but thorough. Categorize findings as CRITICAL, IMPORTANT, or SUGGESTION.
Do not edit any source or test files yourself - report findings only."

  reviewer_result=$(run_claude_with_retry "reviewer" "$item_id" \
    "Bash(gradle test *) Read Write" "Edit" \
    15 1 "$reviewer_prompt")
  reviewer_status=$?
  echo "$reviewer_result" > "$item_dir/reviewer-result.json"

  if [[ "$reviewer_status" -ne 0 ]]; then
    echo "Reviewer phase failed for $item_id after $MAX_ATTEMPTS attempts." >&2
    continue
  fi
  echo "Reviewer phase complete for $item_id."
done

echo "Run $RUN_ID complete. Audit log: $AUDIT_LOG"
