        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        Write-Host "1. Memory Compression: Off (Recommended)"
        Write-Host "2. Memory Compression: Enable`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

Write-Host "Memory Compression: Off..."

# disable memory compression
Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null

# show mmagent
get-mmagent

Pause

exit

          }
        2 {

Clear-Host

Write-Host "Memory Compression: Enable..."

# enable memory compression
Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue | Out-Null

Pause

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }