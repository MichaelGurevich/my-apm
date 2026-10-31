# Verify trace contract

Every trace agent follows this contract. Your agent definition says what you trace; this file says how to trace and what to report.

## Input

- The spec path, and the ticket file paths you trace (`verify-spec` gets every ticket).
- `test-run.txt`: the full suite's output from one run, with each test's name and result. A coverage report, if there is one.
- The exercise report path, or "none".
- Whether `CONTEXT.md` and ADRs exist, and where.

## IDs

- **Story ID:** `US<n>`, the spec's numbered user story `n`.
- **Criterion ID:** `T<NN>.<n>`, acceptance criterion `n` (counting from 1, in the order written) of ticket `NN`.

## Process

1. Read what you trace in full: the tickets, or the spec. Read the spec even as a ticket agent, so you know what each criterion is for.
2. Read `CONTEXT.md` and the ADRs in the area, so you look for the right names in the code.
3. For each item, find the code that implements it: search for the domain terms, the interface the ticket describes, the routes, commands or functions a user of it would call.
4. Find the tests that exercise it: search the test files for the same terms and interfaces, then read each candidate test. A test counts only if it drives the behavior through a public seam and asserts on the result the item describes.
5. Look up each test's result in `test-run.txt` by name. A test missing from the run didn't run; say so.
6. If the exercise report is given, look for a scenario listing the item's ID, and read its result and evidence.
7. Decide the status, then reread each row against the rules below before reporting.

## Rules

- **Read only.** Never edit any file. You can't run code or tests; the run in `test-run.txt` is the only result you have.
- **Every status is anchored.** Proven, weak and failing cite each test by `path:line` and name, with its result from the run. Untested and missing say where you looked and what you searched for. A status with neither is a guess; don't report it.
- **Would it fail?** Proven needs a test that would fail if the behavior were wrong. Read the assertions: a test that only checks no error was thrown, checks a mock it set up itself, or computes its expected value the way the code does, is weak.
- **The whole criterion.** A criterion that names an error path, a limit or several cases is proven only when each of them is tested. Covering part of it is weak; say which part is missing.
- **Exercise counts only with evidence.** A criterion is exercised only when a scenario in the exercise report lists its ID, passed, and has evidence on file. Automated proof beats it: if a test proves the criterion, the status is proven.
- **Recommend the test.** For every criterion that isn't proven, say the test that would prove it: the behavior in one line, the seam it goes through, and the existing test it should sit next to.
- **No padding.** Report each item once, with the status the evidence supports. Don't add concerns outside what you trace.

## Statuses

| Status | Use when |
|---|---|
| **proven** | A test drives the criterion through a public seam, would fail if it were wrong, and passed in the run. |
| **exercised** | No test proves it, but a passing exercise scenario covers it, with evidence. |
| **weak** | A test touches it, but wouldn't catch it being wrong, or covers only part of it. |
| **failing** | A test that would prove it failed or errored in the run. A skipped test doesn't count; without another test, that's untested. |
| **untested** | Code implements it, and no test exercises it. |
| **missing** | No code implements it. |
| **not testable** | It can't be checked by a test or at an interface (documentation, visual design, copy). Say how a person would check it. |

Story statuses (`verify-spec` only):

| Status | Use when |
|---|---|
| **delivered** | One or more tickets deliver it, and its behavior is in the code. |
| **partial** | Part of the story is in the code; say which part isn't. |
| **undelivered** | No ticket delivers it, or no code implements it. |

## Output: `verify-ticket`

Report in exactly this shape, one section per ticket.

```markdown
## Ticket <NN>: <title>

| Criterion | Status | Code | Tests | Exercise |
|---|---|---|---|---|
| T<NN>.<n>: <criterion text, shortened> | <status> | `<path>:<line>` or "none found" | `<path>:<line>` <test name> (<passed / failed / not in run>) | <scenario, or blank> |

### Gaps

#### T<NN>.<n>: <short title>
- **Status:** weak | failing | untested | missing | not testable
- **Evidence:** the quoted assertion, the failure lines from the run, or where you looked and what you searched for
- **What's not proven:** the case or part of the criterion no passing test covers
- **Recommended test:** the behavior, the seam, and the existing test to sit next to; or, when not testable, how a person checks it
```

Leave out the Gaps heading when every criterion is proven.

## Output: `verify-spec`

Report in exactly this shape.

```markdown
## Spec: <title>

| Story | Status | Tickets | Code | Journey test |
|---|---|---|---|---|
| US<n>: <story, shortened> | <status> | <NN, NN> or "none" | `<path>:<line>` or "none found" | `<path>:<line>` <test name> (<result>), or "none" |

### Findings

#### SPC-<n>: <short title>
- **Kind:** undelivered story | untested journey | testing decision not followed | out-of-scope work built | spec and ticket disagree
- **Location:** the story ID, the quoted spec text, and `<path>:<line>` in the code where there is one
- **Evidence:** what you found, or where you looked and what you searched for
- **Problem:** what isn't proven, or what doesn't match, in one to three sentences
- **Recommendation:** the test to add (behavior, seam, neighbouring test), or the question for the author
```

Number findings from 1, undelivered stories first. Leave out the Findings heading when it would be empty.
