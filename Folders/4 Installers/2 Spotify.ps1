. $CommonScript

$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host


Write-Host "Installing: Spotify . . ."
Get-FileFromWeb -URL "https://download.scdn.co/SpotifySetup.exe" -File "$env:TEMP\Spotify.exe"
Start-Process "$env:TEMP\Spotify.exe"
