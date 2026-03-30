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

## explorer "https://www.overclock.net/threads/corecycler-tool-for-testing-single-core-stability-e-g-curve-optimizer-settings.1777398/page-45#post-28999750"
Write-Host "Installing: PBO2 Tuner..."
Write-Host "AM4 CPUS only, 5000 series and below`n"

Pause

# download pbo2 tuner
iwr "https://github.com/FR33THYFR33THY/files/raw/refs/heads/main/PBO2%20Tuner.zip" -OutFile "$env:SystemRoot\Temp\PBO2 Tuner.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\PBO2 Tuner.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\PBO2 Tuner" -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\PBO2 Tuner.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner\PBO2 Tuner.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PBO2 Tuner.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner\PBO2 Tuner.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner"
$Shortcut.Save()

# create pbo2 tuner (-10 undervolt startup) shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\PBO2 Tuner (-10 UNDERVOLT STARTUP).lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner\PBO2 Tuner.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\PBO2 Tuner"
$Shortcut.Arguments = "-10 -10 -10 -10 -10 -10 -10 -10"
$Shortcut.Save()