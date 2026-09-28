# Task Breakdown: Review of `Calculator.divide` (pattern-run vs main)

Diff under review (`git diff main...pattern-run -- src/main/java/calculator/Calculator.java`):

```diff
diff --git a/src/main/java/calculator/Calculator.java b/src/main/java/calculator/Calculator.java
index 19741f7..0de4536 100644
--- a/src/main/java/calculator/Calculator.java
+++ b/src/main/java/calculator/Calculator.java
@@ -13,4 +13,8 @@ public class Calculator {
     public int multiply(int a, int b) {
         return a * b;
     }
+
+    public int divide(int a, int b) {
+        return a / b;
+    }
 }
```

The review is split into 4 narrow-scope worker tasks, one per dimension below. Each worker investigates only its own dimension and writes its findings to `workers/<id>.md`.

## 1. correctness

- [ ] Investigate logic bugs or incorrect behavior introduced by this diff (the new `divide` method).

## 2. test-coverage

- [ ] Check whether the new `divide` method (or any other changed public method/logic) has corresponding tests in `src/test/java/calculator/CalculatorTest.java`.

## 3. edge-cases

- [ ] Assess edge-case robustness of `divide`: divide-by-zero, integer overflow (e.g. `Integer.MIN_VALUE / -1`), and other boundary values.

## 4. style

- [ ] Check whether the new `divide` method matches the existing style/conventions of `add`/`subtract`/`multiply` in the same `Calculator` class.
