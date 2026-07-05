[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]] $RunnerArgs
)

$ErrorActionPreference = "Stop"

$pluginRoot = Split-Path $PSScriptRoot -Parent
$release = Get-Content (Join-Path $pluginRoot "config/runner-release.json") -Raw |
    ConvertFrom-Json

$architecture = switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" { "x86_64" }
    "x86_64" { "x86_64" }
    default { throw "Unsupported Windows architecture: $env:PROCESSOR_ARCHITECTURE" }
}
$asset = $release.assets."windows-$architecture"
if (-not $asset) {
    throw "No runner release asset for windows-$architecture"
}

$tag = "v$($release.version)"
$baseUrl = "https://github.com/$($release.repository)/releases/download/$tag"
$versionRoot = Join-Path $env:LOCALAPPDATA "unity-testing/runner/$tag"
$binDir = Join-Path $versionRoot "bin"
$runner = Join-Path $binDir "unity-test-runner.exe"
$configDir = Join-Path $versionRoot "config"

New-Item $binDir, $configDir -ItemType Directory -Force | Out-Null

$sourceConfig = Join-Path $pluginRoot "config/default.toml"
$targetConfig = Join-Path $configDir "default.toml"

if (
    -not (Test-Path -LiteralPath $targetConfig) -or
    ((Get-FileHash -LiteralPath $sourceConfig -Algorithm SHA256).Hash -ne
     (Get-FileHash -LiteralPath $targetConfig -Algorithm SHA256).Hash)
) {
    Copy-Item $sourceConfig $targetConfig -Force
}

if (-not (Test-Path -LiteralPath $runner)) {
    $download = "$runner.$PID.download"
    $checksumDownload = "$download.sha256"
    try {
        Invoke-WebRequest -UseBasicParsing "$baseUrl/$asset" -OutFile $download
        Invoke-WebRequest -UseBasicParsing "$baseUrl/$asset.sha256" -OutFile $checksumDownload

        $expected = ((Get-Content -Raw $checksumDownload) -split "\s+")[0]
        $actual = (Get-FileHash $download -Algorithm SHA256).Hash
        if ($actual -ne $expected) {
            throw "SHA-256 mismatch for $asset"
        }

        Move-Item $download $runner -Force
    }
    finally {
        Remove-Item $download, $checksumDownload -ErrorAction SilentlyContinue
    }
}

& $runner @RunnerArgs
exit $LASTEXITCODE