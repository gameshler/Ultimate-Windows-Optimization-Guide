If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    function Show-Progress {
        param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
        else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
    }
    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
        if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
        if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
        if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            $writer.Write($buffer, 0, $count)
            $total += $count
            if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
        } while ($count -gt 0)
    }
    finally {
        $reader.Close()
        $writer.Close()
    }
}

function show-menu {
    Clear-Host
    Write-Host "Game launchers, programs and web browsers:" -ForegroundColor Green
    Write-Host "-Disable hardware acceleration" -ForegroundColor Green
    Write-Host "-Turn off running at startup" -ForegroundColor Green
    Write-Host "-Deactivate overlays" -ForegroundColor Green
    Write-Host ""
    Write-Host "Lower GPU usage and higher framerates reduce latency." -ForegroundColor Green
    Write-Host "Optimize your game settings to achieve this." -ForegroundColor Green
    Write-Host "Further tuning can be done via config files or launch options." -ForegroundColor Green
    Write-Host ""
    Write-Host " 1. Exit" -ForegroundColor Red
    Write-Host " 2. 7-Zip" -ForegroundColor Cyan
    Write-Host " 3. Battle.net"  -ForegroundColor Cyan
    Write-Host " 4. Discord"  -ForegroundColor Cyan
    Write-Host " 5. Electronic Arts"  -ForegroundColor Cyan
    Write-Host " 6. Epic Games"  -ForegroundColor Cyan
    Write-Host " 7. Escape From Tarkov"  -ForegroundColor Cyan
    Write-Host " 8. GOG launcher"  -ForegroundColor Cyan
    Write-Host " 9. Google Chrome"  -ForegroundColor Cyan
    Write-Host "10. League Of Legends"  -ForegroundColor Cyan
    Write-Host "11. Notepad ++"  -ForegroundColor Cyan
    Write-Host "12. OBS Studio"  -ForegroundColor Cyan
    Write-Host "13. Roblox"  -ForegroundColor Cyan
    Write-Host "14. Rockstar Games"  -ForegroundColor Cyan
    Write-Host "15. Steam"  -ForegroundColor Cyan
    Write-Host "16. Ubisoft Connect"  -ForegroundColor Cyan
    Write-Host "17. Valorant"  -ForegroundColor Cyan
    Write-Host "18. Plutonium"  -ForegroundColor Cyan
    Write-Host "19. Origin"  -ForegroundColor Cyan
    Write-Host "20. Faceit Launcher"  -ForegroundColor Cyan
    Write-Host "21. Firefox"  -ForegroundColor Cyan
    Write-Host "22. Thorium"  -ForegroundColor Cyan
    Write-Host "23. Brave"  -ForegroundColor Cyan
    Write-Host "24. Microsoft Office 2024 LSTC Edition"  -ForegroundColor Cyan
}
show-menu
while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^(1[0-9]|2[0-4]|[1-9])$') {
        switch ($choice) {
            1 {

                Clear-Host
                exit

            }
            2 {

                Clear-Host
                Write-Host "Installing: 7Zip . . ."
                # download 7zip
                Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7 Zip.exe" -File "$env:TEMP\7 Zip.exe"
                # install 7zip
                Start-Process -wait "$env:TEMP\7 Zip.exe" -ArgumentList "/S"
                show-menu

            }
            3 {

                Clear-Host
                Write-Host "Installing: Battle.net . . ."
                # download battle.net
                Get-FileFromWeb -URL "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -File "$env:TEMP\Battle.net.exe"
                # install battle.net 
                Start-Process "$env:TEMP\Battle.net.exe" -ArgumentList '--lang=enUS --installpath="C:\Program Files (x86)\Battle.net"'
                # create battle.net shortcut
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Battle.net.lnk")
                $Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Battle.net\Battle.net Launcher.exe"
                $Shortcut.Save()
                show-menu

            }
            4 {

                Clear-Host
                Write-Host "Installing: Discord . . ."
                # download discord
                Get-FileFromWeb -URL "https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9036/DiscordSetup.exe" -File "$env:TEMP\Discord.exe"
                # install discord
                Start-Process -wait "$env:TEMP\Discord.exe" -ArgumentList "/s"
                show-menu

            }
            5 {

                Clear-Host
                Write-Host "Installing: Electronic Arts . . ."
                # download electronic arts
                Get-FileFromWeb -URL "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" -File "$env:TEMP\Electronic Arts.exe"
                # install electronic arts
                Start-Process "$env:TEMP\Electronic Arts.exe"
                show-menu

            }
            6 {

                Clear-Host
                Write-Host "Installing: Epic Games . . ."
                # download epic games
                Get-FileFromWeb -URL "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi?launcherfilename=EpicInstaller-15.17.1.msi" -File "$env:TEMP\Epic Games.msi"
                # install epic games
                Start-Process -wait "$env:TEMP\Epic Games.msi" -ArgumentList "/quiet"
                Clear-Host
                Write-Host "Uninstall: Epic Online Services . . ."
                # uninstall epic online services
                cmd /c "msiexec.exe /x {57A956AB-4BCC-45C6-9B40-957E4E125568} /qn >nul 2>&1"
                show-menu

            }
            7 {

                Clear-Host
                Write-Host "Installing: Escape From Tarkov . . ."
                # download escape from tarkov
                Get-FileFromWeb -URL "https://prod.escapefromtarkov.com/launcher/download" -File "$env:TEMP\Escape From Tarkov.exe" 
                # install escape from tarkov
                Start-Process "$env:TEMP\Escape From Tarkov.exe"
                show-menu

            }
            8 {

                Clear-Host
                Write-Host "Installing: GOG launcher . . ."
                # download gog launcher
                Get-FileFromWeb -URL "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" -File "$env:TEMP\GOG launcher.exe"
                # install gog launcher
                Start-Process "$env:TEMP\GOG launcher.exe"
                show-menu

            }
            9 {

                Clear-Host
                Write-Host "Installing: Google Chrome . . ."
                # download google chrome
                Get-FileFromWeb -URL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -File "$env:TEMP\Chrome.msi"
                # install google chrome
                Start-Process -wait "$env:TEMP\Chrome.msi" -ArgumentList "/quiet"
                # open ublock origin in web browser
                Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" "https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh?hl=en"
                show-menu

            }
            10 {

                Clear-Host
                Write-Host "Installing: League Of Legends . . ."
                # download league of legends
                Get-FileFromWeb -URL "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.na.exe" -File "$env:TEMP\League Of Legends.exe"
                # install league of legends
                Start-Process "$env:TEMP\League Of Legends.exe"
                show-menu

            }
            11 {

                Clear-Host
                Write-Host "Installing: Notepad ++ . . ."
                # download notepad ++
                Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Notepad%20++.exe" -File "$env:TEMP\Notepad ++.exe"
                # install notepad ++
                Start-Process -wait "$env:TEMP\Notepad ++.exe" -ArgumentList "/S"
                # create config for notepad ++
                $MultilineComment = @"
<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <FindHistory nbMaxFindHistoryPath="10" nbMaxFindHistoryFilter="10" nbMaxFindHistoryFind="10" nbMaxFindHistoryReplace="10" matchWord="no" matchCase="no" wrap="yes" directionDown="yes" fifRecuisive="yes" fifInHiddenFolder="no" fifProjectPanel1="no" fifProjectPanel2="no" fifProjectPanel3="no" fifFilterFollowsDoc="no" fifFolderFollowsDoc="no" searchMode="0" transparencyMode="1" transparency="150" dotMatchesNewline="no" isSearch2ButtonsMode="no" regexBackward4PowerUser="no" bookmarkLine="no" purge="no">
        <Filter name="" />
        <Find name="" />
        <Find name="sharpening" />
        <Find name="sharpen" />
        <Find name="sharp" />
        <Replace name="" />
    </FindHistory>
    <History nbMaxFile="0" inSubMenu="no" customLength="-1" />
    <ProjectPanels>
        <ProjectPanel id="0" workSpaceFile="" />
        <ProjectPanel id="1" workSpaceFile="" />
        <ProjectPanel id="2" workSpaceFile="" />
    </ProjectPanels>
    <ColumnEditor choice="number">
        <text content="" />
        <number initial="-1" increase="-1" repeat="-1" formatChoice="dec" leadingChoice="none" />
    </ColumnEditor>
    <GUIConfigs>
        <GUIConfig name="ToolBar" visible="yes">small</GUIConfig>
        <GUIConfig name="StatusBar">show</GUIConfig>
        <GUIConfig name="TabBar" dragAndDrop="yes" drawTopBar="yes" drawInactiveTab="yes" reduce="yes" closeButton="yes" doubleClick2Close="no" vertical="no" multiLine="no" hide="no" quitOnEmpty="no" iconSetNumber="0" />
        <GUIConfig name="ScintillaViewsSplitter">vertical</GUIConfig>
        <GUIConfig name="UserDefineDlg" position="undocked">hide</GUIConfig>
        <GUIConfig name="TabSetting" replaceBySpace="no" size="4" />
        <GUIConfig name="AppPosition" x="148" y="77" width="1234" height="773" isMaximized="no" />
        <GUIConfig name="FindWindowPosition" left="460" top="338" right="1074" bottom="702" isLessModeOn="no" />
        <GUIConfig name="FinderConfig" wrappedLines="no" purgeBeforeEverySearch="no" showOnlyOneEntryPerFoundLine="yes" />
        <GUIConfig name="noUpdate" intervalDays="15" nextUpdateDate="20250326">yes</GUIConfig>
        <GUIConfig name="Auto-detection">yes</GUIConfig>
        <GUIConfig name="CheckHistoryFiles">no</GUIConfig>
        <GUIConfig name="TrayIcon">no</GUIConfig>
        <GUIConfig name="MaintainIndent">yes</GUIConfig>
        <GUIConfig name="TagsMatchHighLight" TagAttrHighLight="yes" HighLightNonHtmlZone="no">yes</GUIConfig>
        <GUIConfig name="RememberLastSession">no</GUIConfig>
        <GUIConfig name="KeepSessionAbsentFileEntries">no</GUIConfig>
        <GUIConfig name="DetectEncoding">yes</GUIConfig>
        <GUIConfig name="SaveAllConfirm">yes</GUIConfig>
        <GUIConfig name="NewDocDefaultSettings" format="0" encoding="4" lang="0" codepage="-1" openAnsiAsUTF8="yes" addNewDocumentOnStartup="no" />
        <GUIConfig name="langsExcluded" gr0="0" gr1="0" gr2="0" gr3="0" gr4="0" gr5="0" gr6="0" gr7="0" gr8="0" gr9="0" gr10="0" gr11="0" gr12="0" langMenuCompact="yes" />
        <GUIConfig name="Print" lineNumber="yes" printOption="3" headerLeft="" headerMiddle="" headerRight="" footerLeft="" footerMiddle="" footerRight="" headerFontName="" headerFontStyle="0" headerFontSize="0" footerFontName="" footerFontStyle="0" footerFontSize="0" margeLeft="0" margeRight="0" margeTop="0" margeBottom="0" />
        <GUIConfig name="Backup" action="0" useCustumDir="no" dir="" isSnapshotMode="no" snapshotBackupTiming="7000" />
        <GUIConfig name="TaskList">yes</GUIConfig>
        <GUIConfig name="MRU">yes</GUIConfig>
        <GUIConfig name="URL">0</GUIConfig>
        <GUIConfig name="uriCustomizedSchemes">svn:// cvs:// git:// imap:// irc:// irc6:// ircs:// ldap:// ldaps:// news: telnet:// gopher:// ssh:// sftp:// smb:// skype: snmp:// spotify: steam:// sms: slack:// chrome:// bitcoin:</GUIConfig>
        <GUIConfig name="globalOverride" fg="no" bg="no" font="no" fontSize="no" bold="no" italic="no" underline="no" />
        <GUIConfig name="auto-completion" autoCAction="3" triggerFromNbChar="1" autoCIgnoreNumbers="yes" insertSelectedItemUseENTER="yes" insertSelectedItemUseTAB="yes" autoCBrief="no" funcParams="yes" />
        <GUIConfig name="auto-insert" parentheses="no" brackets="no" curlyBrackets="no" quotes="no" doubleQuotes="no" htmlXmlTag="no" />
        <GUIConfig name="sessionExt"></GUIConfig>
        <GUIConfig name="workspaceExt"></GUIConfig>
        <GUIConfig name="MenuBar">show</GUIConfig>
        <GUIConfig name="Caret" width="1" blinkRate="600" />
        <GUIConfig name="openSaveDir" value="0" defaultDirPath="" lastUsedDirPath="" />
        <GUIConfig name="titleBar" short="no" />
        <GUIConfig name="insertDateTime" customizedFormat="yyyy-MM-dd HH:mm:ss" reverseDefaultOrder="no" />
        <GUIConfig name="wordCharList" useDefault="yes" charsAdded="" />
        <GUIConfig name="delimiterSelection" leftmostDelimiter="40" rightmostDelimiter="41" delimiterSelectionOnEntireDocument="no" />
        <GUIConfig name="largeFileRestriction" fileSizeMB="200" isEnabled="yes" allowAutoCompletion="no" allowBraceMatch="no" allowSmartHilite="no" allowClickableLink="no" deactivateWordWrap="yes" suppress2GBWarning="no" />
        <GUIConfig name="multiInst" setting="0" clipboardHistory="no" documentList="no" characterPanel="no" folderAsWorkspace="no" projectPanels="no" documentMap="no" fuctionList="no" pluginPanels="no" />
        <GUIConfig name="MISC" fileSwitcherWithoutExtColumn="no" fileSwitcherExtWidth="50" fileSwitcherWithoutPathColumn="yes" fileSwitcherPathWidth="50" fileSwitcherNoGroups="no" backSlashIsEscapeCharacterForSql="yes" writeTechnologyEngine="1" isFolderDroppedOpenFiles="no" docPeekOnTab="no" docPeekOnMap="no" sortFunctionList="no" saveDlgExtFilterToAllTypes="no" muteSounds="no" enableFoldCmdToggable="no" hideMenuRightShortcuts="no" />
        <GUIConfig name="Searching" monospacedFontFindDlg="no" fillFindFieldWithSelected="yes" fillFindFieldSelectCaret="yes" findDlgAlwaysVisible="no" confirmReplaceInAllOpenDocs="yes" replaceStopsWithoutFindingNext="no" inSelectionAutocheckThreshold="1024" />
        <GUIConfig name="searchEngine" searchEngineChoice="2" searchEngineCustom="" />
        <GUIConfig name="MarkAll" matchCase="no" wholeWordOnly="yes" />
        <GUIConfig name="SmartHighLight" matchCase="no" wholeWordOnly="yes" useFindSettings="no" onAnotherView="no">yes</GUIConfig>
        <GUIConfig name="DarkMode" enable="yes" colorTone="0" customColorTop="2105376" customColorMenuHotTrack="4210752" customColorActive="4210752" customColorMain="2105376" customColorError="176" customColorText="14737632" customColorDarkText="12632256" customColorDisabledText="8421504" customColorLinkText="65535" customColorEdge="6579300" customColorHotEdge="10197915" customColorDisabledEdge="4737096" enableWindowsMode="no" darkThemeName="DarkModeDefault.xml" darkToolBarIconSet="0" darkTabIconSet="2" darkTabUseTheme="no" lightThemeName="" lightToolBarIconSet="4" lightTabIconSet="0" lightTabUseTheme="yes" />
        <GUIConfig name="ScintillaPrimaryView" lineNumberMargin="show" lineNumberDynamicWidth="yes" bookMarkMargin="show" indentGuideLine="show" folderMarkStyle="box" isChangeHistoryEnabled="1" lineWrapMethod="aligned" currentLineIndicator="1" currentLineFrameWidth="1" virtualSpace="no" scrollBeyondLastLine="yes" rightClickKeepsSelection="no" disableAdvancedScrolling="no" wrapSymbolShow="hide" Wrap="no" borderEdge="yes" isEdgeBgMode="no" edgeMultiColumnPos="" zoom="4" zoom2="0" whiteSpaceShow="hide" eolShow="hide" eolMode="1" npcShow="hide" npcMode="1" npcCustomColor="no" npcIncludeCcUniEOL="no" npcNoInputC0="yes" ccShow="yes" borderWidth="2" smoothFont="no" paddingLeft="0" paddingRight="0" distractionFreeDivPart="4" lineCopyCutWithoutSelection="yes" multiSelection="yes" columnSel2MultiEdit="yes" />
        <GUIConfig name="DockingManager" leftWidth="200" rightWidth="200" topHeight="200" bottomHeight="200">
            <ActiveTabs cont="0" activeTab="-1" />
            <ActiveTabs cont="1" activeTab="-1" />
            <ActiveTabs cont="2" activeTab="-1" />
            <ActiveTabs cont="3" activeTab="-1" />
        </GUIConfig>
    </GUIConfigs>
</NotepadPlus>

"@
                Set-Content -Path "$env:AppData\Notepad++\config.xml" -Value $MultilineComment -Force
                show-menu

            }
            12 {

                Clear-Host
                Write-Host "Installing: OBS Studio . . ."
                # download obs studio
                Get-FileFromWeb -URL "https://github.com/obsproject/obs-studio/releases/download/31.0.2/OBS-Studio-31.0.2-Windows-Installer.exe" -File "$env:TEMP\OBS Studio.exe"
                # install obs studio
                Start-Process -wait "$env:TEMP\OBS Studio.exe" -ArgumentList "/S"
                show-menu

            }
            13 {

                Clear-Host
                Write-Host "Installing: Roblox . . ."
                # download roblox
                Get-FileFromWeb -URL "https://www.roblox.com/download/client?os=win" -File "$env:TEMP\Roblox.exe"
                # install roblox
                Start-Process "$env:TEMP\Roblox.exe"
                show-menu

            }
            14 {

                Clear-Host
                Write-Host "Installing: Rockstar Games . . ."
                # download rockstar games
                Get-FileFromWeb -URL "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe" -File "$env:TEMP\Rockstar Games.exe"
                # install rockstar games
                Start-Process "$env:TEMP\Rockstar Games.exe"
                show-menu

            }
            15 {

                Clear-Host
                Write-Host "Installing: Steam . . ."
                # download steam
                Get-FileFromWeb -URL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -File "$env:TEMP\Steam.exe"
                # install steam
                Start-Process -wait "$env:TEMP\Steam.exe" -ArgumentList "/S"
                show-menu

            }
            16 {

                Clear-Host
                Write-Host "Installing: Ubisoft Connect . . ."
                # download ubisoft connect
                Get-FileFromWeb -URL "https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe" -File "$env:TEMP\Ubisoft Connect.exe"
                # install ubisoft connect
                Start-Process -wait "$env:TEMP\Ubisoft Connect.exe" -ArgumentList "/S"
                show-menu

            }
            17 {

                Clear-Host
                Write-Host "Installing: Valorant . . ."
                # download valorant
                Get-FileFromWeb -URL "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe" -File "$env:TEMP\Valorant.exe"
                # install valorant 
                Start-Process "$env:TEMP\Valorant.exe"
                show-menu

            }
            18 {
                Clear-Host
                Write-Host "Installing: Plutonium . . ."
                # download plutonium
                Get-FileFromWeb -URL "https://cdn.plutonium.pw/updater/plutonium.exe" -File "$env:TEMP\Plutonium.exe"
                # create Plutonium folder in Program Files
                $plutoniumFolderPath = "$env:SystemDrive\Program Files (x86)\Plutonium"
                if (-Not (Test-Path -Path $plutoniumFolderPath)) {
                    New-Item -ItemType Directory -Path $plutoniumFolderPath
                }
                # move plutonium.exe to the Plutonium folder
                Move-Item -Path "$env:TEMP\Plutonium.exe" -Destination "$plutoniumFolderPath\Plutonium.exe"
                # create plutonium shortcut
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Plutonium.lnk")
                $Shortcut.TargetPath = "$plutoniumFolderPath\Plutonium.exe"
                $Shortcut.Save()
                Start-Process "$plutoniumFolderPath\Plutonium.exe"
                show-menu
            }
            19 {
                Clear-Host
                Write-Host "Installing: Origin . . ."
                $localConfigurationPath = "$env:ProgramData\Origin\local.xml"
                # download origin
                Get-FileFromWeb -URL "https://download.dm.origin.com/origin/live/OriginSetup.exe" -File "$env:TEMP\OriginSetup.exe"
                # install origin
                Start-Process -wait "$env:TEMP\OriginSetup.exe" -ArgumentList "/S"


                # set the local.xml configuration file to read-only
                Set-ItemProperty -Path "$localConfigurationPath" -Name IsReadOnly -Value $true

                Clear-Host
                Write-Host "Installing Fuck off EA App . . . (Check Pretend EA App is Installed)"
                # download Fuck off EA App Installer
                Get-FileFromWeb -URL "https://github.com/p0358/Fuck_off_EA_App/releases/download/v6/Fuck_off_EA_App_installer.exe" -File "$env:TEMP\Fuck_off_EA_App_installer.exe"
                # install Fuck off EA App Installer
                Start-Process -wait "$env:TEMP\Fuck_off_EA_App_installer.exe"

                Clear-Host
                Write-Host "Installing: Punkbuster Service Updater . . . (Add Games to Punkbuster)"
                # download punkbuster service updater
                Get-FileFromWeb -URL "https://www.evenbalance.com/downloads/W/gui/pbsetup.zip" -File "$env:TEMP\pbsetup.zip"
                # extract punkbuster service updater
                Expand-Archive "$env:TEMP\pbsetup.zip" -DestinationPath "$env:TEMP\pbsetup" -ErrorAction SilentlyContinue
                # install punkbuster service updater
                Start-Process -wait "$env:TEMP\pbsetup\pbsetup.exe"
                show-menu
            }
            20 {
                Clear-Host
                Write-Host "Installing FaceIt Launcher . . ."
                #download faceit launcher
                Get-FileFromWeb -URL "https://faceit-client.faceit-cdn.net/release/FACEIT-setup-latest.exe" -File "$env:TEMP\FACEIT-setup-latest.exe"
                #install faceit launcher
                Start-Process -wait "$env:TEMP\FACEIT-setup-latest.exe" -ArgumentList "/S"
                Clear-Host
  
                Write-Host "Installing FaceIt Anti-Cheat . . ."
                #download face it AC
                Get-FileFromWeb -URL "https://anticheat-client.faceit-cdn.net/FACEITInstaller_64.exe" -File "$env:TEMP\FACEITInstaller_64.exe"
                #install face it AC
                Start-Process -wait "$env:TEMP\FACEITInstaller_64.exe" -ArgumentList "/S"
                show-menu
            }
            21 {
                Clear-Host
                Write-Host "Installing: Firefox . . ."
                # download firefox
                Get-FileFromWeb -URL "https://download.mozilla.org/?product=firefox-latest-ssl&os=win&lang=en-US" -File "$env:TEMP\Firefox Installer.exe"
                # install firefox
                Start-Process -wait "$env:TEMP\Firefox Installer.exe" -ArgumentList "/S"
                $firefoxPaths = @(
                    "C:\Program Files\Mozilla Firefox\firefox.exe",
                    "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
                )
                $firefoxExtensions = @(
                    "https://addons.mozilla.org/en-US/firefox/addon/decentraleyes/",
                    "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/",
                    "https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/",
                    "https://addons.mozilla.org/en-US/firefox/addon/react-devtools/",
                    "https://addons.mozilla.org/en-US/firefox/addon/search_by_image/"
                )
                $firefoxPath = $firefoxPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($firefoxPath) {
                    foreach ($extension in $firefoxExtensions) {
                        Start-Process $firefoxPath $extension
                    }
                }
                show-menu
            }
            22 {
                Clear-Host
                Write-Host "Installing: Thorium Browser . . ."
                # download thorium browser
                Get-FileFromWeb -URL "https://github.com/Alex313031/Thorium-Win/releases/download/M130.0.6723.174/thorium_AVX2_mini_installer.exe" -File "$env:TEMP\Thorium Browser.exe"
                # install thorium browser
                Start-Process -wait "$env:TEMP\Thorium Browser.exe" -ArgumentList "/S"
                $thoriumPaths = @(
                    "$env:LOCALAPPDATA\Thorium\Application\thorium.exe"
                )
                $chromiumExtensions = @(
                    "https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm",
                    "https://chromewebstore.google.com/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp",
                    "https://chromewebstore.google.com/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi",
                    "https://chromewebstore.google.com/detail/search-by-image/cnojnbdhbhnkbcieeekonklommdnndci",
                    "https://chromewebstore.google.com/detail/decentraleyes/ldpochfccmkkmhdbclfhpagapcfdljkj"
                )
                $thoriumPath = $thoriumPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($thoriumPath) {
                    foreach ($extension in $chromiumExtensions) {
                        Start-Process $thoriumPath $extension
                    }
                }
                show-menu
            }
            23 {
                Clear-Host
                Write-Host "Installing: Brave Browser . . ."
                # download brave browser
                Get-FileFromWeb -URL "https://laptop-updates.brave.com/latest/winx64" -File "$env:TEMP\BraveBrowserSetup.exe"
                # install brave browser
                Start-Process -wait "$env:TEMP\BraveBrowserSetup.exe" -ArgumentList "/silent", "/install"
                $bravePaths = @(
                    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe",
                    "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
                )
                $chromiumExtensions = @(
                    "https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm",
                    "https://chromewebstore.google.com/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp",
                    "https://chromewebstore.google.com/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi",
                    "https://chromewebstore.google.com/detail/search-by-image/cnojnbdhbhnkbcieeekonklommdnndci",
                    "https://chromewebstore.google.com/detail/decentraleyes/ldpochfccmkkmhdbclfhpagapcfdljkj"
                )
                $bravePath = $bravePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($bravePath) {
                    foreach ($extension in $chromiumExtensions) {
                        Start-Process $bravePath $extension
                    }
                }
                show-menu
            }
            24 {
                Clear-Host
                Write-Host "Installing: Microsoft Office 2024 LSTC Edition . . ."
                $toolPath = "$env:TEMP\officedeploymenttool_18227-20162.exe"
                $configurationPath = "$env:TEMP\OfficeDeployment\configuration-Office365-x64.xml"
                # download microsoft office
                Get-FileFromWeb -URL "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18227-20162.exe" -File $toolPath

                # extract office deployment tool
                Start-Process -FilePath $toolPath -ArgumentList "/quiet /extract:$env:TEMP\OfficeDeployment" -Wait

                # create configuration file
                $configureOffice = @"
<Configuration ID="7ccad42d-bf21-44c0-8399-a0d9fba9ba0c">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2024">
    <Product ID="ProPlus2024Volume" PIDKEY="XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB">
      <Language ID="en-gb" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="Outlook" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Updates Enabled="TRUE" />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
</Configuration>
"@
                $configureOffice | Set-Content -Path $configurationPath -Force
                # install microsoft office
                Start-Process -FilePath "$env:TEMP\OfficeDeployment\setup.exe" -ArgumentList "/configure $configurationPath" -Wait
                # activating microsoft office
                Write-Host "Activating Microsoft Office . . ."
                $officePaths = @(
                    "$env:ProgramFiles(x86)\Microsoft Office\Office16",
                    "$env:ProgramFiles\Microsoft Office\Office16"
                )

                foreach ($path in $officePaths) {
                    if (Test-Path $path) {
                        Set-Location -Path $path
                        $licenseFiles = Get-ChildItem -Path "..\root\Licenses16\ProPlus2021VL_KMS*.xrm-ms"
                        foreach ($file in $licenseFiles) {
                            Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /inslic:`"$file`"" -Wait
                        }
                        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /setprt:1688" -Wait
                        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /unpkey:6F7TH >nul" -Wait
                        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /inpkey:FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH" -Wait
                        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /sethst:107.175.77.7" -Wait
                        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /act" -Wait
                    }
                }
                show-menu
            }
        } 
    }
    else { Write-Host "Invalid input. Please select a valid option (1-24)." } 
}