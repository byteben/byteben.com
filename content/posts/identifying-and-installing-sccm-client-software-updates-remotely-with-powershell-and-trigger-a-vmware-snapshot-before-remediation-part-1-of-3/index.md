---
title: "Identifying and Installing SCCM Client Software Updates Remotely with PowerShell and trigger a VMware Snapshot before Remediation - Part 1 of 3"
date: 2018-12-28
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
tags: ["configmgr", "powershell", "sccm", "software-updates", "vmware", "wmi"]
categories: ["configmgr-memcm-sccm", "microsoft"]
---

Try saying that title again without taking a breath, phew.

<!--more-->

We have been playing with ADRs (Automatic Deployment Rules) for a while now. The teams are slowly coming around to the idea that we are now delivering server updates in a more controlled fashion than WSUS could ever provide with useful reports icing the top of this new cake.

Moving from a legacy "We install patches when we can - if we want" mindset to full update automation is going to take a little while for our server admins to swallow. The following posts in this series will hopefully bridge the gap from manual update practices to full automation.

Lets face it, SCCM is awesome. Most of us will be perfectly happy using everything in the SCCM arsenal to manage, deploy and install Software Updates. I have been looking at the whole patch lifecycle which, for our environment, requires taking a snapshot of the VM before remediation. Yes I could tie the teams down to a maintenance window and schedule a VM snapshot before remediation. That is one perfectly reasonable way to do it. As I said earlier, we will get to full automation one day. The following scripts are a stop gap for us and it also gives me a great chance to understand the deep WMI mechanisms SCCM leverages for Patch Management and Remediation...and it sharpens my PowerShell...I wont use the word skill :p

The key Software Update challenges for our teams are:-

1. Identifying SCCM Client non compliance for Software Updates
2. Snapshot a VM before Software Update Remediation
3. SCCM Software Update Remediation

We will focus on each of these in 3 different posts for this mini series, starting with Part 1 below.

### Identifying SCCM Client Non Compliance for Software Updates - Using PowerShell

Let us make an assumption, we have deployed Software Updates to our clients using SCCM. We can identify required Software Updates on clients using 3 methods:-

1. From the SCCM Admin Console
2. Using a SQL Query / SSRS (Report)
3. Local or Remote WMI Query

For the purpose of this series, we are going to be using PowerShell to connect to the clients to identify any non-compliant Software Updates. The bigger picture here is that we are going to install the updates (Part 3) using the same script so it makes sense to ensure we can establish a remote connection to the client. We will be using the same PowerShell script to trigger a VMware Snapshot on each client too (Part 2) before remediation.

#### WMI

> PowerShell and WMI - a match made in, er , a computer.
> 
> Famous quote by Ben Whitmore

Let's start off with the basics. How do we connect to a client to enumerate required updates?

You need to ensure the following:-

1. The SCCM client is installed (sorry, had to say it)
2. You can connect to the Remote WMI Service on the Client [https://docs.microsoft.com/en-us/windows/desktop/wmisdk/connecting-to-wmi-on-a-remote-computer](https://docs.microsoft.com/en-us/windows/desktop/wmisdk/connecting-to-wmi-on-a-remote-computer)
3. You have the necessary permissions (normally Administrator) on the Client (See 2).

All the above sound obvious but they will become a possible deal breaker later when we start to target SCCM Collections. Anyway, I'm in danger of peaking too soon, back to the basics.

**Get-WMIObject**

...Is your friend. If you are have PowerShell 3.0 and above you could expose WMI info using Get-CIMInstance (Thanks @GuyRLeech) but I'm keeping it old school here. Get-WMIObject works just fine and most of the documentation you find for WMI/SCCM refers to the Get-WMIObject cmdlet. If interested, more can be found on Get-CIMInstance here [https://docs.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance?view=powershell-6](https://docs.microsoft.com/en-us/powershell/module/cimcmdlets/get-ciminstance?view=powershell-6)

SCCM has a number of WMI Classes exposed on the client, full details here [https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/client-sdk-wmi-classes](https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/client-sdk-wmi-classes)

The Class we are interested in to check for required Software Updates is CCM\_SoftwareUpdate class [https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/ccm\_softwareupdate-client-wmi-class](https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/ccm_softwareupdate-client-wmi-class)

> The software update client side SDK will only return a set of updates which are deployed to the client from the Configuration Manager site server, are applicable and are yet to be installed on the client.
> 
> Microsoft Source

So an example of what the code might look like to connect to a client and enumerate the required software updates could be:-

```
$Client = "LabPC1"
Get-WmiObject -ComputerName $Client -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where-Object { $_.ComplianceState -eq "0" } | Select @{ Name = 'Client'; Expression = { $Client } }, Name, ComplianceState, EvaluationState, URL
```

This would return something similar to:-

<figure>

[![](/images/2018/12/WMI_SU_PowerShell_1-1024x284.jpg)](/images/2018/12/WMI_SU_PowerShell_1.jpg)

<figcaption>

Results from Querying WMI Class CCM\_SoftwareUpdate Class on Client labpc1

</figcaption>

</figure>

Well that's pretty. We see the Required Software Updates for this client. Imagine a Snowman in a snow globe. He doesn't care where the snow comes from, he just cares that there is snow - likewise our clients just care there are required updates and if they are in compliance.

#### Meaty Stuff (no pie - just WMI)

But we live in the real world. It's pretty neat to be able to use that quick bit of code to check the Software Update Compliance for a single client but my colleagues manage quite a few of them. What if we want to enumerate the same information for multiple clients that are members of a particular collection? That would be quite a normal ask because, after all, our Software Update Groups are deployed to collections. Collections are the neurons that connect the SCCM brain to its Borg subordinates (Clients).

PowerShell (flex biceps) - We will be doing the following in PowerShell:-

1. Connecting to the Site Server
2. Get the members of a specific collection (we will use this for Part 2 of this series too)
3. Attempt a Remote Connection to the collection members
4. If a connection attempt is unsuccessful, catch the error and write to host
5. If the connection is successful, save the results to a new array (Used for Part 3 of this series) and display the results in the console window - because we like to see stuff.

Source:  
[https://github.com/byteben/Get-SoftwareUpdates/blob/master/Get-SU.ps1](https://github.com/byteben/Get-SoftwareUpdates/blob/master/Get-SU.ps1)

```
<#
Get-SU.ps1
Get Required Software Updates for members of a collection and write to Host the results.
#######
Author: Ben Whitmore
Website: byteben.com
Disclaimer: I do not accept any liability this code may have in your Environment. Always test your scripts before using them in a Production Environment.
#######
Example: Get-SU.ps1 -SitServer PSS1 -SiteCode PS1 -Collection SU_Test
#######

Version 1.0 (30/12/18)
Original Script
-------
Version 1.1 (1/1/2019)
Used Array to store EvaluationStateStatus String in $SoftwareUpdates_Append Object instead of calling an If statement for each option - Thanks @GuyrLeech
-------
Version 1.2 (21/03/19)
$Collection members would only return direct membership clients. Update to work with all collection member types
-------
#>

#Set Parameters for Connection
Param (
	[Parameter(Mandatory = $True)]
	[string]$SiteServer = 'PSS1',
	[Parameter(Mandatory = $True)]
	[string]$SiteCode = 'PS1',
	[Parameter(Mandatory = $True)]
	[string]$Collection = 'SU_Test'
)
#Attempt Connection to Site Server and get Clients from Collection
Try
{
	$ErrorActionPreference = "Stop"
	$CollectionResult = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection | where {$_.Name -eq "$Collection"}
}
#If Connection to Site Server fails, or an invalid Collection is specified Write-Host
Catch
{
	Write-Host 'Error Caught Connecting to Site Server. Please retry and check the values for:-' -ForegroundColor Magenta
	Write-Host 'SiteServer: ' -ForegroundColor Blue -NoNewLine; $SiteServer
	Write-Host 'SiteCode: ' -ForegroundColor Blue -NoNewLine; $SiteCode
	Write-Host 'Collection: ' -ForegroundColor Blue -NoNewLine; $Collection
}

#If connection to Site Server is successful and a valid Collection specified add collection members to $Members Object 
$Members = Get-WmiObject -ComputerName $SiteServer -Credential $cred -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($CollectionResult.CollectionID)' order by Name" | select Name

Write-Host "`n---------------------------------------------------------" -ForegroundColor Green
Write-Host "Attempting Connection to "$Members.Count"Clients in Collection "$Collection":" -ForegroundColor Green
Write-Host "---------------------------------------------------------" -ForegroundColor Green
Write-Host $Members.Name

#Create Catch Fail Array
$RPCFailArray = @()

#Connect to Clients in $Members Object
#For each Client in $Members object, connect to the CCM namespace and query Software Updates that are out of compliance
$SoftwareUpdates = ForEach ($Client in $Members)
{
	Try
	{
		Get-WmiObject -ComputerName $Client.Name -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where-Object { $_.ComplianceState -eq "0" } | Select @{ Name = 'Client'; Expression = { $Client.Name } }, Name, ComplianceState, EvaluationState, Deadline, URL -ErrorAction Stop
	}
	Catch
	{
		#If WMI connection fails, add the Client and Exception thrown into an array
		$RPCFailArray += New-object  PSObject -Property ([ordered]@{ Client = $Client.Name; Exception = $_.Exception.Message })
	}
	
}

#If $RPCFailArray is not empty, Write-Host any failures to connect to Clients
If (@($RPCFailArray).Count -ne 0)
{
	$Format_RPCFailArray =
	@{ Name = 'Client'; Expression = { $_.Client } },
	@{ Name = 'Exception'; Expression = { $_.Exception } }
	$Format_RPCFailArrayResult = $RPCFailArray | Format-Table $Format_RPCFailArray -AutoSize | Out-String
	Write-Host "`n---------------------------------------------------------" -ForegroundColor Red
	Write-Host "Couldn't connect to"@($RPCFailArray).Count "Clients:" -ForegroundColor Red
	Write-Host "---------------------------------------------------------" -ForegroundColor Red
	Write-Host $Format_RPCFailArrayResult
}
#Create new Array to Append Evaluation State Status (Integer to String)
<# https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/ccm_softwareupdate-client-wmi-class
The EvaluationState property is only meant to evaluate progress, not to find the compliance state of a software update. When a software update is not in a progress state, the value of EvaluationState is none or available, depending on whether there was any progress at any point in the past. This is not related to compliance state. Also, if a software update was downloaded at activation time, the value of EvaluationState is none. This value only changes once an install is attempted on the software update.
#>
$SoftwareUpdates_Append = $SoftwareUpdates | Select *

#Create Array for EvaluationStateStatus
$EvaluationStateStatus = @('None', 'Available', 'Submitted', 'Detecting', 'PreDownload', 'Downloading', 'WaitInstall', 'Installing', 'PendingSoftReboot', 'PendingHardReboot', 'WaitReboot', 'Verifying', 'InstallComplete', 'Error', 'WaitServiceWindow')

$SoftwareUpdates_Append | ForEach-Object {
	
	If ($_.EvaluationState -ne $Null)
	{
		$_ | Add-Member -MemberType NoteProperty -Name 'EvaluationStateStatus' -Value $EvaluationStateStatus[$_.EvaluationState]
	}
	
}

#Formats Array for Output and display updates, per Client, that are out of compliance
$Format_SoftwareUpdatesArray =
@{ Name = 'Client'; Expression = { $_.Client }; Alignment = "Left" },
@{ Name = 'Name'; Expression = { $_.Name }; Alignment = "Left" },
@{ Name = 'ComplianceState'; Expression = { $_.ComplianceState }; Alignment = "Left" },
@{ Name = 'EvaluationState'; Expression = { $_.EvaluationState }; Alignment = "Left" },
@{ Name = 'EvaluationStateStatus'; Expression = { $_.EvaluationStateStatus }; Alignment = "Left" },
@{ Name = 'Deadline (en-GB)'; Expression = { $Date = $_.Deadline -replace ".{11}$"; $Date = [datetime]::parseexact($Date, 'yyyyMMddhhmmss', $null); $Date.ToString('dd/MM/yyyy hh:mm:ss') }; Alignment = "Left" },
@{ Name = 'URL'; Expression = { $_.URL }; Alignment = "Left" }
$Format_SoftwareUpdatesArrayResult = $SoftwareUpdates_Append | Format-Table $Format_SoftwareUpdatesArray -AutoSize | Out-String

Write-Host "`n---------------------------------------------------------" -ForegroundColor Green
Write-Host "Listing Non Compliant Updates for"($Members.Count - $RPCFailArray.Count)"/"$Members.Count"Clients:" -ForegroundColor Green
Write-Host "---------------------------------------------------------" -ForegroundColor Green
Write-Host $Format_SoftwareUpdatesArrayResult
```

<figure>

[![](/images/2018/12/WMI_SU_PowerShell_2-1024x445.jpg)](/images/2018/12/WMI_SU_PowerShell_2.jpg)

<figcaption>

Console Output from Script

</figcaption>

</figure>

- So what do we have here? We can see that we ran the script, specifying the Site Server, Site Code and Collection as parameters.
- The Collection had 7 members. We were able to successfully connect to 4 of them and list the required Software Updates.
- 3 Connections were unsuccessful, we caught the error and formatted it nicely in the console.
- We created a column called "EvaluationStateStatus" - This isn't necessary but I like it for easy interpretation of the "Evaluation State" code.
- We formatted the Deadline date column
- The results for non compliant updates in the collection are saved in the array $SoftwareUpdates. We also saved another array with the additional "EvaluationStateStatus" as $SoftwareUpdates\_Append
- We also have an array for $Members which we can use for Part 2 of this series - performing a VMware Snapshot before we remediate the Clients

This script is pretty basic, there will be many alterations I expect. I am looking at retrying failed WMI Connections (Access Denied) with the user being prompted for different credentials (to be expected if Collection contains Workgroup computers).

We will use these results to install the non compliant Software Updates when we visit part 3 of this series.

Any thoughts or comments welcome. PowerShell is something I am learning so always keen to be shown how to make the code more efficient.

I'll be working on **"Part 2 - Snapshot a VM before Software Update Remediation"** next (As well as improving this script for error handling)

Thanks @AdamGrossTX (again) for your input on the draft. Adam raised an excellent point about leveraging CMPivot and Run Scripts. This is something I am keen on looking into and this mini series may end up with a Part 4 :) - My hope is that you will have a better understanding of how WMI is leveraged with SCCM. How long will WMI be used? Who knows, Adam has a good blog on the new AdminService that has been introduced..could it spell the end for WMI? Again, who knows :) Check it out here [https://www.asquaredozen.com/category/systemcenterconfigurationmanager/adminservice/](https://www.asquaredozen.com/category/systemcenterconfigurationmanager/adminservice/)

Enjoy, May the SCCM force be with you ..V..