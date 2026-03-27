        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

		# FUNCTION MODERN FILE PICKER
    	function Show-ModernFilePicker {
    	param(
    	[ValidateSet('Folder', 'File')]
    	$Mode,
    	[string]$fileType
    	)
    	if ($Mode -eq 'Folder') {
    	$Title = 'Select Folder'
    	$modeOption = $false
    	$Filter = "Folders|`n"
    	}
    	else {
    	$Title = 'Select File'
    	$modeOption = $true
    	if ($fileType) {
    	$Filter = "$fileType Files (*.$fileType) | *.$fileType|All files (*.*)|*.*"
    	}
    	else {
    	$Filter = 'All Files (*.*)|*.*'
    	}
    	}
    	$AssemblyFullName = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
    	$Assembly = [System.Reflection.Assembly]::Load($AssemblyFullName)
    	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    	$OpenFileDialog.AddExtension = $modeOption
    	$OpenFileDialog.CheckFileExists = $modeOption
    	$OpenFileDialog.DereferenceLinks = $true
    	$OpenFileDialog.Filter = $Filter
    	$OpenFileDialog.Multiselect = $false
    	$OpenFileDialog.Title = $Title
    	$OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    	$OpenFileDialogType = $OpenFileDialog.GetType()
    	$FileDialogInterfaceType = $Assembly.GetType('System.Windows.Forms.FileDialogNative+IFileDialog')
    	$IFileDialog = $OpenFileDialogType.GetMethod('CreateVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null)
    	$null = $OpenFileDialogType.GetMethod('OnBeforeVistaDialog', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $IFileDialog)
    	if ($Mode -eq 'Folder') {
    	[uint32]$PickFoldersOption = $Assembly.GetType('System.Windows.Forms.FileDialogNative+FOS').GetField('FOS_PICKFOLDERS').GetValue($null)
    	$FolderOptions = $OpenFileDialogType.GetMethod('get_Options', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($OpenFileDialog, $null) -bor $PickFoldersOption
    	$null = $FileDialogInterfaceType.GetMethod('SetOptions', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $FolderOptions)
    	}
    	$VistaDialogEvent = [System.Activator]::CreateInstance($AssemblyFullName, 'System.Windows.Forms.FileDialog+VistaDialogEvents', $false, 0, $null, $OpenFileDialog, $null, $null).Unwrap()
    	[uint32]$AdviceCookie = 0
    	$AdvisoryParameters = @($VistaDialogEvent, $AdviceCookie)
    	$AdviseResult = $FileDialogInterfaceType.GetMethod('Advise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdvisoryParameters)
    	$AdviceCookie = $AdvisoryParameters[1]
    	$Result = $FileDialogInterfaceType.GetMethod('Show', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, [System.IntPtr]::Zero)
    	$null = $FileDialogInterfaceType.GetMethod('Unadvise', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $AdviceCookie)
    	if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
    	$FileDialogInterfaceType.GetMethod('GetResult', @('NonPublic', 'Public', 'Static', 'Instance')).Invoke($IFileDialog, $null)
    	}
    	return $OpenFileDialog.FileName
    	}

		Write-Host "TEMPORARILY DISABLE CPU CORE 1 & THREAD 1 FOR TESTING PER APP/GAME`n"
        Write-Host "CORE 1 THREAD 1:"
        Write-Host "1. Off: Already Running"
        Write-Host "2. Off: Startup`n"
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^[1-2]$') {
        switch ($choice) {
        1 {

Clear-Host

# get number of logical processors
$NOLP = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors

# convert input to integer
$NOLP = [int]$NOLP

# set affinity mask with core 1 and thread 1 disabled (exclude bit 0 and bit 1)
$hexadecimal = [int]([math]::Pow(2, $NOLP) - 1) - 3

# copy game exe id
(Get-Process | Where-Object {$_.WorkingSet64 -gt 500MB} | Select-Object Name, Id) | Format-Table -AutoSize
$exeid = Read-Host -Prompt "ENTER GAME EXE ID"

Clear-Host

# set game exe core1/thread1 off
$smthtoff = Get-Process -Id $exeid
$smthtoff.ProcessorAffinity = $hexadecimal

# check new value
$reloadexeid = Get-Process -Id $exeid

# show new value
$showvalue = [Convert]::ToString([int]$reloadexeid.ProcessorAffinity, 2).PadLeft($NOLP, '0')
Write-Host "ID - $exeid = $showvalue`n"

Pause

exit

          }
        2 {

Clear-Host

# stop game launchers running
$stop = "Battle.net", "BsgLauncher", "EADesktop", "EpicGamesLauncher", "GalaxyClient", "RobloxPlayerBeta", "RiotClientServices", "Launcher", "steam", "upc"
$stop | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }

# get number of logical processors
$NOLP = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors

# convert input to integer
$NOLP = [int]$NOLP

# set affinity mask with core 1 and thread 1 disabled (exclude bit 0 and bit 1)
$affinity = [int]([math]::Pow(2, $NOLP) - 1) - 3
$hexadecimal = "{0:X}" -f $affinity

# select game launcher lnk or exe
Write-Host "SELECT LAUNCHER/GAME/SHORTCUT/EXE:"
$gamelauncher = Show-ModernFilePicker -Mode File

Clear-Host

# start game launcher lnk or exe with core1/thread1 off
cmd /c "start `"`" /affinity $hexadecimal `"$gamelauncher`""

Write-Host "GETTING VALUE..."

Start-Sleep -Seconds 10

# convert directory to file name without exe
$gamelauncher = [System.IO.Path]::GetFileNameWithoutExtension($gamelauncher)

# check value
$reloadgamelauncher = (Get-Process -Name "$gamelauncher").ProcessorAffinity

# convert value
$showvalue = [Convert]::ToString([int]$reloadgamelauncher, 2)

Clear-Host

# show new value
$showvalue = $showvalue.PadLeft($NOLP, "0")
Write-Host "EXE - $gamelauncher = $showvalue`n"

Pause

exit

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }