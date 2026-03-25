. $CommonScript

Ensure-Admin

    Write-Host "1. Registry: USB overclock with Secure Boot"
    Write-Host "2. Registry: Default"
	Write-Host "3. Overclock Controller"

    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-3]$') {
    switch ($choice) {
    1 {

Clear-Host
# usb overclock with secure boot regedit
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "WHQLSettings" /t REG_DWORD /d "1" /f | Out-Null
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    2 {

Clear-Host
# revert usb overclock with secure boot
cmd.exe /c "reg delete `"HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy`" /v `"WHQLSettings`" /f >nul 2>&1"
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    3 {

Clear-Host
Write-Host "If not using Option 1, disable Secure Boot in BIOS and delete Secure Boot keys . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
Write-Host "Installing: hidusbf . . ."
# download hidusbf
$result = Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/hidusbf.zip" -File "$env:TEMP\hidusbf.zip"
# extract files
Expand-Archive "$env:TEMP\hidusbf.zip" -DestinationPath "$env:TEMP\hidusbf" -ErrorAction SilentlyContinue
# start hidusbf
Start-Process "$env:TEMP\hidusbf\setup.exe"
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-3)." } }
