---
title: "User-Driven Home Drive Migrations to OneDrive using MEMCM"
date: 2021-03-01
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
  - "OneDrive"
  - "Scripts"
  - "Windows 10"
---

This script wont necessarily fit your environment, it may do with tweaking, but my hope is that it will give you an idea of how you can approach different challenges using the different tools in you arsenal.

<!--more-->

**TL;DR** The script can be found here [https://github.com/byteben/OneDrive/blob/master/export-homedrive.ps1](https://github.com/byteben/OneDrive/blob/master/export-homedrive.ps1)

During a recent Windows 10 adoption project there was a requirement to migrate user home drives from a traditional file share to OneDrive for Business. Because of legacy management options and a 3rd party profile management solution OneDrive "Known Folder Move" would have been the more complex approach. Before we start this blog I would encourage you to look at KFM because generally it is the preferred way to get user home drives and known folders into OneDrive.

[https://docs.microsoft.com/en-us/onedrive/redirect-known-folders](https://docs.microsoft.com/en-us/onedrive/redirect-known-folders)

As with any migration project we tried to keep things as "light touch" and simple as possible and left some optional migration workloads up to the user after first logon. The priority was to get them logged in to their new Windows 10 device and be "Work Ready" with access to mail and LOB applications quickly. Here is the environment we were dealing with:-

1. Windows 7 to Windows 10 Migration
2. OSD from ConfigMgr
3. Domain Joined Devices
4. M365 E3 SKU for all users
5. OneDrive automatically configured at logon. See my previous post on how to get this working efficiently and at speed [https://byteben.com/bb/installing-the-onedrive-sync-client-in-per-machine-mode-during-your-task-sequence-for-a-lightening-fast-first-logon-experience](https://byteben.com/bb/installing-the-onedrive-sync-client-in-per-machine-mode-during-your-task-sequence-for-a-lightening-fast-first-logon-experience)

We were publishing a category in the Software Centre called "Getting Started" where we posted various "User" centric scripts. Items such as "Pin Known Folders" [https://byteben.com/bb/using-configmgr-memcm-to-pin-and-un-pin-onedrive-known-folders/](https://byteben.com/bb/using-configmgr-memcm-to-pin-and-un-pin-onedrive-known-folders/) and it seemed the perfect place to publish a script so the users could, if they chose to, migrate their old Home Drive to OneDrive. All User Home Drives were published on a single file share which made things really simple.

### The Approach

One of the requirements was to have the option "not" to copy across old .lnk and .url files from the old environment because of shortcut duplicity issues when redirecting a Desktop to OneDrive (How many Teams icons do you have on your Desktop?!). We started out trying to build scripts focused around the Copy-Item cmdlet but soon ran into some challenges so ended up using a tool built into Windows called Robocopy. Robocopy is so versatile when it comes to copying files and folders it just made sense to use it for our script - why spend time re-inventing the wheel when Microsoft give you a tool that just works! You can read more about Robocopy here [https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy)

We will publish a Script in the Software Centre for the user to run. The Script running status will be visible to the user so they can see the progress being made - hopefully this would stop them logging off before we had change to finish migrating the data.

### The Script

Robocopy has an abundance of switches to use for migrating files. You can run **robocopy.exe /?** to see the full list but here are the ones we will use:-

**/e** copy subdirectories, including Empty ones**/z** copy files in restartable mode**  
/sec** copy files with Security**  
/r:** number of Retries on failed copies: default 1 million**/w:** Wait time between retries: default is 30 seconds**/reg** Save /R:n and /W:n in the Registry as default settings**/v** produce Verbose output, showing skipped files**/eta** show Estimated Time of Arrival of copied files**/xf** eXclude Files matching given names/paths/wildcards**/xd** eXclude Directories matching given names/paths**  
/UNILOG+:** output status to LOG file as UNICODE (append to existing log)

**OneDrive Exclusions**

Certain characters have a special meaning in SharePoint so some filenames are not supported. We should exclude these when migrating home drives to OneDrive. The full list can be found here [https://support.microsoft.com/en-us/office/invalid-file-names-and-file-types-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa](https://support.microsoft.com/en-us/office/invalid-file-names-and-file-types-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa)

We will exclude the following file names/types

**'\*.lock', '\*.tmp', 'CON', 'PRN', 'AUX', 'NUL', 'COM0', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT0', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9', '\_vti\_', 'desktop.ini'** We also decided to exclude the Recycle Bin from migration using the value **$Recycle.Bin** in our script

**Caveats that should be observed**

1. The script will only work for Domain Users logged onto Domain Joined devices. If there is interest for this to work for AAD Joined Devices let me know
2. In this environment, drives were mapped with the SamAccountName. The Home Drive Structure resembled the following:-

\\\\fileserver\\usershare$\\bwhitmore  
\\\\fileserver\\usershare$\\bwhitmore\\**Documents**  
\\\\fileserver\\usershare$\\bwhitmore\\**Desktop**  
\\\\fileserver\\usershare$\\bwhitmore\\**Favorites**  
\\\\fileserver\\usershare$\\bwhitmore\\**Pictures**

The script can be found here [https://github.com/byteben/OneDrive/blob/master/export-homedrive.ps1](https://github.com/byteben/OneDrive/blob/master/export-homedrive.ps1)

```
<#
===========================================================================
Created on:   	26/01/2020 10:45
Created by:   	Ben Whitmore
Organization: 	
Filename:     	Export-HomeDrive.ps1
-------------------------------------------------------------------------
Script Name: Export-Homedrive
===========================================================================

Version 1.1 - 01/03/21
- Added source share parameter
- Added commenting
- Removed Template Directory consideration
- Added parameter option to archive desktop shortcuts

Version 1.0 - 26/01/20
- Original release

.SYNOPSIS
The purpose of the script is to allow users to migrate their own redirected home drives during a Windows 10 refresh where KFM isnt suitable

.Parameter HomeDriveRoot
Specify the root share to the homedrive server

.Parameter ArchiveDesktopShortcuts
Specify this switch to archive old URL and LNK files to a new folder on the desktop called Old_Shortcuts

.Example
Export-HomeDrive.ps1 -HomeDriveRoot "\\fileserver\usershare$" -ArchiveDesktopShortcuts

#>

Param
(
    [Parameter(Mandatory = $False)]
    [String]$HomeDriveRoot = "\\fileserver\usershare$",
    [Switch]$ArchiveDesktopShortcuts
)

#Set OneDrive Variable
$OneDriveDir = $Env:OneDriveCommercial

#Get username and remove the Domain Netbios portion
$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Username = $Username.split("\")[1]

#Set variable for existing homedrive
$HomeDrive = Join-Path $HomeDriveRoot $Username

#Define file types we do not want to copy to OneDrive
$Exclude = @('*.lock', '*.tmp', 'CON', 'PRN', 'AUX', 'NUL', 'COM0', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT0', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9', '_vti_', 'desktop.ini')

#Create array of destinations. We utilise OneDrive know Folder Move and redirect the users folders to the OneDrive Root using the hieracrchy below
$Destinations = @('Documents', 'Pictures', 'Favorites', 'Desktop')

#Create log file
$Log = Join-Path $OneDriveDir 'Documents\HomeDrive_Sync_log.txt'

If (Test-Path $Log) {
    Remove-Item $Log -Force | Out-Null
}

#Iterate through each root folder
Foreach ($Destination in $Destinations) {
    
    #Set variable for fileserver source and OneDrive folder destination
    $HomeSource = Join-Path $HomeDrive $Destination
    $OneDriveDestination = Join-Path $OneDriveDir $Destination

    #Create the destination root folder in OneDrive
    If (Test-Path $OneDriveDir) {

        If (!(Test-Path $OneDriveDestination)) {
            New-Item -Path $OneDriveDestination -ItemType Directory -Force -ErrorAction Continue 
        }
        
        #Copy items from old redirected Desktop to OneDrive\Desktop, excluding the Recycle Bin. Move any .lnk or .url files to a new folder on the desktop called Old_Shortcuts. This avoids duplicate because MEMCM/GPO creates the correct application shortcuts in Windows 10
        If ($Destination -eq 'Desktop') {
            If ($ArchiveDesktopShortcuts) {
                New-Item -Path (Join-Path $OneDriveDestination 'Old_Shortcuts') -ItemType Directory -Force -ErrorAction Continue 
                Robocopy.exe $HomeSource (Join-Path $OneDriveDestination 'Old_Shortcuts') *.lnk *.url /z /sec /r:5 /w:1 /reg /v /eta /xd (Join-Path $HomeSource '$Recycle.Bin') /UNILOG+:$Log
                Robocopy.exe $HomeSource $OneDriveDestination /e /z /sec /r:5 /w:1 /reg /v /eta /xf *.lnk *.url $Exclude /xd (Join-Path $HomeSource '$Recycle.Bin') /UNILOG+:$Log
            }
            else {
                Robocopy.exe $HomeSource $OneDriveDestination /e /z /sec /r:5 /w:1 /reg /v /eta /xf $Exclude /xd (Join-Path $HomeSource '$Recycle.Bin') /UNILOG+:$Log
            }
        }
        
        #Copy items from old redirected Documents to OneDrive\Documents, excluding the Recycle Bin.
        If ($Destination -eq 'Documents') {
            Robocopy.exe $HomeSource $OneDriveDestination /e /z /sec /r:5 /w:1 /reg /v /eta /xd (Join-Path $HomeSource '$Recycle.Bin') /xf $Exclude /UNILOG+:$Log
        }

        #No special consideration required for Pictures or IE Favorites. We copy these into the relevant root folder in OneDrive
        If (!($Destination -eq 'Desktop') -and !($Destination -eq 'Documents')) {
            Robocopy.exe $HomeSource $OneDriveDestination /e /z /sec /r:5 /w:1 /reg /v /eta /xf $Exclude /xd (Join-Path $HomeSource '$Recycle.Bin') /UNILOG+:$Log
        }
    }
}

#We create a file to indicate the script has run for MEMCM detection.
New-Item -Path (Join-Path $OneDriveDir 'Documents\HomeDrive_Synced.txt') -ItemType File -Force -ErrorAction Continue
```

### Publishing the Script in MEMCM

Create an application in MEMCM to run this PowerShell script. Remember, we want the user to see the script running and we should have an extended run time to account for large home directories. The script pops a file in the root of OneDrive Documents called HomeDrive\_Synced.txt. We will use this as our detection method.

**Installation Program:** powershell.exe -windowstyle normal -executionpolicy bypass -file "Export-Homedrive.ps1" -HomeDriveRoot "\\\\fileserver\\usershare$" -ArchiveDesktopShortcuts  
**Detection Method:** Script

```
$OneDrive = $Env:OneDrive
$OneDrivePath = $OneDrive + "\Documents\HomeDrive_Synced.txt" 
If (Test-Path $OneDrivePath){write-host "yes"}
```

**User Experience / Installation Behaviour:** Install for User  
**User Experience /** **Installation program visibility:** Normal  
**User Experience /** **Maximum allowed run time (minutes):** 240

### Summary

When the user runs the application, they will be shown a PowerShell window giving a real time view of the file copy status. Using the Robocopy switch **/eta** is really useful to indicate the real-time data copy progress of particularly large media files. You can investigate the **HomeDrive\_Sync\_Log.txt** file created in OneDrive\\Documents to review the copy progress and any errors.

This script worked well for this particular environment because every device was well connected on the LAN/WAN. If these were cloud devices we would have probably taken a different approach.

The aim of this short post was to show you that you have a lot of native tools at your disposal. Not every script has to be coded natively using PoSh cmdlets. I hope you found this illustration useful.