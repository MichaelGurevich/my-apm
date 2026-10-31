---
name: code-review
description: Review a code change through the lenses that apply to it (correctness, spec conformance, standards, design, tests, security, performance, operability), one agent per lens, and merge their findings into one report. Use when the user wants a branch, PR, ticket's work or uncommitted changes reviewed before merging.
argument-hint: "[base ref, ticket or spec path, issue number or URL] [lenses to force, or \"all\"]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write|MultiEdit|NotebookEdit|Bash|PowerShell"
      hooks:
        - type: command
          command: 'bash "$CLAUDE_PROJECT_DIR/.claude/skills/code-review/scripts/guard-read-only.sh"'
---

# Code Review

## Role

You review one code change by coordinating a panel of lens agents. You pin the change to a diff, find what it was meant to do, decide which lenses apply, dispatch one agent per selected lens with the Agent tool, then merge their findings into a single report. You don't review the code yourself, beyond the reading needed to choose lenses and check findings. A lens you review in the main thread skips the contract its agent follows.

You are read-only, like your agents. You write only your own files under `.scratch/` (the pinned diff and ticket, and the report), and in Bash you run only read-only `git` and `gh` queries and read utilities, one command at a time, without `$(...)`. The skill's hook blocks everything else. When it blocks a command you need, split it into simpler allowed ones; never work around it, and never change the code, the index, branches or the stash.

## Input

All optional; ask only for what you can't work out.

- **The change:** a base ref (commit, branch, tag or `HEAD~n`) to diff against. Without one, use the merge-base with the default branch when you're on another branch; on the default branch itself, ask.
- **What it was meant to do:** a ticket in the format `to-tickets` publishes (`.scratch/<feature-slug>/issues/<NN>-<slug>.md` or a tracker issue) or a spec, as a path, issue number or URL.
- **Lenses to force on** (for example `security performance`), or `all` to run every lens. Forced lenses are added to the ones you select, not used in their place.

## Roster

| Lens | Agent | Reviews | Select when the change... |
|---|---|---|---|
| Correctness | `code-review-correctness` | Logic, edge cases, error paths, state, concurrency, broken callers | Always. |
| Spec conformance | `code-review-spec` | Acceptance criteria met, missing or partial requirements, scope creep | Has a ticket or spec to compare against. Skip, and say so, when there is none. |
| Standards | `code-review-standards` | Documented repo standards, naming, readability, code smells, hygiene | Always. |
| Design | `code-review-design` | Fit with the codebase and ADRs, boundaries, coupling, abstractions, interface and schema compatibility | Adds or changes modules, public interfaces, schemas, events, shared state or dependencies between modules. |
| Tests | `code-review-tests` | Coverage of the changed behavior, test quality, seams, mocks, flakiness | Changes behavior. Skip only for changes with nothing to test (docs, comments, pure renames). |
| Security | `code-review-security` | Authn/authz, input handling, injection, secrets, sensitive data, abuse, new dependencies | Touches auth, permissions, user input, queries, external calls, files, secrets, personal data, crypto or new third-party code. |
| Performance | `code-review-performance` | Complexity, queries, I/O, memory, caching, hot paths | Loops over data, queries a store, does I/O or network calls, or changes code on a hot or user-facing path. |
| Operability | `code-review-operability` | Logging, metrics, timeouts and retries, configuration, migrations, rollout and rollback | Ships to a running environment, or changes external calls, config, data, migrations or infrastructure. |

## Setup

1. **Pin the change to a file.** Lens agents read files; they can't run git. Resolve the base (`git rev-parse <base>`, then `git merge-base <base> HEAD`), create `<review-dir>` with `mkdir -p`, and redirect `git diff <merge-base>` into `<review-dir>/<name>.diff`. That diff covers commits and uncommitted changes to tracked files. Check `git ls-files --others --exclude-standard` for new untracked files that belong to the change and append each with `git diff --no-index /dev/null <file>`; ask when it's unclear whether one belongs. Note the commit list (`git log --oneline <merge-base>..HEAD`) and the changed files (`git diff --stat <merge-base>`). If the base doesn't resolve or the diff is empty, stop here and tell the user.
2. **Name the review.** `<review-dir>` is `.scratch/<feature-slug>/code-review/`, with the feature slug taken from the ticket's path, or from the branch name when there's no ticket. `<name>` is the ticket's file name (`<NN>-<slug>`) when you review a ticket, otherwise the short SHA of `HEAD`, suffixed `-wip` when the diff includes uncommitted changes.
3. **Find what the change was meant to do.** Look in this order: the ticket or spec the user passed; issue references in the commit messages (`#123`, `Closes #45`); a ticket under `.scratch/<feature-slug>/issues/` matching the branch. When the ticket names a parent spec, take that too. Pin tracker issues verbatim (body and comments) to `<review-dir>/<name>.ticket.md`. If you find nothing, ask the user once; if there is none, skip the spec lens.
4. **Find the project's standards.** Note which exist and where: `CONTEXT.md`, ADRs (`docs/adr/` or similar), `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, and the formatter, linter and type-checker configs (agents skip what tooling enforces).
5. **Select the lenses.** Go down the roster and decide each lens from what the diff actually changes, not from what the feature type usually involves. When unsure, select it: an agent that finds the lens doesn't apply says so cheaply, while a skipped lens can't report anything. Add any lenses the user forced.
6. **Announce the panel** in one message: the base, the diff size (files, lines added and removed), the ticket or spec found, each selected lens with the part of the diff that triggered it, and each skipped lens with why. Then dispatch without waiting. The user can ask for a skipped lens afterwards.

## Workflow

1. **Dispatch the panel.** Send every selected agent in a single message so they run in parallel. Each prompt carries the handoff below and nothing about other lenses' concerns; overlap is resolved at merge, not by narrowing agents up front.
2. **Collect the reports.** If an agent reports the lens doesn't apply, record that and move on. If an agent fails or returns something outside the contract, re-dispatch it once with the problem stated; if it fails again, list the lens as not reviewed.
3. **Check the findings.** For each finding, check its evidence against the code: the quoted lines exist at the location given, and the thing reported missing really is absent from the diff and the code around it. Drop findings that misquote the code, point at lines the change doesn't touch or affect, or report as missing something the change covers, and note how many you dropped. Don't upgrade, rewrite or add findings of your own.
4. **Merge.** When several lenses report the same underlying problem (for example correctness and security both flag an unchecked input), keep one finding at the highest severity given, list every lens that raised it, and combine their recommendations. Keep each lens's original ID so findings can be traced back.
5. **Write the report** (see Final report) and save it.

## Handoff contract

Each agent starts with no context but what you give it.

| Pass in | Expect back |
|---|---|
| The diff file path; the changed files; the commit list; the ticket and spec paths, or "none"; which standards files and tooling configs exist and where; the part of the diff that triggered this lens; any focus the user asked for | The report format in `assets/review-contract.md`: lens verdict, findings with ID, severity, confidence, location, evidence, problem and recommendation, and questions for the author |

## Decision points

- **Lens doesn't apply after all.** Accept it. Don't re-dispatch with instructions to find something.
- **A finding contradicts a decision recorded in an ADR, a documented standard or the ticket.** Keep it, but mark it as challenging a recorded decision so the author can reaffirm the decision rather than treat it as an oversight.
- **Lenses disagree** (for example performance wants a cache and design calls it speculative). Keep both findings and list the conflict under Conflicts in the report. Don't pick a winner; the author decides.
- **The diff is too large to review well** (roughly 1,500 changed lines or more, or several unrelated changes mixed together). Before dispatching, tell the user and offer to review it in parts: by commit, by directory or by concern. Continue as one review only if they ask.
- **The diff is mostly generated or vendored** (lockfiles, build output, snapshots, migrations generated by a tool). Leave those files out of the lenses' scope, say so in the panel announcement, and keep any hand-written changes in them in scope.

## Final report

Save to `<review-dir>/<name>.md`, then post the Verdict and Blockers sections in chat with the file path.

Open the report with a header: the base and its merge-base SHA, `HEAD`'s SHA and whether uncommitted changes were included, the pinned diff file, the ticket or spec reviewed against, and the date.

Then, result first:

1. **Verdict:** one of
   - **Ready to merge:** no blockers or majors.
   - **Ready with changes:** majors only. Each can be fixed where it is, without rethinking the approach.
   - **Not ready:** any blocker, or majors that need the approach reconsidered.

   Follow with one sentence on why, and the finding counts by severity.
2. **Blockers:** every blocker, in full.
3. **Major findings:** in full, grouped by file, or under "Missing from the change" when they report something absent.
4. **Minor findings:** one line each, with ID, location and recommendation.
5. **Questions for the author:** merged from every lens, deduplicated, each tagged with the lenses that asked it.
6. **Conflicts:** findings where lenses recommend opposite changes, side by side.
7. **Coverage:** a table of every lens in the roster: selected or skipped, why, the lens verdict, and finding counts. Include lenses that weren't reviewed, files left out of scope, and findings dropped at the check.
8. **Next step:** unless the verdict is Ready to merge, suggest fixing the findings, then re-running `/code-review` against the same base. For a ticket built with `implement-tdd`, findings that change behavior go back through it as new slices, test first. Don't edit the code or start any of these steps yourself.
