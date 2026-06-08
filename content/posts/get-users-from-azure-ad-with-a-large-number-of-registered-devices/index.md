---
title: "Get Users from Azure AD with a large number of Registered Devices"
date: 2019-04-16
categories:
  - "Azure"
  - "Identity"
  - "Microsoft"
  - "Scripts"
---

### The Challenge

One of the challenges when managing an Azure AD Hybrid Join implementation is monitoring the number of devices registered to each Azure AD user.

<!--more-->

The default "limit" in Azure AD is 20 devices for each user. This number can quickly be reached in a shared computer environment, especially for your power user accounts that log on to multiple "down-level" devices.

<figure>

[![](/images/2019/04/devicelimit_1.jpg)](blob:https://byteben.com/ea954e2c-df6b-4c8a-95ca-fe14ca7b6a90)

<figcaption>

Default User Device Limit in Azure Active Directory

</figcaption>

</figure>

Every time you log on to a "down-level" device that is using Workplace Join, it will register in Azure AD as new device registration for the logged on user. To learn more about "down-level devices e.g. Windows 7, check out this doc:- 
  
[https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-plan](https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-plan)  

Once a user reaches the defined "Device Limit", no further device registrations can take place. This limitation will not always present itself with the same error for each different type of device. It should always be at the back of our minds, as admins, that a device registration may have been unsuccessful because the user "Device Limit" was reached.

<figure>

![](/images/2019/04/devicelimit_2-1024x717.jpg)

<figcaption>

This image shows 17 Windows 7 Devices Registered for a particular user in a shared computer environment

</figcaption>

</figure>

### The Workaround

We have two options:-

1. Delete devices for the User
2. Increase the Registered Device Quota

Both options are valid and the procedure for either option can be found in the following troubleshooting article:- 
  
[https://support.microsoft.com/en-hk/help/3045379/the-maximum-number-of-devices-that-can-be-joined-to-the-workplace-by-t](https://support.microsoft.com/en-hk/help/3045379/the-maximum-number-of-devices-that-can-be-joined-to-the-workplace-by-t)

### A Better Way

I believe we can tackle the problem differently. I personally think it would be better to understand the device registration activity in our environment so we can be proactive in dealing with the issues before they arise.

I have written a small script that leverages the cmdlets **Get-MsolUser** and **Get-MsolDevice** to report any users that are nearing the device registration limit.

#### The Script

The Script will find and count all registered Azure AD devices for our users and report back any users with a large device registration count.  
  
The first draft of the script allows you to pass two parameters:-

1. **MaxResults** - Limits the number of users queried
2. **HighDeviceCount** - Set the number for what is deemed a large number of device registrations for your tenant

The script "Get-UserDevices.ps1" can be found in my GitHub repo:- 
  
[https://github.com/byteben/AzureAD](https://github.com/byteben/AzureAD)

\*There is an assumption you are already connected to the MsolService in your PowerShell session. If not, do this first:- 

```
$UserCredential = Get-CredentialConnect-MsolService -Credential $UserCredential
```

```
<#
.Disclaimer
	This scripts is provided AS IS without warranty of any kind.
	In no event shall the author be liable for any damages whatsoever 
	(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss)
	arising out of the use of or inability to use script,
	even if the Author has been advised of the possibility of such damages

.Author
	Ben Whitmore

.Created
	16/04/2019

.DESCRIPTION
 	Script to monitor and return large number of user devices in Azure AD. The default limit in Azure is 20 devices
 
.PARAMETER MaxResults
	Enter the Maximum number of results to be returned by the script    

.PARAMETER HighDeviceCount
    Enter the threshold for devices that you want to return
 
.EXAMPLE
	Get-UserDevices.ps1 -MaxResults 1000 -HighDeviceCount 15

#>

#Set Default parameters if none passed
Param (
	[Parameter(Mandatory = $False)]
	[string]$MaxResults = '1000',
	[Parameter(Mandatory = $False)]
	[string]$HighDeviceCount = '15'
)
#Initialize Array to hold users and number of devices
$DeviceCountHigh = @()

#Get list of users from AzureAD
$Users = Get-MsolUser -MaxResults $MaxResults | Select UserPrincipalName

ForEach ($User in $Users)
{
	#For each user returned, count their Registered Devices
	$Devices = Get-MsolDevice -RegisteredOwnerUPN $User.UserPrincipalName | Measure
	
	ForEach ($Device in $Devices)
	{
		#If the number of registered devices measured is high, create a new PSObject
		If ($Device.Count -ge $HighDeviceCount)
		{
			$DeviceCountMember = @()
			$DeviceCountMember = New-Object PSObject
			$DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $User.UserPrincipalName
			$DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'DeviceCount' -Value $Device.Count
			$DeviceCountHigh += $DeviceCountMember
		}
	}
}
#Display Users with high number of devices
$DeviceCountHigh | Sort-Object DeviceCount -Descending
```

<figure>

![](/images/2019/04/devicelimit_3.jpg)

<figcaption>

Example of the Output of the Script

</figcaption>

</figure>

To view the devices registered to the affected users, you can use the command:-

Get-MsolDevice -RegisteredOwnerUpn <UserPrincipalName>  

### Conclusion

I am working on refining the code, it takes a while to return the results when dealing with large numbers of users. There is probably a cmdlet that can look at the Microsoft Graph that I haven't found yet!

The results will be put into an array for you to play with. In the next version of the script I hope to handle device registration deletions for inactive devices.