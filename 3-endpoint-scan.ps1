# Endpoint Scans

# Import targets from up list only!
# Network Discovery
$wd =  "C:\powersecops"

$targets = get-childitem $wd"\2-scanresults-current-xml"

$obj= @() ## Import targets

foreach($t in $targets){

$p = $t.name

$o = Import-Clixml -path $wd\2-scanresults-current-xml\$p

$obj += $o

}
$obj |format-table



#select alive targets

$endpoints_ssh = $obj |where-object -propert ssh_status -eq $true

#$endpoints_winrm = $obj | ?{$_. -eq $true}



$linuxps = @()

foreach($ep in $endpoints_ssh){

$hostname = $ep.IP4_Address


$process = Invoke-Command -hostname $hostname -UserName tstark -KeyFilePath C:\powersecops\id_rsa -ScriptBlock {get-process} -AsJob

$linuxps += $process

}
$date = (get-date).DateTime
$linuxps | Export-Clixml C:\powersecops\3-osresults-current-xml\Linux-Process.xml
$linuxps | Export-clixml C:\powersecops\3-osresults-historical-xml\Linux-Process-$date.xml
$linuxps | convertto-html C:\powersecops\3-osresults-html\Linux-Process-$date.html

# windows
$cred = get-credential DESKTOP-G
$windowsps

foreach($ep in $endpoints_winrm){

$hostname = $ep.IP4_Address

$session = new-pssession  -computername $hostname -credential $cred

$process = Invoke-Command -Session $session -ScriptBlock {get-process}

$windowsps += $process

}

$date = (get-date).DateTime
$windowsps | Export-Clixml C:\powersecops\3-osresults-current-xml\Linux-Process.xml
$windowsps | Export-clixml C:\powersecops\3-osresults-historical-xml\Linux-Process-$date.xml
$windowsps | convertto-html C:\powersecops\3-osresults-html\Linux-Process-$date.html
