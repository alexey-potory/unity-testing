---
name: unity-write-tests
description: Use when adding, updating, or reviewing Unity Test Framework tests for C# gameplay, editor tooling, MonoBehaviour lifecycle, scenes, physics, or coroutine behavior.
---

# Unity Write Tests

Inspect the code under test, every caller affected by the behavior, existing test assemblies, and nearby test style before editing.

Choose the cheapest mode that can observe the behavior:

- EditMode for pure C#, editor code, serialization, and logic that does not need frames or player execution.
- PlayMode for MonoBehaviour lifecycle, frames, physics, scenes, coroutines, and runtime-only integration.

Write the smallest focused test that proves the requested behavior. Follow the project's existing NUnit/Unity Test Framework API and naming style. Keep arrange, act, and assert obvious; compare floating-point values with a tolerance; explicitly expect intentional logs; clean up created Unity objects and modified global state.

Prefer `[Test]` for synchronous behavior. Use `[UnityTest]` returning `IEnumerator` only when the assertion genuinely depends on a frame or asynchronous Unity operation. Avoid arbitrary time delays when a deterministic frame, condition, or operation completion can be awaited.

Reuse an existing test asmdef when its references and platform constraints fit. Create or change an asmdef only when the test cannot compile in an existing test assembly.

After writing the test, validate through the `unity_tests` MCP server when it is available. Before using the PowerShell/shared runner fallback, check whether the `unity_tests` MCP server is available in the active tool list/session.

Use `unity_run_tests` for the narrowest matching test selection. It compiles the project and runs Unity tests, so do not run `unity_doctor` or `unity_compile_check` first by default. The MCP tools are independent and there is no required sequence.

Use `format = "minimal-json"` by default unless detailed diagnostics are needed.

Prefer targeted EditMode validation. Switch to PlayMode only when the test requires runtime behavior such as MonoBehaviour lifecycle, frames, physics, scenes, or coroutines. Avoid broad PlayMode tests unless the change requires them.

If the `unity_tests` MCP server is not available, or the tool call clearly fails because the server is missing/unreachable, fall back to the shared utility:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner run --project . --platform EditMode --filter "Namespace.Fixture.TestName" --format minimal
```

On macOS or Linux, use the equivalent `sh <SKILL_DIR>/../../scripts/invoke-runner.sh ...` command. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

For validation output, plain `ok` is sufficient evidence of success. On JSON failure, diagnose from `status`, failed test details, and source before opening raw logs.

If MCP or the fallback runner reports `unity_editor_not_found` or another Unity editor resolution failure, use diagnostics (`unity_doctor` when MCP is available; otherwise fallback `doctor`) and follow the custom Unity Editor path flow in the utility reference: ask the user for a custom Unity Hub Editor root or explicit executable path, validate it, then retry with `--editor-base`/`--editor` or persist the Hub root in project config.

Read the [Unity test patterns reference](../../references/test-patterns.json) when choosing assertions, structuring EditMode/PlayMode tests, or diagnosing common failures. For fallback runner flags, configuration, artifacts, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
