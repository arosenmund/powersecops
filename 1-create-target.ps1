# Target Creation

$wd =  "C:\powersecops\"
#Collect Target Information

$id = (Get-childitem $wd/1-targets-xml).count + 1
$domain = read-host "Domain FDQN"
$network = read-host "Network Gateway"
[int32]$start_ip = read-host "First IP to Scan"
[int32]$end_ip = read-host "Last IP to scan."
[bool]$portscan = read-host "Perform portscan? $true/$false"
[bool]$up = test-connection  $network -quiet

$Properties = @{
    target_id = $id
    domain = $domain
    network = $network
    start_ip = $start_ip
    end_ip = $end_ip
    portscan = [bool]$portscan
    up = $up
}

$target = New-Object -TypeName psobject -Property $Properties

$target |Export-Clixml -path $wd/1-targets-xml/$id-$domain-$network.xml

Write-Host "Saved target $id"
$target

