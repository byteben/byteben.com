---
title: "AppSense Start Menu /Taskbar Icon and Toolbar Personalization for Windows 7 - To Hive or not to Hive?"
date: 2013-02-04
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "registry-hiving", "windows-7-taskbar-icons", "xenapp-taskbar-icons"]
categories: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations"]
---

Ok, so we want to capture users Taskbar/Start Menu and Toolbar Information on Windows 7? There are 2 ways to do this, either use the in built "Desktop Settings" option to capture the information automatically or hive the items and reg keys out manually with policy. We are going to personalize these settings using reg hive and folder copy actions. At the current time of writing this blog there is no conditional flag (AppSense feature team please can we have one) that can be set on session data or desktop settings. You either have it on or off for your personalization group and we need the conditional flexibility for our environment.

<!--more-->

[![AppSense Start Menu Taskbar Icon and Toolbar Personalization for Windows 7](/images/2013/02/AppSense-Start-Menu-Taskbar-Icon-and-Toolbar-Personalization-for-Windows-7.jpg)](http://byteben.com/bb/images/2013/02/AppSense-Start-Menu-Taskbar-Icon-and-Toolbar-Personalization-for-Windows-7.jpg)

Many would argue that you should split your personalization groups up if you don't want to personalize some stuff in the DB for some users. But in this scenario we found it difficult to apply this principal (i'm not going to go into the political detail). I can tell you that we didn't want to capture any taskbar icons for users who log into our Xenapp Farm - desktop settings allow you to split XP and Win7 file/reg items but not server2008r2 (another feature request please) so anything that gets personalized from their Citrix session gets applied to their Windows 7 session...blahhh.

We found hiving reg keys and folders in at logon and out at logoff the best approach for our environment. We would simply add a condition for Server 2008R2 to not hive or copy folders at logoff - perfect! Other conditions are added that are specific to our environment that I won't go into detail on just now.

Any how, below are all of the reg keys and appdata locations you will need to create hive actions for if you also decide not to use the  "desktop settings" option in AppSense Environment Manager.

**Toolbar Registry Keys / AppData Folders**

```
HKEY_CURRENT_USER\Control Panel\TimeDate
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\EnableAutoTray
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MenuOrder
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop
```

```
CSIDL_APPDATA\Microsoft\Internet Explorer\Quick Launch
```

**Taskbar  Registry Keys / AppData Folders**

```
HKEY_CURRENT_USER\Control Panel\TimeDate
HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Toolbar\ShellBrowser\ITBar7Layout
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisablePreviewDesktop
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarGlomLevel
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Taskbar\Glomming
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSizeMove HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\EnableAutotray
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2\Settings
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband
```

```
CSIDL_APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned

```

**Start Menu  Registry Keys / AppData Folders**

```
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_AdminToolsRoot
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_AutoCascade
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_EnableDragDrop
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_JumpListItems
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_LargeMFUIcons
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_MinMFU
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_NotifyNewApps
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_PowerButtonAction
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_SearchFiles
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_SearchPrograms
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowControlPanel
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowDownloads
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowHelp
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowHomegroup
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowMyComputer
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowMyDocs
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowMyGames
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowMyMusic
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowMyPics
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowNetConn
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowNetPlaces
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowPrinters
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowRecentDocs
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowRecordedTV
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowRun
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowSetProgramAccessAndDefaults
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowUser
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowVideos
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_SortByName
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackDocs
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackProgs
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\StartMenuAdminTools
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\StartMenuFavorites
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ApplicationDestinations\MaxEntries
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2
```

```
CSIDL_APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned
```

## AppSense Start Menu /Taskbar Icon and Toolbar Personalization for Windows 7

### AppSense Start Menu /Taskbar Icon and Toolbar Personalization for Windows 7