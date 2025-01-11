Write-Host "Disable: Internet . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# open device manager
Start-Process devmgmt.msc
Clear-Host
Write-Host "Press any key to continue . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
# copy key to clipboard
Set-Clipboard -Value "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
Write-Host "Enter: VK7JG-NPHTM-C97JM-9MPGT-3V66T (Or Paste From Clipboard) . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# create device manager shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Enable Internet.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Windows\System32\devmgmt.msc"
$Shortcut.Save()
# open activation screen
Start-Process slui.exe 3
Clear-Host
Write-Host "Enter: VK7JG-NPHTM-C97JM-9MPGT-3V66T (Or Paste From Clipboard) . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
