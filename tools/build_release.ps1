[CmdletBinding()]
param(
    [string]$Version = '1.0.0',
    [string]$OutputDirectory = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\')
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $root 'dist'
}
$output = [System.IO.Path]::GetFullPath($OutputDirectory).TrimEnd('\')
$stageBase = Join-Path $root 'work\release-staging'
$stage = Join-Path $stageBase "LOTM-English-Patch-$Version"

python (Join-Path $root 'tools\sync_patch_package.py')
if ($LASTEXITCODE -ne 0) { throw 'Package synchronization failed.' }
python -m compileall -q (Join-Path $root 'tools') (Join-Path $root 'tests')
if ($LASTEXITCODE -ne 0) { throw 'Python compilation failed.' }
dotnet build (Join-Path $root 'tools\iostore_inventory\iostore_inventory.csproj') --configuration Release --nologo -p:RestoreLockedMode=true
if ($LASTEXITCODE -ne 0) { throw 'Tool build failed.' }
python -m unittest discover -s (Join-Path $root 'tests') -v
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }

$release = Get-Content -LiteralPath (Join-Path $root 'patch\assets\release.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$release.display_version -ne $Version) {
    throw "Manifest version $($release.display_version) does not match requested version $Version."
}

$stageFull = [System.IO.Path]::GetFullPath($stage)
$stageBaseFull = [System.IO.Path]::GetFullPath($stageBase).TrimEnd('\')
if (-not $stageFull.StartsWith($stageBaseFull + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Unsafe staging path.'
}
if (Test-Path -LiteralPath $stageFull) {
    Remove-Item -LiteralPath $stageFull -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $stageFull | Out-Null
Get-ChildItem -LiteralPath (Join-Path $root 'patch') | Copy-Item -Destination $stageFull -Recurse -Force
Copy-Item -LiteralPath (Join-Path $root 'LICENSE') -Destination $stageFull -Force
Copy-Item -LiteralPath (Join-Path $root 'THIRD_PARTY_NOTICES.md') -Destination $stageFull -Force

New-Item -ItemType Directory -Force -Path $output | Out-Null
$archive = Join-Path $output "LOTM-English-Patch-$Version.zip"
if (Test-Path -LiteralPath $archive) {
    Remove-Item -LiteralPath $archive -Force
}
Compress-Archive -Path $stageFull -DestinationPath $archive -CompressionLevel Optimal
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -LiteralPath ($archive + '.sha256') -Value "$hash  $([System.IO.Path]::GetFileName($archive))" -Encoding ASCII
Write-Host $archive
Write-Host $hash
