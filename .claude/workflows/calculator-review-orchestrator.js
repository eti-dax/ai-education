export const meta = {
  name: 'calculator-review-orchestrator',
  description: 'Orchestrator splits a Calculator diff review into tasks; parallel workers investigate and write reports; orchestrator synthesizes a final report',
  phases: [
    { title: 'Plan', detail: 'orchestrator splits the diff review into narrow tasks and writes task-breakdown.md' },
    { title: 'Research', detail: 'parallel workers each investigate one task and write their own report' },
    { title: 'Synthesize', detail: 'orchestrator reads all worker reports and writes FINAL_REPORT.md' },
  ],
}

const PLAN_SCHEMA = {
  type: 'object',
  properties: {
    tasks: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', description: 'short kebab-case id, used as the worker report filename' },
          title: { type: 'string' },
          prompt: { type: 'string', description: 'full standalone prompt for a worker agent with no other context' },
        },
        required: ['id', 'title', 'prompt'],
      },
    },
  },
  required: ['tasks'],
}

phase('Plan')

const plan = await agent(
  `You are the orchestrator reviewing a Java code change in a git repo.

Run \`git diff main...pattern-run -- src/main/java/calculator/Calculator.java\`. If that fails because \`main\` isn't a valid ref locally, try \`git diff origin/main...pattern-run -- src/main/java/calculator/Calculator.java\`, or as a last resort \`git diff main...HEAD -- src/main/java/calculator/Calculator.java\`. This shows exactly what changed.

Split the review of this diff into 4 narrow-scope tasks, one per dimension:
1. Correctness — logic bugs or incorrect behavior introduced by the diff.
2. Test coverage — new or changed public methods/logic without a corresponding test in src/test/java/calculator/CalculatorTest.java.
3. Edge-case robustness — divide-by-zero, integer overflow (e.g. Integer.MIN_VALUE / -1), boundary values.
4. Style/convention consistency — whether the new method matches the existing style of add/subtract/multiply in the same class.

Write this breakdown as a markdown checklist to task-breakdown.md at the repo root: one heading per task with its id, title, and a short description of scope.

Then return the same 4 tasks as structured output. Each task needs:
- id: short kebab-case id (e.g. "correctness", "test-coverage", "edge-cases", "style"), used as a filename
- title: human-readable title
- prompt: a FULL standalone prompt for a worker agent that starts with zero context. It must tell the worker to: run the same git diff command itself, investigate ONLY that one dimension, label each finding CRITICAL, IMPORTANT, or SUGGESTION with a short justification, and write its findings as markdown to workers/<id>.md at the repo root (creating the workers/ directory if needed) rather than just returning text.`,
  { phase: 'Plan', schema: PLAN_SCHEMA }
)

phase('Research')

const workerResults = await parallel(
  plan.tasks.map(t => () => agent(t.prompt, { label: `worker:${t.id}`, phase: 'Research' }))
)

phase('Synthesize')

const workerFiles = plan.tasks.map(t => `workers/${t.id}.md`).join(', ')

const final = await agent(
  `You are the orchestrator. Worker report files should exist at: ${workerFiles}. Also read task-breakdown.md at the repo root for context on what each worker was asked to investigate.

Read every worker report file. Merge their findings into one consolidated review:
- Sort findings CRITICAL first, then IMPORTANT, then SUGGESTION.
- If more than one worker raised the same or overlapping finding, merge them into one entry and note which workers agreed.
- For each finding, cite which worker report file it came from.

Write the consolidated result to FINAL_REPORT.md at the repo root.

Return a one-paragraph plain-text summary of what you wrote (counts by severity, and whether all expected worker files were found).`,
  { phase: 'Synthesize' }
)

log(final)

return { plan, workerResults, final }
