# wayfinder

APM package for Matt Pocock's `wayfinder` skill. Invoke it as `/wayfinder` after installation.

Source: [mattpocock/skills](https://github.com/mattpocock/skills/tree/3cca18b368ae95cdbdebbff572ccafa662551015/skills/engineering/wayfinder).

Imported from upstream version `1.2.3`, commit `3cca18b368ae95cdbdebbff572ccafa662551015`. Package version `0.1.0` tracks this packaging separately.

The complete upstream skill directory is preserved byte-for-byte under `.apm/skills/wayfinder/`, including any agent metadata, templates, and reference files. The APM manifest, this README, and the upstream MIT license are packaging additions.

## Install

From a consuming project, use the local package path:

```powershell
apm install C:/Coding/my-apm/packages/wayfinder
```

Once this package is committed and pushed to the repository:

```sh
apm install MichaelGurevich/my-apm/packages/wayfinder
```

## Dependencies

APM installs these supporting upstream skills, pinned to the same commit:

- `setup-matt-pocock-skills`
- `grilling`
- `domain-modeling`
- `research`
- `prototype`

Before using tracker-dependent workflows, invoke `/setup-matt-pocock-skills` in the consuming project to configure its tracker and labels. Installing the dependency does not run setup.
