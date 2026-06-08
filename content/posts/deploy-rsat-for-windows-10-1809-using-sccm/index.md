---
title: "Deploy RSAT for Windows 10 1809 using SCCM"
date: 2019-03-22
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
---

Starting Windows 10 1809 Remote Server Administration Tools (RSAT) is now included as a set of "Features on Demand". In the following post we will show you how to deploy individual features with SCCM.

<!--more-->

The RSAT tools are added using the "Add-WindowsCapability" cmdlet [https://docs.microsoft.com/en-us/powershell/module/dism/add-windowscapability?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/dism/add-windowscapability?view=win10-ps)  
Because we are deploying each feature with an appliction, we are going to use two parameters with the above cmdlet:-

1 . **Online** (Specifies we are adding the feature to the current Windows image  
2 . **Source** (We need to specify the CCMCache as a source)

### **The challenge**

The Features On Demand Pack is massive, 4.7GB. You can download it from the VLSC. You only need "Disk 1" for the RSAT features. Choose the correct version for the OS you are deploying the tools to.

[![](/images/2019/03/rsat_1.jpg)](/images/2019/03/rsat_1.jpg)

After you have downloaded the ISO, extract the contents to a folder. If we used this as the source for our deployment, 4.7GB of content would make its way to the client. This will present lots of interesting challenges.  
  
In the following steps, we will extract only the required files from the FOD pack for each RSAT feature. We will use the "DHCP" feature (language en-gb) for our example.  
  
You will need the following:-

1. The whole "metadata" folder
2. FoDMetadata\_Client.Cab
3. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~~.Cab
4. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~en-GB~.Cab
5. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~en-US~.Cab

<figure>

[![](/images/2019/03/rsat_27.jpg)](/images/2019/03/rsat_27.jpg)

<figcaption>

Files in Explorer

</figcaption>

</figure>

You will need items 1 and 2 for every FOD application you build. Item 3 and 4 will be specific to the tool and the language of the OS.  
  
_**Item 5 seemed to be a pre-requisite too, my assumption is the FOD media language cab has to be present when installing other languages.**_

### Access to the Internet

When you use the "Add-WindowsCapability" cmdlet, if you do not specify a _Source_, the default location set by Group Policy is used. If that fails, Windows Update is also used for online images.

In this post, we will specify the _Source_ as CCMCache using some PowerShell.

### Scripts

As already mentioned, we will use the "Add-WindowsCapability" cmdlet to install the RSAT Feature. We will also use the "Remove-WindowsCapability" cmdlet for uninstalling the Feature and the "Get-WindowsCapability" cmdlet for the application detection method.

**Add-WindowsCapability\_DHCP.ps1**

```
#Specify Source as current script directory
$ScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
Add-WindowsCapability -Name "Rsat.DHCP.Tools~~~~0.0.1.0" -Online -Source: $ScriptRoot
```

**Remove-WindowsCapability\_DHCP.ps1**

```
Remove-WindowsCapability -Name "Rsat.DHCP.Tools~~~~0.0.1.0" -Online
```

**Get-WindowsCapability\_DHCP.ps1**

```
If (Get-WindowsCapability -Name "Rsat.DHCP.Tools~~~~0.0.1.0" -Online | Where {$_.State -eq "Installed"})
{ 
write-Output "Installed"
}
```

### Putting it all together

Our source directory (Content Location) for the DHCP RSAT Feature should now contain:-

1. metadata (folder from the extracted ISO)
2. FoDMetadata\_Client.cab
3. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~~.cab
4. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~en-GB~.cab
5. Microsoft-Windows-DHCP-Tools-FoD-Package~31bf3856ad364e35~amd64~en-US~.cab
6. Add-WindowsCapability\_DHCP.ps1
7. Get-WindowsCapability\_DHCP.ps1
8. Remove-WindowsCapability\_DHCP.ps1

<figure>

![](/images/2019/03/rsat_26.jpg)

<figcaption>

Files in Explorer

</figcaption>

</figure>

1 . Create a new Application. Choose "Manually specify the application information" and click "Next"

<figure>

[![](/images/2019/03/rsat_3.jpg)](/images/2019/03/rsat_3.jpg)

<figcaption>

Choose "Manually specify the application information

</figcaption>

</figure>

2 . Enter a name for the application (and any other information you need) and click "Next"

<figure>

[![](/images/2019/03/rsat_4.jpg)](/images/2019/03/rsat_4.jpg)

<figcaption>

Specify an application name

</figcaption>

</figure>

3 . Enter a "Localized application name" (and any other information you need - including a nice icon!) and click "Next"

<figure>

[![](/images/2019/03/rsat_5-1.jpg)](/images/2019/03/rsat_5-1.jpg)

<figcaption>

Choose a localized application name (and shiny icon)

</figcaption>

</figure>

4 . To configure a "Deployment Type", click "Add"

<figure>

[![](/images/2019/03/rsat_6.jpg)](/images/2019/03/rsat_6.jpg)

<figcaption>

Click "Add" to create a Deployment Type

</figcaption>

</figure>

5 . Choose Type "Script Installer" and click "Next"

<figure>

[![](/images/2019/03/rsat_7.jpg)](/images/2019/03/rsat_7.jpg)

<figcaption>

Choose Type Script Installer

</figcaption>

</figure>

6 . Choose a Deployment Type Name and click "Next"

<figure>

[![](/images/2019/03/rsat_8.jpg)](/images/2019/03/rsat_8.jpg)

<figcaption>

Choose a Deployment Type Name

</figcaption>

</figure>

7 . Set the following information and click "Next"

**Content Location** = \\\\server\\packages\\Microsoft FOD\\1809 - DHCP

**\*Installation Program** = Powershell.exe -ExecutionPolicy Bypass -File "Add-WindowsCapability\_DHCP.ps1"

**\*Uninstall Program** = Powershell.exe -ExecutionPolicy Bypass -File "Remove-WindowsCapability\_DHCP.ps1"

\*Assumes you are not already bypassing the client execution policy

<figure>

![](/images/2019/03/rsat_10.jpg)

<figcaption>

Specify Content Information

</figcaption>

</figure>

8 . Choose to use a Custom Script for application detection and click "Edit"

<figure>

![](/images/2019/03/rsat_11.jpg)

<figcaption>

Choose a custom application detection script

</figcaption>

</figure>

9 . In the Script Editor dialogue, choose Script Type "PowerShell" and click "Open"

<figure>

![](/images/2019/03/rsat_12.jpg)

<figcaption>

Choose the Script Type  

</figcaption>

</figure>

10 . Browse to "Get-WindowsCapability\_DHCP.ps1" and click "Open" and then "Ok"

<figure>

![](/images/2019/03/rsat_13.jpg)

<figcaption>

Choose Get-WindowsCapability\_DHCP.ps1

</figcaption>

</figure>

11 . Click "Next" to complete the Application Detection method

<figure>

![](/images/2019/03/rsat_14.jpg)

<figcaption>

Application Detection Method

</figcaption>

</figure>

12 . I like to specify an "Installation Requirement" to ensure the OS is Windows 10 1809. For this we can query the OS build to ensure it is "17763". Click "Add"

<figure>

![](/images/2019/03/rsat_15.jpg)

<figcaption>

Add an Application Requirement

</figcaption>

</figure>

13 . Click "Create"

<figure>

[![](/images/2019/03/rsat_16.jpg)](/images/2019/03/rsat_16.jpg)

<figcaption>

Create Requirement

</figcaption>

</figure>

14 . Enter the following information and click "Ok"

**Name:** Windows 10 Build Number  
**Description:** Windows 10 Build Number  
**Condition Type:** Setting  
**Setting Type:** Registry Value  
**Hive Name:** HKEY\_LOCAL\_MACHINE  
**Key Name:** SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion  
**Value Name:** CurrentBuild

<figure>

[![](/images/2019/03/rsat_17.jpg)](/images/2019/03/rsat_17.jpg)

<figcaption>

Global Condition for Windows 10 Build

</figcaption>

</figure>

15 . Choose the Global Condition that we just created and in the value field type "17763". Click "Ok"

<figure>

[![](/images/2019/03/rsat_18.jpg)](/images/2019/03/rsat_18.jpg)

<figcaption>

Specify the Windows 10 1809 Build Number

</figcaption>

</figure>

16 . Click "Next" to proceed to Software Dependencies

17 . Click "Next" to read the Application Summary

18 . Click "Next" to create the Deployment and click "Close"

19 . The Deployment Type has been created, click "Next"

<figure>

[![](/images/2019/03/rsat_19.jpg)](blob:https://byteben.com/389e03b6-0aa4-4d21-a071-0741bb3ef97a)

<figcaption>

Deployment Type Created

</figcaption>

</figure>

20 . Click "Next" to confirm the Application Settings

21 . Click "Close" to complete the wizard

### Rinse and Repeat

We can follow the same steps to create Applications for DNS, DSLD, FS, GPO and RDS RSAT Features. I have created an application for each RSAT Feature because each will use a different Detection Method.

<figure>

[![](/images/2019/03/rsat_20.jpg)](/images/2019/03/rsat_20.jpg)

<figcaption>

Repeat to create and Application for other RSAT Features

</figcaption>

</figure>

To help duplicating and modifying your installation, removal and detection scripts, the Windows-Capability Name for the other RSAT tools are:-

Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0  
Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0  
Rsat.CertificateServices.Tools~~~~0.0.1.0  
Rsat.DHCP.Tools0.0.1.0  
Rsat.Dns.Tools~~~~0.0.1.0  
Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0  
Rsat.FileServices.Tools~~~~0.0.1.0  
Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0  
Rsat.IPAM.Client.Tools~~~~0.0.1.0  
Rsat.LLDP.Tools~~~~0.0.1.0  
Rsat.NetworkController.Tools~~~~0.0.1.0  
Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0  
Rsat.ServerManager.Tools~~~~0.0.1.0  
Rsat.Shielded.VM.Tools~~~~0.0.1.0 Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 Rsat.StorageReplica.Tools~~~~0.0.1.0  
Rsat.SystemInsights.Management.Tools~~~~0.0.1.0 Rsat.VolumeActivation.Tools~~~~0.0.1.0  
Rsat.WSUS.Tools~~~~0.0.1.0

### Deployment

The (Add/Remove/Get)-Windows-Capability cmdlets require elevation. Consider this when deploying to Devices or Users.

With this in mind, you need to ensure that you have chosen to "Install as System" on the User Experience tab of the Deployment Type we created earlier.

Once deployed as "Available", and after the client has run a Machine/User Policy Refresh, the application appears in Software Center.

<figure>

[![](/images/2019/03/rsat_21-1024x588.jpg)](/images/2019/03/rsat_21.jpg)

<figcaption>

New Application in the Software Center

</figcaption>

</figure>

Our Application Detection method has worked if we peek in appdiscovery.log on the client

<figure>

[![](/images/2019/03/rsat_22-1024x50.jpg)](blob:https://byteben.com/ac27900a-729a-45bf-8a88-1d34afba4ced)

<figcaption>

appdiscovery.log

</figcaption>

</figure>

Lets install the new Application

<figure>

[![](/images/2019/03/rsat_23.jpg)](/images/2019/03/rsat_23.jpg)

<figcaption>

Installing the DHCP RSAT Feature

</figcaption>

</figure>

Appenforce.log on the client gives more information on the installation

<figure>

[![](/images/2019/03/rsat_24-1024x214.jpg)](blob:https://byteben.com/fec9dc82-9c6f-4efa-ac56-3dfcc085cabe)

<figcaption>

appenforce.log

</figcaption>

</figure>

The application should be available from the Start Menu after installation

<figure>

[![](/images/2019/03/rsat_25.jpg)](/images/2019/03/rsat_25.jpg)

<figcaption>

Application Installation Successful

</figcaption>

</figure>

### Summary

Some points to remember:-

1. The EN-US cab files for each feature must also be present in your source directory for each Application you create
2. The Application must be deployed to "Install as System" because the \*-WindowsCapability cmdlets require elevation

Happy Feature deploying :)