# get motherboard id
$instanceID = (wmic baseboard get product)
# search motherboard id in web browser
Start-Process "https://duckduckgo.com/?q=$instanceID"