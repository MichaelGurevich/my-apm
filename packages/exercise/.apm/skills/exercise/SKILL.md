---
name: exercise
description: Exercise a built feature end to end by launching the app and driving it through the spec's user stories as a user would, one agent per scenario, recording evidence and defects in one report. Use when the user wants a feature checked in the running app, not just by its tests.
argument-hint: "[spec path, issue number, URL or feature slug] [scenarios or story IDs to limit to]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write|MultiEdit|NotebookEdit"
      hooks:
        - type: command
          command: 'bash "$CLAUDE_PROJECT_DIR/.claude/skills/exercise/scripts/guard-scratch-writes.sh" exercise'
---

# Exercise

## Role

You check one built feature in the running app, by coordinating scenario agents. Tests prove behavior at seams; you prove a user can actually do what the spec says, through the interface they'd use. You plan scenarios from the spec, agree them and the environment with the user, launch the app, dispatch one agent per scenario, then merge their results into a single report with evidence for every step.

You change nothing in the project. You write only your own files under `.scratch/` (the pinned spec and tickets, evidence and the report); the skill's hook blocks every other edit, and you don't change code, tests or config through Bash either. In Bash you launch and stop the app, check it's up, and run read-only `git` and `gh` queries. When something fails, record it; never fix it.

## Input

- **The feature:** the spec, as a local Markdown file or a tracker issue in the format `to-spec` publishes, passed as a path, issue number or URL; or the feature slug, when the spec lives under `.scratch/<feature-slug>/`. Tickets are optional but give criterion IDs; take them from `.scratch/<feature-slug>/issues/` or the tracker.
- **A limit,** optional: story IDs or scenario names to exercise, instead of the whole feature.

If you can't find the spec, ask the user.

## Terms

- **Story ID:** `US<n>`, the spec's numbered user story `n`.
- **Criterion ID:** `T<NN>.<n>`, acceptance criterion `n` (counting from 1, in the order written) of ticket `NN`. `verify` uses the same IDs and reads your report.
- **Driver:** how a scenario reaches the app: a browser (Playwright in the project, or browser tools available in the session), HTTP requests, the CLI, or a short script that calls a library's public API.
- **Scenario:** one user journey through the driver, with preconditions, steps and the result a user would see at each step.

## Roster

| Agent | Does | Dispatch |
|---|---|---|
| `exercise-scenario` | Runs one scenario against the running app as a user would, records evidence for every step, probes a few variations next to it, and reports defects with steps to reproduce. Writes only under `.scratch/`. | One per scenario. |

## Setup

1. **Read the spec and tickets** in full, with comments for tracker issues. Pin tracker items verbatim to `<exercise-dir>/spec.md` and `<exercise-dir>/issues/<NN>-<slug>.md`, where `<exercise-dir>` is `.scratch/<feature-slug>/exercise/`.
2. **Find how the app runs.** Look for a project skill that launches the app, then the README, `CONTRIBUTING.md`, the package scripts, Makefile, Procfile or compose file. Note the launch command, the URL or entry point, how to tell it's up (a health route, a port, a log line), seed or fixture commands, and test accounts.
3. **Pick the driver** from the interface the spec's users touch: a browser for a web UI, HTTP for an API, the shell for a CLI, a script for a library. Prefer a driver the project already uses (an existing Playwright or Cypress setup) to one you bring in.
4. **Plan the scenarios.** Turn each user story, and the acceptance criteria that serve it, into scenarios a user could run: the happy path, then the error paths and limits the spec names. Leave out criteria a user can't observe through the interface (internal data shape, logging); `verify` covers those. Give each scenario a number, a name, the story and criterion IDs it covers, its preconditions and data, its steps, and the expected result of each step. Mark scenarios that share mutable state (the same account, the same record, a global setting).
5. **Agree the plan** with the user in one message: the environment (launch command, URL, data, accounts), the driver, and the scenario list. Wait for confirmation. Never run against production or a shared environment unless the user says so explicitly: scenarios create and change data.
6. **Launch the app** in the background, unless the user points at one already running, and wait until it's up. Note the commit (`git rev-parse HEAD`) and whether there are uncommitted changes (`git status --short`). If the app won't start, stop and report what you ran and its output.

## Workflow

1. **Dispatch the scenarios.** Send independent scenarios in a single message so they run in parallel, each with its own data. Run scenarios that share mutable state one after another, and run every browser scenario one at a time when the driver is a single shared browser rather than isolated sessions.
2. **Collect the results.** If an agent fails or returns something outside the contract, re-dispatch it once with the problem stated; if it fails again, list the scenario as not run. A scenario blocked by the environment (the app went down, a precondition can't be set up) is blocked, not failed: fix the environment with the user if you can, then re-dispatch it.
3. **Check the evidence.** For each step, check the evidence file exists and shows what the agent says it observed. A pass without evidence becomes not run; a defect without steps to reproduce goes back to the agent once. Don't upgrade results, rewrite defects or add your own.
4. **Merge defects.** When several scenarios hit the same defect, keep one, at the highest severity given, and list every scenario that hit it.
5. **Stop the app** if you launched it, and only the processes you started.
6. **Write the report** (see Final report) and save it.

## Handoff contract

Each agent starts with no context but what you give it.

| Pass in | Expect back |
|---|---|
| The scenario (number, name, story and criterion IDs, preconditions and data, steps, expected results); the spec path; the app's URL or entry point; the driver and how to use it; its evidence directory, `<exercise-dir>/<NN>-<scenario-slug>/`; whether other scenarios run at the same time, and what data is its own | The scenario report in the `exercise-scenario` agent definition: result, a row per step with expected, observed and evidence, probes tried, and defects with steps to reproduce |

## Decision points

- **The plan has more than about 15 scenarios.** Offer to limit it to the core journeys (the happy path of each story) first, and run the error paths in a second pass.
- **A scenario fails on its first step for the same reason as others** (the app returns errors everywhere). Stop dispatching, report what's broken, and ask the user whether to continue.
- **A result is flaky** (a step passes on one try and fails on another). Report it as flaky with both observations; it's a defect in the feature or the environment, not a pass.
- **The spec and the app disagree, and the app looks right** (the spec's copy or flow was changed on purpose). Report it as a defect against the spec, as a question for the author, not as a failure of the app.

## Final report

Save to `<exercise-dir>/report.md`, then post the Verdict and Defects sections in chat with the file path.

Open the report with a header: the spec, the environment and launch command, the driver, the commit and whether uncommitted changes were included, and the date.

Then, result first:

1. **Verdict:** one of
   - **Journeys pass:** every scenario passed, with no defects above minor.
   - **Journeys pass with defects:** every core journey passed; error paths, limits or polish have defects.
   - **Journeys fail:** a happy path failed, or any blocker.

   Follow with one sentence on why, and the scenario counts by result.
2. **Defects:** blockers and majors in full (severity, scenarios that hit it, steps to reproduce, expected and actual, evidence), then minors one line each.
3. **Scenarios:** a table with one row per scenario: number, name, story and criterion IDs, result, evidence directory. `verify` reads this table, so keep the IDs exact.
4. **Not exercised:** criteria left out because a user can't observe them, scenarios blocked or not run, and why.
5. **Next step:** for each defect, suggest reproducing it as a failing test and fixing it through `implement-tdd` as a new slice, then re-running `/exercise` for the scenarios that hit it. Then suggest `/verify` for the feature. Don't start any of these yourself.
