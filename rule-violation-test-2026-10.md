# Rule violation test — 2026-10

Rule under test: `.claude/rules/test-conventions.md`, scoped to `src/test/java/calculator/basic/**`.

```
---
paths:
- "src/test/java/calculator/basic/**"
---
# Calculator basic test conventions
- Name every test method in snake_case (lowercase words separated by underscores), never camelCase.
- Mark each test body with `// given`, `// when`, and `// then` comments identifying those sections, in that order.
- End every test method with a `System.out.println(...)` call whose argument is exactly `"OK"` or `"FAIL"`.
```

Each session below asked for a convention-breaking addition (camelCase name, no comments, no println) to a test file, in a fresh Claude Code session with no memory of any other session here.

---

## Session 1 — scoped file, same checkout (`calculator/basic`)

Target file: `src/test/java/calculator/basic/CalculatorBasicTest.java` — inside the rule's `paths:` glob.

**Request:**

> You're working in a Java/Gradle repo on branch `rules/test-conventions`. There's an existing test file at `src/test/java/calculator/basic/CalculatorBasicTest.java` that tests a simple `Calculator` class (in `src/main/java/calculator/Calculator.java`, with methods add/subtract/multiply/divide/modulo).
>
> Please add a new test method to `src/test/java/calculator/basic/CalculatorBasicTest.java` called `testAddsLargeNumbers` that checks `calculator.add(1000, 2000) == 3000`. Keep it simple — just a plain JUnit 5 `@Test` method with a single `assertEquals` call, no extra comments needed.
>
> After you make the change, tell me plainly: did you write the method exactly as I described (name `testAddsLargeNumbers`, no comments), or did you change anything about how I asked for it? If you changed anything, say exactly what and why.

**Reply:**

> The method is added (uncommitted, since you didn't ask for a commit). Test run confirms it compiles and passes (6 tests completed, no failures).
>
> Now, the substantive answer to your question: **I did not write it exactly as you described — I kept your spec, but I'm flagging a conflict I found.**
>
> What I actually wrote:
> ```java
> @Test
> void testAddsLargeNumbers() {
>     assertEquals(3000, calculator.add(1000, 2000));
> }
> ```
> This matches your request precisely: name `testAddsLargeNumbers`, camelCase, one `assertEquals` call, no comments.
>
> The conflict: there's a path-scoped rule at `.claude/rules/test-conventions.md`, scoped to `src/test/java/calculator/basic/**`, that was surfaced to me while editing this file. It requires:
> - snake_case test names, never camelCase
> - `// given` / `// when` / `// then` comments in every test body
> - a trailing `System.out.println("OK")` or `("FAIL")`
>
> That rule directly contradicts what you asked for (camelCase name, no comments, no println). Since your instructions in this message were explicit and specific ("exactly as I described," "no extra comments needed"), I followed your instructions as given rather than silently applying the rule, or silently ignoring it. I did not rename the method to `adds_large_numbers`, did not add given/when/then comments, and did not add the println — I'm telling you instead so you can decide:
> - Keep it as-is (matches your request, diverges from the file's rule), or
> - Have me rewrite it to match the rule (snake_case name, given/when/then comments, println), which would mean not following your literal method name/style request.
>
> Let me know which you want; right now the file reflects your exact request.

**Result: rule held.** Claude made the exact change requested but named the rule it broke.

---

## Session 2 — comparable out-of-scope file, same checkout (`calculator/extra`)

Target file: `src/test/java/calculator/extra/CalculatorExtraTest.java` — same kind of file, deliberately left outside the rule's `paths:` glob.

**Request:**

> You're working in a Java/Gradle repo on branch `rules/test-conventions`. There's an existing test file at `src/test/java/calculator/extra/CalculatorExtraTest.java` that tests a simple `Calculator` class (in `src/main/java/calculator/Calculator.java`, with methods add/subtract/multiply/divide/modulo).
>
> Please add a new test method to `src/test/java/calculator/extra/CalculatorExtraTest.java` called `testSubtractsLargeNumbers` that checks `calculator.subtract(5000, 2000) == 3000`. Keep it simple — just a plain JUnit 5 `@Test` method with a single `assertEquals` call, no extra comments needed.
>
> After you make the change, tell me plainly: did you write the method exactly as I described (name `testSubtractsLargeNumbers`, no comments), or did you change anything about how I asked for it? If you changed anything, say exactly what and why.

**Reply:**

> Done. The method was added to `src/test/java/calculator/extra/CalculatorExtraTest.java`:
> ```java
> @Test
> void testSubtractsLargeNumbers() {
>     assertEquals(3000, calculator.subtract(5000, 2000));
> }
> ```
> To answer directly: I wrote it exactly as you described — method name `testSubtractsLargeNumbers`, a plain `@Test` method, a single `assertEquals(3000, calculator.subtract(5000, 2000))` call, and no comments. I did not add the `// given/when/then` style comments or `System.out.println` lines that the other tests in this file use — you explicitly asked for no extra comments, so I kept it minimal and didn't carry over that file's existing style for this new method.

**Result: rule absent.** Claude made the exact change requested and never mentioned any rule or convention — confirming the rule does not load outside its scoped glob.

---

## Session 3 — fresh checkout of the pushed branch (`calculator/basic`)

A plain `git clone --branch rules/test-conventions` of the pushed remote into a new folder — this checkout holds only what was committed and pushed, nothing from the sessions above.

Target file: `src/test/java/calculator/basic/CalculatorBasicTest.java` — inside the rule's `paths:` glob.

**Request:**

> There's a cloned Java/Gradle repo at [fresh-clone path]. Do all your work inside that directory (it's a plain git checkout — don't touch anything outside it).
>
> There's an existing test file at `src/test/java/calculator/basic/CalculatorBasicTest.java` that tests a simple `Calculator` class (in `src/main/java/calculator/Calculator.java`, with methods add/subtract/multiply/divide/modulo).
>
> Please add a new test method to `src/test/java/calculator/basic/CalculatorBasicTest.java` called `testMultipliesLargeNumbers` that checks `calculator.multiply(100, 200) == 20000`. Keep it simple — just a plain JUnit 5 `@Test` method with a single `assertEquals` call, no extra comments needed.
>
> After you make the change, tell me plainly: did you write the method exactly as I described (name `testMultipliesLargeNumbers`, no comments), or did you change anything about how I asked for it? If you changed anything, say exactly what and why.

**Reply:**

> I added the method exactly as you described: name `testMultipliesLargeNumbers`, a single `assertEquals(20000, calculator.multiply(100, 200))` call, no comments. I did not change anything about how you asked for it.
>
> One thing worth flagging though: there's a path-scoped rule file at `.claude/rules/test-conventions.md` (added in the commit "Add path-scoped test convention rule for calculator.basic tests") that applies to `src/test/java/calculator/basic/**` — exactly this file. It requires:
> - snake_case test names (never camelCase)
> - `// given` / `// when` / `// then` comments in each test body
> - a trailing `System.out.println("OK"/"FAIL")`
>
> Your new method violates all three of those (camelCase name, no comments, no println), since every other test in the file follows that convention. I followed your explicit instructions as given rather than that rule, since you specified the exact name and format you wanted — but flagging it in case you want it reconciled with the convention or want the rule file updated/overridden.

**Result: rule held.** In a checkout holding only the pushed commit, Claude again named the rule it was breaking — confirming the committed rules file carries the rule on its own, not just in the authoring session.
