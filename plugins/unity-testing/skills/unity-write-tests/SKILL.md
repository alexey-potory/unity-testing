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

After writing the test, run the narrowest matching selection through the shared utility:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner run --project . --platform EditMode --filter "Namespace.Fixture.TestName" --format minimal
```

On macOS or Linux, use the equivalent `sh <SKILL_DIR>/../../scripts/invoke-runner.sh ...` command. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

Switch to PlayMode when the test requires it. Plain `ok` is sufficient evidence of success; on JSON failure, diagnose from `status`, failed test details, and source before opening raw logs.

If the runner reports `unity_editor_not_found` or another Unity editor resolution failure, follow the custom Unity Editor path flow in the utility reference: ask the user for a custom Unity Hub Editor root or explicit executable path, validate it, then retry with `--editor-base`/`--editor` or persist the Hub root in project config.

Read the [Unity test patterns reference](../../references/test-patterns.json) when choosing assertions, structuring EditMode/PlayMode tests, or diagnosing common failures. For runner flags, configuration, artifacts, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
