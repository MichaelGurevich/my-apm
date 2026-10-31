---
name: spec-review
description: Review a spec through the lenses that apply to it (requirements, NFRs, security, privacy, architecture, operability, testing, delivery), one agent per lens, and merge their findings into one report. Use when the user wants a spec reviewed before it is broken into tickets.
argument-hint: "[spec path, issue number or URL] [lenses to force, or \"all\"]"
disable-model-invocation: true
---

# Spec Review

## Role

You review one spec by coordinating a panel of lens agents. You read the spec, decide which lenses apply, dispatch one agent per selected lens with the Agent tool, then merge their findings into a single report. You don't review the spec yourself, beyond the reading needed to choose lenses and check findings. A lens you review in the main thread skips the contract its agent follows.

## Input

One spec: a local Markdown file, or a tracker issue in the format `to-spec` publishes, passed as a path, issue number or URL. If no spec is given, or you can't read the one given, ask the user.

Optionally, lens names to force on (for example `security privacy`), or `all` to run every lens. Forced lenses are added to the ones you select, not used in their place.

## Roster

| Lens | Agent | Reviews | Select when the spec... |
|---|---|---|---|
| Requirements | `spec-review-functional` | Completeness, ambiguity, consistency, testability, scope, traceability | Always. |
| Non-functional | `spec-review-nfr` | Performance, scalability, reliability, usability, accessibility, i18n, compatibility | Has users, load, latency, uptime, UI or multiple platforms. Skip for internal tooling or docs-only changes with none of these. |
| Security | `spec-review-security` | Authn/authz, threat model, input handling, secrets, abuse, new dependencies | Touches auth, permissions, user input, external calls, network exposure, secrets, files, payments or new third-party code. |
| Privacy & compliance | `spec-review-privacy` | PII, retention, consent, regulation, licensing | Stores, moves, logs or shows data about people, or names a regulated domain (health, finance, children, EU users). |
| Architecture | `spec-review-architecture` | Fit with the codebase, alternatives, boundaries, data model, API contracts, concurrency | Adds or changes modules, services, schemas, APIs, events or shared state. |
| Operability | `spec-review-operability` | Observability, rollout, rollback, migration, configuration, support | Ships to a running environment, or changes data, infrastructure or config that live systems depend on. |
| Testing | `spec-review-testing` | Testing decisions, seams, coverage of acceptance criteria, test data | Describes behavior to implement. Skip only for specs with nothing to test. |
| Delivery | `spec-review-delivery` | Dependencies, risks, assumptions, cost, success metrics, open questions | Depends on other teams, vendors or paid services, carries a deadline, or claims a business outcome. |

## Setup

1. **Read the spec**: its full body, and its comments if it's a tracker issue.
2. **Pin the spec to a file.** Lens agents read files; they can't reach the tracker. For a local file, use its path. For a tracker issue, write the body and comments verbatim to `.scratch/<feature-slug>/spec.md` and use that path. Every agent reviews the same text.
3. **Read the project's language.** Note whether `CONTEXT.md` and ADRs exist (`docs/adr/` or similar), so you can point agents at them.
4. **Select the lenses.** Go down the roster and decide each lens from what the spec actually says, not from what the feature type usually involves. When unsure, select it: an agent that finds the lens doesn't apply says so cheaply, while a skipped lens can't report anything. Add any lenses the user forced.
5. **Announce the panel** in one message: each selected lens with the spec content that triggered it, and each skipped lens with why. Then dispatch without waiting. The user can ask for a skipped lens afterwards.

## Workflow

1. **Dispatch the panel.** Send every selected agent in a single message so they run in parallel. Each prompt carries the handoff below and nothing about other lenses' concerns; overlap is resolved at merge, not by narrowing agents up front.
2. **Collect the reports.** If an agent reports the lens doesn't apply, record that and move on. If an agent fails or returns something outside the contract, re-dispatch it once with the problem stated; if it fails again, list the lens as not reviewed.
3. **Check the findings.** For each finding, check its evidence against the spec: the quoted text exists, or the thing reported missing really is absent. Drop findings that misquote the spec or report as missing something the spec covers, and note how many you dropped. Don't upgrade, rewrite or add findings of your own.
4. **Merge.** When several lenses report the same underlying problem (for example security and privacy both flag unencrypted PII), keep one finding at the highest severity given, list every lens that raised it, and combine their recommendations. Keep each lens's original ID so findings can be traced back.
5. **Write the report** (see Final report) and save it.

## Handoff contract

Each agent starts with no context but what you give it.

| Pass in | Expect back |
|---|---|
| The spec file path; the feature name; whether `CONTEXT.md` and ADRs exist and where; the spec content that triggered this lens; any focus the user asked for | The report format in `assets/review-contract.md`: lens verdict, findings with ID, severity, location, evidence, problem and recommendation, and questions for the author |

## Decision points

- **Lens doesn't apply after all.** Accept it. Don't re-dispatch with instructions to find something.
- **A finding contradicts a decision recorded in an ADR or in the spec's own rationale.** Keep it, but mark it as challenging a recorded decision so the author can reaffirm the decision rather than treat it as an oversight.
- **Lenses disagree** (for example operability wants a feature flag and delivery calls it scope creep). Keep both findings and list the conflict under Conflicts in the report. Don't pick a winner; the author decides.
- **The spec is too thin to review** (no requirements, only a title or a paragraph). Stop before dispatching and tell the user. Suggest `grill-me` and `to-spec` first.

## Final report

Save to `.scratch/<feature-slug>/spec-review.md`, then post the Verdict and Blockers sections in chat with the file path.

Open the report with a header: the spec's source (the path, or the issue number and URL), the pinned file the agents reviewed, and the date. `spec-revise` uses it to find the spec.

Then, result first:

1. **Verdict:** one of
   - **Ready:** no blockers or majors.
   - **Ready with changes:** majors only. Each can be fixed by editing the spec, without reopening the design.
   - **Not ready:** any blocker, or majors that need design decisions the spec doesn't make.

   Follow with one sentence on why, and the finding counts by severity.
2. **Blockers:** every blocker, in full.
3. **Major findings:** in full, grouped by spec section, or under "Missing from the spec" when they report something absent.
4. **Minor findings:** one line each, with ID and recommendation.
5. **Questions for the author:** merged from every lens, deduplicated, each tagged with the lenses that asked it.
6. **Conflicts:** findings where lenses recommend opposite changes, side by side.
7. **Coverage:** a table of every lens in the roster: selected or skipped, why, the lens verdict, and finding counts. Include lenses that weren't reviewed and findings dropped at the check.
8. **Next step:** unless the verdict is Ready, suggest `/spec-revise` to work through the findings, then re-run `/spec-review`. Once the verdict is Ready, suggest `to-tickets`. Don't edit the spec or start any of these steps yourself.
