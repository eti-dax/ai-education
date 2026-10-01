# Scaling notes — orchestration-recipe-add-test-coverage-2026-09.sh

Job: writer→reviewer pattern, adapted to loop over a list of items. Each item
is one documented test-coverage gap in `src/main/java/calculator/Calculator.java`
(gaps taken from this repo's own prior review artifacts: `FINAL_REPORT.md`,
`workers/*.md`). Small run = first 5 items. Full run = all 8 items (the real
job's full set — there are exactly 8 documented coverage gaps, no more).

## Did the script hold?

Yes, both runs completed end-to-end with exit code 0 and no crashes. All 16
`claude -p` calls in the full run (8 items × writer + reviewer) and all 10 in
the small run succeeded on the **first attempt** — the retry-with-backoff path
was never exercised for real (it was verified separately with a stubbed
`claude` function; see below). All 8 test-coverage gaps ended up with correct,
passing tests in `CalculatorTest.java` (`gradle test` → `BUILD SUCCESSFUL`,
verified by me after each run, not just claimed by the script).

## What broke, named specifically

**1. `--allowedTools "Bash(gradle test *)"` never actually granted permission,
in any of the 26 real `claude -p` calls across both runs.** Every single
writer and reviewer call had its own `gradle test` invocation denied
(`permission_denials` in the audit record, 2-6 denials per call). This
matches the CLI's own `--help` example syntax (`Bash(git *)`), and I confirmed
in isolated follow-up calls that the same pattern shape (`Bash(echo *)`)
*does* get allowed for a plain command — but neither `Bash(gradle test *)` nor
the broader `Bash(gradle *)` unblocked `gradle test` in several more isolated,
minimal repro calls. Root cause is unresolved as of this writeup (possibly
`gradle`/build-tool invocations get extra scrutiny beyond simple
prefix-allowlisting, independent of the `--allowedTools` flag).

Consequence: the writer and reviewer never actually ran the test suite
themselves inside their sandboxed calls, despite the prompt asking them to and
`--permission-mode acceptEdits` being set. Every affected call still reported
`is_error: false` — this is a **silent** degradation, not a crash. Reading a
call's `result` text (e.g. "gradle test requires approval that wasn't granted
in this run, so I couldn't confirm the suite passes") is the only way to
notice it; the top-level `success`/`is_error` field in the audit line does
not surface it. The actual correctness of the added tests was only confirmed
because I ran `gradle test` myself outside the loop after each run.

**2. `--max-turns` is not a recognized flag in the installed CLI (Claude Code
2.1.283) — it does not appear anywhere in `claude --help`, and evidence
confirms it was silently ignored rather than enforced.** One reviewer call in
the small run reached **19 turns** despite the script requesting
`--max-turns 15`. Unknown flags don't error on this CLI (`claude --bogus-flag
--version` still succeeds), so the flag was accepted syntactically but had no
effect. Only `--max-budget-usd` is a confirmed, documented, real cap on this
version.

Neither issue caused an item to fail or a run to stop — both are silent
gaps in enforcement, not visible failures, which is arguably worse: nothing
in the script's own audit trail flags them as problems.

## Rate limits, token budgets, timeouts

No rate limits or timeouts were hit. Total spend: **$1.96** (small run, 10
calls) + **$3.10** (full run, 16 calls) = **$5.06** for both required runs
combined. The single most expensive call was $0.28 — nowhere near the
$1/call `--max-budget-usd` cap. Turns ranged 9–19 against nominal caps of
20 (writer) / 15 (reviewer) — the closest approach to a cap was that same
19-turn reviewer call, and (per finding #2 above) it was already over its
cap when it stopped on its own.

## Could you tell from the audit record alone which item failed and why?

No item failed outright, so this wasn't tested end-to-end. But the audit
record's structural weakness is visible anyway: `success`/`final` are
derived only from Claude's own `is_error` field, so a call that completes
without error but silently failed to do part of its task (finding #1) reads
identically to a fully successful call unless you grep the `result` text by
hand. A production version of this audit log should separately track
whether the required verification command (`$TEST_CMD`) actually ran and
exited 0, rather than trusting the model's self-report.

## Is the cost sustainable?

At ~$0.32/item ($5.06 / 16 items-worth of writer+reviewer pairs across both
runs) and roughly 1-2 minutes per call run sequentially, this is fine for an
occasional, human-supervised pass (e.g. "improve coverage on this file
before a release") but not something to run unattended on every commit —
both on cost grounds and because of the two enforcement gaps above: without
working turn caps and with test verification silently skippable, an
unsupervised larger run has no reliable circuit breaker if a future item
prompts an infinite-loop-shaped task.

## What I'd fix next

- Find the actual reason `gradle`/build-tool commands bypass
  `--allowedTools` prefix matching (or work around it, e.g. wrapping
  `gradle test` in a pre-approved shell script name).
- Drop `--max-turns` from the script (or replace it with whatever the
  current CLI's real turn-cap flag is) since it does nothing on this
  version and its presence is misleading.
- Have the audit log record an explicit `test_cmd_verified: true/false` by
  parsing the writer/reviewer's actual tool-call trace, instead of trusting
  `is_error` alone.
