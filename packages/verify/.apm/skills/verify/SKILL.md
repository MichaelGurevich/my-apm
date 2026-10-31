---
name: verify
description: Verify a built feature against its spec and tickets by running the test suite and tracing every user story and acceptance criterion to the tests that prove it, one read-only agent per ticket plus one for the spec, merged into one traceability report. Use when the user wants to know whether a feature is done before shipping it.
argument-hint: "[spec path, issue number, URL or feature slug]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write|MultiEdit|NotebookEdit"
      hooks:
        - type: command
          command: 'bash "$CLAUDE_PROJECT_DIR/.claude/skills/verify/scripts/guard-scratch-writes.sh" verify'
---

# Verify

## Role

You verify one feature after its tickets are built, by coordinating a panel of trace agents. `implement-tdd` proves each ticket's criteria one at a time and `code-review` reviews each change; nothing before you checks the whole feature against the spec. You pin the spec and tickets to files, run the full test suite once, dispatch one agent per ticket and one for the spec, then merge their traces into a single traceability report with a ship verdict.

You change nothing. You write only your own files under `.scratch/` (the pinned spec and tickets, the test run and the report); the skill's hook blocks every other edit. In Bash you run the test suite and read-only `git` and `gh` queries. When a test fails, record it; never fix the code or the tests, and never rerun the suite in a different way until it passes.

## Input

One feature, as any of:

- the spec: a local Markdown file, or a tracker issue in the format `to-spec` publishes, passed as a path, issue number or URL
- the feature slug, when the spec and tickets live under `.scratch/<feature-slug>/`

If you can't find the spec, or can't find the tickets that implement it, ask the user.

## Terms

- **Story ID:** `US<n>`, the spec's numbered user story `n`.
- **Criterion ID:** `T<NN>.<n>`, acceptance criterion `n` (counting from 1, in the order written) of ticket `NN`. `exercise` uses the same IDs, so its report lines up with yours.

## Roster

| Agent | Traces | Dispatch |
|---|---|---|
| `verify-ticket` | Each acceptance criterion of one ticket to the code that implements it and the tests that prove it, using the test run's results | One per ticket. With more than about 12 tickets, give each agent two or three adjacent tickets. |
| `verify-spec` | Each user story to the tickets and code that deliver it, journeys that span tickets, the spec's testing decisions and out-of-scope list | Once per feature. |

## Setup

1. **Find the spec and the tickets.** Take the spec the user passed, or `.scratch/<feature-slug>/spec.md`. Take the tickets from `.scratch/<feature-slug>/issues/`, or from the tracker: the spec issue's sub-issues, or issues that name it as their parent. Read every one in full, with comments for tracker issues.
2. **Pin them to files.** Agents read files; they can't reach the tracker. `<verify-dir>` is `.scratch/<feature-slug>/verify/`. Write a tracker spec verbatim to `<verify-dir>/spec.md` and each tracker ticket to `<verify-dir>/issues/<NN>-<slug>.md`, numbered in the tracker's dependency order. Use local files where they are. Every agent traces the same text.
3. **Check the tickets are built.** List any ticket whose status isn't done (an open issue, or a local ticket not marked done). If there are any, ask the user whether to verify anyway; the open tickets will show up as missing.
4. **Settle the test command**: the full suite, with a reporter that prints each test's name and result (for example `--reporter=verbose`, `-v`, `--verbose`). Find it in the project config, or ask. If a coverage report is cheap to produce with the same run, add it.
5. **Run the suite once.** Note the commit (`git rev-parse HEAD`) and whether there are uncommitted changes (`git status --short`). Redirect the whole output to `<verify-dir>/test-run.txt` and note the counts. A red suite isn't a reason to stop; the failures become part of the trace.
6. **Look for exercise results.** If `.scratch/<feature-slug>/exercise/report.md` exists, note its date and commit. Agents may count a scenario it passed as evidence for a criterion, but only when it ran against the same commit; otherwise mention that it's stale and leave it out.
7. **Announce the panel** in one message: the spec, the tickets (with any not yet built), the suite result with counts, whether exercise results are used, and the agents you're dispatching. Then dispatch without waiting.

## Workflow

1. **Dispatch the panel.** Send every agent in a single message so they run in parallel.
2. **Collect the traces.** If an agent fails or returns something outside the contract, re-dispatch it once with the problem stated; if it fails again, list its tickets as not traced.
3. **Check the evidence.** For each test an agent cites, check the test exists at the location given and its result matches `test-run.txt`. For each criterion marked missing or untested, check that what's reported absent really is absent. Change the status where the evidence doesn't hold, and note how many you changed. Don't upgrade a status without evidence, and don't add traces of your own.
4. **Join the traces.** Build the matrix: each user story, the tickets `verify-spec` says deliver it, each of those tickets' criteria with their status and tests. Criteria that serve no user story and stories with no criteria both go in the report.
5. **Write the report** (see Final report) and save it.

## Handoff contract

Each agent starts with no context but what you give it.

| Agent | Pass in | Expect back |
|---|---|---|
| `verify-ticket` | Its ticket file paths; the spec path; `test-run.txt` and any coverage report; the exercise report path, or "none"; whether `CONTEXT.md` and ADRs exist and where | The ticket trace in `assets/trace-contract.md`: one row per criterion with status, implementing code, tests and evidence, then a gap for every criterion not proven |
| `verify-spec` | The spec path; every ticket file path; `test-run.txt`; the exercise report path, or "none"; whether `CONTEXT.md` and ADRs exist and where | The spec trace in `assets/trace-contract.md`: one row per user story, then findings for undelivered stories, untested journeys, testing decisions not followed and out-of-scope work built |

## Decision points

- **The suite is red before anything else is wrong.** Still dispatch. The report shows which criteria the failures hit, which tells the user what is actually broken.
- **The suite can't run at all** (it doesn't build, or the command errors before any test runs). Stop and tell the user; a trace without results would mark everything untested.
- **A criterion is reported proven by a test outside the ticket's change.** Accept it if the evidence holds; older tests count. Proof is about behavior, not about when the test was written.
- **The spec and a ticket disagree** (a ticket narrowed or changed a story). Keep both traces and list it under Spec findings; the author decides which one is right.
- **The feature has no spec, only tickets.** Run `verify-ticket` agents only, skip `verify-spec`, and say in the report that user stories weren't traced.

## Final report

Save to `<verify-dir>/report.md`, then post the Verdict and Blocking gaps sections in chat with the file path.

Open the report with a header: the spec, the tickets traced, the commit and whether uncommitted changes were included, the test command and its counts, the exercise report used (or none, or stale), and the date.

Then, result first:

1. **Verdict:** one of
   - **Ready to ship:** the suite is green, every user story is delivered, and every criterion is proven or exercised.
   - **Ready with gaps:** the suite is green and everything is delivered, but some criteria are weak, untested or not testable. Each gap can be closed with a test, or accepted.
   - **Not ready:** a failing test, a criterion missing, or a user story not delivered.

   Follow with one sentence on why, and the criterion counts by status.
2. **Blocking gaps:** every failing and missing criterion and every undelivered story, in full.
3. **Traceability matrix:** a table with one row per criterion, grouped by user story: story ID, criterion ID and text, status, tests (`path:line` and name), exercise scenario if used. Then criteria that serve no story, and stories with no criteria.
4. **Other gaps:** weak, untested and not testable criteria, each with the test the agent recommends (behavior and seam), or how to check it by hand.
5. **Spec findings:** from `verify-spec`, in full: untested journeys across tickets, testing decisions not followed, out-of-scope work built, spec and ticket disagreements.
6. **Coverage:** each agent with its tickets and whether it traced them, statuses changed at the check, tickets not built, and tests excluded from the run.
7. **Next step:** unless the verdict is Ready to ship, suggest how to close each gap. A failing or missing criterion goes through `implement-tdd` as a new slice, test first. A weak or untested criterion only needs the recommended test, which should pass straight away, so it's written outside the loop (`tdd-red` stops on a test that passes at once); check it fails when the behavior is broken before trusting it. For criteria only visible in the running app, suggest `exercise`. Then re-run `/verify`. Don't start any of these yourself.
