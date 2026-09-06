# My APM packages

Ten independently installable APM packages imported from [mattpocock/skills](https://github.com/mattpocock/skills) at commit [`3cca18b368ae95cdbdebbff572ccafa662551015`](https://github.com/mattpocock/skills/commit/3cca18b368ae95cdbdebbff572ccafa662551015) (upstream version `1.2.3`).

| Package | Skill invocation |
| --- | --- |
| [grill-with-docs](packages/grill-with-docs/) | `/grill-with-docs` |
| [wayfinder](packages/wayfinder/) | `/wayfinder` |
| [code-review](packages/code-review/) | `/code-review` |
| [implement](packages/implement/) | `/implement` |
| [to-spec](packages/to-spec/) | `/to-spec` |
| [to-tickets](packages/to-tickets/) | `/to-tickets` |
| [wait-what](packages/wait-what/) | `/wait-what` |
| [wizard](packages/wizard/) | `/wizard` |
| [tdd](packages/tdd/) | `/tdd` |
| [prototype](packages/prototype/) | `/prototype` |

Package names match the upstream skill names. The upstream skill contents are preserved.

## Install a package

Run from the project where you want to use the skill:

```powershell
apm install C:/Coding/my-apm/packages/tdd
```

Replace `tdd` with any package name in the table. Once the packages are committed and pushed, they can also be installed from GitHub:

```sh
apm install MichaelGurevich/my-apm/packages/tdd
```

The repository's root `apm.yml` remains the existing project manifest. Each directory under `packages/` has its own `apm.yml`, upstream MIT license, provenance and installation README, and one complete skill under `.apm/skills/<upstream-name>/`. This follows the [APM skill package layout](https://microsoft.github.io/apm/producer/author-primitives/skills/).

## Supporting skills and setup

Manifests declare the supporting skills needed by each workflow, pinned to the same upstream commit. Dependencies use upstream paths so each package can be installed independently, including before this repository is published. For example, `grill-with-docs` brings in `grilling` and `domain-modeling`; `implement` brings in the upstream `tdd` and `code-review` skills and their supporting references/setup.

For tracker-dependent workflows (`wayfinder`, `code-review`, `implement`, `to-spec`, and `to-tickets`), run `/setup-matt-pocock-skills` in the consuming project before using them. It is included as a dependency; installation does not execute it. Skill workflows and the wizard's Bash template have been copied without executing them.
