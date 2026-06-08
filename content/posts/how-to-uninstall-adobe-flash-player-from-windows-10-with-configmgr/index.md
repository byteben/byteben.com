---
title: "How to Uninstall Adobe Flash Player from Windows 10 with ConfigMgr"
date: 2021-01-02
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
tags: ["adobe-flash-player", "edge", "flash-eol", "powershell-script-remove-flash", "remove-flash", "windows-10"]
categories: ["configmgr-memcm-sccm", "microsoft", "scripts", "windows-10"]
---

> **Update 22/01/21**
> 
>   
> I have now modified the script to include support for Windows Servers. In this tutorial, when prompted to download the updates from the Microsoft Update Catalog for "Windows 10", also include updates for the server versions you plan to deploy the update to.

<!--more-->

Adobe Flash Player has been around, drilling security holes in your network, for 20 years. Back in 2017 Microsoft and Adobe announced Adobe Flash Player will no longer be supported after December 2020. Adobe will start to actively block content from running in Flash Player beginning 12th January 2021. Customers who have deployed Adobe Flash Player Plugins, outside of the version included with Windows 10, will need to consider how they remove it across their organisations. There will also need to be consideration for those who have deployed the NPAPI and PPAPI plugins for Windows 10.

### Which Adobe Flash Player Plugins need Removing

##### **Flash Player shipped with Windows 10**

Microsoft released an update on the Microsoft Update Catalog back in October 2020 called **Update for Removal of Adobe Flash Player** **(KB4577586)** that permanently removes Adobe Flash Player as a component of the Windows OS for Microsoft Edge (Legacy) and Internet Explorer. This update can be downloaded manually from the catalog but will also be made available via WSUS early in 2021 as **Optional**.

Search for Update for **Removal of Adobe Flash Player for Windows 10 Version** to find the update for ALL Windows 10 versions.

[![](/images/2021/01/image-1-1024x544.png)](/images/2021/01/image-1.png)

A few months later this update will classified as **Recommended**. This update cannot be removed once it has been deployed. Starting around Summer 2021 all API's, GPO's and other mechanisms that control the behaviour of Adobe Flash player will be removed. The update will then be included as part of the **Cumulative Update** and **Monthly Rollup** from that point on. Yes - unless you stop installing Windows Updates Adobe Flash Player is going whether you like it or not. During the transition to automatic removal, Microsoft will continue to provide security updates for Adobe Flash Player.

You can find more information here: -

[https://www.catalog.update.microsoft.com/search.aspx?q=4577586](https://www.catalog.update.microsoft.com/search.aspx?q=4577586)  
[https://blogs.windows.com/msedgedev/2020/09/04/update-adobe-flash-end-support](https://blogs.windows.com/msedgedev/2020/09/04/update-adobe-flash-end-support)

**Note:** Flash Player will be disabled/removed from Microsoft Edge (Chromium) as part of the Chromium Roadmap. Currently touted for Chrome release 88+  
[https://www.chromium.org/flash-roadmap#TOC-Flash-Player-blocked-as-out-of-date-Target:-All-Chrome-versions---Jan-2021-](https://www.chromium.org/flash-roadmap#TOC-Flash-Player-blocked-as-out-of-date-Target:-All-Chrome-versions---Jan-2021-)

Edge Chromium is still enabled in 87+ at the time of writing this post.

[![](/images/2021/01/image-1024x538.png)](/images/2021/01/image.png)

##### **NPAPI (Firefox) and PPAPI (Chrome) plugins for Windows 10 devices**

To support Flash content on Mozella Firefox and Google Chrome admins would have been deploying the PPAPI or NPAPI plugins, or both. Adobe have released a universal uninstaller for these products to simplify uninstallation for all versions of the plugins. The uninstaller works for both 32 and 64bit versions of the Plugin.

You can find more information here: -

[https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html](https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html)  
[https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html#main\_\_Solution](https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-windows.html#main__Solution)

**Note:** If you have deployed Flash Player BETA, you will need to deploy the corresponding Flash Player BETA uninstaller which is available from Adobe Labs

### Tutorial

In this post, we will focus on deploying the Microsoft Update that removes Adobe Flash Player support for Microsoft Edge and Internet Explorer on Windows 10 using ConfigMgr / MEMCM

#### Uninstalling Flash Player for Microsoft Edge / Internet Explorer on Windows 10 with ConfigMgr / MEMCM

The chances are that by the time you are reading this post Microsoft will have published the optional update to your WSUS catalog. Ignore the rest of this post and go and drink tea..or take a peek anyway.

Importing Updates into WSUS on Server 2016 has its challenges so I will deploy the update as an Application in ConfigMgr. Because there is a unique update for each Windows 10 version I have decided to roll all the updates into a single application and use PowerShell to handle the installation. This way we have a single script that can handle all Windows 10 versions. Better than creating an application for each OS version right?

The scripts are pretty simple. Please test them before using them in production. This update cannot be removed once installed which limits how much testing I could do in my lab.

One script installs the update dependant on the OS architecture and ReleaseID and the other is used as the application detection method.

**[Install\_Flash\_Removal\_KB4577586.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall/Install_Flash_Removal_KB4577586.ps1)**

**\*\*UPDATES\*\***  
1.2.1 - 22/01/2021  
Added support for Server OS - Thanks @Hoorge for the suggestion  
  
1.2 - 04/01/2021  
Fixed 20H2 coding error - Credit @AndyUpperton  
  
1.1 02/01/2021  
Basic Transcript Logging added

```
<#	
===========================================================================
	 Created on:   	0/01/2021 13:06
	 Created by:   	Ben Whitmore
	 Organization: 	-
	 Filename:     	Install_Flash_Removal_KB4577586.ps1
	 Target System: Windows 10 , Windows Server 2012/R2 | 2016 | 2019 | 1903 | 1909 | 2004
===========================================================================
    
Version:
1.2.1 - 22/01/2021
Added support for Server OS - Thanks @Hoorge for the suggestion

1.2 - 04/01/2021
Fixed 20H2 coding error - Credit @AndyUpperton

1.1 02/01/2021
Basic Transcript Logging added

1.0 - 01/01/2021
Release
#>

#Set Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

$Log = Join-Path $ENV:TEMP "Flash_Uninstall.log"
Start-Transcript $Log

#Set WUSA.EXE Variable
$WUSA = "$env:systemroot\System32\wusa.exe"

#Get OS Product Name
$OS_ProductName = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' ProductName).ProductName

#Build OS Version String
Switch ($OS_ProductName) {
	{ $_.StartsWith("Windows 10") } { $OS_String = ($OS_ProductName -split "\s+" | Select-Object -First 2) -Join ' ' }
	{ $_.StartsWith("Windows Server 2012 R2") } { $OS_String = ($OS_ProductName -split "\s+" | Select-Object -First 4) -Join ' ' }
	{ ($_.StartsWith("Windows Server") -and (!($_.Contains("R2")))) } { $OS_String = ($OS_ProductName -split "\s+" | Select-Object -First 3) -Join ' ' }
}

#Get OS Release ID for valid OS's
If (!($OS_String -match "Server 2012")) {
	$OS_ReleaseID = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' ReleaseId).ReleaseId
}
else {
	Write-Output "Skipping check of Release ID for $($OS_ProductName)"
}

#Rename $OS_ReleaseID variable for "Windows 10 20H2" and "Windows Server, version 1909" because the same KB update is used for both 2004 and 2009
If (($OS_ReleaseID -eq "2009" -and $OS_ProductName -match "Windows 10")) {
	$OS_ReleaseID = "2004"
}

#Build OS Version Name variable
Switch ($OS_String) {
	{ $_.Equals("Windows 10") } { $Version_String = $OS_String + " Version " + $OS_ReleaseID }
	{ $_.StartsWith("Windows Server 2") } { $Version_String = $OS_String }
	{ $_.StartsWith("Windows Server,") } { $Version_String = $OS_String + $OS_ReleaseID }
}

#Get OS Architecture
$OS_Architecture = Switch (Get-CIMInstance -Namespace "ROOT\CIMV2" -Class "Win32_Processor" | Select-Object -Unique -ExpandProperty Architecture) {
	9 { 'x64-based' }
	0 { 'x86-based' }
	5 { 'ARM64-based' }
}

$PatchRequired = "Update for Removal of Adobe Flash Player for " + $Version_String + " for " + $OS_Architecture + " systems (KB4577586)"

#Get Patch Titles
$PatchNames = Get-ChildItem $CurrentDir | Where-Object { $_.PSIsContainer } | Foreach-Object { $_.Name }

#Check if the patch has been downloaded for the current system
$PatchFound = $False

#Check Installation
$Patch = Get-Hotfix | Where-Object { $_.HotFixID -match "KB4577586" }
If ($Patch) {
	Write-Host "Patch Already Installed"
}
else {

	Foreach ($Patch in $PatchNames) {
		If ($Patch -eq $PatchRequired) {
			$PatchFound = $True

			#Get MSU from the correct Directory
			$MSU = Get-ChildItem (Join-Path $CurrentDir $Patch) -Recurse | Where-Object { $_.Extension -eq ".msu" }
			$MSUFullPath = Join-Path (Join-Path $CurrentDir $PatchRequired) $MSU.Name

			#Set WUSA Args
			$Args = @(
				"""$MSUFullPath"""
				"/quiet"
				"/norestart"
			)
		}
	}

	#Patch detection determines outcome
	If ($PatchFound) {
		Write-Host "Patch found for this system"
		Write-Host "Patch Required: $($PatchRequired)"
		Write-Host "Patch Name: $($MSU.Name)"
		Write-Host "Installing Update..."

		#Install Patch
		Start-Process -FilePath $WUSA -ArgumentList $Args -Wait

		#Check Installation
		$Patch = Get-Hotfix | Where-Object { $_.HotFixID -match "KB4577586" }
		If ($Patch) {
			Write-Host "Patch Installed Successfully"
		}
		else {
			Write-Warning "Patch Installation Failed"
		}
	}
	else {
		Write-Host "Patch not found for this system"
		Write-Host "Patch Required: $($PatchRequired)"
	}
}
Stop-Transcript
```

**[Detect\_Flash\_Removal\_KB4577586.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall/Detect_Flash_Removal_KB4577586.ps1)**

```
$Patch = Get-Hotfix | Where-Object { $_.HotFixID -match "KB4577586" }
If ($Patch) 
{
    Write-Host "Installed"
}
else
{
}
```

Before we start building our ConfigMgr application, we must first download all the Windows 10 versions of the KB4577586 update from the Microsoft Catalog. I download mine from the WSUS console link because it creates nicely formatted folders that we can use later on for our application content folder structure.

1 . Open your WSUS Console  
2 . Expand your WSUS Server Node and select **Updates** from the Navigation pane  
3 . Select **Action > Import Updates** from the Actions menu

[![](/images/2021/01/image-2-1024x362.png)](/images/2021/01/image-2.png)

4 . A browser window will open, search the Catalog for **Update for Removal of Adobe Flash Player for Windows 10**  
5 . **Add** "ALL" the updates to your basket \*. There are 24 in total - the removal tool for Windows 10 20H1 can be used to remove Flash from Windows 10 20H2  
  
**\*** The **Add** button is only available when browsing the catalog from Internet Explorer. I will not be importing these updates directly into the Catalog because of various known challenges with WSUS on Server 2016

6 . Select **View Basket > Download**

[![](/images/2021/01/image-15-1024x324.png)](/images/2021/01/image-15.png)

7 . Choose a folder to download the updates to

[![](/images/2021/01/image-13.png)](/images/2021/01/image-13.png)

Your files will download into a similar folder structure as below. Place this folder onto a UNC that you normally stage application content from when building applications in ConfigMgr

[![](/images/2021/01/image-14.png)](/images/2021/01/image-14.png)

8 . Download the following PowerShell Scripts to the same folder as above  
  
**[Detect\_Flash\_Removal\_KB4577586.ps1  
](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall/Detect_Flash_Removal_KB4577586.ps1)[Install\_Flash\_Removal\_KB4577586.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall/Install_Flash_Removal_KB4577586.ps1)**

Your content staging folder should now look like this

[![](/images/2021/01/image-16.png)](/images/2021/01/image-16.png)

9 . Create a new Application in ConfigMgr. From the ConfigMgr Console, navigate to **Software Library > Overview > Application management > Applications** and select **Create Application** from the ribbon

[![](/images/2021/01/image-17.png)](/images/2021/01/image-17.png)

10 . Select **Manually specify the application information** and click **Next**

[![](/images/2021/01/image-18.png)](/images/2021/01/image-18.png)

11 . Enter the following information and then select **Next**: -

**Name:** Update for Removal of Adobe Flash Player for Windows 10  
**Publisher:** Microsoft

[![](/images/2021/01/image-19.png)](/images/2021/01/image-19.png)

12 . Customize the **Software Center entry** and click **Next**

[![](/images/2021/01/image-20.png)](/images/2021/01/image-20.png)

13 . Click **Add** to add a deployment type  
14 . Choose **Manually specify the deployment type information** and click **Next**

[![](/images/2021/01/image-21.png)](/images/2021/01/image-21.png)

15 . Enter a **Name** for the deployment type and click **Next**  
16 . Enter the following information and click **Next**: -

**Content Location:** Same UNC path you specified for your staging content in Step 8  
**Installation Program:** PowerShell.exe -ExecutionPolicy Bypass -File "Install\_Flash\_Removal\_KB4577586.ps1"

[![](/images/2021/01/image-22.png)](/images/2021/01/image-22.png)

17 . Select **Use a custom script to detect the presence of this deployment type** in the deployment detection wizard and click **Edit**

[![](/images/2021/01/image-23.png)](/images/2021/01/image-23.png)

18 . For **Script type** choose **PowerShell**, paste the content of **Detect\_Flash\_Removal\_KB4577586.ps1** and click **OK**

[![](/images/2021/01/image-24.png)](/images/2021/01/image-24.png)

19 . Click **Next**  
20 . For installation behaviour, choose the following and click **Next**: -

**Installation behaviour:** Install for system  
**Logon requirement:** Whether or not a user is logged on  
**Installation program visibility:** Hidden  
**Maximum Allowed run time:** 15 minutes  
**Estimated installation time:** 2 minutes

[![](/images/2021/01/image-25.png)](/images/2021/01/image-25.png)

21 . in the Requirement Type dialogue box, add a requirement for **Operating System = Windows 10** and click **Next**

[![](/images/2021/01/image-26.png)](/images/2021/01/image-26.png)

22 . Click **Next** twice (skipping software dependencies)  
23 . Click **Close**  
24 . Click **Next** twice, review the wizard summary and click **Close**  
25 . Deploy the application as **Required** to your Windows 10 device collection that is in scope for Adobe Flash removal.

Review the deployment to ensure the application is installing which means Adobe Flash Player for Windows 10 (Edge and Internet Explorer) is being uninstalled

<figure>

[![](/images/2021/01/image-27.png)](/images/2021/01/image-27.png)

<figcaption>

appenforce.log on the client

</figcaption>

</figure>

Before and after the application was deployed

[![](/images/2021/01/image-28.png)](/images/2021/01/image-28.png)

Review basic Transcript log in the %TEMP% Directory on the client

[![](/images/2021/01/image-30.png)](/images/2021/01/image-30.png)

Deployment Status for application deployment

[![](/images/2021/01/image-32.png)](/images/2021/01/image-32.png)

Application Deployed to different Windows 10 Versions and ran successfully

[![](/images/2021/01/image-33.png)](/images/2021/01/image-33.png)

### Summary

In this post we reviewed the upcoming changes and end of support for Adobe Flash Player. We used ConfigMgr to deploy an update from the Microsoft Catalog which removes Adobe Flash Player support from Windows 10 for Microsoft Edge and Internet Explorer.  
  
We briefly touched on the PPAPI and NPAPI plugins which Adobe has a removal tool for.

With any luck, by the time you read this post KB 4577568 will be released to WSUS which will make deployment of the update much simpler.