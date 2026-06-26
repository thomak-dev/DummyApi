[CmdletBinding()]
param(
    [string]$Configuration = "Release",
    [string]$Platform = "x64",
    [string]$VsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$project = Join-Path $root "WindowsInstaller\WindowsInstaller.wapproj"

if (-not (Test-Path $VsWherePath)) {
    throw "vswhere.exe was not found at '$VsWherePath'."
}

$msbuild = & $VsWherePath `
    -latest `
    -products "*" `
    -requires Microsoft.Component.MSBuild `
    -find "MSBuild\Current\Bin\MSBuild.exe" |
    Select-Object -First 1

if (-not $msbuild) {
    throw "MSBuild.exe was not found. Install Visual Studio Build Tools with MSBuild."
}

& $msbuild $project `
    /restore `
    /t:Rebuild `
    /p:Configuration=$Configuration `
    /p:Platform=$Platform `
    /p:UapAppxPackageBuildMode=SideloadOnly `
    /p:GenerateAppInstallerFile=false `
    /nr:false `
    /v:minimal

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$package = Get-ChildItem (Join-Path $root "WindowsInstaller\AppPackages") -Recurse -Filter "*.msix" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $package) {
    throw "Build succeeded, but no MSIX package was found."
}

$package.FullName
