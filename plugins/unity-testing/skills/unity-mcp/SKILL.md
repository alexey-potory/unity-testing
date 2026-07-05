---
name: unity-mcp
description: Use this skill when working in a Unity project that has the unity_tests MCP server available, especially for Unity diagnostics, compilation checks, or EditMode/PlayMode test runs.
---

# Unity MCP Validation

Use the `unity_tests` MCP server for Unity checks when it is available. By default, check whether the `unity_tests` MCP server exists in the active tool list/session before falling back to PowerShell or shared runner commands.

The MCP tools are independent. Do not assume a required sequence.

Choose the tool based on the goal:

- Need diagnostics or the Unity Editor version: use `unity_doctor`.
- Need compilation only: use `unity_compile_check`.
- Need test results: use `unity_run_tests`.

Use `format = "minimal-json"` by default unless detailed diagnostics are needed.

Prefer targeted checks whenever possible. For tests, target the narrowest useful EditMode or PlayMode selection by platform, assembly, category, fixture, test name, or small set of test names. Avoid broad PlayMode tests unless the change requires runtime behavior such as MonoBehaviour lifecycle, frames, physics, scenes, or coroutines.

`unity_run_tests` compiles the project and runs tests. Do not call `unity_compile_check` first unless the user only asked for compilation or a separate compile-only result is useful.

Use `unity_doctor` for setup diagnostics, Unity/project environment issues, Unity Editor resolution problems, or when the Unity Editor version is explicitly requested. Do not run it before every compile or test run by default.

If the MCP server is missing, unavailable, or the tool call clearly fails because the server cannot be reached, fall back to the project’s PowerShell/shared runner workflow from the relevant Unity skill:

- For compilation-only validation, use the `unity-check-compilation` fallback flow.
- For test execution, use the `unity-run-tests` fallback flow.
- After writing tests, use the `unity-write-tests` validation guidance and then the narrowest available test run.

When reporting results, treat MCP `status` and `ok` as authoritative. Keep infrastructure failures such as `compile_error`, `package_error`, `license_error`, `timeout`, and `unity_startup_error` distinct from test assertion failures. Include failed test names, compiler diagnostics, messages, and file/line locations when available.
