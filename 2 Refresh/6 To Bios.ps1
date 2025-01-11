Write-Host "Press 'Y' To Restart To BIOS"
while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[yY]$') {
        switch ($choice) {
            y {

                Clear-Host
                Write-Host "Restarting To BIOS: Press any key to restart . . ."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                # restart to bios
                cmd /c C:\Windows\System32\shutdown.exe /r /fw
                exit

            }
        } 
    }
    else { Write-Host "Invalid input. Please select a valid option (Y)." } 
}