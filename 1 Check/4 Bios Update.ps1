$mbInfo = Get-WmiObject win32_baseboard | Select-Object Product
$mbModel = "$($mbInfo.Product)"
$url = "https://www.duckduckgo.com/?q=$mbModel"
Start-Process $url
