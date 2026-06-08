---
title: "Deploy the Update for Removal of Adobe Flash Player (KB4577586) using Intune"
date: 2021-01-03
categories:
  - "Intune"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
---

In our previous post [How to Uninstall Adobe Flash Player from Windows 10 with ConfigMgr (byteben.com)](https://byteben.com/bb/how-to-uninstall-adobe-flash-player-from-windows-10-with-configmgr/) we reviewed the End of Life for Adobe Flash Player and what that meant for Windows 10 devices. We also stepped through a tutorial showing you how to deploy the update with ConfigMgr. Please review this post first as it contains a lot more detail about the update intention than this post does.

<!--more-->

In this post, we will look at how to deploy the same update (KB4577586) using Intune and a Win32App

The chances are that by the time you are reading this post Microsoft will have published the optional update to your WUfB. Ignore the rest of this post and go and drink tea...or take a peek anyway.

As in our previous [post](https://byteben.com/bb/how-to-uninstall-adobe-flash-player-from-windows-10-with-configmgr/) when we deployed the update with ConfigMgr, there is a unique KB4577586 update for each Windows 10 version and I have decided to roll all the updates into a single Win32App and use PowerShell to handle the installation. This way we have a single script/app that can handle all Windows 10 versions. The updates are only about 150kb each. You will need access to a WSUS console to download the updates in the correct folder format for the script to work. I have uploaded the updates to my GitHub repository which you could use in your test environment [](https://github.com/byteben/Windows-10/tree/master/Flash%20Uninstall_Intune)[Windows-10/Flash Uninstall\_Intune at master · byteben/Windows-10 (github.com)](https://github.com/byteben/Windows-10/tree/master/Flash%20Uninstall_Intune)

The scripts are pretty simple. Please test them before using them in production. This update cannot be removed once installed which limits how much testing I could do in my lab.

One script installs the update dependant on the OS architecture and ReleaseID and the other is used as the application detection method.

**[Install\_Flash\_Removal\_KB4577586.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall_Intune/Install_Flash_Removal_KB4577586.ps1)**

```
<#	
===========================================================================
	 Created on:   	0/01/2021 13:06
	 Created by:   	Ben Whitmore
	 Organization: 	-
	 Filename:     	Install_Flash_Removal_KB4577586.ps1
	 Target System: Windows 10 Only
===========================================================================
    
Version:
1.2
Fixed 20H2 coding error - Credit @AndyUpperton

1.1
Basic Transcript Logging added

1.0 
Release
#>

#Set Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

$Log = Join-Path $ENV:WINDIR "Temp\Flash_Uninstall.log"
Start-Transcript $Log

#Set WUSA.EXE Variable
$WUSA = "$env:systemroot\System32\wusa.exe"

#Get OS Release ID
$OS_ReleaseID = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object -ExpandProperty ReleaseID

#Rename variable for Windows 10 20H2 ReleaseID because the same update is used for 2004/2009
If ($OS_ReleaseID -eq "2009"){
	$OS_ReleaseID = "2004"
}

$OS_ProductName = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object -ExpandProperty ProductName

#Get OS Architecture
$OS_Architecture = Switch (Get-CIMInstance -Namespace "ROOT\CIMV2" -Class "Win32_Processor" | Select-Object -Unique -ExpandProperty Architecture) {
	9 { 'x64-based' }
	0 { 'x86-based' }
	5 { 'ARM64-based' }
}

#Build OS Version String
$OS_String = ($OS_ProductName -split "\s+" | Select-Object -First 2) -Join ' '

#Build Patch Name String
$PatchRequired = "Update for Removal of Adobe Flash Player for " + $OS_String + " Version " + $OS_ReleaseID + " for " + $OS_Architecture + " systems (KB4577586)"

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
		Write-Host "`Installing Update..."

		#Install Patch
		Start-Process -FilePath $WUSA -ArgumentList $Args -Wait

		#Check Installation
		$Patch = Get-Hotfix | Where-Object { $_.HotFixID -match "KB4577586" }
		If ($Patch) {
			Write-Host "Patch Installed Successfully"
		}
		else {
			Write-Host "Patch Installation Failed"
		}
	}
	else {
		Write-Host "Patch not found for this system"
		Write-Host "Patch Required: $($PatchRequired)"
		Write-Host "Current System: $($OS_String) $($OS_ReleaseID) $($OS_Architecture) PC"
	}
}
Stop-Transcript
```

**[Detect\_Flash\_Removal\_KB4577586\_Intune.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall_Intune/Detect_Flash_Removal_KB4577586_Intune.ps1)**

```
Try {
    $Patch = Get-Hotfix | Where-Object { $_.HotFixID -match "KB4577586" }
    If ($Patch) {
        Write-Output "Compliant"
        Exit 0
    } 
    Write-Warning "Not Compliant"
    Exit 1
} 
Catch {
    Write-Warning "Not Compliant"
    Exit 1
}
```

1 . Open your WSUS Console  
2 . Expand your WSUS Server Node and select **Updates** from the Navigation pane  
3 . Select **Action > Import Updates** from the Actions menu

[![](/images/2021/01/image-2-1024x362.png)](/images/2021/01/image-2.png)

4 . A browser window will open, search the Catalog for **Update for Removal of Adobe Flash Player for Windows 10**  
5 . **Add** “ALL” the updates to your basket \*. There are 24 in total – the removal tool for Windows 10 20H1 can be used to remove Flash from Windows 10 20H2  
  
**\*** The **Add** button is only available when browsing the catalog from Internet Explorer.

6 . Select **View Basket > Download**

[![](/images/2021/01/image-15-1024x324.png)](/images/2021/01/image-15.png)

7 . Choose a folder to download the updates to

[![](/images/2021/01/image-13.png)](/images/2021/01/image-13.png)

Your files will download into a similar folder structure as below

[![](/images/2021/01/image-34-1024x700.png)](/images/2021/01/image-34.png)

8 . Download the following PowerShell Scripts to the same folder as above  
  
**[Detect\_Flash\_Removal\_KB4577586\_Intune.ps1  
](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall_Intune/Detect_Flash_Removal_KB4577586_Intune.ps1)[Install\_Flash\_Removal\_KB4577586.ps1](https://github.com/byteben/Windows-10/blob/master/Flash%20Uninstall_Intune/Install_Flash_Removal_KB4577586.ps1)**

Your content staging folder should now look like this

[![](/images/2021/01/image-35-1024x733.png)](/images/2021/01/image-35.png)

9 . Download the Win32 Content Prep Tool Zip file in order to create the .intunewin file for deployment [https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/master.zip](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/master.zip)

10 . Extract the tool to a local folder, e.g. **C:\\Microsoft-Win32-Content-Prep-Tool-master**

You should see the following files

![](/images/2020/04/image-42.png)

11 . Make sure you “Unblock” IntuneWinAppUtil.exe

![](/images/2020/04/image-43.png)

12 . Copy **IntuneWinAppUtil.exe** to the same content folder as the updates and PowerShell scripts specified in step 8

[![](/images/2021/01/image-36-1024x204.png)](/images/2021/01/image-36.png)

13 . Double click IntuneWinAppUtil.exe

Specify the following Values:-

Source Folder: **.\\**  
Setup File: **Install\_Flash\_Removal\_KB4577586.ps1**  
Output Folder: **.\\**  
Specify Catalog Folder?: **N**

[![](/images/2021/01/image-37-1024x243.png)](/images/2021/01/image-37.png)

You should now see a file called **Install\_Flash\_Removal\_KB4577586.intunewin** in the content folder. We will use this file in the following steps. It contains all the KB4577586 updates for the different versions of Windows 10.

14 . Navigate to **Microsoft Endpoint Manager Admin Center** Windows 10 Apps blade and click **Add** [https://endpoint.microsoft.com/#blade/Microsoft\_Intune\_DeviceSettings/AppsWindowsMenu/windowsApps](https://endpoint.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/AppsWindowsMenu/windowsApps)

[![](/images/2021/01/image-38-1024x474.png)](/images/2021/01/image-38.png)

15 . Choose **Other > Windows app (Win32**)

16 . Click **Select**

17 . Choose **Select app package file**

![](/images/2020/04/image-47.png)

18 . Browse to the ****Install\_Flash\_Removal\_KB4577586.intunewin**** file we created previously and Select **OK**

[![](/images/2021/01/image-39-1024x433.png)](/images/2021/01/image-39.png)

19 . Fill in the required application information

[![](/images/2021/01/image-40-1002x1024.png)](/images/2021/01/image-40.png)

20 . Click **Next**  
21\. Enter the following information on the program tab

Install Command:  
**Powershell.exe -ExecutionPolicy Bypass -file “**Install\_Flash\_Removal\_KB4577586.ps1**”**  
Uninstall Command:  
**Powershell.exe -**ExecutionPolicy Bypass** -file “**Install\_Flash\_Removal\_KB4577586.ps1**”**  
Install behaviour: **System**  
Device restart behaviour: **No specific action**

**Remember**: This update cannot be uninstalled but the **Uninstall Command** requires some input. I have used the same command line again with the understanding that this will never be used.

[![](/images/2021/01/image-49-1024x458.png)](/images/2021/01/image-49.png)

22 . Click **Next**  
23 . Fill in the app requirements.

[![](/images/2021/01/image-42-1024x729.png)](/images/2021/01/image-42.png)

24 . Click **Next**  
25 . Under **Detection rules**, Select **Use a custom script** from the **Rules format** drop down box  
26 . Select the **Detect\_Flash\_Removal\_KB4577586\_Intune.ps1** script from your original content directory

[![](/images/2021/01/image-43-1024x460.png)](/images/2021/01/image-43.png)

27 . Click **Next**  
28 . Review Dependencies and Click **Next** (we don’t have any specific dependencies for this app)  
29 . Assign the Win32App to a group of Windows 10 devices in scope for the **Removal of Adobe Flash Player** update

[![](/images/2021/01/image-44-1024x195.png)](/images/2021/01/image-44.png)

30 . Click **Next**  
31 . Click **Create**

### Monitoring the Deployment

Once deployed, you can monitor installation progress both on the client...

**C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\IntuneManagementExtension.log** indicates the policy is retrieved from Intune

[![](/images/2021/01/image-48-1024x340.png)](/images/2021/01/image-48.png)

[![](/images/2021/01/image-47.png)](/images/2021/01/image-47.png)

[![](/images/2021/01/image-51-1024x286.png)](/images/2021/01/image-51.png)

[![](/images/2021/01/image-50.png)](/images/2021/01/image-50.png)

and from Intune...

[![](/images/2021/01/image-46-1024x664.png)](/images/2021/01/image-46.png)

[![](/images/2021/01/image-52-1024x555.png)](/images/2021/01/image-52.png)

### Summary

In this post we deployed the Update for Removal of Adobe Flash Player using Intune. You don't necessarily have to download all the updates into a single package but this is an example of how versatile Win32Apps can be - we had a single Win32App that could deploy the unique Update for the Removal of Adobe Flash Player for all Windows 10 versions and architectures. It is very plausible to create a Win32App with a single version of the update and then target a specific Windows 10 Version for that update.

You can also do deploy the updates using ConfigMgr - see the other post [How to Uninstall Adobe Flash Player from Windows 10 with ConfigMgr (byteben.com)](https://byteben.com/bb/how-to-uninstall-adobe-flash-player-from-windows-10-with-configmgr/)