# Workshop: Security Operations with Powershell

**Aaron Rosenmund**
*@arosenmund*


2 Hour Workshop 10am to 12pm

## Introduction (Abstract)
Following along with the spirit of powershelling all of the things, open-source PowerShell and PScore 7+ supported all OS platforms; it is time to learn multi-platform PowerShell security operations. Stopping there?  No way! With information coming from every source imaginable, you need a way to collect and analyze that information. Which is a perfect job for everyone's favorite open source database/interface solution, the Elastic Stack. Powershell is either already in place or allowed by default in many restricted environments and makes and makes for a ubiquitous living on the land binary for defensive cyber operators.

Whether performing continuous monitoring, intermittent threat hunting, or incident response, having access to the devices and resources available in your respective enterprise is a success condition. In this workshop, you learn how to install PowerShell cor 7 (current release) on Windows, Linux, and macOS devices through different local and remote install options. Next, you learn to leverage winRM for windows and ssh remoting for nix/osx devices to create power shell remote connections to each device. With PowerShell remote sessions established to every device, everything is pretty familiar.  Pull net connections, query running process, and several other available queries useful for identifying malicious activity and pull that back to your centralized "security operations" endpoint. If you don't have the flexibility to create an elasticsearch service in your environment, don't sweat it.  Aggregating, analyzing, and reporting interesting findings with nothing more than PowerShell is the perfect tool for your toolbelt.  But, for when the opportunity arises, you will learn to quickly spin up a cloud instance, convert your freshly procured security opeartions data into json, ingest ,and analyze in kibana with ease and dashboard creating swag over 9000. 

## Setting Up your PowerShell Environment                               15 min
## Powershell Network Discover and Enumeration                          20 min
## Deploying PowerShell core 7 on dissimilar OS's                       15 min
## Creating Powershell Remoting Sessions with Winrm and SSH             20 min
## Running OS information queries across your Environment               20 min
## Collecting and Analyzing Information with PowerShell                 10 min
## Analyzing Powershell Collected Information with the Elastic Stack    20 min

Pre- Requirements:  Create an elasticsearch cloud trial account, have 1 of each a Linux OS and 1 Windows OS, VM, or hard box prepared. If you also are virtualizing these on a Mac, then that is helpful, but we will have a Mac device for you to connect to if you like(be nice).


modifications: 
- No mac available but feel free to use your own.
- No Brandon @solderswag totally bailed to go train americas best and brightest in the ways of the cyber


# Setting Up your PowerShell Environment 15 Minutes 10:00 - 10:15am

First thing first, we will be setting the environment from which you will run the scans and detections. Ideally this is done on windows environment.  The idea is that there will likely be a windows device in your enviornment, and you can use any windows device to run sucrity operations.  Many of which can be done without administrative acces.

Download the correct file from this location, under **preview** and this will give you the 

https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0-preview.6

Install the file on your system.

Verify opening of the powershell core shell and record where that executable exists as well as it's location.

Open a command prompt, terminal or standard powershell terminal and launch powershell core 7.

Should be **"c:\program files\powershell\7-preview\pwsh.exe"**

You now have installed the latest build of powershell core.  This is a very similar process for the other supported OS's.

# Now for some theory!

This is not about trying to replace other capabilities.  It is not about creating a custom soluion or the next open soruce sensation. It is about prvoiding the tools and the framework of thought to accomplish security operations, detcions, and hunts regardless of your environment, funding or softwar constraings.

This has been a solution that I have used time and time again, and the process goes like this.

Collected Data with PS-->Store in XML-->Analyze the Collected Data-->Display Analysis

Powershell
XML
MorePowershell
Php.exe

Projects using this methodology: 

### MigrationTime

### SiteChecker

### CreepTumor

Applying that to security operations.

Identify Scope of Environment-->Scan Scope for live Devices-->Analyze scan data to build asset list-->Interogate Assets-->Analyze Data

This is what the scripts inside this git repo accomplish, but with a bonus of being able to interogate linux and mac devices with powershell core. Hurray!

If you don't have git installed you can simply browse to the github repo and download the zip file.

In a terminal of some kind.


```
git clone github.com\arosenmund\powershellops

https://github.com/arosenmund/powersecops.git

cd "C:\"

```

CD "c:\powersecops"

This is the main folder with a structure of the following:

c:\powersecops
    - 1-create-target.ps1
    - f:1-targets-xml
    - 2-network-discovery.ps1
    - f:2-scanresults-current-xml
    - f:2-scanresults-historical-xml
    - f:2-scanresults-html
    - 3-endpoint-scan.ps1
      - f:os-current-xml
      - f:os-historical-xml
      - f:os-html
    - 4-analysis.ps1
      - f:analysis-current-xml
      - f:analysis-historical-xml
      - f:analysis-html
   -f:references

```
cd references/creep_tumor_master/
php.exe -S localhost:777
```

> Browse to localhost:777 to find sample page showing a basic example of what can be done with this example.

This is not security data but this is one way you can visualize this data once it is created and analyzed. Another option is to use an Elastic stack but this will require some manipulation for your specific dataset...also Brandon isn't here.

The basic environment is setup time to get to our specific use case.

# 2) Powershell Network Discover and Enumeration (20 min) 10:15 - 10:35am

> Who came ready with VM's? If you did set up nat translation for your vm's to share your host networks and use the NAT vmnet as the target.

Depending on networking, you may be able to reach the devices setup for this workshop that infomration will be used in the demos and is here:


| Parameter | Value   |
|---|---|
| Domain  | globomantics.local  |
| Gateway | 192.168.43.1 |
| First IP | 2 |
| End IP | 254 |
| Port Scan | $true |


## Create Targets

> Windows tested and vscode will be used to view, review an run the code throughout.

In terminal of your choice run:

`c:\program files\powershell\7-preview\pwsh.exe`

This enters the powershell core 7 shell.

Open **c:\powersecops\1-create-target.ps1**

Script Notes:
  - Creates psobject and stores as xml
  - Tests connection to use that data to save time
  - Iterates through ID numbers to prevent clobbering

Change path variable *$wd* to match your environment before running.

This script will create a target file in the associated targets folder to be used in the next steps.  You can create as many as you would like and the following scripts will use this data to perform scans subsequent interrogation of devices found in each subnet.

Verify the creation of that file and open the c:\powersecops\2-network-discovery.ps1

Script Notes:
  - Imports multple targets and combines them into one object
  - Watchout for single row vs multi row object behavior
  - Splits and recreates just the first 3 of the IP
  - Creates range based on start and end ip
  - Only uses networks that were determined to be up.(May need to change behavior based on ICMP usage)
  - Test connection to each ip, then tests the remaining of the ports.  Simple to add a port to check.  (Common Port vs Specified Port)
  - Test connection behavior different for powershell core
  - Throttles jobs for memory(may not work on all OS's)

Run the script to begin scanning your environment, if it is just your local environment only one or two machines will show up.  If you are trying to scan the entire wifi network..it will be more but they won't be useful to you as you move forward.  No guaruntees the devices I have set up can handle all of you scanning. At the time I am writing this I don't know how many of you there are.

Once it is complete it will save 3 separate reports.  You guessed it those will be used in the 3rd script and only the devices that responded with data will be used for interogation.  

But first those devices need to be setup.

## Deploying PowerShell core 7 on dissimilar OS's (15 min) 10:35 - 10:50

> You will not be able to use the workshop devices for this, they have already been setup, staged for the following steps.

From a windows or macOS device.  Using your virtualization system of choice have a running windows virtual machine and a running ubuntu virtual machine.
All downloads are located here:
https://github.com/PowerShell/PowerShell

All OS installation instructions are located here:
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7


## Ubuntu 18.04


```
scp c:\powersecops\powershell-preview_7.0.0-preview.6-1.ubuntu.18.04_amd64.deb tstark@x.x.x.x:/home/tstark
**In Ubunute Device**
sudo dpkg -i powershell-preview_7.0.0-preview.6-1.ubuntu.18.04_amd64.deb
sudo apt-get install -f
sudo dpkg -i powershell-preview_7.0.0-preview.6-1.ubuntu.18.04_amd64.deb

**Configure ssh client**

sudo apt-get install openssh-client
sudo apt-get install openssh-server
sudo nano /etc/sshd/sshd_config
```
Ensure **PasswordAuthentication: YES** 
and add
**Subsystem powershell /usr/bin/pwsh-preview -sshs -NoLogo -NoProfile**

Save and close

`sudo service sshd restart`

> Always verify it worked!  

Back in you main device with connectivity to the ubuntu device that was just setup for SSH, open a powershell core 7 shell and run the following to connect to the device over ssh.

First verify that openssh is properly installed on the windows device. (Not an issue for MacOS or Linux)

`(Get-Command New-PSSession).ParameterSets.Name`

If you see the  ssh parameters you are in business. If not run the following to install the client and server:
```
## Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

## Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

## Both of these should return the following output:

Path          :
Online        : True
RestartNeeded : False
```

Then attempt to create a new session.

`new-pssession -hostname x.x.x.x -username tstark -SSHtransport`

> **Hostname** seems to triger it whereas **Computername** attempts winrm.

If you connect you are good to go and you can now run awesome powershell commands on ubuntu remotely. 


# Windows 10 - WinRM/WSMAN

On windows you have to run the install powershell remoting script!!!!!  It comes with the package.

Notes:
- Ensure the device is on a private network
- Run as administrator
- Ensure you have a local user with admin rights. (In production you would use domain credentials.)
- No it isn't really going to be this easy.

You will notice it says it is setup and ready to roll but WINRM is a bit more finicky than that especially on a non-domain joined device.

Attempt to connect in your powershell core 7 shell

```
$cred = get-credential devicename\username

new-pssession -computername x.x.x.x -credential $cred
``` 

# Creating PowerShell Remoting Sessions with WinRM and SSH (20 min) 10:50pm - 11:10pm

## Ubuntu - SSH

> Using a password after being prompted is not condusive to automation. So you need to setup RSA keys.

Back on the Ubuntu device run the following commands to generate a key, and add that key to the ssh service.

```
ssh-keygen -t rsa -b 4096

ssh-copy-id -i ~/.ssh/id_rsa tstark@<host>
```
Then copy the public and private key to the main device from which you are performing the remoting.

You can copy these to the sshd configs for every linux device to remote using the same private key. Allowing for proper auomation.

Test with the following command:

new-pssession -hostname x.x.x.x -username tstark -keyfilepath c:\powersecops\id_rsa  -sshtransport

With a successful loging you should simply be able enter the session and run commands.

> Rembmer you can run some nromal bash commands within the pssession as well.


## Windows

winrm is no done with you yet!

```
winrm qc
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

```

`Set-Item "wsman:\localhost\client\trustedhosts" -Value '*' -Force` 
or 
`Set-Item "wsman:\localhost\client\trustedhosts" -Value 'x.x.x.*' -Force`

Now test again!

```
$cred = get-credential <computername>\tstark
new-pssession -computername name -credential $cred
```
That worked now take it for a test ride.



# Running OS information queries across your Environmnet (20 min) 11:10 - 11:30


Now that is all done and you are set up for automatin of endpoint interogation time!

On your main devices that you started on, the one responsible for the tragets and scanning, open a powershell core prompt as well as the script **c:\powersecops\3-endpoint-scan.ps1**

Script Notes:
  - throttles as well
  - only focuses on device detrmined up from previous scan output
  - leverage invoke-command

get-process
get-filehashes
netstat

> Potenial to display that info with html browser and php.

# Collecting and Analyzing Information with PowerShell  (10 min) 11:30 - 11:40 

Open the **c:\powersecops\4-analysis.ps1**

Script Notes:
- Collect into xml files
- Import into analysis script
- Import all data.

Pick out intersting things:

- services that happen only a few times.
- processes with cmd arguments
- processes with no on disk image
- connections that are not on all the devices (listenint|established) 

## Analyzing Powershell Collected Information with Elastic Stack (20 min) 11:40 12:00


Sign up with no credit card required here:
https://www.elastic.co/cloud/elasticsearch-service/signup

create un:pw  by verifying the email account

Create deployment.

Launch kibana.

Convert the data to JSON.  

Then upload the files directly through kibana. JSON 

Browser to that data

Elasticsearch is the database backend that we will be duming data into.  It will not be formatted but could be prior to it being injest as well as manipulation of the files to allow for better searching nd dashboards to be created. 

