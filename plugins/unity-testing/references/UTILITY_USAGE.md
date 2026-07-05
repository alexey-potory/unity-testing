# unity-test-runner utility usage reference

This file contains detailed option/reference guidance for `unity-test-runner.exe`. Keep `SKILL.md` short and use it for routing and normal operation; read this file only when a task needs uncommon flags, configuration details, artifact handling, sandbox guidance, or helper scripts.

## Executable and Unity resolution

Call the platform launcher; it downloads the pinned release on first use, verifies the release SHA-256 sidecar, and reuses the cached binary afterwards.

```powershell
<PLUGIN_ROOT>\scripts\invoke-runner.ps1
```

On macOS or Linux use `sh <PLUGIN_ROOT>/scripts/invoke-runner.sh`.

The utility resolves the Unity Editor executable by itself from the Unity project and configuration. It reads the project version, searches configured/default Unity Hub editor roots, builds the Unity command line, chooses artifact paths, and launches the correct Unity executable.

Do not manually search for `Unity.exe`, inspect Unity Hub directories, or call Unity directly before running tests. Use `--editor <path>` only when the user explicitly provides an editor path or when `doctor`/runner JSON reports that Unity editor resolution failed. Use `--editor-base <path>` only to add an extra Unity Hub editor search root.

### When the Unity Editor is not found

Trigger this flow only after `doctor`, `compile-check`, or `run` reports `unity_editor_not_found` or another explicit Unity editor resolution failure. Do not ask for a custom path before the utility has tried its configured search roots.

In an interactive Codex session, stop and ask one concise question. Prefer a directory that contains Unity Hub version folders, not the Unity executable itself. Example prompt:

```text
I couldn't find the Unity Editor version required by this project. Is Unity installed in a custom Unity Hub Editor root?

Reply with one of:
1. A Hub Editor root directory, e.g. D:\Unity\Hub\Editor, /Applications/Unity/Hub/Editor, /opt/unity/editors
2. A full Unity executable path, e.g. D:\Unity\Hub\Editor\2022.3.40f1\Editor\Unity.exe
3. "No" to stop here
```

If the user provides a Hub Editor root, validate the expected executable for the project version before changing config:

```text
<custom-root>/<m_EditorVersion>/<platform-executable-relative-path>
```

Platform executable relative paths are:

```text
Windows: Editor\Unity.exe
macOS:   Unity.app/Contents/MacOS/Unity
Linux:   Editor/Unity
```

For a one-off retry, pass `--editor-base <custom-root>` and rerun the original command. For a persistent project fix, update the project config instead. Prefer `.codex/unity-test-runner.toml` unless the repository already uses `unity-test-runner.toml`.

Important: a project config value for `[unity].search_roots` replaces the previous list rather than appending to it. When adding a custom root, preserve any existing project roots and the plugin defaults, then add the custom root once. Do not write only the custom root unless the user explicitly wants to restrict searches to that root.

Example persistent project config snippet:

```toml
[unity]
search_roots = [
  "D:\\Unity\\Hub\\Editor",
  "C:\\Program Files\\Unity\\Hub\\Editor",
  "%LOCALAPPDATA%\\Unity\\Hub\\Editor",
  "/Applications/Unity/Hub/Editor",
  "$HOME/Unity/Hub/Editor"
]
```

If the user provides a full Unity executable path instead of a Hub Editor root, prefer a one-off `--editor <path>` retry. Only persist `editor_executable` when the user asks for that exact executable to always be used for the project.

If download fails, report the release URL and diagnostic. Do not bypass checksum verification.

## Command behavior

```text
version        Show utility version and JSON schema version.
doctor         Resolve/check the Unity Editor executable path only; does not compile or run tests.
print-config   Print resolved configuration after CLI/project/default/built-in merge.
compile-check  Check whether the Unity project compiles; does not run tests.
run            Compile the project, run Unity Test Framework tests, classify status, and print output.
```

`doctor`, `compile-check`, and `run` are independent commands. `run` already compiles the project before running tests, so do not run `compile-check` before `run` unless the user asked for a compile-only check or you are deliberately isolating a compile failure.

## Common flags

These flags are available where the command supports them:

```text
--project <path>                       Unity project root. Default: current directory.
--editor <path>                        Explicit Unity.exe path; usually unnecessary because the utility resolves it.
--editor-base <path>                   Additional Unity Hub editor search root. Repeatable.
--config <path>                        Explicit TOML config path.
--format minimal|minimal-json|compact-json|pretty-json
                                       Output format. Prefer minimal unless full success JSON is needed.
--keep                                 Keep artifacts regardless of status.
--artifact-dir <path-or-template>      Artifact directory. Supports {temp}, {system_temp}, {project}, {project_hash}, {platform}.
--timeout <seconds>                    Override timeout.
--log-tail <lines>                     Override saved log-tail line count.
--dry-run                              Return planned command/artifact info without launching Unity.
--no-graphics                          Pass Unity -nographics.
--accept-apiupdate                     Pass Unity -accept-apiupdate.
--forget-project-path                  Pass Unity -forgetProjectPath.
--unity-arg <arg>                      Pass an extra raw Unity CLI argument. Repeat for multiple args.
--verbose, -v                          Write progress stages to stderr. Stdout must remain final output only.
--progress                             Enable progress logging.
--progress-file <path>                 Write progress stages to a file.
```

## `run` flags

`run` supports common flags plus test/player selection flags:

```text
--platform EditMode|PlayMode|All|both  Test platform. All/both runs EditMode and PlayMode sequentially and aggregates JSON.
--filter <test-filter>                 Unity -testFilter: names, full-name regex, semicolon list, and negation.
--category <categories>                Unity -testCategory: semicolon list and negation such as "Fast;!Flaky".
--test-names <names>                   Unity -testNames: semicolon-separated full test names.
--assembly <assembly>                  Unity -assemblyNames: semicolon-separated test assembly names, e.g. Tiles.Tests.
--assembly-type EditorOnly|EditorAndPlatforms
--requires-play-mode true|false        Unity -requiresPlayMode.
--run-synchronously                    Unity -runSynchronously; use only for simple EditMode tests.
--ordered-test-list <path>             Unity -orderedTestListFile.
--test-settings <path>                 Unity -testSettingsFile.
--player-heartbeat-timeout <seconds>   Unity -playerHeartbeatTimeout.
--build-player-path <path>             Unity -buildPlayerPath.
--build-target <name>                  Unity -buildTarget, e.g. StandaloneWindows64, Android.
```

Notes for filters:

- `--category` and `--filter` are applied after the project compiles. Compile errors happen before test filtering.
- If both category and filter are supplied, Unity runs only tests matching both.
- Use quotes around semicolon-separated values in PowerShell: `--category "Smoke;!Flaky"`.
- For an asmdef named `Tiles.Tests`, use `--assembly Tiles.Tests`.

Examples:

```powershell
& $runner run --project . --platform EditMode --assembly Tiles.Tests --format minimal
& $runner run --project . --platform EditMode --assembly Tiles.Tests --category Smoke --format minimal
& $runner run --project . --platform EditMode --filter "MyFixture.MyTest" --format minimal
& $runner run --project . --platform All --category Runner.Pass --format minimal --keep
```

## `compile-check` flags

`compile-check` supports infrastructure/output flags, not test-selection flags:

```text
--project <path>
--editor <path>
--editor-base <path>
--config <path>
--format minimal|minimal-json|compact-json|pretty-json
--keep
--artifact-dir <path-or-template>
--timeout <seconds>
--log-tail <lines>
--dry-run
--no-graphics
--accept-apiupdate
--forget-project-path
--unity-arg <arg>
--verbose, -v
--progress
--progress-file <path>
```

Do not pass test-only flags such as `--platform`, `--filter`, `--category`, `--test-names`, `--assembly`, `--assembly-type`, `--requires-play-mode`, `--run-synchronously`, `--ordered-test-list`, or `--test-settings` to `compile-check`.

## `doctor`, `print-config`, and `version`

Useful commands:

```powershell
& $runner version
& $runner doctor --project . --format minimal
& $runner print-config --project . --format pretty-json
```

`doctor` is only for resolving/checking the Unity Editor executable path for the project/configuration. It is not a mandatory preflight, does not check compilation, and does not run tests. Do not manually locate Unity first. Use `pretty-json` for `doctor` only when successful diagnostic details are needed.

`print-config` is normally used for inspection, so `pretty-json` is acceptable when the user needs the resolved configuration.

## Output format policy

Prefer `--format minimal` for normal `doctor`, `compile-check`, and `run` calls. Minimal output is the default routing choice because clean success should be as small as possible.

Expected minimal success output:

```text
ok
```

On failure, `minimal` must still print the same compact JSON diagnostics as `compact-json`, so failures remain machine-readable and actionable.

Use fuller output only when it is actually needed:

- Use `--format compact-json` when a successful run also needs full machine-readable summary/details.
- Use `--format pretty-json` when a human needs to inspect the full JSON manually.
- Do not request full success JSON/logs just to confirm that tests passed; `ok` is enough.

## Configuration

The utility is configured by TOML. Default plugin config:

```text
config/default.toml
```

Config resolution order:

```text
CLI args > project config > plugin default config > built-in defaults
```

Expected project config paths:

```text
.codex/unity-test-runner.toml
unity-test-runner.toml
```

The default config can contain Unity search roots, artifact paths, timeout, logging limits, diagnostic limits, and output preferences. Prefer `format = "minimal"` unless the project explicitly needs full success JSON.

## Reporting

Always read stdout first. With `--format minimal`, plain `ok` means the command succeeded and no full success JSON/log is needed. If stdout is JSON, parse it before doing anything else. Do not read raw Unity logs unless the utility reports `unknown_error`, `results_missing`, or `results_parse_error`, or unless artifact inspection is specifically needed.

Clean run with `--format minimal`:

```text
Unity tests passed.
```

If full success JSON was intentionally requested, include the richer summary:

```text
Unity tests passed: <passed>/<total>. Failed: 0, skipped: <skipped>. Duration: <duration>s.
```

Failed tests: report failed test name, message, file:line when available, and a concrete likely fix grounded in the failure message, stack trace, and source code.

Infrastructure/runtime errors: do not describe them as test assertion failures. Report `status`, top diagnostics, and artifact paths when useful.

Important statuses:

```text
passed
tests_failed
compile_error
unity_startup_error
package_error
license_error
timeout
results_missing
results_parse_error
unknown_error
runner_config_error
```

Exit codes are secondary. Prefer JSON `status` and `ok`:

```text
0 = passed / ok
1 = tests failed
2 = Unity/runtime/infrastructure error
3 = utility usage/config error
```

For `--platform All`, read aggregate top-level `status`, `summary`, and `runs[]` when stdout is JSON.

## Unity command-line behavior reflected by the utility

Unity Test Framework documents `-runTests`, `-testPlatform`, `-testResults`, `-testFilter`, `-testCategory`, `-assemblyNames`, `-testNames`, `-orderedTestListFile`, `-playerHeartbeatTimeout`, `-runSynchronously`, and `-testSettingsFile`. The utility exposes these as higher-level `run` flags and adds JSON/artifact classification.

Unity documents that `-runSynchronously` is only supported for EditMode tests and filters out multi-frame tests such as `[UnityTest]`; therefore do not add `--run-synchronously` by default and never use it for PlayMode unless the utility explicitly supports/ignores it safely.

## Sandbox

Unity and the utility normally need access outside the repo for Licensing, Package Manager, AppData, caches, and Unity Hub IPC. Run the utility with escalation when Codex asks for permission.

Suggested Codex execution settings:

```text
sandbox_permissions: require_escalated
justification: Allow unity-test-runner.exe to launch Unity and access Licensing, Package Manager, AppData, and caches while running tests.
prefix_rule: ["<PLUGIN_ROOT>\\scripts\\invoke-runner.ps1"]
```

If Unity fails with license, AppData, cache, Package Manager, or IPC access errors, rerun with escalation.

Read `references/test-patterns.json` only when writing new Unity tests, improving test structure, classifying failures, or explaining best-practice fixes. Do not read it for a simple clean test run.
