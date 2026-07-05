$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
$plugin = Join-Path $root "plugins/unity-testing"
$releasePath = Join-Path $plugin "config/runner-release.json"
$powershellLauncher = Join-Path $plugin "scripts/invoke-runner.ps1"
$shellLauncher = Join-Path $plugin "scripts/invoke-runner.sh"

foreach ($path in @($releasePath, $powershellLauncher, $shellLauncher)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing launcher file: $path"
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
