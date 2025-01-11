# get motherboard id
$instanceID = (wmic baseboard get product)
# search motherboard id in web browser
Start-Process "https://www.google.com/search?q=$instanceID"