# Carousel Studio installer: adds Desktop and Start menu shortcuts that open the program
# in its own app window (Microsoft Edge or Google Chrome, no address bar).
# Run with -Uninstall to remove the shortcuts. Nothing outside the two shortcuts is changed.
param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$name     = 'Carousel Studio'
$desktop  = [Environment]::GetFolderPath('Desktop')
$programs = [Environment]::GetFolderPath('Programs')
$links    = @((Join-Path $desktop "$name.lnk"), (Join-Path $programs "$name.lnk"))

if ($Uninstall) {
    foreach ($l in $links) { if (Test-Path $l) { Remove-Item $l -Force -Confirm:$false } }
    Write-Host "Removed the $name shortcuts."
    return
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $here 'Carousel-Studio.html'
$icon = Join-Path $here 'icon.ico'
if (-not (Test-Path $html)) { throw "Carousel-Studio.html was not found next to install.ps1" }

$browsers = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$browser = $browsers | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $browser) { throw "Microsoft Edge or Google Chrome is required." }

$url   = ([System.Uri]$html).AbsoluteUri
$shell = New-Object -ComObject WScript.Shell
foreach ($l in $links) {
    $s = $shell.CreateShortcut($l)
    $s.TargetPath       = $browser
    $s.Arguments        = "--app=`"$url`" --start-maximized"
    $s.WindowStyle      = 3
    $s.WorkingDirectory = $here
    $s.IconLocation     = "$icon,0"
    $s.Description      = 'AI carousel content for Facebook posts and ads'
    $s.Save()
}
Write-Host "Installed: $name shortcuts on the Desktop and in the Start menu."
Write-Host "Browser: $browser"
