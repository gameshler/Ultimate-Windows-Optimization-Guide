# Gameshler's Ultimate Windows Optimization Guide

# Run as administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
  Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
  Exit
}

# Set the console title and colors
$Host.UI.RawUI.WindowTitle = "Gameshler's Ultimate Windows Optimization Guide (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"

# Define the root directory
$rootDirectory = $PSScriptRoot

# Define the directories
$directories = Get-ChildItem -Path $rootDirectory -Directory

# ASCII art for the name
$asciiArt = @"
______                          __    __             ____             __  
/ ____/___ _____ ___  ___  _____/ /_  / /__  _____   / __ \____ ______/ /__
/ / __/ __ `/ __ `__ \/ _ \/ ___/ __ \/ / _ \/ ___/  / /_/ / __ `/ ___/ //_/
/ /_/ / /_/ / / / / / /  __(__  ) / / / /  __/ /     / ____/ /_/ / /__/ ,<   
\____/\__,_/_/ /_/ /_/\___/____/_/ /_/_/\___/_/     /_/    \__,_/\___/_/|_|  
                                                                         
"@

# Function that displays the menu
function Show-Menu {
  
  Clear-Host
  Write-Host $asciiArt -ForegroundColor Magenta
  Write-Host "-----------------------------------------------" -ForegroundColor Green
  Write-Host "Select an option:" -ForegroundColor Green
  Write-Host ""

  for ($i = 0; $i -lt $directories.Length; $i++) {
    $folderName = $directories[$i].Name -replace '^\d+\s*'
    Write-Host "$($i+1). $folderName" -ForegroundColor Cyan
  }
  Write-Host "0. Exit" -ForegroundColor Red
  Write-Host "-----------------------------------------------" -ForegroundColor Green

  $choice = Read-Host " "
  if ($choice -match '^[1-9]\d*$' -and [int]$choice -le $directories.Length) {
    $selectedDirectory = $directories[$choice - 1]
    Show-FilesInDirectory -Directory $selectedDirectory
  }
  elseif ($choice -eq "0") {
    Exit
  }
  else {
    Write-Host "Invalid choice. Please try again." -ForegroundColor Red
    Start-Sleep -Seconds 1
    Show-Menu
  }
}

# Function that displays the files in a directory
function Show-FilesInDirectory {
  
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.DirectoryInfo]$Directory
  )

  try {
    $files = Get-ChildItem -Path $Directory.FullName -File | Sort-Object { [int]($_.Name -replace '^\D*(\d+).*$', '$1') }

    Clear-Host
    Write-Host "Files in $($Directory.Name):" -ForegroundColor Yellow
    for ($i = 0; $i -lt $files.Length; $i++) {
      $fileName = $files[$i].Name -replace '^\d+\s*'
      Write-Host "$($i+1). $fileName" -ForegroundColor Cyan
    }
    Write-Host "0. Go back" -ForegroundColor Red
    Write-Host "-----------------------------------------------" -ForegroundColor Yellow

    $choice = Read-Host " "
    if ($choice -match '^[1-9]\d*$' -and [int]$choice -le $files.Length) {
      $selectedFile = $files[$choice - 1]
      Invoke-Expression -Command "& '$($selectedFile.FullName)'"
      Start-Sleep -Seconds 1
      Show-FilesInDirectory -Directory $Directory
    }
    elseif ($choice -eq "0") {
      Show-Menu
    }
    else {
      Write-Host "Invalid choice. Please try again." -ForegroundColor Red
      Start-Sleep -Seconds 1
      Show-FilesInDirectory -Directory $Directory
    }
  }
  catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    Start-Sleep -Seconds 2
    Show-Menu
  }
}

# Start the menu
Show-Menu