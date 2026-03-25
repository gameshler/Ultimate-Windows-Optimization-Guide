. $CommonScript

Ensure-Admin
Show-ModernFilePicker

    Write-Host "1. Priority: Already Running"
    Write-Host "2. Priority: Launcher/Game Startup"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
# show priority options
Write-Host "1. Real Time"
Write-Host "2. High"
Write-Host "3. Above Normal"
Write-Host "4. Normal"
Write-Host "5. Below Normal"
Write-Host "6. Idle"
Write-Host ""
# select priority
$priochoice = Read-Host -Prompt "Priority"
Clear-Host
# map choice to priority
switch ($priochoice) {
"1" {$prio = "RealTime"}
"2" {$prio = "High"}
"3" {$prio = "AboveNormal"}
"4" {$prio = "Normal"}
"5" {$prio = "BelowNormal"}
"6" {$prio = "Idle"}
default {
Write-Host "Invalid input . . ." -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
}
}
# copy game exe id
(Get-Process | Where-Object {$_.WorkingSet64 -gt 500MB} | Select-Object Name, Id) | Format-Table -AutoSize
$exeid = Read-Host -Prompt "Enter Game Exe Id"
Clear-Host
# set game exe priority
$processid = Get-Process -Id $exeid -ErrorAction SilentlyContinue
$processid.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::$prio
Write-Host "Getting Value . . ."
Timeout /T 3 | Out-Null
Clear-Host
# show new value
$currentprio = $processid.PriorityClass
Write-Host "ID - $exeid = $currentprio"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    2 {

Clear-Host
# stop game launchers running
$stop = "Battle.net", "BsgLauncher", "EADesktop", "EpicGamesLauncher", "GalaxyClient", "RobloxPlayerBeta", "RiotClientServices", "Launcher", "steam", "upc"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
Clear-Host
# show priority options
Write-Host "1. Real Time"
Write-Host "2. High"
Write-Host "3. Above Normal"
Write-Host "4. Normal"
Write-Host "5. Below Normal"
Write-Host "6. Low"
Write-Host ""
# select priority
$priochoice = Read-Host -Prompt "Priority"
Clear-Host
# map choice to priority
switch ($priochoice) {
"1" {$prio = "realtime"}
"2" {$prio = "high"}
"3" {$prio = "abovenormal"}
"4" {$prio = "normal"}
"5" {$prio = "belownormal"}
"6" {$prio = "low"}
default {
Write-Host "Invalid input . . ." -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
}
}
# select game launcher lnk or exe
Write-Host "Select Launcher/Game: Shortcut/Exe"
$gamelauncher = Show-ModernFilePicker -Mode File
Clear-Host
# set game exe priority
cmd /c "start `"`" /$prio `"$gamelauncher`""
# convert directory to file name without exe
$gamelauncher = [System.IO.Path]::GetFileNameWithoutExtension($gamelauncher)
# check value
$reloadgamelauncher = (Get-Process -Name "$gamelauncher").PriorityClass
Write-Host "Getting Value . . ."
Timeout /T 3 | Out-Null
Clear-Host
# show new value
Write-Host "EXE - $gamelauncher = $reloadgamelauncher"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
