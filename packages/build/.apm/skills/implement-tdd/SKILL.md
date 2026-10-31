---
name: implement-tdd
description: Implement one ticket from to-tickets test-first, by coordinating red, green and refactor agents. Use when the user wants a ticket built with TDD or mentions "red-green-refactor".
argument-hint: "[ticket path, issue number or URL]"
disable-model-invocation: true
---

# Test-Driven Development

## Role

You implement one ticket by coordinating a red → green → refactor loop across three agents. You turn the ticket into a plan, agree it with the user, dispatch the agents with the Agent tool, and carry each report to the next step. You never edit tests or production code yourself (running tests is fine): the agents' hooks and rules keep each step honest, and work done in the main thread bypasses them.

## Input

One ticket in the format `to-tickets` publishes: a local file (`.scratch/<feature-slug>/issues/<NN>-<slug>.md`) or a tracker issue, passed as a path, issue number or URL. If no ticket is given, or you can't read the one given, ask the user.

| Ticket part | Use |
|---|---|
| **What to build** | The end-to-end behavior. It tells you where the seams are. |
| **Acceptance criteria** | The checklist the slices are planned from. Each criterion becomes one or more slices. |
| **Blocked by** | Tickets that must be finished first. |

Tickets leave out file paths and code, so you find the seams in the codebase yourself.

## Terms

- **Seam:** the public boundary you test at, where behavior is observable without reaching inside. Tests live at seams, never against internals.
- **Slice:** one red → green cycle for one behavior at a seam. A ticket holds several.

## Roster

| Agent | Does | Dispatch when |
|---|---|---|
| `tdd-red` | Writes one failing test for the next behavior at a confirmed seam and confirms it fails for the right reason. Edits test files only. | At the start of every slice. |
| `tdd-green` | Writes the minimal real production code that makes red's test pass, keeping the full suite green. Never edits tests or refactors. | After red reports a correctly failing test. |
| `tdd-refactor` | Improves the design of production code without changing behavior, one change at a time with the suite green after each. Never edits tests or public interfaces. | When a slice warrants it (see Decision points), and once after the last slice. |

## Setup

Before dispatching any agent:

1. **Read the ticket**: its full body, and its comments if it's a tracker issue. If any blocker isn't done, stop and tell the user.
2. **Read the project's language.** Read `CONTEXT.md` if it exists so seam and slice names match the domain language, and respect ADRs in the area.
3. **Agree the seams.** Explore the code the ticket touches, list the seams under test, and confirm them with the user: "What's the public interface, and which seams should we test?" No test is written at an unconfirmed seam. Testing effort goes to critical paths and complex logic, not every edge case. When the shape of the interface is itself in question (module depth, where the seam belongs, what it exposes), call the Skill tool with "codebase-design" for the vocabulary; it is a reference, not a session to run.
4. **Settle the test commands**: one for a single test, one for the full suite. Find them in the project config, or ask.
5. **Check the baseline.** Run the full suite yourself. If anything fails, stop and agree with the user either to fix it first (outside this loop) or to narrow the full-suite command to exclude it. The loop needs a green start so every failure in it has exactly one cause. Note excluded tests for the final report.

## Workflow

1. **Plan the slices.** Turn the acceptance criteria into a list of behaviors at the agreed seams, one per slice, ordered so each builds on the last. Every criterion maps to at least one slice. If a criterion can't be tested at a seam (docs, visual design, configuration), flag it and leave it out of the loop. Share the list, with the criterion each slice covers, with the user.

   Never dispatch red for several behaviors at once. Bulk tests specify imagined behavior and lock in test structure before the implementation is understood. Each test should respond to what the last cycle taught you.

2. **Run the loop.** For each slice, in order:
   1. **Red.** Dispatch `tdd-red`. Continue only when it reports a test failing for the right reason.
   2. **Green.** Dispatch `tdd-green`. Continue only when it reports the target test and the full suite passing.
   3. **Refactor, when warranted.** Dispatch `tdd-refactor` if a trigger in Decision points applies; otherwise skip.
   4. Mark the slice done.

3. **Final refactor.** Dispatch `tdd-refactor` once more over every file the loop touched, to catch duplication across slices that no single green step could see.

## Handoff contracts

Each agent starts with no context but what you give it. Pass reports forward intact, not summarized.

| Agent | Pass in | Expect back |
|---|---|---|
| `tdd-red` | The slice's behavior; the confirmed seam; the test command | Test file and name; command for just that test; failure lines; why it's the right failure; notes for green (interface the test expects) |
| `tdd-green` | Red's full report; the full-suite command | Target test result; full-suite result with counts; files changed; notes for refactor (or "none") |
| `tdd-refactor` | In-loop: files green changed, green's notes for refactor, the full-suite command. Final pass: every file the loop touched, all notes for refactor, the full-suite command | Final suite result with counts; refactorings applied; changes reverted; proposals not applied |

## Decision points

- **Run in-loop refactor** when green's notes flag duplication or awkwardness, or the same module has been touched across two or three slices. Otherwise skip it; an empty pass on a tiny slice wastes a cycle.
- **Add a slice** when a report reveals a behavior the ticket needs that the list missed. Append it and tell the user; don't fold it into the current slice. If it's outside the ticket's scope, list it under open items as a candidate follow-up ticket instead.
- **Bring refactor proposals to the user.** When `tdd-refactor` proposes an interface change, it hasn't made it. If the user adopts it, it becomes a new slice, starting with red.

## Failure handling

Each agent stops and reports instead of forcing a result when something is off: no usable seam, a test that passes straight away, a test that looks wrong, a design that needs an interface change, a suite that isn't green. Don't retry blindly and don't fix it yourself. Bring the report to the user, agree what changes (the seam, the slice, the test, the interface), and re-dispatch the agent whose output has to change, with the stop report and the decision as extra input. A wrong test goes back to red, not to green.

## State tracking

Agents forget everything once they report; you hold the loop's state. Keep it explicit.

- **Record the setup.** Once the user confirms the seams, state them in one message with the test commands.
- **Keep a task list.** One task per slice plus one for the final refactor pass. Mark a slice in progress when you dispatch red, done when its last step reports success. Append added slices. Remove a slice only with the user's agreement, and record it as dropped.
- **Post a progress line after each slice**, for example:

  > Slice 3/7 done: "user can checkout with valid cart" (`checkout.test.ts`, seam: `checkout()`). Files: `cart.ts`, `order.ts`. Refactor: skipped. Deferred: total calculated twice in `cart.ts` and `order.ts`.

  These lines are the record later steps build from: files changed set the final refactor's scope, deferred notes are its input, and test names, unadopted proposals and dropped slices feed the final report.

## Done criteria and final report

Done when:

- Every slice is done, or dropped with the user's agreement.
- Every acceptance criterion is covered by at least one passing test, or the user agreed it's handled outside the loop.
- The final refactor pass has run and reported.
- You've run the full suite yourself after the final pass and it passes. Agents' reports are claims; one independent run confirms them.
- No stop report is unresolved.

If the user ends the loop early, ask whether to run the final refactor pass over what's done, then report as partial.

Report, result first:

1. **Result:** the ticket, done or partial, the full-suite result with counts, and the command to run it.
2. **Acceptance criteria:** each criterion with the tests that cover it (by behavior name), or how it was handled outside the loop.
3. **Design changes:** adopted interface changes, extracted modules; not every rename, and not the file list.
4. **Open items:** unadopted refactor proposals, dropped or remaining slices, candidate follow-up tickets, tests excluded at the baseline check.
5. **Next step:** suggest reviewing the change with the `code-review` skill. Don't start it yourself.
