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

The repository's root `apm.yml` remains the existing project manifest. Each directory under `packages/` has its own `apm.yml` and one complete skill under `.apm/skills/<skill-name>/`; all but `tdd` also carry the upstream MIT license and a provenance README, and `tdd` adds agents under `.apm/agents/`. This follows the [APM skill package layout](https://microsoft.github.io/apm/producer/author-primitives/skills/).

## Supporting skills and setup

Manifests declare the supporting skills needed by each workflow, pinned to the same upstream commit. Dependencies use upstream paths so each package can be installed independently, including before this repository is published.

For tracker-dependent workflows (`code-review`, `to-spec`, and `to-tickets`), run `/setup-matt-pocock-skills` in the consuming project before using them. It is included as a dependency; installation does not execute it. Skill workflows have been copied without executing them.
