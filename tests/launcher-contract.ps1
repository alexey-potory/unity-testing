$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
$plugin = Join-Path $root "plugins/unity-testing"
$pluginJsonPath = Join-Path $plugin ".codex-plugin/plugin.json"
$skillsRoot = Join-Path $plugin "skills"
$releasePath = Join-Path $plugin "config/runner-release.json"
$powershellLauncher = Join-Path $plugin "scripts/invoke-runner.ps1"
$shellLauncher = Join-Path $plugin "scripts/invoke-runner.sh"

foreach ($path in @($pluginJsonPath, $skillsRoot, $releasePath, $powershellLauncher, $shellLauncher)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing package file: $path"
    }
}

$pluginJson = Get-Content -Raw $pluginJsonPath | ConvertFrom-Json
if ($pluginJson.skills -ne "./skills/") {
    throw "plugin.json must register skills through ./skills/, found: $($pluginJson.skills)"
}

$expectedSkills = @(
    "unity-check-compilation",
    "unity-mcp",
    "unity-run-tests",
    "unity-write-tests"
)

$actualSkills = Get-ChildItem -LiteralPath $skillsRoot -Directory | Select-Object -ExpandProperty Name | Sort-Object
$missingSkills = $expectedSkills | Where-Object { $actualSkills -notcontains $_ }
if ($missingSkills) {
    throw "Missing skill directories: $($missingSkills -join ', ')"
}

foreach ($skill in $expectedSkills) {
    $skillDir = Join-Path $skillsRoot $skill
    $skillMarkdown = Join-Path $skillDir "SKILL.md"
    $agentYaml = Join-Path $skillDir "agents/openai.yaml"
    $assetDir = Join-Path $skillDir "assets"

    foreach ($path in @($skillMarkdown, $agentYaml, $assetDir)) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Missing required skill file for ${skill}: $path"
        }
    }

    $skillText = Get-Content -Raw $skillMarkdown
    if ($skillText -notmatch "(?m)^name:\s+$([regex]::Escape($skill))\s*$") {
        throw "SKILL.md name does not match directory: $skill"
    }

    $agentText = Get-Content -Raw $agentYaml
    $promptSkillPattern = [regex]::Escape('$' + $skill)
    if ($agentText -notmatch "default_prompt:" -or $agentText -notmatch $promptSkillPattern) {
        throw "agents/openai.yaml must include a default_prompt referencing `$${skill}"
    }

    if (-not (Get-ChildItem -LiteralPath $assetDir -Filter "*.svg" -File)) {
        throw "Skill must include at least one SVG asset: $skill"
    }
}

$release = Get-Content -Raw $releasePath | ConvertFrom-Json
$expectedAssets = @(
    "unity-test-runner-windows-x86_64.exe",
    "unity-test-runner-linux-x86_64",
    "unity-test-runner-macos-x86_64",
    "unity-test-runner-macos-aarch64"
)
foreach ($asset in $expectedAssets) {
    if ($release.assets.PSObject.Properties.Value -notcontains $asset) {
        throw "Missing release asset mapping: $asset"
    }
}

$psText = Get-Content -Raw $powershellLauncher
if ($psText -notmatch "Get-FileHash" -or $psText -notmatch "Invoke-WebRequest") {
    throw "PowerShell launcher must download and verify SHA-256"
}

$shText = Get-Content -Raw $shellLauncher
if ($shText -notmatch "curl" -or $shText -notmatch "sha256") {
    throw "Unix launcher must download and verify SHA-256"
}

if (Get-ChildItem -Recurse $plugin -Filter "*.exe") {
    throw "Plugin repository must not contain an executable"
}

"launcher-contract=ok"
