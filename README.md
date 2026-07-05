# Unity Testing Codex Marketplace

Codex plugin for checking Unity compilation, running targeted EditMode or PlayMode tests, and writing focused Unity tests.

## Install

```text
codex plugin marketplace add alexey-potory/unity-testing --ref main
codex plugin add unity-testing@alexey-potory
```

Start a new Codex thread after installation. The first compile or test run downloads the pinned `unity-test-runner` release, verifies its SHA-256 checksum, and caches it outside the plugin directory.

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

## License

MIT. Lucide icons retain their ISC license in `plugins/unity-testing/assets/LICENSE-lucide.txt`.
