# Test Coverage Review: Calculator.divide

Scope: whether the new `divide(int a, int b)` method added to `Calculator` has corresponding test coverage in `src/test/java/calculator/CalculatorTest.java`. Correctness of the implementation and code style are out of scope (covered by other workers).

## Findings

1. **IMPORTANT: No test exists for `divide` at all.**
   - Justification: `CalculatorTest.java` contains exactly three test methods — `addsTwoNumbers`, `subtractsTwoNumbers`, and `multipliesTwoNumbers` — each covering the corresponding existing `Calculator` method (`add`, `subtract`, `multiply`). There is no `dividesTwoNumbers` (or similarly named) test method, and no reference to `calculator.divide(...)` anywhere in the test file. The new public method was merged with zero test coverage, including no coverage of the basic/normal case (e.g. `divide(6, 3) == 2`). Missing test coverage for a newly added public method is at least IMPORTANT by default, and here it is total (not just partial).

2. **Note (informational, not separately scored): divide-by-zero edge case is also untested.**
   - Justification: Beyond the normal-case gap above, there is also no test exercising a divide-by-zero scenario (e.g. `divide(1, 0)`), which for integer division would throw `ArithmeticException`. Flagging its absence here for completeness since it falls under "test coverage," but per scope instructions this is not being analyzed in depth — edge-case/correctness analysis of division-by-zero behavior overlaps with another worker's scope (correctness review).

## Summary

No test coverage exists for the new `divide` method — neither the normal case nor edge cases (e.g. divide-by-zero) are tested. This should be treated as IMPORTANT and addressed before merge by adding at least one test for normal division behavior in `CalculatorTest.java`.
