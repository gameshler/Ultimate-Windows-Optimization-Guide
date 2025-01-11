Write-Host "NVIDIA High-Bandwidth Digital Content Protection"
Write-Host "1. Off"
Write-Host "2. Default"
while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
        switch ($choice) {
            1 {

                Clear-Host
                # get gpu driver id
                $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
                foreach ($key in $subkeys) {
                    if ($key -notlike '*Configuration') {
                        # disable hdcp regedit
                        reg add "$key" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f | Out-Null
                    }
                }
                Clear-Host
                Write-Host "HDCP: Off . . ."
                $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
                foreach ($key in $subkeys) {
                    if ($key -notlike '*Configuration') {
                        # show regedit value
                        Get-ItemProperty -Path "Registry::$key" -Name 'RMHdcpKeyglobZero'
                    }
                }
                Write-Host "Restart to apply . . ."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit

            }
            2 {

                Clear-Host
                # get gpu driver id
                $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
                foreach ($key in $subkeys) {
                    if ($key -notlike '*Configuration') {
                        # enable hdcp regedit
                        reg add "$key" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f | Out-Null
                    }
                }
                Clear-Host
                Write-Host "HDCP: Default . . ."
                $subkeys = (Get-ChildItem -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -Force -ErrorAction SilentlyContinue).Name
                foreach ($key in $subkeys) {
                    if ($key -notlike '*Configuration') {
                        # show regedit value
                        Get-ItemProperty -Path "Registry::$key" -Name 'RMHdcpKeyglobZero'
                    }
                }
                Write-Host "Restart to apply . . ."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                exit

            }
        } 
    }
    else { Write-Host "Invalid input. Please select a valid option (1-2)." } 
}
