---
title: "Using ConfigMgr #MEMCM to Pin and Un-Pin OneDrive Known Folders"
date: 2020-01-26
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "OneDrive"
  - "Windows 10"
---

First blog post of 2020 using the new #MEMCM tag! One of the things asked for recently was the ability for users to "choose" to keep OneDrive "Known Folders" available offline. This isn't necessary for a user on their Primary computer - the OneDrive files will already be local but when the user logs on to a different computer in a shared computer environment, the files will only be available on demand. We were asked to give the users the option of "Pinning" these known folders and for the admin to have the option to force it. The folders being redirected by OneDrive Known Folder Move were:-

<!--more-->

1. Desktop
2. Pictures
3. Documents
4. Favorites (IE)

During periods of network inaccessibility and to improve performance in some situations (IE didn't behave too well using symbolic links with files that were not synced offline) there was a request to make the Desktop and Favorites folders available Offline. This was a shared computing environment and customers could log on to any number of Windows 10 devices. And yes, IE is still being used, in anger, in a lot enterprises.

## The Approach

We first needed to understand how we could make these folders and files available offline in OneDrive.

Out files can be in 3 states when approaching this:-

1. File is available offline (Usually after it is recalled/opened)
2. Always keep on this device - file is always kept offline **(Pinned)**
3. Free Up Space - file is not kept on the device but is downloaded when accessed by the user (Default) **(Recall on Data Access / Unpinned)**

These file states are represented by the following icons:-

<figure>

![](/images/2019/12/onedrive-offline-memcm_2-1024x255.png)

<figcaption>

OneDrive Offline file/folder status

</figcaption>

</figure>

The terminology used since Windows 10 1703 is "Pinned", "UnPinned" when looking to set file attributes. Lets take a look at the command in Windows 10 1909. Look for the **P** and **U** attributes below:-

<figure>

![](/images/2019/12/onedrive-offline-memcm-1024x600.png)

<figcaption>

attrib.exe /?

</figcaption>

</figure>

Lets use a simple PowerShell script to identify the file attributes in our lab. We have created a nested folder structure for the purpose of this blog post

```
Get-ChildItem $ENV:OneDrive"\Desktop" -recurse | foreach {attrib.exe $_.fullname}
```

<figure>

![](/images/2019/12/onedrive-offline-memcm_3-1024x154.png)

<figcaption>

Get-ChildItem $ENV:OneDrive"\\Desktop" -recurse | foreach {attrib.exe $\_.fullname}

</figcaption>

</figure>

We can use attrib.exe to show some basic file attributes of our files. We can see clearly the **P** and **U** attribute in play in the above example

I was looking for another way to do this because attrib.exe doesn't show me the "Recall on Data Access" attribute although this attribute goes hand in hand with the Unpinned attribute - I stumbled across a cool discussion:-

[https://social.technet.microsoft.com/Forums/windowsserver/en-US/375f3933-fcab-450c-bb9c-da54155549e2/how-do-i-getset-onedrive-quotfiles-on-demandquot-status-from-powershell?forum=ITCG](https://social.technet.microsoft.com/Forums/windowsserver/en-US/375f3933-fcab-450c-bb9c-da54155549e2/how-do-i-getset-onedrive-quotfiles-on-demandquot-status-from-powershell?forum=ITCG)

JRV was showing how we can enumerate the attributes based on the flags. This gets really fun if you love .NET and SDKs. Not really on my radar but it was fun to look at this method to get the file attributes - including "Recall on Data Access" - Flag 0x00400000

- Pinned = 0x00080000
- Unpinned = 0x00100000
- Recall on Data Access = 0x00400000

```
$OneDrive = $Env:OneDrive
$OneDriveDesktop = $OneDrive + "\Desktop"
$AttributeTypes = @'
using System;
[FlagsAttribute]public enum FileAttributes : uint {
Readonly = 0x00000001,    
Hidden = 0x00000002,    
System = 0x00000004,    
Directory = 0x00000010,    
Archive = 0x00000020,    
Device = 0x00000040,    
Normal = 0x00000080,    
Temporary = 0x00000100,    
SparseFile = 0x00000200,    
ReparsePoint = 0x00000400,    
Compressed = 0x00000800,    
Offline = 0x00001000,    
NotContentIndexed = 0x00002000,    
Encrypted = 0x00004000,    
IntegrityStream = 0x00008000,    
Virtual = 0x00010000,    
NoScrubData = 0x00020000,    
EA = 0x00040000,    
Pinned = 0x00080000,    
Unpinned = 0x00100000,  
RecallOnDataAccess = 0x00400000,     
U200000 = 0x00200000,    
U800000 = 0x00800000,    
U1000000 = 0x01000000,    
U2000000 = 0x02000000,    
U4000000 = 0x04000000,    
U8000000 = 0x08000000,    
U10000000 = 0x10000000,    
U20000000 = 0x20000000,    
U40000000 = 0x40000000,    
U80000000 = 0x80000000}'

@Add-Type $AttributeTypes
Get-ChildItem $OneDriveDesktop -Recurse | Select FullName, @{Name='Attributes';E={[FileAttributes]$_.Attributes.Value__}} | Out-GridView
```

<figure>

![](/images/2019/12/onedrive-offline-memcm_4-1024x399.png)

<figcaption>

We can see which files have the Pinned, Unpinned and RecallOnDataAccess attributes set

</figcaption>

</figure>

We can also see these attributes in action when we manually pin/unpin files in OneDrive from explorer

1. Right click the file in Explorer and select "Always Keep on this Device" **(Pinned)** 0x80000 Attribute Added
2. Right click the file in Explorer and deselect "Always Keep on this Device" **(Unpinned)** Pinned Attribute Removed
3. Right click the file in Explorer and select "Free up space on this device" **(Recall on Data Access)** 0x100000 Attribute Added

<figure>

![](http://byteben.com/bb/images/2019/12/onedrive-offline-memcm_5-1024x212.png)

<figcaption>

Attributes being queried by OneDrive.exe after the attributes are changed in Explorer

</figcaption>

</figure>

### Where is this going?

That is what I started to think at this point. Where am I going with this? Well essentially I have concluded a few things:-

1. By default, all OneDrive files are kept on the device but can be moved to a "Recall on Data Access / Unpinned" status if the disk runs low on space or the user chooses to "Free Up Space" on the file/folder context menu.
2. When using the "Files on Demand" feature, all files in Onedrive are set to "Recall on Data Access / Unpinned". The Recall on Data Access and Unpinned attributes are set.
3. For files and folders, a user can choose to "Always Keep on this Device" in OneDrive - which is known as "Pinning" Items. This sets the Pinned attribute.
4. When a user chooses to "Unpin" i.e deselects "Always Keep on this Device" the Pinned attribute is removed

We can keep things really simple and stick with attrib.exe, it works really well and can be executed from a PowerShell script. A nice overview can be found here [https://techcommunity.microsoft.com/t5/Microsoft-OneDrive-Blog/OneDrive-Files-On-Demand-For-The-Enterprise/ba-p/117234](https://techcommunity.microsoft.com/t5/Microsoft-OneDrive-Blog/OneDrive-Files-On-Demand-For-The-Enterprise/ba-p/117234)

> Attrib.exe enables 2 core scenarios.  “**attrib -U +P /s**”, makes a set of files or folders always available and “**attrib +U -P /s**”, makes a set of files or folders online only. 
> 
> [https://techcommunity.microsoft.com/t5/Microsoft-OneDrive-Blog/OneDrive-Files-On-Demand-For-The-Enterprise/ba-p/117234](https://techcommunity.microsoft.com/t5/Microsoft-OneDrive-Blog/OneDrive-Files-On-Demand-For-The-Enterprise/ba-p/117234)

And that is what I am going to do to set the folder and file attributes to Pinned/Un-Pinned.

### Back on track

What do we need to do then? I will be creating an application in ConfigMgr to run a PowerShell script. The script will set the attributes of a Known Folder using attrib.exe.

Important Note: If you unpin or choose to keep any child item as online only, the attributes of the parent folders will remain pinned but the icon of the top level folders will change. Not sure if this is by design but I am keeping an eye on this for changes from Microsoft.

<figure>

![](/images/2019/12/onedrive-offline-memcm_6-1024x925.png)

<figcaption>

Attributes and Icons don't always match!

</figcaption>

</figure>

## The Script

This script either "Pins" or "Un-Pins" our Known Folders in OneDrive. Be sure to check the GIT Repository for any updates (Link Below). Code pasted below is accurate at time of this post.

[https://github.com/byteben/OneDrive/blob/master/Set\_KFM\_Attribute.ps1](https://github.com/byteben/OneDrive/blob/master/Set_KFM_Attribute.ps1)

```
<#
===========================================================================
Created on:   	26/01/2020 10:45
Created by:   	Ben Whitmore
Organization: 	
Filename:     	Set_KFM_Attribute.ps1
-------------------------------------------------------------------------
Script Name: Set_KFM_Attribute
===========================================================================
    
Version:
1.1.26.2   26/01/2020  Ben Whitmore
Added logging to HKCU for MEMCM Detection Method
HKEY_CURRENT_USER\ScriptStatus\Set_KFM_Attributes
> Attribute_Set
> Folders_Specified
> LastRun

1.1.26.1   26/01/2020  Ben Whitmore
Added "Favorites" as Known Folder Location

1.1.26.0   26/01/2020  Ben Whitmore

.DESCRIPTION
Script to set KnownFolder Pinned status

.PARAMETER KnownFolder
Specify which KnownFolders to process. Choice of "Desktop", "Documents", "Pictures", "Favorites".

.PARAMETER PinStatus
Specify the Pinned atribute to pass. Choice of "Pin", "Unpin".

.EXAMPLE
Set_KFM_Attribute.ps1 -KnownFolder "Desktop", "Documents" -PinStatus "Pin"

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet("Desktop", "Documents", "Pictures", "Favorites")]
    [String[]]$KnownFolder,
    [Parameter(Mandatory)]
    [ValidateSet("Pin", "UnPin")]
    [String]$PinStatus
)

#Set attributes to pass to attrib.exe
If ($PinStatus -eq 'Pin') { $AttributeState1 = '+P'; $AttributeState2 = '-U' }
If ($PinStatus -eq 'UnPin') { $AttributeState1 = '-P'; $AttributeState2 = '+U' }  

#Set variable for OneDrive Commercial
$OneDriveLoc = $ENV:OneDriveCommercial

#Update attributes for all files and folders specified, including toplevel KnownFolder
Foreach ($Folder in $KnownFolder) {

    #Set KnownFolder 
    $OneDriveKnownFolder = Join-Path $OneDriveLoc $Folder

    #Set the KnownFolder attribute so new items match the pinned status passed in the script
    attrib.exe $OneDriveKnownFolder $AttributeState1 $AttributeState2 /s /d

    #Process child items in the KnownFolder
    Get-ChildItem $OneDriveKnownFolder -Recurse | Select-Object Fullname | ForEach-Object { attrib.exe $_.FullName $AttributeState1 $AttributeState2 }
}

#Prepare to write registry key for MEMCM Detection Method
$RegistryPath = "HKCU:\ScriptStatus\Set_KFM_Attributes"

#Check If Script Registry Key Exists 
If (!(Test-Path $RegistryPath)) {

    #If Registry Key doesn't exist, create it
    New-Item -Path $RegistryPath -Force | Out-Null

    #Dealing with "Value Exists" logic in MEMCM Detection Method so will force the value here to say script has run
    New-ItemProperty -Path $RegistryPath -Name "Last_Run" -Value (Get-Date) -PropertyType String -Force | Out-Null

    #Create Registry Item for Known Folder the script has run against
    New-ItemProperty -Path $RegistryPath -Name "Attribute_Set" -Value $PinStatus -PropertyType String -Force | Out-Null
}
else {
     
    #Dealing with "Value Exists" logic in MEMCM Detection Method so will force the value here to say script has run
    New-ItemProperty -Path $RegistryPath -Name "Last_Run" -Value (Get-Date) -PropertyType String -Force | Out-Null

    #Create Registry Item for Known Folder the script has run against
    New-ItemProperty -Path $RegistryPath -Name "Attribute_Set" -Value $PinStatus -PropertyType String -Force | Out-Null 
}

#Reset Variables
$KnownFoldersProcessed = $Null
$Count = 0

Foreach ($Folder in $KnownFolder) {

    #Build string for Registry
    If ($Count -gt 0) { $LineBreak = ' | ' } else { $LineBreak = $Null }
    $KnownFoldersProcessed = $KnownFoldersProcessed + $LineBreak + $Folder 
    $Count ++
}

#Create Registry Item for Known Folder the script has run against
New-ItemProperty -Path $RegistryPath -Name "Folders_Specified" -Value $KnownFoldersProcessed -PropertyType String -Force | Out-Null 
```

This script will enumate the KnownFolders you specify and either Pin or UnPin the files and folders. Cool. It will also output the actions to the Users Registry so we have something to perform an Application Discovery Method against in ConfigMgr / MEMCM

An example of how we can pass parameters to this script could be:- **Set\_KFM\_Attribute.ps1 -KnownFolder "desktop", "documents", "pictures" -PinStatus "unpin"**

<figure>

![](/images/2020/01/onedrive-offline-memcm_7-1024x487.png)

<figcaption>

Logging to User Registry in anticipation of using an Application Detection Method in ConfigMgr / MEMCM

</figcaption>

</figure>

### Putting it All Together

- Create an Application in MEMCM (In our example we will deploy an Application to **PIN** the users **DESKTOP** items)
- Add an Installation Program
- Add a Repair Program
- Add a Detection Method
- Deploy to a User/Group

#### **Create an Application in MEMCM**

**Creating a Requirement to check if OneDrive exists?**

Not necessary but it might be nice to check the user has OneDrive installed before we deploy this Application to users. In one environment I created a custom Global Condition that uses a script to detect if the OneDrive path exists. Don't forget that Global Condition scripts need to be signed. More on Signing scripts here [https://byteben.com/bb/code-signing-powershell-sccm-app-detection-methods/](https://byteben.com/bb/code-signing-powershell-sccm-app-detection-methods/)  
You could always look for a registry key too to make things a little more simple. Your custom Global Condition will be available under the "Application Requirements" but to keep this post short we will omit any "Application Requirements". An example of using a Script or Registry Key lookup are below:-

Global Condition Script to Detect OneDrive is initialised

```
$OneDriveExist = $Env:OneDriveCommercial
If (Test-Path $OneDriveExist {write-host "yes"} else {write-host "No"}
```

or you could check the following Registry Key Exists using a Global Condition too

HKEY\_CURRENT\_USER\\Environment\\OneDriveCommercial

More on Creating Global Conditions can be found at [https://docs.microsoft.com/en-us/configmgr/apps/deploy-use/create-global-conditions](https://docs.microsoft.com/en-us/configmgr/apps/deploy-use/create-global-conditions)

#### **Add an Installation Program**

In our example below, we will not use a Global Condition to create a requirement for our Application.

1 . From the Application Management Workspace, select **Create > Create Application** from the ribbon bar

<figure>

![](/images/2020/01/onedrive-offline-memcm_8-1024x694.png)

<figcaption>

Create Application

</figcaption>

</figure>

2 . Choose **Manually specify the application information** and **Click** **Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_9-1024x907.png)

<figcaption>

Choose **Manually specify the application information** and click **Next**

</figcaption>

</figure>

3 . Enter an **Application Name** and **Publisher Information** and **Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_10-1024x909.png)

<figcaption>

3 . Enter an **Application Name** and **Publisher Information** and **Click Next**

</figcaption>

</figure>

4 . Choose a Software Centre Icon for you Application and **Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_11-1024x901.png)

<figcaption>

Choose a Software Centre Icon for you Application and **Click Next**

</figcaption>

</figure>

5 . To create a deployment type, **Click Add**

<figure>

![](/images/2020/01/onedrive-offline-memcm_12-1024x908.png)

<figcaption>

To create a deployment type, **Click Add**

</figcaption>

</figure>

6 . Choose **Script Installer** from the **Type** drop down box and **Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_13-1024x913.png)

<figcaption>

Choose **Script Installer** from the **Type** drop down box and **Click Next**

</figcaption>

</figure>

7 . Enter a Deployment Type **Name** and **Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_14-1024x908.png)

<figcaption>

Enter a Deployment Type **Name** and **Click Next**

</figcaption>

</figure>

8 . Enter the following Content Information:- 
  
**Content Location:** \\\\yourserver\\contentdirectory (Should contain the PowerShell Script **Set\_KFM\_Attribute.ps1**)  
**Installation Program \* :** **Powershell.exe -ExecutionPolicy Bypass -File "Set\_KFM\_Attribute.ps1" -KnownFolder "desktop" -PinStatus "pin"**  
  
\* This command line assumes you have not signed the PowerShell script. Modify the parameters according to the Execution Policy in your environment.

**Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_15-1024x915.png)

<figcaption>

Enter the Content Information detailed above

</figcaption>

</figure>

9 . **Click Add Clause**

<figure>

![](/images/2020/01/onedrive-offline-memcm_16-1024x913.png)

<figcaption>

**Click Add Clause**

</figcaption>

</figure>

10 . Set the following Detection Method **HKEY\_CURRENT\_USER\\ScriptStatus\\Set\_KFM\_Attributes**  
  
**Setting Type:** Registry  
**Hive:** HKEY\_CURRENT\_USER  
**Key:** ScriptStatus\\Set\_KFM\_Attributes

**Click OK**

<figure>

![](/images/2020/01/onedrive-offline-memcm_17-1024x1014.png)

<figcaption>

Set the Detection Method to **HKEY\_CURRENT\_USER\\ScriptStatus\\Set\_KFM\_Attributes**

</figcaption>

</figure>

11 . **Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_18-1024x910.png)

<figcaption>

**Click Next**

</figcaption>

</figure>

12 . Specify the following User Experience settings:-

  
**Installation Behaviour:** Install for user  
**Installation program visibility:** Hidden  
**Maximum allowed run time (minutes):** 30 (Change this to suite your user environment. If your users have a large number of files and folders you may need to increase this)  
**Estimated installation time (minutes):** 5 (Same advice as above in regards to this setting)

**Click Next**

![](/images/2020/01/onedrive-offline-memcm_19-1024x912.png)

13 . On the Installation Requirements screen, **Click Next** (Unless you have created a Global Condition to detect OneDrive exists as discussed earlier in the post)

14 . On the Software Dependencies screen, **Click Next**

15 . On the Summary screen, **Click Next**

16 . **Click Close**

17 . **Click Edit** (We want to edit the Deployment Type to add a "Repair Program" option)

![](/images/2020/01/onedrive-offline-memcm_20-1024x915.png)

18 . On the **Programs** tab, copy the Installation Program and paste it into the Repair Program box then **Click OK**

Adding a Repair Program will give the User the option of "Re-Running" this script at a later date from Software Centre. Cool! (Although Software Centre will display the "Repair" button which may confuse users)

<figure>

![](/images/2020/01/onedrive-offline-memcm_21-1024x956.png)

<figcaption>

On the **Programs** tab, copy the Installation Program and paste it into the Repair Program box then **Click OK**

</figcaption>

</figure>

19 . **Click Next** (Twice)

20 . **Click Close**

#### **Deploy the Application to a User/s**

1 . From the Applications Workspace, highlight our new app and **Click Deploy** on the Ribbon bar

<figure>

![](/images/2020/01/onedrive-offline-memcm_22-1024x629.png)

<figcaption>

**Click Deploy** on the Ribbon bar

</figcaption>

</figure>

2 . To choose a Collection for Deployment, **Click Browse**

<figure>

![](/images/2020/01/onedrive-offline-memcm_23-1024x939.png)

<figcaption>

**Click Browse**

</figcaption>

</figure>

3 . Select the target User or User Group to deploy the application to and **Click OK** (I am using **All Users** because it is my lab environment - I don't expect you to use that Collection!)

![](/images/2020/01/onedrive-offline-memcm_24-1024x688.png)

4 . **Click Next**

5 . Choose a Distribution Point or Distribution Point Group to deploy this application content to and **Click Next**

![](/images/2020/01/onedrive-offline-memcm_25-1024x855.png)

6 . Select the following Deployment Settings

**Action:** Install  
**Purpose:** Available  
**Allow end users to attempt to repair this application:** Check (This will allow the User to re-run this script again from the Software Centre)

**Click Next**

<figure>

![](/images/2020/01/onedrive-offline-memcm_26-1024x956.png)

<figcaption>

Select the Deployment Settings outlined above

</figcaption>

</figure>

7 . On the Schedule page, set the options that suite your environment and **Click Next**

8 . On the User Experience page, set the options that suite your environment and **Click Next**

9 . On the Alerts page, set the options that suite your environment and **Click Next**

10 . On the Summary page, **Click Next**

11 . **Click Close**

#### **Seeing the Script in Action**

I am going to log on to a Windows 10 client in my lab. The user account logged in has OneDrive installed and a GPO has set the Known Folder Move settings already

We can tell a few things from the screenshot below:- 
  
1\. The New Application is available in Software Centre to my user  
2\. KFM GPO has mapped my Desktop Folder to OneDrive and I can see stuff  
3\. My Desktop files are currently not on my computer, their attribute is set to "Recall on Data Access"

<figure>

![](/images/2020/01/onedrive-offline-memcm_27-1024x764.png)

<figcaption>

User logged on in my lab environment

</figcaption>

</figure>

Lets go and run the Application in Software Centre and see what happens. Select the Application and **Click Install**

<figure>

![](/images/2020/01/onedrive-offline-memcm_28-1024x717.png)

<figcaption>

**Click Install**

</figcaption>

</figure>

The Script is running, I was quick with the screen grab and can see my file statuses changing! (So much fun)

<figure>

![](/images/2020/01/onedrive-offline-memcm_29-1024x680.png)

<figcaption>

File and Folder Status changing as the script runs

</figcaption>

</figure>

And once the Application has completed we get a "Repair" option in Software Centre and ALL our Desktop files are now "Pinned" Offline

<figure>

![](/images/2020/01/onedrive-offline-memcm_30-1024x677.png)

<figcaption>

Application Installation Succeeded

</figcaption>

</figure>

Lets check the Registry! The Application Succeeded which means our Detection Method has read the relevant Registry Keys installed by the script.  
The script has created the Key used for Application Detection but also some other useful values for troubleshooting like:-

1. Which Attributes were last passed by the script
2. Which Folders were specified when the script last ran
3. What date/time did the script last run

<figure>

![](/images/2020/01/onedrive-offline-memcm_31-1024x672.png)

<figcaption>

The Script also sets some useful registry entries for Admin purposes

</figcaption>

</figure>

### Summary

What a long post!

I now have a better appreciation of OneDrive and how file attributes work when pinning and unpinning stuff. There is a slight quirk with top level folder icons not matching its pinned/unpinned attribute but this may get "looked at" in future versions.

If the user clicked "Repair" the same script will run again and re-pin everything. We can create multiple applications and pass different parameters to the same script to achieve different outcomes. For example, some users may wish to free up space on their computer so deploying the script with the "UnPin" parameter could be handy

I am using the "Repair" option **A LOT** these days when deploying scripts. If the ConfigMgr team are reading this, I would love the option to change the "repair" button to a "re-run" button for these type of deployments....A guy can dream haha :)

Let me know if you think this process can be improved. See you next time :) Ben