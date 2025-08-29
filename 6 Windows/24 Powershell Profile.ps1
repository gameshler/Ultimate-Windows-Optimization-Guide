# ==============================================
# PowerShell Profile for Full-Stack Developer
# ==============================================

# Import Modules
Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine
Import-Module -Name posh-git

$psReadLineVersion = (Get-Module PSReadLine -ListAvailable | Select-Object -First 1).Version

if ($psReadLineVersion -ge [version]"2.1.0") {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

# Common options for all versions
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteCharOrExit

# ==============================================
# Oh-My-Posh Theme
# ==============================================
try {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
}
catch {
    Write-Host "Oh-My-Posh not available. Using basic prompt." -ForegroundColor Yellow
    function prompt { "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) " }
}

# ==============================================
# Aliases for Development
# ==============================================

# Git Shortcuts
function gs { git status }
function ga { git add $args }
function gcom { git commit -m $args }
function gpush { git push }
function gpull { git pull }
function gco { git checkout $args }
function gb { git branch $args }
function gl { git log --oneline --graph --decorate --all }
function gd { git diff $args }

# Navigation
function dev { Set-Location ~\Development }
function proj { Set-Location ~\projects }
function docs { Set-Location ~\Documents }

# Node.js/PNPM
function pni { pnpm install $args }
function pns { pnpm start }
function pnt { pnpm test }
function pnrd { pnpm run dev }
function pnrb { pnpm run build }

# Docker
function dk { docker $args }
function dkc { docker-compose $args }
function dkup { docker-compose up -d }
function dkdown { docker-compose down }
function dklogs { docker-compose logs -f }
function code. { code . }

# ==============================================
# Environment Variables
# ==============================================
$env:PATH += ";C:\Program Files\Git\bin"
$env:PATH += ";C:\Program Files\nodejs"
$env:PATH += ";$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin"

# ==============================================
# Functions
# ==============================================

# Quick directory creation and navigation
function mkcd ($dir) {
    New-Item $dir -ItemType Directory -ErrorAction SilentlyContinue
    Set-Location $dir
}

# Clear node_modules and reinstall
function pnpm-clean {
    Write-Host "Removing node_modules and package-lock.json..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
    Remove-Item package-lock.json -ErrorAction SilentlyContinue
    Write-Host "Installing fresh dependencies..." -ForegroundColor Green
    pnpm install
}

# Quick Git repository status
function repo-status {
    Write-Host "Git Status:" -ForegroundColor Cyan
    git status --short

    Write-Host "`nRecent Commits:" -ForegroundColor Cyan
    git log --oneline -5

    Write-Host "`nBranches:" -ForegroundColor Cyan
    git branch -v
}

# Find process using specific port
function Find-Port($port) {
    Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess
}

# Quick HTTP server
function serve($port = 3000) {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $port
    }
    elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server $port
    }
    else {
        Write-Host "Python not found. Using Node.js http-server..." -ForegroundColor Yellow
        npx http-server -p $port
    }
}

# ==============================================
# PowerShell Configuration
# ==============================================
try {
    Set-PSReadLineOption -Colors @{
        "Command" = [ConsoleColor]::Green
        "Parameter" = [ConsoleColor]::Gray
        "Operator" = [ConsoleColor]::Magenta
        "Variable" = [ConsoleColor]::Cyan
        "String" = [ConsoleColor]::Yellow
    }
}
catch {
    Write-Host "PSReadLine version doesn't support color customization" -ForegroundColor DarkGray
}

# ==============================================
# Startup Message
# ==============================================
Write-Host "Welcome back! " -ForegroundColor Green -NoNewline

# Display system info
try {
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "System Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor DarkGray
}
catch {
    Write-Host "Profile loaded at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
}
