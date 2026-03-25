. $CommonScript

Ensure-Admin

Write-Host "Installing: Furmark . . ."
# download furmark
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Furmark.zip" -File "$env:TEMP\Furmark.zip"
# extract files
Expand-Archive "$env:TEMP\Furmark.zip" -DestinationPath "$env:TEMP\Furmark" -ErrorAction SilentlyContinue
# start furmark
Start-Process "$env:TEMP\Furmark\Furmark.exe"
Clear-Host
Write-Host "Run a basic GPU stress test."
Write-Host ""
Write-Host "Basic troubleshooting items to monitor:"
Write-Host "-Temps"
Write-Host "-Framerate"
Write-Host "-Artifacts"
Write-Host "-Freezing"
Write-Host "-Driver crashes"
Write-Host "-Shutdowns"
Write-Host "-Blue screens"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
