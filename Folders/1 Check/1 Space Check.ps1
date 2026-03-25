. $CommonScript

Ensure-Admin

Write-Host "Maintain at least 10% free space"
$driveletter = $env:SystemDrive -replace ':', ''
$volume = Get-Volume $driveletter | Select-Object Size,SizeRemaining
$percentRemain = ($volume.SizeRemaining / $volume.Size) * 100
Write-Host "Free space =" "$($percentRemain.ToString().substring(0,4))%"
Write-Host ""
Write-Host "Disable BitLocker Encryption"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process diskmgmt.msc
Start-Process explorer shell:MyComputerFolder
control /name Microsoft.BitLockerDriveEncryption
