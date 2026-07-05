---
name: unity-check-compilation
description: Use when checking whether a Unity project compiles, isolating compiler errors, or validating compilation without running EditMode or PlayMode tests.
---

# Unity Check Compilation

Use the plugin launcher instead of launching Unity directly. On Windows:

```powershell
$runner = "<SKILL_DIR>\..\..\scripts\invoke-runner.ps1"
& $runner compile-check --project . --format minimal
```

On macOS or Linux, call `sh <SKILL_DIR>/../../scripts/invoke-runner.sh compile-check --project . --format minimal`. The first call downloads the pinned runner release and verifies its SHA-256 checksum.

`compile-check` compiles only. Do not pass test selectors such as `--platform`, `--filter`, `--category`, `--test-names`, or `--assembly`.

Do not run `doctor` first. Use it only when the runner reports that the Unity Editor cannot be resolved:

```powershell
& $runner doctor --project . --format minimal
```

Read stdout first. `ok` means compilation succeeded. On JSON output, treat `status` and `ok` as authoritative; report compiler diagnostics with file and line where available. Inspect raw logs only for `unknown_error` or when the JSON explicitly lacks usable diagnostics.

If sandboxing blocks the first download, Unity Licensing, Package Manager, user caches, or Unity Hub IPC, rerun with the required permission.

For configuration, uncommon flags, artifact handling, and edge cases, read the [complete utility reference](../../references/UTILITY_USAGE.md).
