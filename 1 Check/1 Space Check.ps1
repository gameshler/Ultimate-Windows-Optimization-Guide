Write-Host "Maintain at least 10% free space"
$driveletter = $env:SystemDrive -replace ':', ''
$volume = Get-Volume $driveletter | Select-Object Size, SizeRemaining
$percentRemain = ($volume.SizeRemaining / $volume.Size) * 100
Write-Host "Free space =" "$($percentRemain.ToString().substring(0,4))%"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process explorer shell:MyComputerFolder
