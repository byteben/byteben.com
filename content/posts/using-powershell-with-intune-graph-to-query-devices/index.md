---
title: "Using PowerShell with Microsoft Graph to query Intune Devices"
date: 2019-01-08
categories:
  - "Intune"
  - "Microsoft"
  - "Scripts"
tags: ["ems", "github", "intune", "intune-sdk", "microsoft-graph", "powershell"]
categories: ["intune", "microsoft", "scripts"]
---

### What is Microsoft Graph?

Microsoft Graph connects resources across Office 365 services. Using [https://graph.microsoft.com](https://graph.microsoft.com) you can connect to these services and access a wealth of resources, relationships and intelligence.  

<!--more-->
  
You can read more on Microsoft Graph at [https://docs.microsoft.com/en-us/graph/overview](https://docs.microsoft.com/en-us/graph/overview)

### How do I use Microsoft Graph?

If you have a requirement to return a wealth of information about your Intune Devices (more than Get-MSOLDevice can offer) we must use Microsoft Graph. We can just pop over to [https://graph.microsoft.com](https://graph.microsoft.com/) to return some data. Lets take a look at this before we jump into some PowerShell

1. Authenticate with your Global Admin Account
2. Choose a simple query GET - V1.0 - "https://graph.microsoft.com/v1.0/me"
3. Click "Run Query"

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_0-1024x55.jpg)

<figcaption>

Simple Query will look like this

</figcaption>

</figure>

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_1-1024x424.jpg)

<figcaption>

The returned data will look similar to this

</figcaption>

</figure>

You can try a load of other simple, cool examples documented at [https://docs.microsoft.com/en-us/graph/overview](https://docs.microsoft.com/en-us/graph/overview)

### Introducing the Intune PowerShell SDK

[https://github.com/Microsoft/Intune-PowerShell-SDK](https://github.com/Microsoft/Intune-PowerShell-SDK)

This is your friend. What an awesome project! This PowerShell module will provide support for the Intune API using Microsoft Graph. Lets have a look at downloading the module, connecting to Microsoft Graph and querying our Intune data.

1 . Navigate to [https://github.com/Microsoft/Intune-PowerShell-SDK/releases](https://github.com/Microsoft/Intune-PowerShell-SDK/releases)

2 . Download the release zip

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_2.jpg)

<figcaption>

Download the Zip File

</figcaption>

</figure>

3 . You may need to "Unblock the file" before you extract it (Windows 10 unblock scripts downloaded from the Internet [https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-6](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-6)

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_3.jpg)

<figcaption>

Unblock the Zip File to allow scripts to run that have been downloaded from the Internet

</figcaption>

</figure>

4 . You will see the "Microsoft.Graph.Intune" PowerShell module we will need to import

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_4.jpg)

<figcaption>

Intune SDK PowerShell Module

</figcaption>

</figure>

5 . Import the Module

```
Import-Module .\Microsoft.Graph.Intune.psd1
```

6 . Connect to the Microsoft Graph **(You must have .NET 4.7.1 or higher installed)**

```
Connect-MSGraph -AdminConsent
```

7 . Accept the Permission request for Intune PowerShell

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_5.jpg)

<figcaption>

Accept the permission request

</figcaption>

</figure>

You should have a successful connection

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_6.jpg)

<figcaption>

Successful Connection

</figcaption>

</figure>

### PowerShell Time

Lets see what this Module can do. How many cmdlets do we have?

```
Get-Command -Module Microsoft.Graph.Intune | measure
```

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_7.jpg)

<figcaption>

914 cmdlets!

</figcaption>

</figure>

That's a lot of cmdlets!

The post title suggested we are querying our Intune Devices. So here is a useful cmdlet for your arsenal:-

```
Get-IntunemanagedDevice
```

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_9.jpg)

<figcaption>

Get-IntuneManagedDevice

</figcaption>

</figure>

Running this cmdlet will return all your Intune Managed Devices with all Device Details - cool! Lets see what this would look like in the PowerShell Grid View

```
Get-IntuneManagedDevice | Out-GridView
```

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_10-1024x516.jpg)

<figcaption>

A wealth of information is returned about our Intune Managed Devices

</figcaption>

</figure>

47 columns are returned for each Intune Managed Device, that is a lot of cool info right there at your fingertips. The Columns are:-

- id
- userId
- deviceName
- managedDeviceOwnerType
- enrolledDateTime
- lastSyncDateTime
- operatingSystem
- complianceState
- jailBroken
- managementAgent
- osVersion
- easActivated
- easDeviceId
- easActivationDateTime
- azureADRegistered
- deviceEnrollmentType
- activationLockBypassCode
- emailAddress
- azureADDeviceId
- deviceRegistrationState
- deviceCategoryDisplayName
- isSupervised
- exchangeLastSuccessfulSyncDateTime
- exchangeAccessState
- exchangeAccessStateReason
- remoteAssistanceSessionUrl
- remoteAssistanceSessionErrorDetails
- isEncrypted
- userPrincipalName
- model
- manufacturer
- imei
- complianceGracePeriodExpirationDateTime
- serialNumber
- phoneNumber
- androidSecurityPatchLevel
- userDisplayName
- configurationManagerClientEnabledFeatures
- wiFiMacAddress
- deviceHealthAttestationState
- subscriberCarrier
- meid
- totalStorageSpaceInBytes
- freeStorageSpaceInBytes
- managedDeviceName
- partnerReportedThreatState
- deviceActionResults

Let's try another command. I want to find my iPhone:-

```
Get-IntuneManagedDevice | Where-Object {$_.userDisplayName -eq "Ben Whitmore" -and $_.model -like "iphone*"}
```

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_11-1024x694.jpg)

<figcaption>

Results for a query looking for model "iphone\*" for user "Ben Whitmore"

</figcaption>

</figure>

Another example. What if we wanted to find all the old iPhones in the company so we can prepare for product End of Support?

```
Get-IntuneManagedDevice | Where-Object {$_.model -like "iphone 5*"} | Select userDisplayName, model, osVersion
```

<figure>

![](/images/2019/01/microsoftgraph_intunepowershell_12-1024x298.jpg)

<figcaption>

Old Company iPhones

</figcaption>

</figure>

Here is another real world example we encountered recently. We upload corporate identifiers to Intune so our Company devices enroll as "Corporate" instead of "Personal". There was/is a bug which means the IMEI is not exposed and captured by Intune so our devices were registering as "Personal". We could use Microsoft Graph to find all IOS devices that have a $Null IMEI field

```
Get-IntuneManagedDevice | Where-Object {$_.operatingsystem -eq 'ios' -and $_.imei -eq $Null} | Select userDisplayName, model, osVersion
```

So now we are leveraging PowerShell with Intune, the possibilities are endless...ish. But certainly alot more powerfull than relying on our old buddy Get-MSOLDevice

I hope this post has given you an oversight on using PowerShell with Microsoft Graph to query Intune Devices. More posts will follow with real world examples.

Have a great day!