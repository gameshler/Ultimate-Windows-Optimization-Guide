        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

        # FUNCTION FASTER DOWNLOADS % BAR
        function Get-FileFromWeb {
        param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
        function Show-Progress {
        param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
        else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
        }
        try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "401, 403 or 404 '$URL'." }
        if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
        if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
        if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        do {
        $count = $reader.Read($buffer, 0, $buffer.Length)
        $writer.Write($buffer, 0, $count)
        $total += $count
        if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
        } while ($count -gt 0)
        }
        finally {
        $reader.Close()
        $writer.Close()
        }
        }

        Write-Host "1. Gamebar Xbox: Off (Recommended)"
        Write-Host "2. Gamebar Xbox: Default`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

Write-Host "Gamebar Xbox: Off..."

# create reg file
$GameBarOff = @"
Windows Registry Editor Version 5.00

; disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000

; disable enable open xbox game bar using game controller
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000

; disable use view + menu as guide button in apps
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"GamepadNexusChordEnabled"=dword:00000000

; disable ms-gamebar notifications with xbox controller plugged in
[HKEY_CLASSES_ROOT\ms-gamebar]
"(Default)"="URL:ms-gamebar"
"URL Protocol"=""
"NoOpenWith"=""

[HKEY_CLASSES_ROOT\ms-gamebar\shell\open\command]
"(Default)"="%SystemRoot%\\System32\\systray.exe"

[HKEY_CLASSES_ROOT\ms-gamebarservices]
"(Default)"="URL:ms-gamebarservices"
"URL Protocol"=""
"NoOpenWith"=""

[HKEY_CLASSES_ROOT\ms-gamebarservices\shell\open\command]
"(Default)"="%SystemRoot%\\System32\\systray.exe"

[HKEY_CLASSES_ROOT\ms-gamingoverlay]
"(Default)"="URL:ms-gamingoverlay"
"URL Protocol"=""
"NoOpenWith"=""

[HKEY_CLASSES_ROOT\ms-gamingoverlay\shell\open\command]
"(Default)"="%SystemRoot%\\System32\\systray.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter]
"ActivationType"=dword:00000000
"@
Set-Content -Path "$env:SystemRoot\Temp\GameBarOff.reg" -Value $GameBarOff -Force

# import reg file
Start-Process -Wait "regedit.exe" -ArgumentList "/S `"$env:SystemRoot\Temp\GameBarOff.reg`"" -WindowStyle Hidden

# stop gamebar running
Stop-Process -Force -Name GameBar -ErrorAction SilentlyContinue | Out-Null

# uninstall gamebar & xbox apps
Get-AppXPackage -AllUsers | Where-Object {
$_.Name -like '*Gaming*' -or
$_.Name -like '*Xbox*'
} | Remove-AppxPackage -ErrorAction SilentlyContinue

# stop microsoft gameinput running
cmd /c "sc stop `"GameInputSvc`" >nul 2>&1"
$stop = "gamingservices", "gamingservicesnet", "GameInputRedistService"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

# uninstall microsoft gameinput
$findmicrosoftgameinput = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
$microsoftgameinput = Get-ItemProperty $findmicrosoftgameinput -ErrorAction SilentlyContinue |
Where-Object { $_.DisplayName -like "*Microsoft GameInput*" }
if ($microsoftgameinput) {
$guid = $microsoftgameinput.PSChildName
Start-Process "msiexec.exe" -ArgumentList "/x $guid /qn /norestart" -Wait -NoNewWindow
}

# stop microsoft gameinput running again
cmd /c "sc stop `"GameInputSvc`" >nul 2>&1"
$stop = "gamingservices", "gamingservicesnet", "GameInputRedistService"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }

exit

          }
        2 {

Clear-Host

Write-Host "Gamebar Xbox: Default..."

# create reg file
$GameBarOn = @"
Windows Registry Editor Version 5.00

; game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=-

; enable open xbox game bar using game controller
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=-

; enable use view + menu as guide button in apps
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"GamepadNexusChordEnabled"=-

; ms-gamebar notifications with xbox controller plugged in regedit
[-HKEY_CLASSES_ROOT\ms-gamebar]

[HKEY_CLASSES_ROOT\ms-gamebar]
"URL Protocol"=""
@="URL:ms-gamebar"

[-HKEY_CLASSES_ROOT\ms-gamebar\shell\open\command]

[-HKEY_CLASSES_ROOT\ms-gamebarservices]

[-HKEY_CLASSES_ROOT\ms-gamebarservices\shell\open\command]

[-HKEY_CLASSES_ROOT\ms-gamingoverlay]

[HKEY_CLASSES_ROOT\ms-gamingoverlay]
"URL Protocol"=""
@="URL:ms-gamingoverlay"

[-HKEY_CLASSES_ROOT\ms-gamingoverlay\shell\open\command]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter]
"ActivationType"=dword:00000001

; gameinput service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\GameInputSvc]
"Start"=dword:00000003

; gamedvr and broadcast user service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BcastDVRUserService]
"Start"=dword:00000003

; xbox accessory management service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxGipSvc]
"Start"=dword:00000003

; xbox live auth manager service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblAuthManager]
"Start"=dword:00000003

; xbox live game save service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblGameSave]
"Start"=dword:00000003

; xbox live networking service
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxNetApiSvc]
"Start"=dword:00000003
"@
Set-Content -Path "$env:SystemRoot\Temp\GameBarOn.reg" -Value $GameBarOn -Force

# import reg file
Start-Process -Wait "regedit.exe" -ArgumentList "/S `"$env:SystemRoot\Temp\GameBarOn.reg`"" -WindowStyle Hidden

# install store, gamebar & xbox apps
Get-AppXPackage -AllUsers | Where-Object {
$_.Name -like '*Gaming*' -or
$_.Name -like '*Xbox*' -or
$_.Name -like '*Store*'
} | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}

# download edge webview installer
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/refs/heads/main/EdgeWebView.exe" -File "$env:SystemRoot\Temp\EdgeWebView.exe"

# start edge webview installer
Start-Process -Wait "$env:SystemRoot\Temp\EdgeWebView.exe"

# download gamebar repair tool
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/refs/heads/main/GamingRepairTool.exe" -File "$env:SystemRoot\Temp\GamingRepairTool.exe"

# start gamebar repair too
Start-Process "$env:SystemRoot\Temp\GamingRepairTool.exe"

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }