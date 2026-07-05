---
name: unity-run-tests
description: Use when running, validating, or diagnosing Unity Test Framework EditMode or PlayMode tests, including filtered test runs and Unity test failures.
---

# Unity Run Tests

Use the plugin launcher instead of launching Unity directly. On Windows:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner run --project . --platform EditMode --format minimal
```

On macOS or Linux, call `sh <SKILL_DIR>/../../scripts/invoke-runner.sh run --project . --platform EditMode --format minimal`. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

Default to EditMode. Use PlayMode only for runtime behavior such as MonoBehaviour lifecycle, frames, physics, scenes, or coroutines. Use `--platform All` only when both are required.

Run the narrowest useful selection:

```powershell
& $runner run --project . --platform EditMode --assembly Tiles.Tests --format minimal
& $runner run --project . --platform EditMode --category "Smoke;!Flaky" --format minimal
& $runner run --project . --platform EditMode --filter "MyFixture.MyTest" --format minimal
& $runner run --project . --platform EditMode --test-names "Namespace.Fixture.TestA;Namespace.Fixture.TestB" --format minimal
```

`run` already compiles the project. Do not run `doctor` or `compile-check` first by default. Compile errors occur before selectors are applied.

Read stdout first. Plain `ok` means success; do not inspect logs. For JSON output, treat `status` and `ok` as authoritative over the exit code. Report failed test names, messages, and file/line locations when present. Keep infrastructure statuses such as `compile_error`, `package_error`, `license_error`, `timeout`, and `unity_startup_error` distinct from assertion failures. Read raw logs only for `unknown_error`, `results_missing`, or `results_parse_error`, or when artifact inspection was requested.

If the runner reports `unity_editor_not_found` or another Unity editor resolution failure, follow the custom Unity Editor path flow in the utility reference: ask the user for a custom Unity Hub Editor root or explicit executable path, validate it, then retry with `--editor-base`/`--editor` or persist the Hub root in project config.

Use `--keep` only when artifacts must survive the run. If sandboxing blocks Unity Licensing, Package Manager, AppData, caches, or Unity Hub IPC, rerun with the required permission.

For all flags, configuration, output schemas, artifacts, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
