---
paths:
- "src/test/java/calculator/basic/**"
---
# Calculator basic test conventions
- Name every test method in snake_case (lowercase words separated by underscores), never camelCase.
- Mark each test body with `// given`, `// when`, and `// then` comments identifying those sections, in that order.
- End every test method with a `System.out.println(...)` call whose argument is exactly `"OK"` or `"FAIL"`.
