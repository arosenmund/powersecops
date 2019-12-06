# Network Discovery
$wd =  "C:\powersecops"

$targets = get-childitem $wd\1-targets-xml

$obj= @() ## Import targets
foreach($t in $targets){

$p = $t.name

$o = Import-Clixml -path $wd\1-targets-xml\$p

$obj += $o
}

$obj |fl

write-host "Targets Loaded"

# powerscan function

#subnetscan

$wd = "C:\powersecops\"

write-verbose "Welcome to power-scan the least creative name th3m3ch4nic could think of, but alas we can't choose our parents."

#First step run according to input, display results in chart.  One off capability.
#Next step, run off of generated configuration file.  Store data in the collection per network and use change tracking dashboard.
#Subnet Comparison
    $report = @() #initialize memory space for the 

    get-job|remove-job #removes jobs from last run

    #first octet
    #$first_three = read-host "Please enter the  frist 3 octets of network to be scanned with a '.' at the end.  
    #Like so:  Examples: 192.168.1."


    #last octet
    #$Starting_IP = read-host "Enter starting ip (last octet)"
    #$Ending_IP= read-host "Enter ending ip (last octet)"

    #Maybe some sort of range of ports option here?
$object = $obj|?{$_.up -eq $true}


foreach($obj in $object){
    #parse input for scanning
    
    $l = $obj.network[$i].Length
    if($l -lt 4){
        $firstthree = $obj.network
        $iprange = $obj.start_ip..$obj.end_ip
    }else{
        $firstthree = $obj.network[$i]
        $iprange = $obj.start_ip[$i]..$obj.end_ip[$i]
    }

   $firstthree = $firstthree.split(".")[0] + "." + $firstthree.Split(".")[1] + "." + $firstthree.split(".")[2] + "."

    ###need to add progress bar###

    Foreach( $ip in $iprange){
        $c = $iprange.count
        $o = 1

        write-progress -Activity "Scanning the input range." -Status "Starting job for $ip"  -PercentComplete ($ip/$c*100)
        
        $I = $firstthree+[string]$ip

        Start-Job -Name "Testing $I" -ArgumentList $I -ScriptBlock {
        Try {$name = [System.net.DNS]::GetHostByAddress($args[0])|select-object HostName -ErrorAction Continue}catch{write-host "Input null or non resolved"}

        #Try {icmp_response = test-netconnection -port $port_TCP -InformationLevel Quiet -ComputerName $I  -erroraction Continue}catch{write-verbose "blip blop"}
        Try {$response = test-connection -quiet -Count 1 -ComputerName $args[0]  -erroraction Continue}catch{write-host "ICMP response failed to "+ $args[0]}
                if($response -eq $true){$more = test-connection -count 1 -ComputerName $args[0]}
        Try {$SMB_response = Test-NetConnection -ComputerName $args[0] -CommonTCPPort SMB -InformationLevel Quiet -ErrorAction Continue}catch{write-host "SMB Connection failed to $args[0]"}
        Try {$RDP_response = Test-NetConnection -ComputerName $args[0] -CommonTCPPort RDP -InformationLevel Quiet -ErrorAction Continue}catch{write-host "RDP Connection failed to $args[0]"}
        Try {$WINRM_response = Test-NetConnection -ComputerName $args[0] -CommonTCPPort WINRM -InformationLevel Quiet -ErrorAction Continue}catch{write-host "WINRM Connection failed to $args[0]"}    
        Try {$HTTP_response = Test-NetConnection -ComputerName $args[0] -CommonTCPPort HTTP -InformationLevel Quiet -ErrorAction Continue}catch{write-host "HTTP Connection failed to $args[0]"}
        Try {$SSH_response = Test-Netconnection -ComputerName $args[0] -port 22 -InformationLevel Quiet -ErrorAction Continue}catch{write-host "SSH Connection failed to $args[0]"}
                #if($SMB_response -eq $true -or $RDP_response -eq $true -or $WINRM_respone -eq $true -or $HTTP_response -eq $true){
                #        Port_scan($I)
                #}

        $properties = @{

                    IP4_Address = $args[0]
                    Computer_Name = $name.HostName
                    Response_Status = $response
                    Time_to_Live = $more.reply.options.ttl #pscore specific
                    Response_time = $more.latency # pscore specific
                    SMB_Status = $SMB_response
                    RDP_Status = $RDP_response
                    HTTP_Status = $WINRM_response
                    WINRM_Status = $HTTP_response
                    SSH_Status = $SSH_response

                    }

        new-object -TypeName psobject -Property $properties
        
        }

    #memory throttle

        $memuse = Get-Counter -counter "\memory\% committed bytes in use"
        $percmem = $memuse.CounterSamples.cookedvalue
        write-host "Current mem usage is $percmem percent."
        While($percmem -gt 80){

                                write-host "Mem is too high....throttling for you pleasure."; start-sleep 1
                                $memuse = Get-Counter -counter "\memory\% committed bytes in use"
                                $percmem = $memuse.CounterSamples.cookedvalue
                                write-host "Current mem usage is $percmem percent."
                            }
        $o++
    }

    #####need to wait for all jobs to finish cyclically then recieve them and add them to the report.

    $report = get-job |receive-job -Wait -AutoRemoveJob

    $date = get-date -format dd_MM_yy_HHmmss
    $sp = $obj.start_ip
    $ep = $obj.end_ip
    $report |Export-Clixml -path $wd/2-scanresults-historical-xml/$firstthree-$sp-$ep-$date.xml
    $report |Export-Clixml -path $wd/2-scanresults-current-xml/$firstthree-$sp-$ep.xml
    $report |convertto-html |out-file $wd/2-scanresults-html/$firstthree-$sp-$ep-$date.html
    }


# Build list of "UP" Targets

