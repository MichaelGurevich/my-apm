# My APM packages

Six independently installable APM packages imported from [mattpocock/skills](https://github.com/mattpocock/skills) at commit [`3cca18b368ae95cdbdebbff572ccafa662551015`](https://github.com/mattpocock/skills/commit/3cca18b368ae95cdbdebbff572ccafa662551015) (upstream version `1.2.3`), except `grill-me`, which is the original standalone skill from commit [`a6bdfd9`](https://github.com/mattpocock/skills/tree/a6bdfd9/grill-me).

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

[plan](packages/plan/) is original to this repository, not imported from upstream. It refines a rough idea through a non-technical interview (`/ideation`), then writes it up as an idea brief (`/to-idea`), to run before `grill-me`.

[spec-review](packages/spec-review/) is also original to this repository. It reads a spec, picks the review lenses that apply (requirements, non-functional, security, privacy and compliance, architecture, operability, testing, delivery), runs one read-only agent per selected lens in parallel, and merges their findings into a single report with a readiness verdict, saved to `.scratch/<feature-slug>/spec-review.md`. It fits between `to-spec` and `to-tickets`.

[spec-revise](packages/spec-revise/), also original, acts on that report. It walks the user through each finding (accept, modify, decline or defer), writes the agreed changes into the spec at its source, records declined and deferred items in the spec so the next review doesn't re-raise them, and saves a revision log to `.scratch/<feature-slug>/spec-revision.md`.

[asdlc](packages/asdlc/) adds no skill of its own. Installing it pulls in `plan`, `design` and `tdd` from this repository's `main` branch on GitHub, so the bundle reflects only pushed changes. [design](packages/design/) is itself a bundle that pulls in `grill-me`, `to-spec`, `spec-review`, `spec-revise` and `to-tickets` the same way.

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

The repository's root `apm.yml` remains the existing project manifest. Each directory under `packages/` has its own `apm.yml` and one complete skill under `.apm/skills/<skill-name>/` (`plan` has two); all but `tdd`, `plan`, `spec-review` and `spec-revise` also carry the upstream MIT license and a provenance README, and `tdd` and `spec-review` add agents under `.apm/agents/`. This follows the [APM skill package layout](https://microsoft.github.io/apm/producer/author-primitives/skills/).

## Supporting skills and setup

Manifests declare the supporting skills needed by each workflow, pinned to the same upstream commit. Dependencies use upstream paths so each package can be installed independently, including before this repository is published.

For tracker-dependent workflows (`code-review`, `to-spec`, and `to-tickets`), run `/setup-matt-pocock-skills` in the consuming project before using them. It is included as a dependency; installation does not execute it. Skill workflows have been copied without executing them.
