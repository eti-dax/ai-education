# Correctness Review: `Calculator.divide(int a, int b)`

Scope: correctness only (logic bugs / incorrect behavior). Test coverage, edge cases, overflow, and style are explicitly out of scope for this report.

## Findings

1. **IMPORTANT** — Integer division silently truncates the result, which misrepresents "division" as a general arithmetic operation.
   - The method is declared as `public int divide(int a, int b)` and returns `a / b` using Java's `int` division, which discards any fractional remainder (rounds toward zero) rather than computing the mathematically correct quotient.
   - Example: `divide(1, 2)` returns `0`, and `divide(7, 2)` returns `3` instead of `3.5`. For a general-purpose `divide` operation (as opposed to an explicitly named `intDivide`/`floorDiv`), this is a logic/semantics mismatch between what the method name promises and what it actually computes — callers expecting real division semantics (consistent with mathematical division, and analogous to how `add`/`subtract`/`multiply` are exact for `int` inputs but division is not closed over `int`) will get silently wrong answers rather than an error or a correctly-rounded/fractional result.
   - Justification for severity: this is not a crash or an edge case — it's the core, normal-path behavior of the method being incorrect relative to its apparent contract, so it's rated IMPORTANT rather than CRITICAL/SUGGESTION. It is not CRITICAL because it may be an intentional design choice consistent with the rest of the class (all methods are `int`-typed), but that intent is not documented anywhere in the diff, so the ambiguity itself is a correctness concern worth flagging.

2. **No other correctness issues found.** The operator (`/`) is the correct one for a divide operation (not `*`, `-`, etc.), the operands are used in the correct order (`a / b`, not `b / a`), the parameters are otherwise unused/unmodified correctly, and the method signature (name, parameter types, and usage) is internally consistent with the rest of the `Calculator` class.
