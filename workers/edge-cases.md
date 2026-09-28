# Edge-Case Robustness Review: `Calculator.divide(int a, int b)`

Scope: boundary/edge-case input behavior only (divide-by-zero, integer overflow, and other boundary values). General correctness of operator choice, test coverage, and code style are out of scope for this report.

```java
public int divide(int a, int b) {
    return a / b;
}
```

## Findings

1. **CRITICAL — Divide-by-zero is unhandled and will crash the caller.**
   When `b == 0`, `a / b` throws an unchecked `ArithmeticException: / by zero`. There is no guard, no documented contract (no Javadoc), and no alternative (e.g., returning a sentinel, throwing a custom/checked exception, or using a domain-appropriate error path) for callers. Given the sibling methods (`add`, `subtract`, `multiply`) are total functions that never throw, `divide` silently introduces a partial function with a very different failure mode. Any caller that doesn't explicitly know to guard `b != 0` (e.g., driven by user input, computed data, or a loop variable) can crash the program. This is CRITICAL because it's a guaranteed, easily-triggered runtime exception with no defensive handling anywhere in the diff.

2. **IMPORTANT — `Integer.MIN_VALUE / -1` silently overflows instead of signaling an error.**
   In Java, `int` division overflows in exactly one case: `Integer.MIN_VALUE / -1`. Because `Integer.MIN_VALUE` (-2147483648) has no positive two's-complement counterpart representable in 32 bits, the JVM does *not* throw — it silently returns `Integer.MIN_VALUE` again (an incorrect, wrapped-around result masquerading as valid output). Unlike divide-by-zero, this failure is silent: no exception, no log, just a mathematically wrong answer returned as if it were correct. This is IMPORTANT rather than CRITICAL because it requires a specific, less-common boundary input (`Integer.MIN_VALUE` combined with divisor `-1`), but it's a real correctness trap that's easy to miss in review/testing and could produce hard-to-diagnose bugs downstream (e.g., silently wrong totals/calculations rather than a visible crash).

3. **SUGGESTION — Other boundary values behave correctly but are worth noting as implicitly relied-upon.**
   - `a / 1` and `a / -1` (except `Integer.MIN_VALUE / -1`, see #2) behave correctly per standard integer division.
   - `0 / b` for any nonzero `b` correctly returns `0`.
   - Negative operand combinations (`-a / b`, `a / -b`, `-a / -b`) follow Java's truncating-toward-zero division semantics correctly (e.g., `-7 / 2 == -3`, not floor division's `-4`). This is standard and consistent with Java semantics, but if any caller expects floor-division behavior (e.g., for modular arithmetic use cases), this could be a latent source of subtle bugs. Flagging as a SUGGESTION since it's correct-per-Java-spec behavior, just worth documenting/being aware of given no Javadoc currently states the semantics.
   - `Integer.MAX_VALUE / -1` and similar non-`MIN_VALUE` boundary combinations do not overflow and behave as expected.
