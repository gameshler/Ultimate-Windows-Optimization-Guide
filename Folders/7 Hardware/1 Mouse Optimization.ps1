. $CommonScript

Ensure-Admin

Write-Host "Installing: Mouse Movement Recorder . . ."
# download mouse movement recorder
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Mouse%20Movement%20Recorder.exe" -File "$env:TEMP\Mouse Movement Recorder.exe"
# open mouse movement recorder
Start-Process "$env:TEMP\Mouse Movement Recorder.exe"
Clear-Host
Write-Host "Mouse optimizations:"
Write-Host "-Keep dongle close to mouse"
Write-Host "-Disable angle snapping"
Write-Host "-Turn off motion sync"
Write-Host "-Set lowest debounce time"
Write-Host "-Use maximum polling rate"
Write-Host ""
Write-Host "Extreme polling may affect some PCs and game engines."
Write-Host ""
Write-Host "Set a comfortable DPI."
Write-Host "Increased DPI reduces pixel skipping and latency."
Write-Host "Suggested settings to reduce pixel skipping:"
Write-Host "-400dpi for 1080p"
Write-Host "-800dpi for 1440p"
Write-Host "-1600dpi for 4k"
Write-Host ""
Write-Host "To prevent mouse acceleration when gaming:"
Write-Host "-Enable raw input in games when possible"
Write-Host "-Set 6/11 and pointer precision off"
Write-Host "-Use 100% scaling"
Write-Host ""
Write-Host "Some game engines might override 100% scaling for 4K and higher resolutions."
Write-Host "This can occasionally occur on laptops of any resolution as well."
Write-Host "Scaling may need to manually be set 100% through Advanced Scaling Settings."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
