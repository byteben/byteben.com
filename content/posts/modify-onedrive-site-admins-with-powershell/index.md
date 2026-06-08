---
title: "Modify OneDrive Site Admins with PowerShell"
date: 2018-10-16
categories:
  - "Microsoft"
  - "Office 365"
tags: ["get-sposite", "get-spouser", "onedrive", "set-spouser", "sharepoint-personal-site", "siteadmin", "spo"]
---

In our previous post [**Office 365 – Access a Users OneDrive Folder**](https://byteben.com/bb/office-365-access-users-onedrive-folder/) we looked at giving an Admin access to a users OneDrive files. In this post we will focus on adding and removing Site Admins, on a users Personal SharePoint Site (OneDrive), using PowerShell.

<!--more-->

First we will need to connect to SharePoint Online (see an earlier post on how to do this [**Connect to SharePoint Online using PowerShell**](https://byteben.com/bb/connect-sharepoint-online-powershell/)

We will use the [Get-SPOSite](https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/get-sposite) cmdlet first to see the existing Primary Site Admin on the users Personal SharePoint site:-

```
Get-SPOSite 'https://<tenantid>-my.sharepoint.com/personal/first_last_domain_com' | Select Owner
```

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_1.jpg)

Waste of time hey? We can assume the Primary Site Owner will always be the OneDrive user :)

Another way of doing this is with the User Principal Name:-

```
Get-SPOSite -IncludePersonalSite $True -Limit All -Filter "Url -like 'my.sharepoint.com/personal/'" | Where-Object {$_.Owner -eq 'first.last@domain.com'}
```

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_2.jpg)

We have to use a different command to find any Secondary Site Admins using the [Get-SPOUser](https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/get-spouser) cmdlet:-

```
Get-SPOUser -site https://<tenant-id>-my.sharepoint.com/personal/first_last_domain_com | Select LoginName,IsSiteAdmin | Where-Object {$_.IsSiteAdmin -eq 'True'}
```

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_4.jpg)

Let us look at adding a Secondary Site Admin to the user's Personal SharePoint Folder where "LoginName" is the user you are adding:-

```
Set-SPOUser -Site https://<tenant-id>-my.sharepoint.com/personal/first_last_domain_com -LoginName first.last@domain.com -IsSiteCollectionAdmin $True -ErrorAction SilentlyContinue
```

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_5.jpg)

So let us see what our Secondary Site Admin list looks like now

![](/images/2018/10/Access-a-Users-OneDrive-Folder_7.jpg)

Great, we have two Secondary Site Admins. If required, how do we delete one of them. We run the same script as Set-SPOUser above but replace "IsSiteCollectionAdmin $True" with "IsSiteCollectionAdmin $false":-

```
Set-SPOUser -Site https://<tenant-id>-my.sharepoint.com/personal/first_last_domain_com -LoginName first.last@domain.com -IsSiteCollectionAdmin $false -ErrorAction SilentlyContinue
```

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_8.jpg)

and when we use the Get-SPOUser command again, the Secondary Site Admin has been removed

![](/images/2018/10/Modify-OneDrive-Site-Admins-with-PowerShell_4.jpg)

This is quite a handy way to give yourself temporary access to a users OneDrive folder by adding yourself as a Secondary Site Admin