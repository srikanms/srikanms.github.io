<#
    Recursively counts tokens in every *.md file under a root folder
    and prints folder-level roll-ups.

    Usage:
        .\Count-Tokens.ps1               # current dir
        .\Count-Tokens.ps1 C:\docs\wiki  # explicit path
#>

[CmdletBinding()]
param(
    [string]$Root = 'C:\temp\src\euhb\Documentation'
)

$rootDir = (Resolve-Path $Root).Path.TrimEnd('\')

$totals = @{}          # [string]folder → [int]token-sum
$sep    = [IO.Path]::DirectorySeparatorChar

Get-ChildItem -Path $rootDir -Filter '*.md' -File -Recurse | ForEach-Object {

    # 1️⃣  run TokenCounter and grab the number at the end of the line
    $out = & TokenCounter $_.FullName
    if ($out -notmatch '(\d+)$') {
        Write-Warning "Could not parse output for $($_.FullName)"
        return
    }
    $tokens = [int]$Matches[1]

    # 2️⃣  add that count to every ancestor directory (inclusive)
    for ($dir = $_.Directory ; $dir ; $dir = $dir.Parent) {
        $path = $dir.FullName
        $totals[$path] = ($totals[$path] + $tokens)
        if ($path -eq $rootDir) { break }
    }
}

# ---------- print nicely ----------

$totals.GetEnumerator() |
    Sort-Object { $_.Key.Split($sep).Count } -Descending |
    ForEach-Object {
        $relative = $_.Key.Substring($rootDir.Length).TrimStart($sep)
        if ([string]::IsNullOrEmpty($relative)) { $relative = '.' }
        "{0,-60} {1,10:N0}" -f $relative, $_.Value
    }

if ($totals.ContainsKey($rootDir)) {
    "`nTOTAL tokens under '$Root': $($totals[$rootDir])" |
        Write-Host -ForegroundColor Cyan
} else {
    Write-Host 'No .md files found.' -ForegroundColor Yellow
}
