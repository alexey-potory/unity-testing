# Unity Testing Codex Marketplace

Codex plugin for checking Unity compilation, running targeted EditMode or PlayMode tests, and writing focused Unity tests.

## Install

```text
codex plugin marketplace add alexey-potory/unity-testing --ref main
codex plugin add unity-testing@alexey-potory
```

Start a new Codex thread after installation. The first compile or test run downloads the pinned `unity-test-runner` release, verifies its SHA-256 checksum, and caches it outside the plugin directory.

## Configure Unity editor roots

The runner searches Unity Hub editor roots from `config/default.toml`. If Unity is installed outside the defaults, add the Hub `Editor` root, not a project-specific override.

### Via Codex agent

Ask Codex:

```text
Use @unity-testing. Globally add Unity Hub Editor root <ROOT> to [unity].search_roots. Inspect invoke-runner.ps1 or invoke-runner.sh to find the plugin config/default.toml and the cached default.toml next to the runner binary. Preserve existing roots, do not edit project config. Validate the editor path for the version in ProjectSettings/ProjectVersion.txt, then run doctor --project . --format minimal without --editor-base.
```

Expected editor paths:

- Windows: `<ROOT>\<version>\Editor\Unity.exe`
- Linux: `<ROOT>/<version>/Editor/Unity`
- macOS: `<ROOT>/<version>/Unity.app/Contents/MacOS/Unity`

### Manually

1. Edit the plugin default config: `plugins/unity-testing/config/default.toml`.
2. Add the Hub `Editor` root to `[unity].search_roots`, keeping the existing entries.
3. If the runner is already cached, edit the copied config too:
   - Windows: `%LOCALAPPDATA%\unity-testing\runner\v<runner-version>\config\default.toml`
   - Linux/macOS: `${XDG_CACHE_HOME:-$HOME/.cache}/unity-testing/runner/v<runner-version>/config/default.toml`
4. Verify with the launcher:

```powershell
& plugins/unity-testing/scripts/invoke-runner.ps1 doctor --project . --format minimal
```

```sh
sh plugins/unity-testing/scripts/invoke-runner.sh doctor --project . --format minimal
```

## Supported runner platforms

- Windows x86-64
- Linux x86-64
- macOS x86-64
- macOS arm64

## Repository layout

- `.agents/plugins/marketplace.json`: Git-backed Codex marketplace catalog
- `plugins/unity-testing`: plugin package
- `tests/launcher-contract.ps1`: package and launcher contract check

## Validate

```powershell
& .\tests\launcher-contract.ps1
```
