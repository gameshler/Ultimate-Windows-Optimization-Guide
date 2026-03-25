. $CommonScript

Ensure-Admin

Write-Host "Installing: Direct X . . ."
# download direct x
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"
# download 7zip
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7 Zip.exe" -File "$env:TEMP\7 Zip.exe"
# install 7zip
Start-Process -wait "$env:TEMP\7 Zip.exe" /S
# extract files with 7zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null
# install direct x
Start-Process "$env:TEMP\DirectX\DXSETUP.exe"
