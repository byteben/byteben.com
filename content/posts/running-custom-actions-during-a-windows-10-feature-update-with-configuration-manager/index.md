---
title: "Running custom actions during a Windows 10 Feature Update with Configuration Manager"
date: 2021-04-12
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "Scripts"
  - "Windows 10"
---

Deploying Windows 10 Feature Updates in your organisation can be approached in multiple ways. As we merge the perimeter with the Cloud some of us are trying to understand the best way to deliver Feature Updates to our devices. Should we deploy an in-place upgrade using a ConfigMgr task sequence? Perhaps we should push the Feature Update directly from ConfigMgr to our devices. Have we considered leveraging our CMG and using Microsoft as a source for the update binaries to save our VPNs? Maybe some of us are on a co-management journey and are looking at using WUfB. Which ever technology we are leveraging one of the questions that normally gets asked is "Can we control the update process in a way that lets us 'Run Stuff' after the Feature Update has completed".

<!--more-->

## SetupConfig.ini

When a Feature Update is deployed using the Windows Update Service a file called **SetupConfig.ini** can be used to control some aspects of the update process. The **SetupConfig.ini** file can be used by admins in scenarios where there is the inability to pass specific switch parameters to setup.exe during a Windows 10 Feature Update.

Below is an example of the what the content of **SetupConfig.ini** might look like

\[SetupConfig\]  
NoReboot  
ShowOobe=None  
Telemetry=Enable  
InstallDrivers=  
ReflectDrivers=

The example above is taken from  
[https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview)

For a more comprehensive list of the commands that can be used during Windows Setup check out the following Microsoft article  
[https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options)

The Feature Update process will look for **SetupConfig.ini** in the following location: -

SystemDrive\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\WSUS\\**SetupConfig.ini**

## PostOOBE

We can specify the **POSTOOBE** parameter in the **SetupConfig.ini** file to tell the Windows Update Service to run a command after the Feature Update has been installed. If you have previously used a ConfigMgr Task Sequence to manage in-place upgrades, you may have noticed that ConfigMgr would typically reference a batch file called **SetupComplete.cmd** to run after the update process. It makes sense to use the same batch file name for familiarity when we use the Windows Update Service to deploy a Feature Update. The batch file can be placed anywhere on the device as long as it isn't removed during the Feature Update process. For this reason, placing it outside of the Windows directory is quite sensible.

Below is an example of what the **POSTOOBE** reference might look like in the **SetupConfig.ini**

\[SetupConfig\]  
NoReboot  
ShowOobe=None  
Telemetry=Enable  
InstallDrivers=  
ReflectDrivers=  
POSTOOBE=C:\\ProgramData\\FeatureUpdate\\SetupComplete.cmd

**A Batch File...Really?**

**SetupComplete.cmd** is simply used to kick off any script or process we want to run after the Feature Update has been installed. You can specify multiple commands within the batch file or call your other custom scripts. An example of what **SetupComplete.cmd** may contain could be: -

```
PowerShell.exe -ExecutionPolicy Bypass -File C:\ProgramData\FeatureUpdate\SetupComplete.ps1 -WindowStyle Hidden
```

## Practical Example

"**Feature Update - Post OOBE Script**"

Because we are using the Windows Update Service to deliver the Feature Update (not a Task Sequence), I would typically deploy my custom **POSTOOBE** scripts and files as an application in ConfigMgr or Win32app in Intune. In the example that follows I will show you how to leverage **SetupConfig.ini** to run a PowerShell script during **POSTOOBE** and copy some files back into the Windows directory that may have been overwritten during the Feature Update.

> Ensure the application is deployed to the client before the client is targeted for a Feature Update

The example application we will create is called **Feature Update - Post OOBE Script - 1.09.04**. We will deploy the application with ConfigMgr. The application uses version control and installs files used for **POSTOOBE** to **C:\\ProgramData\\FeatureUpdate\\<version>**. The reference to the **POSTOOBE** command in the **SetupConfig.ini** will change to reflect the version of the application we deploy from ConfigMgr e.g.

```
[SetupConfig]
POSTOOBE=C:\ProgramData\FeatureUpdate\1.09.04\SetupComplete.cmd
```

### Application Intent

Our application will do the following: -

1. Create/Replace **SetupConfig.ini** at _SystemDrive\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\WSUS\\**SetupConfig.ini**_
2. Create a folder structure at: - _SystemDrive\\ProgramData\\FeatureUpdate\\<version>_
3. Create **SetupComplete.cmd** and add a reference to run **SetupComplete.ps1**. Both of these files will be saved in: - _SystemDrive\\ProgramData\\FeatureUpdate\\<version>_
4. Add a reference in **SetupConfig.ini** for **POSTOOBE** to run _SystemDrive\\ProgramData\\FeatureUpdate\\<version>\\**SetupComplete.cmd**_
5. **Version.txt** should contain the version number of the application being deployed. This is useful if you change the application intent and need to ensure your devices have the up-to-date files/scripts in place before they attempt a Feature Update. The version number in this file is used to dynamically build the different elements of the solution, including the actual path where the solution will be installed. In our example, **Version.txt** will contain one line of text: **1.09.04**
6. Add a reference in **SetupConfig.ini** to set the Priority of Windows Setup to "Normal". Some parts of a Feature Update are set to run with a low priority. Microsoft have published best practice for Feature Update priority here: - [https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install](https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install))
7. Copy the **Files** folder to _SystemDrive\\ProgramData\\FeatureUpdate\\<version>_. This folder contains the files we want to copy back to the _SystemDrive_ during **POSTOOBE**. The **Files** folder structure, in your application content source, should resemble the existing Windows disk layout. In this example, we are copying back some Default User Account Pictures to _C:\\ProgramData\\Microsoft\\User Account Pictures_ and a new wallpaper to _C:\\Windows\\Web\\Wallpaper_

<figure>

![](/images/2021/04/image-18-1024x370.png)

<figcaption>

"Files" folder structure

</figcaption>

</figure>

<figure>

![](/images/2021/04/image-19-1024x298.png)

<figcaption>

User Account Pictures Files

</figcaption>

</figure>

<figure>

![](/images/2021/04/image-20-1024x296.png)

<figcaption>

Wallpaper Files

</figcaption>

</figure>

### Application Installation Flow

Below is an overview of the installation flow for the **Feature Update - Post OOBE Script** application we will deploy from ConfigMgr

![](/images/2021/04/image-21-1024x869.png)

### Application Scripts

We will use 3 scripts to install / maintain our **"Feature Update - Post OOBE Script"** application

1. Install\_SetupComplete.ps1
2. Uninstall\_SetupComplete.ps1
3. Detect\_SetupComplete.ps1

**[Install\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Install_SetupComplete.ps1)**

```
<#
.Synopsis
Created on:   10/04/2021
Created by:   Ben Whitmore
Filename:     Install_SetupComplete.ps1
.Description
Script to install a custom SetupComplete.cmd which will be used POSTOOBE when installing a Feautre Update using Windows Update.
Files in the "Files" source folder should resemble the structure from the root $env:SystemDrive
e.g. If you want to copy custom account pictures to your device after the OOBE they should be placed in ..\Files\ProgramData\Microsoft\User Account Pictures
Version.txt should contain the current version of SetupComplete.cmd. The application is designed with version control in mind. The version value will determine the path in $env:SystemDrive\ProgramData which the "FeatureUpdate" folder is created and the reference in SetupConfig.ini will also point to $env:SystemDrive\ProgramData\FeatureUpdate\<version>\SetupComplete.cmd
#>
#Setup environment
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SetupCompleteVersionFile = Join-Path -Path $ScriptPath -ChildPath "Version.txt"
#Get intended Version of SetupComplete
Try {
    If (Test-Path -Path $SetupCompleteVersionFile) {
        $SetupCompleteVersion = Get-Content $SetupCompleteVersionFile
        $SetupCompleteLocation = Join-Path -Path "$($env:SystemDrive)\ProgramData\FeatureUpdate" -ChildPath $SetupCompleteVersion
        $SetupCompleteCMD = Join-Path -Path $SetupCompleteLocation -ChildPath "SetupComplete.cmd"
    }
}
Catch {
    Write-Host "Error getting SetupComplete Version from Script Source Directory. Does version.txt exist?"
}
  
Try {
    #Setup Directory and create SetupComplete.cmd
    New-Item $SetupCompleteLocation -ItemType Directory -Force 
    New-Item $SetupCompleteCMD -ItemType File -Force 
    #Add correct version of SetupComplete.ps1 to run post Feature Update
    Add-Content -Path $SetupCompleteCMD -Value "powershell.exe -executionpolicy bypass -file $($SetupCompleteLocation)\SetupComplete.ps1 -WindowStyle Hidden"
}
Catch {
    Write-Host "Error creating file ""$($SetupCompleteCMD)"""
}
Try {
    #Declare items to copy to Feature Update staging folder
    $SetupFiles = @("SetupComplete.ps1", "Files", "Version.txt")
    #Copy Files from Script Root to Feature Update staging folder
    Foreach ($File in $SetupFiles) {
        $FiletoCopy = Join-Path -Path $ScriptPath -ChildPath $File -ErrorAction SilentlyContinue
        Try {
            Copy-Item -Path $FiletoCopy -Destination $SetupCompleteLocation -Force -Recurse
        }
        Catch {
            Write-Warning: "Error copying item ""$($File)"" to ""$($SetupCompleteLocation)"""
        } 
    }
}
Catch {
    Write-Warning "Error setting up the Feature Update staging folder"
}
#Create SetupConfig.ini
#Source https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install#step-2-override-the-default-windows-setup-priority-windows-10-version-1709-and-later
#Variables for SetupConfig
$iniFilePath = "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\WSUS\SetupConfig.ini"
$PriorityValue = "Normal"
$iniSetupConfigSlogan = "[SetupConfig]"
$iniSetupConfigKeyValuePair = @{"Priority" = $PriorityValue; "PostOOBE" = $SetupCompleteCMD }
#Init SetupConfig content
$iniSetupConfigContent = @"
$iniSetupConfigSlogan
"@
Try {
    #Setup SetupConfig Directory
    #Build SetupConfig content with settings
    foreach ($k in $iniSetupConfigKeyValuePair.Keys) {
        $val = $iniSetupConfigKeyValuePair[$k]
        $iniSetupConfigContent = $iniSetupConfigContent.Insert($iniSetupConfigContent.Length, "`r`n$k=$val")
    }
    #Write content to file 
    New-Item $iniFilePath -ItemType File -Value $iniSetupConfigContent -Force
}
Catch {
    Write-Warning "Error creating ""$($iniFilePath)"""
}
```

[Uninstall\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Uninstall_SetupComplete.ps1)

```
<#
.Synopsis
Created on:   10/04/2021
Created by:   Ben Whitmore
Filename:     Uninstall_SetupComplete.ps1
.Description
Script to uninstall a custom SetupComplete.cmd which will be used POSTOOBE when installing a Feautre Update using Windows Update.
$env:SystemDrive\ProgramData\FeatureUpdate\<version>\ will be removed
$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\WSUS\SetupConfig.ini will be removed if the following line is present in SetupConfig.ini "PostOOBE=$env:SystemDrive\ProgramData\FeatureUpdate\<version>\SetupComplete.cmd"
#>
#Setup environment
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SetupCompleteVersionFile = Join-Path -Path $ScriptPath -ChildPath "Version.txt"
#Get intended Version of SetupComplete
Try {
    If (Test-Path -Path $SetupCompleteVersionFile) {
        $SetupCompleteVersion = Get-Content $SetupCompleteVersionFile
        $SetupCompleteLocation = Join-Path -Path "$($env:SystemDrive)\ProgramData\FeatureUpdate" -ChildPath $SetupCompleteVersion
    }
}
Catch {
    Write-Host "Error getting SetupComplete Version from Script Source Directory. Does version.txt exist?"
}
  
Try {
    #Remove Directory
    Remove-Item $SetupCompleteLocation -Force -Recurse
}
Catch {
    Write-Host "Error removing ""$($SetupCompleteLocation)"""
}
#Remove SetupConfig.ini
Try {
    $iniFilePath = "$($env:SystemDrive)\Users\Default\AppData\Local\Microsoft\Windows\WSUS\SetupConfig.ini"
    if (Test-Path -Path $iniFilePath) {
        $SetupConfigini_Content = Get-Content $iniFilePath
        foreach ($line in $SetupConfigini_Content) { 
            If ($line -like "PostOOBE=$($SetupCompleteLocation)\SetupComplete.cmd") {
                Remove-Item $iniFilePath -Force
            }
        } 
    }
}
Catch {
    Write-Host "Error removing ""$($iniFilePath)"""
}
```

[Detect\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Detect_SetupComplete.ps1)

```
<#
.Synopsis
Created on:   10/04/2021
Created by:   Ben Whitmore
Filename:     Detect_SetupComplete.ps1
.Description
Detection script to be deployed with ConfigMgr to detect SetupComplete.cmd in $env:SystemDrive\ProgramData\FeatureUpdate\<version>\SetupComplete.cmd and to check SetupCOnfig.ini references the correct version of the application i.e. $env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\WSUS\SetupConfig.ini POSTOOBE will reference SetupComplete.cmd as outlined above
#>
$SetupCompleteVersion = "1.09.04"
$SetupCompleteLocation = Join-Path -Path "$($env:SystemDrive)\ProgramData\FeatureUpdate" -ChildPath $SetupCompleteVersion
$FUFilesInComplete = $Null
$SetupConfigini_Valid = $Null
Try {
	If (!(Test-Path -Path $SetupCompleteLocation)) {
		$FUFilesInComplete = $True
	}
}
Catch {
	$FUFilesInComplete = $True
}
Try {
	$iniFilePath = "$($env:SystemDrive)\Users\Default\AppData\Local\Microsoft\Windows\WSUS\SetupConfig.ini"
	if (Test-Path -Path $iniFilePath) {
		$SetupConfigini_Content = Get-Content $iniFilePath
		foreach ($line in $SetupConfigini_Content) { 
			If ($line -like "PostOOBE=$($SetupCompleteLocation)\SetupComplete.cmd") {
				$SetupConfigini_Valid = $True
			}
		} 
	}
	else {
		$FUFilesInComplete = $True
	}
}
Catch {
	$FUFilesInComplete = $True
}
If (($SetupConfigini_Valid) -and (!($FUFilesInComplete))) {
	Write-Output "Installed"
}
```

The installation and removal scripts will reference **Version.txt** to install/remove the correct version of the application. We cannot reference **Version.txt** to get the application version when we use a script for the detection method so the version number must be manually updated within the detection script

> The version number in the Detection Method script must be updated manually to reflect the content of **Version.txt**

### Application Content Source

You should have the following files present in your application content source folder. (The Install/Uninstall and Detect scripts will not get copied to _SystemDrive\\ProgramData\\FeatureUpdate\\<version>_).

- **[Files](https://github.com/byteben/Windows-10/tree/master/Feature%20Updates/SetupCompleteCMD/Files)** (Folder containing any files you wish to restore after a Feature Update
- **[Detect\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Detect_SetupComplete.ps1)**
- **[Install\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Install_SetupComplete.ps1)**
- **[SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/SetupComplete.ps1)** (This is the script that will be launched from **SetupComplete.cmd** during **POSTOOBE**)
- **[Uninstall\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Uninstall_SetupComplete.ps1)**
- **[Version.txt](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Version.txt)**

![](/images/2021/04/image-22-1024x277.png)

### Build the Application

1\. Create a new Application in Configuration Manager

2\. Choose to **Manually specify the application information**

3\. **Name** the application **Feature Update - Post OOBE Script - 1.09.04** and add a **Software version**: **1.09.04**

4\. Add a **Deployment Type** of type **Script Installer**

5\. **Name** the Deployment Type **Feature Update - Post OOBE Script - 1.09.04**

6\. Specify the content location for application source files as mentioned in the previous section "Application Content Source"

7\. Set the Installation program to

```
powershell.exe -executionpolicy bypass -file "install_setupcomplete.ps1"
```

8\. Set the Uninstallation program to

```
powershell.exe -executionpolicy bypass -file "uninstall_setupcomplete.ps1"
```

9\. Set the **Detection Method** to use the **[Detect\_SetupComplete.ps1](https://github.com/byteben/Windows-10/blob/master/Feature%20Updates/SetupCompleteCMD/Detect_SetupComplete.ps1)** PowerShell script. Remember the version in the detection script must match the value within **Version.txt**

10\. Set the user experience settings to

**Installation Behaviour:** Install for System  
**Logon requirement:** Whether or not a user is logged on  
**Installation program visibility:** Hidden  
**Maximum allowed run time (minutes):** 15

11\. Add a **Requirement** for the Operating System to equal **Windows 10**

12\. Deploy the application as **Required** to the device collection that will be targeted for the Feature Update

### Review Installation

You should observe the following on your targeted devices:-

- **SetupConfig.ini** exists at _SystemDrive\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\WSUS\\SetupConfig.ini_ and has the **Priority** and **POSTOOBE** values have been populated as expected

<figure>

[![](/images/2021/04/image-1.png)](/images/2021/04/image-1.png)

<figcaption>

SetupConfig.ini

</figcaption>

</figure>

- The folder _SystemDrive\\ProgramData\\FeatureUpdate\\1.09.04_ exists and contains the expected files and folders

<figure>

![](/images/2021/04/image-25.png)

<figcaption>

POSTOOBE Installation Folder

</figcaption>

</figure>

- **SetupComplete.cmd** contains the following line

```
powershell.exe -executionpolicy bypass -file C:\ProgramData\FeatureUpdate\1.09.04\SetupComplete.ps1 -WindowStyle Hidden
```

- **SetupComplete.ps1** contains the following

```
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
#Copy Files from Script Root to Feature Update staging folder     
Try {
    $FilestoCopy = Join-Path -Path $ScriptPath -ChildPath "Files"
    Robocopy.exe $FilestoCopy $env:systemdrive\ /e /z /r:5 /w:1 /eta
}
Catch {
    Write-Warning: "Error copying files to ""$($env:systemdrive)"""
}
#Do other stuff here...
```

## POSTOOBE Review

After the Feature Update has completed, you can review **Setupact.log** in the C:\\Windows\\Panther folder and see that your script was used during **POSTOOBE**

<figure>

[![](/images/2021/04/image-1024x267.png)](/images/2021/04/image.png)

<figcaption>

Setupact.log

</figcaption>

</figure>

And in our example, the default User Account Pictures were restored and the new wallpaper copied to the Windows\\Web\\Wallpaper directory (and set by policy)

<figure>

![](/images/2021/04/image-28.png)

<figcaption>

Default User Account Pictures restored

</figcaption>

</figure>

<figure>

![](/images/2021/04/image-29.png)

<figcaption>

New wallpaper added (and set via Policy)

</figcaption>

</figure>

## Summary

In this blog post we looked at how we could manipulate the Feature Update process when it is being deployed using the Windows Update Service. Now you understand the concept of **SetupConfig.ini** and **POSTOOBE** you can very easily adapt the application to be deployed as a Win32app in Intune. There are other actions you can leverage using **SetupConfig.ini** to give your users the best experience during a Feature Update.

**SetupConfig.ini** is not as versatile as using a Task Sequence but it gives us some degree of control over the update process. I am really excited to see the new feature in ConfigMgr 2103 where we can deliver Feature Updates in a Task Sequence!

Further reading and best practice can be found below

[Best practices - deploy feature updates for user-initiated installations - Windows Deployment | Microsoft Docs](https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install)

[Windows Setup Command-Line Options | Microsoft Docs](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options#priority)

[https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install#step-2-override-the-default-windows-setup-priority-windows-10-version-1709-and-later](https://docs.microsoft.com/en-us/windows/deployment/update/feature-update-user-install#step-2-override-the-default-windows-setup-priority-windows-10-version-1709-and-later)