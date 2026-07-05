---
name: unity-run-tests
description: Use when running, validating, or diagnosing Unity Test Framework EditMode or PlayMode tests, including filtered test runs and Unity test failures.
---

# Unity Run Tests

Prefer the `unity_tests` MCP server for Unity validation. Before using the PowerShell/shared runner fallback, check whether the `unity_tests` MCP server is available in the active tool list/session.

Use `unity_run_tests` when test results are needed. It compiles the project and runs Unity tests. Do not run `unity_doctor` or `unity_compile_check` first by default; the MCP tools are independent and there is no required sequence.

Use `format = "minimal-json"` by default unless detailed diagnostics are needed.

Default to EditMode. Use PlayMode only for runtime behavior such as MonoBehaviour lifecycle, frames, physics, scenes, or coroutines. Avoid broad PlayMode tests unless the change requires them. Use all tests only when both EditMode and PlayMode coverage are required.

Run the narrowest useful selection with `unity_run_tests` whenever possible: target a specific platform, assembly, category, fixture, test name, or small set of test names.

Read the MCP output first. Treat `status` and `ok` as authoritative. Report failed test names, messages, and file/line locations when present. Keep infrastructure statuses such as `compile_error`, `package_error`, `license_error`, `timeout`, and `unity_startup_error` distinct from assertion failures. Ask for or inspect detailed diagnostics only when the minimal output is insufficient.

If the `unity_tests` MCP server is not available, or the tool call clearly fails because the server is missing/unreachable, fall back to the plugin launcher instead of launching Unity directly. On Windows:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner run --project . --platform EditMode --format minimal
```

On macOS or Linux, call `sh <SKILL_DIR>/../../scripts/invoke-runner.sh run --project . --platform EditMode --format minimal`. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

Fallback examples for narrow selections:

```powershell
& $runner run --project . --platform EditMode --assembly Tiles.Tests --format minimal
& $runner run --project . --platform EditMode --category "Smoke;!Flaky" --format minimal
& $runner run --project . --platform EditMode --filter "MyFixture.MyTest" --format minimal
& $runner run --project . --platform EditMode --test-names "Namespace.Fixture.TestA;Namespace.Fixture.TestB" --format minimal
```

`run` already compiles the project. Do not run `doctor` or `compile-check` first by default. Compile errors occur before selectors are applied.

For fallback output, read stdout first. Plain `ok` means success; do not inspect logs. For JSON output, treat `status` and `ok` as authoritative over the exit code. Read raw logs only for `unknown_error`, `results_missing`, or `results_parse_error`, or when artifact inspection was requested.

If MCP or the fallback runner reports `unity_editor_not_found` or another Unity editor resolution failure, use diagnostics (`unity_doctor` when MCP is available; otherwise fallback `doctor`) and follow the custom Unity Editor path flow in the utility reference: ask the user for a custom Unity Hub Editor root or explicit executable path, validate it, then retry with `--editor-base`/`--editor` or persist the Hub root in project config.

Use `--keep` only when artifacts must survive the run. If sandboxing blocks Unity Licensing, Package Manager, AppData, caches, or Unity Hub IPC, rerun with the required permission.

For all fallback flags, configuration, output schemas, artifacts, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
