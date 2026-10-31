# My APM packages

Five independently installable APM packages imported from [mattpocock/skills](https://github.com/mattpocock/skills) at commit [`3cca18b368ae95cdbdebbff572ccafa662551015`](https://github.com/mattpocock/skills/commit/3cca18b368ae95cdbdebbff572ccafa662551015) (upstream version `1.2.3`), except `grill-me`, which is the original standalone skill from commit [`a6bdfd9`](https://github.com/mattpocock/skills/tree/a6bdfd9/grill-me).

| Package | Skill invocation |
| --- | --- |
| [grill-me](packages/grill-me/) | `/grill-me` |
| [code-review](packages/code-review/) | `/code-review` |
| [to-spec](packages/to-spec/) | `/to-spec` |
| [to-tickets](packages/to-tickets/) | `/to-tickets` |
| [wait-what](packages/wait-what/) | `/wait-what` |
| [tdd](packages/tdd/) | `/implement-tdd` |
| [plan](packages/plan/) | `/ideation`, `/to-idea` |
| [spec-review](packages/spec-review/) | `/spec-review` |
| [spec-revise](packages/spec-revise/) | `/spec-revise` |
| [exercise](packages/exercise/) | `/exercise` |
| [verify](packages/verify/) | `/verify` |

[plan](packages/plan/) is original to this repository, not imported from upstream. It refines a rough idea through a non-technical interview (`/ideation`), then writes it up as an idea brief (`/to-idea`), to run before `grill-me`.

[spec-review](packages/spec-review/) is also original to this repository. It reads a spec, picks the review lenses that apply (requirements, non-functional, security, privacy and compliance, architecture, operability, testing, delivery), runs one read-only agent per selected lens in parallel, and merges their findings into a single report with a readiness verdict, saved to `.scratch/<feature-slug>/spec-review.md`. It fits between `to-spec` and `to-tickets`.

[spec-revise](packages/spec-revise/), also original, acts on that report. It walks the user through each finding (accept, modify, decline or defer), writes the agreed changes into the spec at its source, records declined and deferred items in the spec so the next review doesn't re-raise them, and saves a revision log to `.scratch/<feature-slug>/spec-revision.md`.

[code-review](packages/code-review/) is original too, replacing the upstream two-axis `code-review`, and applies the same panel model to code. It pins a change (commits and uncommitted work since a base ref) to a diff, finds the ticket or spec it implements, picks the lenses that apply (correctness, spec conformance, standards, design, tests, security, performance, operability), runs one read-only agent per selected lens in parallel, and merges their findings into a single report with a merge-readiness verdict, saved to `.scratch/<feature-slug>/code-review/`. The whole review is read-only: the lens agents have no write or shell tools, and a hook limits the coordinator to writing under `.scratch/` and running read-only `git` and `gh` queries. The upstream Standards and Spec axes live on as the standards lens (with its code-smell baseline) and the spec conformance lens. It runs after `implement-tdd`.

[exercise](packages/exercise/), also original, checks a built feature in the running app rather than through its tests. It reads the spec, finds how the app is launched, picks a driver (a browser, HTTP, the CLI or a script against a library's public API), plans one scenario per user journey and agrees the plan and environment with the user. It then launches the app and runs one agent per scenario, independent ones in parallel. Each agent works through the real interface, saves evidence for every step, probes a few variations nearby, and reports defects with steps to reproduce. The results merge into a report with a verdict, saved to `.scratch/<feature-slug>/exercise/`. A hook limits the coordinator and its agents to editing files under `.scratch/`. They need the shell to launch and drive the app, so their instructions, not the hook, keep them from changing code through it.

[verify](packages/verify/), also original, is the last check before shipping. `implement-tdd` proves each ticket on its own; `verify` checks the whole feature against its spec. It runs the full test suite once, then dispatches one read-only agent per ticket, which traces each acceptance criterion to the code that implements it and a test that would fail if it broke, and one for the spec, which traces each user story to its tickets and code, journeys that span tickets, the spec's testing decisions and its out-of-scope list. It joins the traces into a traceability matrix with a ship verdict, saved to `.scratch/<feature-slug>/verify/`. Criteria are identified as `T<NN>.<n>` and stories as `US<n>` in both `exercise` and `verify`, so a scenario `exercise` passed against the same commit counts as evidence for criteria no test covers. Like `exercise`, a hook limits its file edits to `.scratch/`.

[asdlc](packages/asdlc/) adds no skill of its own. Installing it pulls in `plan`, `design`, `build` and `test` from this repository's `main` branch on GitHub, so the bundle reflects only pushed changes. [design](packages/design/) is itself a bundle that pulls in `grill-me`, `to-spec`, `spec-review`, `spec-revise` and `to-tickets` the same way, [build](packages/build/) is a bundle that pulls in `tdd` and `code-review`, and [test](packages/test/) is a bundle that pulls in `exercise` and `verify`.

Package names match the upstream skill names. Upstream skill contents are preserved, except `tdd`, whose skill is renamed `implement-tdd` and rewritten as a coordinator for three `tdd-red`/`tdd-green`/`tdd-refactor` agents.

## Install a package

Run from the project where you want to use the skill:

```powershell
apm install C:/Coding/my-apm/packages/tdd
```

Replace `tdd` with any package name in the table. Once the packages are committed and pushed, they can also be installed from GitHub:

```sh
apm install MichaelGurevich/my-apm/packages/tdd
```

The repository's root `apm.yml` remains the existing project manifest. Each directory under `packages/` has its own `apm.yml`. The bundles (`asdlc`, `design`, `build` and `test`) hold nothing else; every other package has one complete skill under `.apm/skills/<skill-name>/` (`plan` has two). All but `tdd`, `code-review`, `plan`, `spec-review`, `spec-revise`, `exercise` and `verify` also carry the upstream MIT license and a provenance README, and `tdd`, `code-review`, `spec-review`, `exercise` and `verify` add agents under `.apm/agents/`. This follows the [APM skill package layout](https://microsoft.github.io/apm/producer/author-primitives/skills/).

## Supporting skills and setup

Manifests declare the supporting skills needed by each workflow, pinned to the same upstream commit. Dependencies use upstream paths so each package can be installed independently, including before this repository is published.

For tracker-dependent workflows (`to-spec` and `to-tickets`), run `/setup-matt-pocock-skills` in the consuming project before using them. It is included as a dependency; installation does not execute it. Skill workflows have been copied without executing them.
