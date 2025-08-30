param(
    [switch]$SkipChocoInstall = $false,
    [switch]$SkipAppInstall = $false,
    [switch]$Force = $false
)

# Set up error handling
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Admin rights check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not ($isAdmin)) {
    Write-Host "This script requires administrator privileges. Restarting with elevated permissions..." -ForegroundColor Yellow

        $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$PSCommandPath`""
    )
    if ($Force) { $arguments += " -Force" }
    if ($SkipChocoInstall) { $arguments += " -SkipChocoInstall" }
    if ($SkipAppInstall) { $arguments += " -SkipAppInstall" }
    $arguments += $args
    try {
        Start-Process PowerShell.exe -ArgumentList $arguments -Verb RunAs -Wait
        Exit
    }
    catch {
        Write-Host "Failed to elevate permissions: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Exit 1
    }
}

# Configure console
$Host.UI.RawUI.WindowTitle = "$($myInvocation.MyCommand.Definition) (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp $Level] $Message" -ForegroundColor $Color
}

# Chocolatey installation function
function Install-Chocolatey {
    try {
        Write-Log "Installing Chocolatey package manager..." -Color Green

        # Check if Chocolatey is already installed
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log "Chocolatey is already installed" -Color Yellow
            return $true
        }

        Write-Log "Downloading and installing Chocolatey..." -Color Green

        # Set execution policy
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        # Install Chocolatey
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # Wait a moment for installation to complete
        Start-Sleep -Seconds 5

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Log "Chocolatey installed successfully" -Color Green
        return $true
    }
    catch {
        Write-Log "Failed to install Chocolatey: $($_.Exception.Message)" -Level "ERROR" -Color Red
        return $false
    }
}

# Application installation functions
function Install-ChocoApps {
    param(
        [string[]]$Apps
    )

    $failedApps = @()

    foreach ($app in $Apps) {
        try {
            Write-Log "Installing $app via Chocolatey..." -Color Cyan

            # Check if already installed
            $installed = choco list --local-only $app -r
            if ($installed -like "$app*") {
                Write-Log "$app is already installed" -Color Green
                continue
            }

            choco install $app -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Successfully installed $app" -Color Green
            } else {
                throw "Exit code: $LASTEXITCODE"
            }
        }
        catch {
            Write-Log "Failed to install $app : $($_.Exception.Message)" -Level "WARN" -Color Yellow
            $failedApps += $app
        }
    }

    return $failedApps
}

function Install-WingetApps {
    param(
        [string[]]$Apps
    )

    $failedApps = @()

    # Check if Winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log "Winget is not available on this system" -Level "WARN" -Color Yellow
        return $Apps # All winget apps will be considered failed
    }

    foreach ($app in $Apps) {
        try {
            Write-Log "Installing $app via Winget..." -Color Cyan

            # Check if already installed
            $installed = winget list --id $app --exact -s winget 2>$null
            if ($installed -like "*$app*") {
                Write-Log "$app is already installed" -Color Green
                continue
            }

            winget install --id $app -e --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Successfully installed $app" -Color Green
            } else {
                throw "Exit code: $LASTEXITCODE"
            }
        }
        catch {
            Write-Log "Failed to install $app : $($_.Exception.Message)" -Level "WARN" -Color Yellow
            $failedApps += $app
        }
    }

    return $failedApps
}

# Main execution
try {
    Write-Log "Starting application installation script..." -Color Magenta

    # Define applications to install
    $chocoApps = @(
        "cpu-z", "git", "hwinfo", "postman", "mongodb-compass",
        "revo-uninstaller", "slack", "gpu-z", "vlc", "vscode",
        "winscp", "zoom", "nodejs-lts", "cypress", "pnpm"
    )
# Add winget apps here
    $wingetApps = @()

    # Install Chocolatey if not skipped
    $chocoSuccess = $true
    if (-not $SkipChocoInstall) {
        $chocoSuccess = Install-Chocolatey
    }

    # Install applications if not skipped
    if (-not $SkipAppInstall -and $chocoSuccess) {
        # Install Chocolatey apps
        $failedChocoApps = Install-ChocoApps -Apps $chocoApps

        # Install Winget apps
        $failedWingetApps = Install-WingetApps -Apps $wingetApps

        # Report failures
        if ($failedChocoApps.Count -gt 0 -or $failedWingetApps.Count -gt 0) {
            Write-Log "Some applications failed to install:" -Level "WARN" -Color Yellow
            if ($failedChocoApps.Count -gt 0) {
                Write-Log "Failed Chocolatey apps: $($failedChocoApps -join ', ')" -Level "WARN" -Color Yellow
            }
            if ($failedWingetApps.Count -gt 0) {
                Write-Log "Failed Winget apps: $($failedWingetApps -join ', ')" -Level "WARN" -Color Yellow
            }
        }
    }

    Write-Log "Script execution completed!" -Color Green
    Write-Log "Press any key to exit..." -Color Gray

    # Pause until user interaction
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    Exit 0
}
catch {
    Write-Log "Script execution failed: $($_.Exception.Message)" -Level "ERROR" -Color Red
    Write-Log "Press any key to exit..." -Color Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit 1
}
