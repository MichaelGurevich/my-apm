# Spec review contract

Every lens agent follows this contract. Your agent definition says what your lens covers; this file says how to review and what to report.

## Input

- The spec file path. Read the whole file, not only the sections that look like yours: requirements for your lens often sit in other sections.
- The feature name.
- Whether `CONTEXT.md` and ADRs exist, and where.
- The spec content that triggered your lens.
- Any focus the user asked for.

## Process

1. Read the spec end to end.
2. Read `CONTEXT.md` and the ADRs in the area, if they exist, so findings use the project's domain language and don't re-argue settled decisions unknowingly.
3. Read the codebase only where the spec makes a claim about it that your lens depends on: an existing module, API, schema, pattern or test. Check the claim and stop there. You review the spec, not the code.
4. Go through your lens's checklist. For each item, decide whether it applies to this spec. Skip items that don't apply without mentioning them.
5. Write findings for the gaps and defects you found, then reread each one against the rules below before reporting.

## Rules

- **Read only.** Never edit the spec or any other file.
- **Stay in your lens.** Leave other lenses' concerns to them, even when you notice them. The coordinator merges overlaps.
- **Every finding is anchored.** Either quote the spec text it is about, or state precisely what is missing and where it would belong. A finding with neither is an opinion; drop it.
- **Missing vs. wrong.** Say which one it is. "The spec says X, and X causes Y" and "The spec doesn't say what happens when Z" are different problems with different fixes.
- **Recommend a change to the spec, not to the code.** The recommendation is text the author could add or change in the spec: a requirement, a number, a decision, a constraint. Where the right answer is the author's call, give the options and file it as a question.
- **Proportionate.** Match the bar to the feature. A two-user internal tool doesn't need a 99.99% SLO; don't ask for one. Only call something missing when its absence would plausibly change what gets built, or how it gets tested or run.
- **No padding.** Five real findings beat fifteen generic ones. If your lens finds nothing, say so; an empty review is a valid result.
- **Respect recorded decisions.** If the spec or an ADR records a decision and its rationale, challenge it only with a concrete consequence the rationale didn't consider, and say that you're challenging a recorded decision.

## Severity

| Severity | Use when |
|---|---|
| **blocker** | Building the spec as written would ship a defect, security hole, data loss or compliance breach, or a core requirement can't be built or verified at all. |
| **major** | A gap or ambiguity that would likely cause rework, divergent implementations, or a production incident. |
| **minor** | Clarity, consistency or completeness polish. Builders would probably get it right anyway. |
| **question** | Something only the author can answer, that may or may not be a defect depending on the answer. |

When torn between two severities, pick the lower one and say what would raise it.

## Output

Report in exactly this shape.

```markdown
## Lens: <lens name>

**Verdict:** applies, no findings | applies, findings below | doesn't apply: <one sentence on why>

### Findings

#### <PREFIX>-<n>: <short title>
- **Severity:** blocker | major | minor | question
- **Kind:** wrong | missing | ambiguous | inconsistent
- **Location:** <spec section heading>, or "Missing: belongs in <section>"
- **Evidence:** "<exact quote from the spec>", or what is absent
- **Problem:** what goes wrong if the spec is built as written, in one to three sentences
- **Recommendation:** the concrete change to the spec
- **Challenges recorded decision:** yes, <where> (include only when it does)

### Questions for the author
1. <question>, and why the answer matters
```

Number findings from 1 using your lens prefix, most severe first. Leave out the Findings or Questions heading when it would be empty.
