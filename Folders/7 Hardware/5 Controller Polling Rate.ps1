. $CommonScript

Ensure-Admin

Write-Host "Installing: Gamepadla . . ."
# download gamepadla
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Gamepadla.exe" -File "$env:TEMP\Gamepadla.exe"
# open gamepadla
Start-Process "$env:TEMP\Gamepadla.exe"
