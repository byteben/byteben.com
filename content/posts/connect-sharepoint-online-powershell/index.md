---
title: "Connect to SharePoint Online using PowerShell"
date: 2018-10-16
tags: ["connect-sposervice", "powershell", "sharepoint-online", "spo"]
categories: ["microsoft", "office365"]
---

So you want to do some PowerShell stuff in SharePoint Online. You will need the "SharePoint Online Global Administrator" permission to perform the connection. Before we do that, lets check if we have the SharePoint Online Management Shell already installed.

<!--more-->

1\. Launch PowerShell in Administrative mode and run:-

```
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name,Version
```

2\. If it is not listed, go ahead and download it from the PowerShell Gallery [https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell/16.0.8029.0](https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell/16.0.8029.0) or if you have PowerShell 5 or newer, install the shell by running the following command:-

```
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
```

3\. Once the SharePoint Management Shell is installed, connect to SPO by running:-

```
$Credential = Get-Credential
Connect-SPOService -Url https://<tenantid>-admin.sharepoint.com -Credential $Credential
```

More information can be found at [https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps)