. $CommonScript

Ensure-Admin

Write-Host "Installing: Gpu Z . . ."
# download gpuz
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Gpu%20Z.exe" -File "$env:TEMP\Gpu Z.exe"
# start gpuz
Start-Process "$env:TEMP\Gpu Z.exe"
Clear-Host
Write-Host "Check PCIe bus interface is at maximum."
Write-Host "Verify monitor cable is connected to the GPU."
Write-Host "Confirm GPU is in the top PCIe motherboard slot."
Write-Host "Running multiple graphics cards is not recommended."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
