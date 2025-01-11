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

Write-Host "Installing: Cpu Z . . ."
# download cpuz
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Cpu%20Z.zip" -File "$env:TEMP\Cpu Z.zip" 
# extract files
Expand-Archive "$env:TEMP\Cpu Z.zip" -DestinationPath "$env:TEMP\Cpu Z" -ErrorAction SilentlyContinue
# start cpuz
Start-Process "$env:TEMP\Cpu Z\cpuz_x64.exe"
Clear-Host
Write-Host "Check (XMP DOCP EXPO) is enabled."
Write-Host "Verify RAM is in the correct slots."
Write-Host "Confirm there is no mismatch in RAM modules."
Write-Host "At least two RAM sticks (dual channel) is ideal."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
