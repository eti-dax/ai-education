# Single-Run Report

## Change: Add `Calculator.divide` (intentional missing-test gap)

Added `Calculator.divide(int, int)` to `src/main/java/calculator/Calculator.java` without
corresponding test coverage in `src/test/java/calculator/CalculatorTest.java`, to exercise a
missing-test review workflow.

### Review findings

| Severity | Finding |
|----------|---------|
| IMPORTANT | `divide()` performs unchecked integer division and throws an unhandled `ArithmeticException` on `divide(5, 0)`. No zero-divisor guard exists, unlike `add`/`subtract`/`multiply`, which have no equivalent failure mode. Should be fixed before merge (guard the divisor or explicitly document/propagate the exception intentionally). |
| IMPORTANT | No test coverage was added for `divide`, unlike every other method in `Calculator`, which has a corresponding test in `CalculatorTest.java`. At minimum a happy-path test and a divide-by-zero test are missing (the intentional gap the workflow was meant to catch). |

No CRITICAL or SUGGESTION-level issues were found.

## Follow-up research: divide-by-zero handling & testing in Java

**Task:** Research idiomatic approaches for handling division-by-zero in a small Java utility
method like `Calculator.divide`, and how to unit test it with JUnit 5.

### Findings

**Common approaches:**
- **Let `ArithmeticException` propagate (unchecked)** — idiomatic default; Java already throws
  `ArithmeticException: / by zero` on integer division by zero, matching Java convention of
  unchecked exceptions for programmer/argument errors.
- **Throw a custom exception** (e.g. `IllegalArgumentException` via an explicit `if (b == 0)`
  guard) — useful for a clearer message; still unchecked, in line with modern Java guidance
  (checked exceptions are discouraged — Effective Java, Item 71).
- **Return a sentinel value** (`0`, `Integer.MAX_VALUE`, `Optional<Integer>`) — generally
  **not** idiomatic here; it silently masks the error and is easy to misuse.

**Idiomatic choice:** let `ArithmeticException` propagate, optionally with an explicit
`if (b == 0) throw new ArithmeticException("...")` guard for a clearer message.

**JUnit 5 test pattern:**
```java
@Test
void divideByZeroThrowsArithmeticException() {
    Calculator calc = new Calculator();
    ArithmeticException ex = assertThrows(ArithmeticException.class,
            () -> calc.divide(10, 0));
    assertEquals("/ by zero", ex.getMessage());
}
```

### Token usage for this research task

| Metric | Value |
|--------|-------|
| Subagent tokens | 23,752 |
| Tool uses | 3 |
| Duration | 22.9s |
