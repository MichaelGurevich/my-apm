---
name: spec-revise
description: Revise a spec from its spec-review report, by walking the user through each finding, agreeing the changes, and writing them into the spec. Use after spec-review, when the user wants to act on its findings.
argument-hint: "[spec-review report path]"
disable-model-invocation: true
---

# Spec Revise

## Role

You turn a `spec-review` report into a revised spec. The findings are claims from reviewers; the user is the spec's author and decides what changes. You walk them through the findings, draft each change, and once every decision is made you write the changes into the spec so it reads as one document, not a spec with patches attached. You don't re-review the spec or add findings of your own.

## Input

A `spec-review` report, passed as a path. If none is given, use the most recently modified `.scratch/*/spec-review.md` and tell the user which one. If there is none, or you can't read it, ask the user.

The report's header names the spec's source (a local path or a tracker issue) and the pinned copy that was reviewed. For a tracker issue, the issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Setup

1. **Read the report** in full: verdict, every finding, questions, conflicts and coverage.
2. **Read the spec at its source**, not the pinned copy.
3. **Check for drift.** If the source differs from the pinned copy, the spec changed after the review. Tell the user which findings touch the changed sections; findings there may already be fixed or may no longer apply. Agree whether to carry on or re-run `/spec-review` first.
4. **Read the project's language.** Read `CONTEXT.md` if it exists, and the ADRs in the area, so new spec text uses the domain's terms and respects settled decisions.
5. **Share the plan** in one message: how many findings by severity, and the order you'll take them in.

## Workflow

### 1. Triage

Take items in this order: blockers, conflicts, majors, questions, then minors. For every item except minors, one at a time:

1. Show the finding: its ID (and the other lenses that raised it), severity, the spec text it's about, and the problem, in your own short words.
2. Draft the change: the exact spec text to add or replace, and the section it goes in. For a question, propose the answer you'd recommend and the spec text that answer produces. For a conflict, lay out both sides and recommend one.
3. Ask for a decision:
   - **Accept:** use the draft.
   - **Modify:** the user changes the substance; redraft and confirm.
   - **Decline:** keep the spec as is. Ask for the reason in one sentence; it goes into the spec (see Recording decisions).
   - **Defer:** a real issue, but not settled now. Ask who owns it, if anyone.

If the user's answer to one item changes another (one decision often settles two findings), say so, update the other draft, and confirm it when you reach it rather than skipping it.

Minors come last, as one numbered list of one-line drafts. The user accepts all of them, or names the ones to decline, modify or defer.

The user can say "accept the rest as drafted" at any point. Then show every remaining draft in one list and get one confirmation before moving on.

### 2. Edit

Once every item has a decision, revise the spec in one pass:

- Put each change where it belongs in the spec's structure. A new requirement goes with its related requirements or user stories, not at the end.
- Rewrite surrounding text where a change makes it stale or contradictory. Don't leave the old text with the new one appended.
- Keep the spec's template and voice. For a `to-spec` spec, keep its sections, and keep file paths and code out of it.
- Change nothing that no decision covers. If an edit forces another change, raise it with the user first.

### 3. Recording decisions

Reviewers respect decisions the spec records with a rationale, so recording them is what stops the next review re-raising them.

- **Declined:** add the decision and the user's reason to the spec. Where it goes depends on what was declined: Implementation Decisions for a design choice, Out of Scope for a feature left out, Further Notes otherwise.
- **Deferred:** add it under an "Open questions" list in Further Notes, with its owner.

Don't cite finding IDs in the spec: they mean nothing outside this review. They go in the revision log.

### 4. Approve and publish

1. **Show the changes** before writing anything back: each changed section, old text then new, plus the decisions recorded. Get the user's approval, and redo any section they object to.
2. **Write the spec back.** For a local file, edit it in place. For a tracker issue, update the issue body, then add a comment summarizing the revision: findings accepted, declined and deferred, and a link to or copy of the revision log.
3. **Write the revision log** to `.scratch/<feature-slug>/spec-revision.md`, next to the report.

## Revision log

Save it so the next review and the user can trace each finding to what happened to it:

1. **Header:** the spec's source, the report revised from, and the date.
2. **Decisions:** a table with one row per finding: ID, severity, title, decision (accepted, modified, declined, deferred), and a one-line note on the change made or the reason given.
3. **Sections changed:** the spec sections edited.
4. **Follow-ups:** deferred items with owners, and anything raised during triage that the review didn't cover.

## Done criteria

Done when:

- Every finding, question and conflict in the report has a decision.
- The revised spec is written back to its source and the user has approved it.
- Every declined or deferred item is recorded in the spec.
- The revision log is saved.

If the user stops partway, write back only the changes already decided and approved, mark the rest as untriaged in the log, and say so.

Then report: the counts by decision, the sections changed, the log's path, and the next step: re-run `/spec-review` to confirm the verdict. Don't start it yourself.
