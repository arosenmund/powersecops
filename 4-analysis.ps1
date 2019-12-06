# Powershell Operations with Powershell Core

#Ensure Environemnt is Built
## enter your working directory

$wd "c:\powersecops"

# Hosts Up

$scan_results = Import-Clixml C:\powersecops\2-scanresults-current-xml\*

$scan_analysis = @()
$networks = $scan_results |where-object -prop
$Hosts_Up = $scan_results |?{}

$properties = @{

    Networks = $networks
    Hosts_Up = $hosts_up
    HTTP_Open = $http_count
    Linux = $linux_count
    Windows = $windows_count


}

$scan_analysis = New-Object -TypeName psobject -Property $properties
#Setup environment if required.

osscan_results = Import-clixml C:\powersecops\3-osresults-current-xml\













