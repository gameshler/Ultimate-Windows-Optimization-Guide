Write-Host "Installing PowerShell Profile..." -ForegroundColor Cyan

# Ensure profile file exists
if (!(Test-Path $PROFILE)) {
    Write-Host "Creating profile file..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $PROFILE -Force
}

# Check PSReadLine version and set compatible options
$psReadLineVersion = (Get-Module PSReadLine -ListAvailable | Select-Object -First 1).Version

Write-Host "PSReadLine version detected: $($psReadLineVersion.ToString())" -ForegroundColor Yellow

# Install required modules
Write-Host "Installing required modules..." -ForegroundColor Yellow

try {
    # Install PowerShell modules
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Host "Terminal-Icons already installed" -ForegroundColor Green
    }
    else {
        Write-Host "Installing Terminal-Icons..." -ForegroundColor Yellow
        Install-Module -Name Terminal-Icons -Force
    }

    if (Get-Module -ListAvailable -Name posh-git) {
        Write-Host "posh-git already installed" -ForegroundColor Green
    }
    else {
        Write-Host "Installing posh-git..." -ForegroundColor Yellow
        Install-Module -Name posh-git -Force
    }

    # Install Oh-My-Posh
    Write-Host "Checking for Oh-My-Posh..." -ForegroundColor Yellow
    $ohMyPoshInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue

    if (-not $ohMyPoshInstalled) {
        Write-Host "Installing Oh-My-Posh via winget..." -ForegroundColor Yellow
        try {
            winget install JanDeDobbeleer.OhMyPosh --source winget --scope user --force
            Write-Host "Oh-My-Posh installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install Oh-My-Posh via winget. You may need to install it manually." -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Oh-My-Posh already installed" -ForegroundColor Green
    }

    # Import modules temporarily for this session
    Write-Host "Importing modules..." -ForegroundColor Yellow
    Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
    Import-Module -Name PSReadLine -ErrorAction SilentlyContinue
    Import-Module -Name posh-git -ErrorAction SilentlyContinue

    # Create the profile content with version-compatible PSReadLine options
    $profileContent = @'
# Import Modules
Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine
Import-Module -Name posh-git

$psReadLineVersion = (Get-Module PSReadLine -ListAvailable | Select-Object -First 1).Version

if ($psReadLineVersion -ge [version]"2.1.0") {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteCharOrExit

try {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
}
catch {
    Write-Host "Oh-My-Posh not available. Using basic prompt." -ForegroundColor Yellow
    function prompt { "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) " }
}

# Environment Variables

$env:PATH += ";C:\Program Files\Git\bin"
$env:PATH += ";C:\Program Files\nodejs"
$env:PATH += ";$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin"

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
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if (-not $connections) {
        Write-Host "No processes found using port $port" -ForegroundColor Red
        return
    }

    foreach ($connection in $connections) {
        if ($connection.OwningProcess -gt 0) {
            try {
                $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
                if ($process) {
                    Write-Host "Process found on port ${port}:" -ForegroundColor Green
                    Write-Host "Name: $($process.ProcessName)" -ForegroundColor Cyan
                    Write-Host "PID: $($process.Id)" -ForegroundColor Cyan
                    Write-Host "State: $($connection.State)" -ForegroundColor Cyan
                    Write-Host "Path: $($process.Path)" -ForegroundColor Gray
                    Write-Host ""
                }
            }
            catch {
                Write-Host "Process ID $($connection.OwningProcess) not found (may have terminated)" -ForegroundColor Yellow
            }
        }
    }
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

# DIRECTORY SEARCH FUNCTIONS

function Search-Files {
    <#
    .SYNOPSIS
        Advanced file search with regex, content search, and multiple filters
    #>

    param(
        [string]$NamePattern = "*",
        [string]$ContentPattern,
        [string]$Path = ".",
        [string[]]$Extension,
        [switch]$UseRegex,
        [switch]$CaseSensitive,
        [switch]$Recursive,
        [double]$MaxSizeMB,
        [double]$MinSizeMB,
        [datetime]$ModifiedAfter,
        [datetime]$ModifiedBefore,
        [datetime]$CreatedAfter,
        [datetime]$CreatedBefore,
        [string[]]$ExcludeDirs = @("node_modules", ".git", "bin", "obj", "packages"),
        [switch]$IncludeHidden,
        [int]$MaxResults = 500,
        [switch]$Parallel,
        [switch]$ShowFullPath
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "Searching..." -ForegroundColor Cyan

    $searchParams = @{
        Path = $Path
        File = $true
        ErrorAction = "SilentlyContinue"
    }

    if ($Recursive) { $searchParams.Recurse = $true }
    if ($IncludeHidden) { $searchParams.Force = $true }


    $searchParams.Filter = if (-not $UseRegex -and $NamePattern -ne "*") {
        if ($NamePattern.Contains('*')) { $NamePattern } else { "*$NamePattern*" }
    } else {
        "*"
    }


    $files = Get-ChildItem @searchParams | Where-Object {
        $file = $_


        $shouldInclude = $true

        $shouldInclude = $shouldInclude -and (Test-ExcludedDirectory -File $file -ExcludeDirs $ExcludeDirs)
        $shouldInclude = $shouldInclude -and (Test-Extension -File $file -Extension $Extension)
        $shouldInclude = $shouldInclude -and (Test-FileSize -File $file -MinSizeMB $MinSizeMB -MaxSizeMB $MaxSizeMB)
        $shouldInclude = $shouldInclude -and (Test-DateFilters -File $file -ModifiedAfter $ModifiedAfter -ModifiedBefore $ModifiedBefore -CreatedAfter $CreatedAfter -CreatedBefore $CreatedBefore)
        $shouldInclude = $shouldInclude -and (Test-NamePattern -File $file -NamePattern $NamePattern -UseRegex $UseRegex -CaseSensitive $CaseSensitive)

        return $shouldInclude
    }


    if ($ContentPattern) {
        $files = Search-Content -Files $files -ContentPattern $ContentPattern -CaseSensitive $CaseSensitive -Parallel $Parallel
    }

    $results = $files | Select-Object -First $MaxResults
    $stopwatch.Stop()


    Show-Results -Results $results -Stopwatch $stopwatch -ShowFullPath $ShowFullPath
}

# Search-Files Helper Functions
function Test-ExcludedDirectory {
    param($File, $ExcludeDirs)

    foreach ($dir in $ExcludeDirs) {
        if ($File.FullName -like "*\$dir\*") {
            return $false
        }
    }
    return $true
}

function Test-Extension {
    param($File, $Extension)

    if (-not $Extension -or $Extension.Count -eq 0) { return $true }

    $fileExt = $File.Extension.TrimStart('.')
    return ($Extension -contains $fileExt) -or ($Extension -contains "*.$fileExt")
}

function Test-FileSize {
    param($File, $MinSizeMB, $MaxSizeMB)

    $sizeMB = $File.Length / 1MB

    $passMin = if ($MinSizeMB) { $sizeMB -ge $MinSizeMB } else { $true }
    $passMax = if ($MaxSizeMB) { $sizeMB -le $MaxSizeMB } else { $true }

    return $passMin -and $passMax
}

function Test-DateFilters {
    param($File, $ModifiedAfter, $ModifiedBefore, $CreatedAfter, $CreatedBefore)

    $passModifiedAfter = if ($ModifiedAfter) { $File.LastWriteTime -ge $ModifiedAfter } else { $true }
    $passModifiedBefore = if ($ModifiedBefore) { $File.LastWriteTime -le $ModifiedBefore } else { $true }
    $passCreatedAfter = if ($CreatedAfter) { $File.CreationTime -ge $CreatedAfter } else { $true }
    $passCreatedBefore = if ($CreatedBefore) { $File.CreationTime -le $CreatedBefore } else { $true }

    return $passModifiedAfter -and $passModifiedBefore -and $passCreatedAfter -and $passCreatedBefore
}

function Test-NamePattern {
    param($File, $NamePattern, $UseRegex, $CaseSensitive)

    if (-not $UseRegex -and $NamePattern -eq "*") { return $true }

    $pattern = if ($UseRegex) { $NamePattern } else { [regex]::Escape($NamePattern) }
    $regexOptions = if ($CaseSensitive) { [Text.RegularExpressions.RegexOptions]::None } else { [Text.RegularExpressions.RegexOptions]::IgnoreCase }

    return [regex]::IsMatch($File.Name, $pattern, $regexOptions)
}

function Search-Content {
    param($Files, $ContentPattern, $CaseSensitive, $Parallel)

    $contentRegexOptions = if ($CaseSensitive) { [Text.RegularExpressions.RegexOptions]::None } else { [Text.RegularExpressions.RegexOptions]::IgnoreCase }

    if ($Parallel -and $PSVersionTable.PSVersion -ge [version]"7.0") {
        return $Files | ForEach-Object -Parallel {
            $file = $_
            try {
                if ($file.Length -gt 0 -and $file.Length -lt 10MB) {
                    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
                    if ($content -and [regex]::IsMatch($content, $using:ContentPattern, $using:contentRegexOptions)) {
                        $file
                    }
                }
            } catch {}
        } -ThrottleLimit 8
    } else {
        return $Files | Where-Object {
            try {
                if ($_.Length -gt 0 -and $_.Length -lt 10MB) {
                    $content = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
                    $content -and [regex]::IsMatch($content, $ContentPattern, $contentRegexOptions)
                } else {
                    $false
                }
            } catch {
                $false
            }
        }
    }
}

function Show-Results {
    param($Results, $Stopwatch, $ShowFullPath)

    if ($Results) {
        Write-Host "Found $($Results.Count) files in $($Stopwatch.Elapsed.TotalSeconds.ToString('0.00'))s" -ForegroundColor Green

        if ($ShowFullPath) {
            $Results | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    Size = Format-FileSize $_.Length
                    Modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                    FullPath = $_.FullName
                }
            } | Format-Table -AutoSize
        } else {
            $Results | Format-Table @(
                @{Name="Name"; Expression={$_.Name}; Width=35},
                @{Name="Size"; Expression={Format-FileSize $_.Length}; Width=10},
                @{Name="Modified"; Expression={$_.LastWriteTime.ToString("yyyy-MM-dd")}; Width=12},
                @{Name="Directory"; Expression={$_.DirectoryName}; Width=50}
            ) -AutoSize
        }
    } else {
        Write-Host "No files found" -ForegroundColor Red
    }
}

function Format-FileSize {
    param([long]$Size)
    switch ($Size) {
        { $_ -gt 1GB } { return "{0:N1} GB" -f ($_ / 1GB) }
        { $_ -gt 1MB } { return "{0:N1} MB" -f ($_ / 1MB) }
        { $_ -gt 1KB } { return "{0:N1} KB" -f ($_ / 1KB) }
        default { return "$_ B" }
    }
}

function Find-Duplicates {
    <#
    .SYNOPSIS
        Find duplicate files by content hash with full paths
    #>
    param(
        [string]$Path = ".",
        [switch]$Recursive,
        [int]$MinSizeKB = 100,
        [switch]$ShowFullPath
    )

    Write-Host "Finding duplicate files..." -ForegroundColor Cyan
    $hashes = @{}
    $duplicates = @()

    Get-ChildItem -Path $Path -File -Recurse:$Recursive |
        Where-Object { $_.Length -gt ($MinSizeKB * 1KB) } |
        ForEach-Object {
            $hash = (Get-FileHash -Path $_.FullName -Algorithm MD5).Hash
            if ($hashes.ContainsKey($hash)) {
                $duplicates += [PSCustomObject]@{
                    Hash = $hash
                    Size = $_.Length
                    Files = @($hashes[$hash], $_.FullName)
                }
            } else {
                $hashes[$hash] = $_.FullName
            }
        }

    if ($duplicates) {
        Write-Host "Found $($duplicates.Count) sets of duplicates:" -ForegroundColor Green
        $duplicates | ForEach-Object {
            Write-Host "`nHash: $($_.Hash) | Size: $(Format-FileSize $_.Size)" -ForegroundColor Yellow
            $_.Files | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        }
    } else {
        Write-Host "No duplicates found" -ForegroundColor Green
    }
}

function Find-LargeFiles {
    <#
    .SYNOPSIS
        Find large files consuming disk space with full paths
    #>
    param(
        [string]$Path = ".",
        [double]$MinSizeMB = 50,
        [int]$Top = 20,
        [switch]$ShowFullPath
    )

    Write-Host "Finding large files (> ${MinSizeMB}MB)..." -ForegroundColor Cyan

    $results = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -gt ($MinSizeMB * 1MB) } |
        Sort-Object Length -Descending |
        Select-Object -First $Top

    if ($ShowFullPath) {
        $results | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Size = Format-FileSize $_.Length
                Modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                FullPath = $_.FullName
            }
        } | Format-Table -AutoSize
    } else {
        $results | Format-Table @(
            @{Name="Name"; Expression={$_.Name}; Width=35},
            @{Name="Size"; Expression={Format-FileSize $_.Length}; Width=12},
            @{Name="Modified"; Expression={$_.LastWriteTime.ToString("yyyy-MM-dd")}; Width=12},
            @{Name="Path"; Expression={$_.DirectoryName}; Width=50}
        ) -AutoSize
    }
}

function Search-Recent {
    <#
    .SYNOPSIS
        Find recently modified files with full paths
    #>
    param(
        [int]$Days = 7,
        [string]$Path = ".",
        [string]$Pattern = "*",
        [switch]$ShowFullPath
    )

    $since = (Get-Date).AddDays(-$Days)

    $results = Get-ChildItem -Path $Path -File -Recurse -Filter $Pattern -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $since } |
        Sort-Object LastWriteTime -Descending

    if ($ShowFullPath) {
        $results | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Size = Format-FileSize $_.Length
                Modified = $_.LastWriteTime.ToString("MM-dd HH:mm")
                FullPath = $_.FullName
            }
        } | Format-Table -AutoSize
    } else {
        $results | Format-Table @(
            @{Name="Name"; Expression={$_.Name}; Width=35},
            @{Name="Size"; Expression={Format-FileSize $_.Length}; Width=10},
            @{Name="Modified"; Expression={$_.LastWriteTime.ToString("MM-dd HH:mm")}; Width=12},
            @{Name="Path"; Expression={$_.DirectoryName}; Width=50}
        ) -AutoSize
    }
}


function Get-DirectoryStats {
    <#
    .SYNOPSIS
        Show statistics for the current directory
    #>
    param([string]$Path = ".")

    $dir = Get-Item -Path $Path
    $files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue
    $directories = Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction SilentlyContinue

    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $extensions = $files | Group-Object -Property Extension | Sort-Object -Property Count -Descending

    Write-Host "Directory Statistics for: $($dir.FullName)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files:        $($files.Count)" -ForegroundColor Cyan
    Write-Host "Directories:  $($directories.Count)" -ForegroundColor Cyan
    Write-Host "Total Size:   $(Format-FileSize $totalSize)" -ForegroundColor Cyan
    Write-Host "`nTop File Extensions:" -ForegroundColor Yellow

    $extensions | Select-Object -First 5 | ForEach-Object {
        Write-Host ("{0,-8} {1}" -f $_.Name, $_.Count) -ForegroundColor Gray
    }

    Write-Host ""
}

# ALIASES

# Main alias
Set-Alias -Name search -Value Search-Files
Set-Alias -Name fs -Value Search-Files
Set-Alias -Name port -Value Find-Port
Set-Alias -Name stats -Value Get-DirectoryStats

# Quick search functions
function ds { Search-Files -NamePattern $args -Recursive }
function dscs { Search-Files -NamePattern $args -CaseSensitive -Recursive  }
function dsre { Search-Files -NamePattern $args -UseRegex -Recursive  }
function dscont { Search-Files -ContentPattern $args -Recursive  }

# Specialized searches
function find-large { Find-LargeFiles @args }
function find-dupes { Find-Duplicates @args }
function find-recent { Search-Recent @args  }
function find-ext { Search-Files -Extension $args -Recursive  }

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
function rmrf { Remove-Item $args -Recurse -Force}

# Node.js/PNPM
function pni { pnpm install $args }
function pns { pnpm start }
function pnt { pnpm test }
function pnrd { pnpm run dev }
function pnrsd {pnpm run start:dev}
function pnrb { pnpm run build }

# Docker
function dk { docker $args }
function dkc { docker-compose $args }
function dkup { docker-compose up -d }
function dkdown { docker-compose down }
function dklogs { docker-compose logs -f }
function code. { code . }


# PowerShell Configuration

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

# Startup Message

Clear-Host
Write-Host "Welcome back! Master" -ForegroundColor Green
Write-Host "What are we building today?" -ForegroundColor Cyan

# Display system info
try {
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "System Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor DarkGray
}
catch {
    Write-Host "Profile loaded at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
}


'@

    # Write the content to the profile
    Write-Host "Writing profile configuration..." -ForegroundColor Yellow
    $profileContent | Out-File -FilePath $PROFILE -Encoding UTF8 -Force

    Write-Host "Profile installed successfully!" -ForegroundColor Green
    Write-Host "Profile location: $PROFILE" -ForegroundColor Cyan
    Write-Host "press any key to exit" -ForegroundColor Cyan

    # Pause until user interaction
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    Exit 0
}
catch {
    Write-Host "Error occurred during installation: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to run this script as Administrator for module installation" -ForegroundColor Yellow
    Write-Host "press any key to exit" -ForegroundColor Cyan

    # Pause until user interaction
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    Exit 0
}
