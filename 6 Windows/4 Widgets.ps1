Write-Host "1. Widgets: Off (Recommended)"
Write-Host "2. Widgets: Default"
while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
        switch ($choice) {
            1 {

                Clear-Host
                # disable widgets regedit
                reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" /v "value" /t REG_DWORD /d "0" /f | Out-Null
                # remove windows widgets from taskbar regedit
                reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f | Out-Null
                # stop widgets running
                Stop-Process -Force -Name Widgets -ErrorAction SilentlyContinue | Out-Null
                Stop-Process -Force -Name WidgetService -ErrorAction SilentlyContinue | Out-Null
                Write-Host "Restart to apply . . ."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit

            }
            2 {

                Clear-Host
                # widgets regedit
                reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" /v "value" /t REG_DWORD /d "1" /f | Out-Null
                # windows widgets from taskbar regedit
                cmd /c "reg delete `"HKLM\SOFTWARE\Policies\Microsoft\Dsh`" /f >nul 2>&1"
                Write-Host "Restart to apply . . ."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit

            }
        } 
    }
    else { Write-Host "Invalid input. Please select a valid option (1-2)." } 
}