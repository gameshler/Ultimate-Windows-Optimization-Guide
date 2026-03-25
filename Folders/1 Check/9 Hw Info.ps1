. $CommonScript

Ensure-Admin

Write-Host "Installing: Hw Info . . ."
# download hwinfo
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Hw%20Info.exe" -File "$env:TEMP\Hw Info.exe"
# start hwinfo
Start-Process "$env:TEMP\Hw Info.exe"
