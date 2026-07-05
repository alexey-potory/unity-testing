# Unity Testing Codex Marketplace

Codex plugin for MCP-first Unity diagnostics, compilation checks, targeted EditMode or PlayMode test runs, and focused Unity test authoring.

## Install

```text
codex plugin marketplace add alexey-potory/unity-testing --ref main
codex plugin add unity-testing@alexey-potory
```

Start a new Codex thread after installation. When the `unity_tests` MCP server is available, the Unity skills use it first for diagnostics, compilation checks, and test runs. If MCP is unavailable, the first fallback compile or test run downloads the pinned `unity-test-runner` release, verifies its SHA-256 checksum, and caches it outside the plugin directory.

## Skills

The plugin registers skills from `plugins/unity-testing/.codex-plugin/plugin.json` through the directory pointer:

```json
"skills": "./skills/"
```

Skill directories currently shipped by the package:

- `unity-mcp`: MCP-first Unity validation using `unity_doctor`, `unity_compile_check`, and `unity_run_tests`.
- `unity-check-compilation`: compile-only validation; prefers `unity_compile_check`, then falls back to the shared runner.
- `unity-run-tests`: targeted Unity Test Framework runs; prefers `unity_run_tests`, then falls back to the shared runner.
- `unity-write-tests`: focused NUnit/Unity Test Framework test authoring with MCP-first validation.

The MCP tools are independent. Choose `unity_doctor` for diagnostics or the Unity Editor version, `unity_compile_check` for compilation only, and `unity_run_tests` for test results. Use `format = "minimal-json"` by default unless detailed diagnostics are needed.

## Configure Unity editor roots

The fallback runner searches Unity Hub editor roots from `config/default.toml`. If Unity is installed outside the defaults, add the Hub `Editor` root, not a project-specific override.

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
- `plugins/unity-testing/.codex-plugin/plugin.json`: plugin metadata and `./skills/` registration pointer
- `plugins/unity-testing/skills`: individual skill packages, including `unity-mcp`
- `tests/launcher-contract.ps1`: package, launcher, and skill registration contract check

## Validate

```powershell
& .\tests\launcher-contract.ps1
```
