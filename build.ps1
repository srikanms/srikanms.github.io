<#
  Rebuilds *all* *.csproj below the repo root,
  publishes them, then copies each exe to %USERPROFILE%\bin
#>

$publishDir = "$PSScriptRoot\_publish"
Remove-Item $publishDir -Recurse -ErrorAction SilentlyContinue
New-Item $publishDir -ItemType Directory | Out-Null

Get-ChildItem -Recurse -Filter *.csproj |
  ForEach-Object {
    dotnet publish $_.FullName -c Release | Write-Host
    $out = Join-Path $_.Directory.FullName "bin\Release\net8.0\win-x64\publish"
    Copy-Item "$out\*.exe" $publishDir -Force
  }

$target = "$env:USERPROFILE\bin"
if (!(Test-Path $target)) { New-Item $target -ItemType Directory | Out-Null }
Copy-Item "$publishDir\*.exe" $target -Force

Write-Host "Done!  Tools copied to $target"
