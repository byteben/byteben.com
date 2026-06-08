---
title: "How to Deploy Fonts with MEMCM"
date: 2020-07-04
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Windows 10"
tags: ["configmgr", "fonts", "memcm", "powershell", "sccm", "windows10"]
categories: ["configmgr-memcm-sccm", "microsoft", "windows-10"]
---

I have been releasing a lot of "Quick Tips" on Twitter recently. This post falls into that category. It isn't necessarily a deep dive but something that has been requested a few times. In this post I will show you how to deploy SYSTEM Fonts using MEMCM (ConfigMgr)

<!--more-->

1. [Background](#1)
2. [Prerequisites](#2)
3. [Scripts](#3)
4. [MEMCM Application](#4)
5. [Observe the Deployment](#5)

### 1 . Background [⏏](#NavMenu)

From time to time we may be asked to deploy Fonts to devices. This can be done manually via the Fonts Control Panel applet **Start > Settings > Personalization > Fonts**

![](/images/2020/07/image-1024x789.png)

or downloaded by the user from the Microsoft Store. But we like automation and we like MEMCM, so lets create a script and deploy the Font using an application.

### 2 . Prerequisites [⏏](#NavMenu)

The Font will need to be of file type:-

- TTF
- OTF
- FON
- FNT

If you have downloaded a Font from one of the many free sites, make sure you have permissions to distribute it in your organization. Not all Fonts are free for commercial use.

In this example, we are only installing a single Font - Switzerland.ttf

### 3 . Scripts [⏏](#NavMenu)

We will be using PowerShell to install the Font and will require two scripts. One for installation and another for uninstallation.

Script 1: Install a Font [https://github.com/byteben/Windows-10/blob/master/Install\_Font.ps1](https://github.com/byteben/Windows-10/blob/master/Install_Font.ps1)

```
<#	
===========================================================================
	 Created on:   	04/07/2020 13:06
	 Created by:   	Ben Whitmore
	 Organization: 	-
	 Filename:     	Install_Font.ps1
===========================================================================
    
Version:
1.0
#>

#Set Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#Set Font Reg Key Path
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

#Grab the Font from the Current Directory
foreach ($Font in $(Get-ChildItem -Path $CurrentDir -Include *.ttf, *.otf, *.fon, *.fnt -Recurse)) {

    #Copy Font to the Windows Font Directory
    Copy-Item $Font "C:\Windows\Fonts" -Force
    
    #Set the Registry Key to indicate the Font has been installed
    New-ItemProperty -Path $FontRegPath -Name $Font.Name -Value $Font.Name -PropertyType String | Out-Null
}
```

Script 2: Uninstall a Font [https://github.com/byteben/Windows-10/blob/master/Uninstall\_Font.ps1](https://github.com/byteben/Windows-10/blob/master/Uninstall_Font.ps1)

```
<#	
===========================================================================
	 Created on:   	04/07/2020 13:06
	 Created by:   	Ben Whitmore
	 Organization: 	-
	 Filename:     	Uninstall_Font.ps1
===========================================================================
    
Version:
1.0
#>

#Set Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#Set Font Reg Key Path
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

#Grab the Font from the Current Directory
foreach ($File in $(Get-ChildItem -Path $CurrentDir -Include *.ttf, *.otf, *.fon, *.fnt -Recurse)) {

    #Remove the Font from the Windows Font Directory
    Remove-Item (Join-Path "C:\Windows\Fonts" $File.Name) -Force | Out-Null

    #Remove the corresponding Registry Key
    Remove-ItemProperty -Path $FontRegPath -Name $File.Name | Out-Null
}
```

### 4 . MEMCM Application [⏏](#NavMenu)

1 . Put the following files into your source content directory.

Install\_Font.ps1  
Uninstall\_Font.ps1  
Switzerland.ttf

![](/images/2020/07/image-1.png)

2 . Navigate to **Software Library > Application Management > Applications > Create Application**

![](/images/2020/07/image-2.png)

3 . Select **Manually specify the application information** and click **Next**

![](/images/2020/07/image-3.png)

4 . Fill in the Application information and click **Next**

![](/images/2020/07/image-4.png)

5 . Specify how the Application will appear in the Software Centre and click **Next**

![](/images/2020/07/image-6.png)

6 . Click **Add** to add a Deployment Type

![](/images/2020/07/image-7.png)

7 . Select **Script Installer** from the drop down box and click **Next**

![](/images/2020/07/image-8.png)

8 . Specify a **Name** and click **Next**

![](/images/2020/07/image-10.png)

9 . Specify the following information and click **Next**

1. **Content Location** = We identified the source files in Step 1
2. **Installation Program** = Powershell.exe -ExecutionPolicy Bypass -File "Install\_Font.ps1"
3. **Uninstallation Program** = Powershell.exe -ExecutionPolicy Bypass -File "Uninstall\_Font.ps1"

![](/images/2020/07/image-11.png)

10 . Click **Add Clause** to specify a detection method

![](/images/2020/07/image-12.png)

11 . Add the **Path** and **File Name** of the font and click **OK**

![](/images/2020/07/image-13.png)

12 . Click **Next**

13 . Set the following information and click **Next**

1. **Installation Behaviour** \= Install for System
2. **Logon Requirement** \= Whether or not a user is logged on
3. **Installation Program Visibility** = Hidden
4. **Maximum Allowed Run Time =** 15
5. **Estimated Installation Run Time =** 2

![](/images/2020/07/image-15.png)

14 . Click **Add** to add a Requirement

![](/images/2020/07/image-16.png)

15 . Set the Condition to **Operating System** and select **All Windows 10 (64bit)** and click **OK**

![](/images/2020/07/image-17.png)

16 . Click **Next** three times and then click **Close**

17 . Click **Next** twice

18 . Review the Application Summary and click **Close**

19 . Right clikc the application and choose **Deploy**

![](/images/2020/07/image-18.png)

20 . Choose a **Collection** to deploy the new application to and click **Next**

![](/images/2020/07/image-19.png)

21 . Click **Add** and choose a Distribution Point or Distribution Point Group and click **Next**

![](/images/2020/07/image-20.png)

22 . Choose a **Purpose** for the deployment, in this example we have chosen to make the application **Available** in the Software Centre. Click **Next**

![](/images/2020/07/image-21.png)

22 . Click **Next** on the **Specify the schedule for this deployment** step or set a time/day when this application will be available from

23 . Set the **User notifications** to something suitable for your environment and click **Next**

![](/images/2020/07/image-22.png)

23 . Click **Next** on the **Alerts** step or specify a setting suitable for your environment

![](/images/2020/07/image-23.png)

24 . Click **Next**, review the deployment and click **Close**

### 5 . Observe the Deployment [⏏](#NavMenu)

If we allow adequate time or force a machine policy refresh on a Windows 10 client targeted for deployment we will see our new app in the Software Centre

![](/images/2020/07/image-24.png)

Click **Install**

![](/images/2020/07/image-25.png)

Launch the Fonts control panel applet to verify the Font has been installed

![](/images/2020/07/image-26-1024x789.png)

### Summary

In this post we used two fairly simple PowerShell scripts to deploy a single Font to Windows 10 devices. The same scripts can be used to deploy the Font from Intune as a Win32App. See my previous post for an example of how to deploy a Win32App from Intune

[https://byteben.com/bb/deploy-custom-microsoft-teams-backgrounds-easily-with-powershell-and-intune/](https://byteben.com/bb/deploy-custom-microsoft-teams-backgrounds-easily-with-powershell-and-intune/)