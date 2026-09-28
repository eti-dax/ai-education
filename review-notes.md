# Review Notes

## Commit reviewed
`1b0444f` — "Add Calculator.divide without test coverage" (branch `pattern-run`)

## Diff
```java
public int divide(int a, int b) {
    return a / b;
}
```

## Findings

### CRITICAL — Division by zero is unhandled
`divide` performs raw integer division with no guard on `b == 0`. Calling
`divide(1, 0)` throws an unchecked `ArithmeticException: / by zero` at
runtime instead of failing predictably or being documented as the caller's
responsibility. Every other method in the class (`add`, `subtract`,
`multiply`) is total over all `int` inputs; `divide` silently breaks that
invariant. This needs an explicit decision (throw a clear
`IllegalArgumentException`, return an `Optional`, etc.) before merge.

### IMPORTANT — No test coverage for the new method
`src/test/java/calculator/CalculatorTest.java` has a test for `add`,
`subtract`, and `multiply`, but none for `divide`. Per `writer-notes.md`
this gap is intentional ("Intentional gap for the missing-test review
workflow to catch"), but as a standalone change it should not merge without
tests covering at least: normal division, truncation toward zero for
negative operands, and the divide-by-zero case above (once behavior is
decided).

### SUGGESTION — `Integer.MIN_VALUE / -1` overflow
`divide(Integer.MIN_VALUE, -1)` overflows silently and returns
`Integer.MIN_VALUE` again (Java integer division semantics), which may
surprise callers. Not necessarily worth guarding given the scope of this
calculator, but worth a comment or test if correctness under edge inputs
matters here.
