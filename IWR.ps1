# silent
$progresspreference = 'silentlycontinue'

# download
iwr "https://github.com/FR33THYFR33THY/Ultimate/archive/refs/heads/main.zip" -OutFile "$env:SystemRoot\Temp\Ultimate.zip"

# extract
Expand-Archive -Path "$env:SystemRoot\Temp\Ultimate.zip" -DestinationPath "$env:SystemRoot\Temp\Ultimate" -Force

# rename
Rename-Item -Path "$env:SystemRoot\Temp\Ultimate\Ultimate-main" -NewName "Ultimate" -Force

# move
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
Move-Item -Path "$env:SystemRoot\Temp\Ultimate\Ultimate" -Destination "$Desktop" -Force

# open
Start-Process "$Desktop\Ultimate"

# exit
exit