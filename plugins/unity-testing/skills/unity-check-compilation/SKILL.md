---
name: unity-check-compilation
description: Use when checking whether a Unity project compiles, isolating compiler errors, or validating compilation without running EditMode or PlayMode tests.
---

# Unity Check Compilation

Prefer the `unity_tests` MCP server for Unity validation. Before using the PowerShell/shared runner fallback, check whether the `unity_tests` MCP server is available in the active tool list/session.

Use `unity_compile_check` when compilation status is needed without running tests. Do not run `unity_doctor` first by default; the MCP tools are independent and there is no required sequence.

Use `format = "minimal-json"` by default unless detailed diagnostics are needed.

`unity_compile_check` compiles only. Do not pass test selectors such as platform, filter, category, test names, or assembly unless the MCP tool explicitly supports compilation scoping for that project.

Read the MCP output first. Treat `status` and `ok` as authoritative. Report compiler diagnostics with file and line where available. Ask for or inspect detailed diagnostics only when the minimal output is insufficient.

If the `unity_tests` MCP server is not available, or the tool call clearly fails because the server is missing/unreachable, fall back to the plugin launcher instead of launching Unity directly. On Windows:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner compile-check --project . --format minimal
```

On macOS or Linux, call `sh <SKILL_DIR>/../../scripts/invoke-runner.sh compile-check --project . --format minimal`. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

Fallback `compile-check` compiles only. Do not pass test selectors such as `--platform`, `--filter`, `--category`, `--test-names`, or `--assembly`.

Use diagnostics only when needed. If MCP is available and editor/project diagnostics or the Unity Editor version are needed, call `unity_doctor`. If MCP is unavailable and the fallback runner reports that the Unity Editor cannot be resolved, use:

```powershell
& $runner doctor --project . --format minimal
```

For fallback output, read stdout first. `ok` means compilation succeeded. On JSON output, treat `status` and `ok` as authoritative; report compiler diagnostics with file and line where available. Inspect raw logs only for `unknown_error` or when the JSON explicitly lacks usable diagnostics.

If MCP or the fallback runner reports `unity_editor_not_found` or another Unity editor resolution failure, follow the custom Unity Editor path flow in the utility reference: ask the user for a custom Unity Hub Editor root or explicit executable path, validate it, then retry with `--editor-base`/`--editor` or persist the Hub root in project config.

If sandboxing blocks the first download, Unity Licensing, Package Manager, user caches, or Unity Hub IPC, rerun with the required permission.

For fallback configuration, uncommon flags, artifact handling, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
