. $CommonScript

Ensure-Admin

Write-Host "Installing: AMD Driver . . ."
# download amd driver
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/AMD%20Driver.exe" -File "$env:TEMP\AMD Driver.exe"
# start amd driver installer
Start-Process "$env:TEMP\AMD Driver.exe" /S
