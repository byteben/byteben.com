---
title: "Install Microsoft Teams PowerShell Module"
date: 2018-10-23
tags: ["connect-microsoftteams", "install-teams-module", "msteam", "posh", "powershell", "powershell-gallery", "teams"]
categories: ["microsoft", "office365"]
---

Quick post this afternoon on how to install the Microsoft Teams PowerShell Module. The latest version in the PowerShell Gallery at the time of writing this post is 0.9.5. More info on this module can be found at [https://www.powershellgallery.com/packages/MicrosoftTeams/0.9.5](https://www.powershellgallery.com/packages/MicrosoftTeams/0.9.5) <!--more-->

You should be running PowerShell Version 3 or greater to install the Teams Module. You can check your PowerShell Version by entering the following variable:-

```
$PSVersionTable.PSVersion
```

![](/images/2018/10/install_teams_module.png)

To install the Microsoft Teams Module, run:-

```
Install-Module -Name MicrosoftTeams
```

Press "Y" when prompted to Accept installing the module from an untrusted repository

![](/images/2018/10/install_teams_module_2.jpg)

Thats it! Before you can call any cmdlets, you will need to call the [Connect-MicrosoftTeams](https://docs.microsoft.com/en-us/powershell/module/teams/connect-microsoftteams) cmdlet:-

```
$Credential = Get-Credential
Connect-MicrosoftTeams -tenantid <tenant-id> -Credential $Credential

```

**\*HINT\* To find your Office 365 tenant ID in the Azure AD portal**

1. Log in to Microsoft Azure as an administrator.
2. In the Microsoft Azure portal, click **Azure Active Directory**.
3. Under **Manage**, click **Properties**. The tenant ID is shown in the **Directory ID** box.

![](/images/2018/10/install_teams_module_3.jpg)

If you are connecting with a Global Administrator, you should see a successful connection

![](/images/2018/10/install_teams_module_4.jpg)

**UPDATE 29/10/18**

Use the variable "TenantDomain" for an easier alternative to finding the Tenant ID"

```
Connect-MicrosoftTeams -tenantdomain <tenant>.onmicrosoft.com -Credential $Credential
```

Go ahead and use the cmdlet we all use first "Get-Team" :)

Other available cmdlets for this module are:-

[Add-TeamUser](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Add-TeamUser%22 "Search for Add-TeamUser") [Get-Team](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-Team%22 "Search for Get-Team") [Get-TeamChannel](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamChannel%22 "Search for Get-TeamChannel") [Get-TeamFunSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamFunSettings%22 "Search for Get-TeamFunSettings") [Get-TeamGuestSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamGuestSettings%22 "Search for Get-TeamGuestSettings") [Get-TeamMemberSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamMemberSettings%22 "Search for Get-TeamMemberSettings") [Get-TeamMessagingSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamMessagingSettings%22 "Search for Get-TeamMessagingSettings") [Get-TeamHelp](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamHelp%22 "Search for Get-TeamHelp") [Get-TeamUser](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Get-TeamUser%22 "Search for Get-TeamUser") [New-TeamChannel](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22New-TeamChannel%22 "Search for New-TeamChannel")[New-Team](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22New-Team%22 "Search for New-Team") [Remove-Team](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Remove-Team%22 "Search for Remove-Team") [Remove-TeamChannel](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Remove-TeamChannel%22 "Search for Remove-TeamChannel") [Remove-TeamUser](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Remove-TeamUser%22 "Search for Remove-TeamUser") [Set-TeamFunSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamFunSettings%22 "Search for Set-TeamFunSettings") [Set-TeamGuestSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamGuestSettings%22 "Search for Set-TeamGuestSettings") [Set-TeamMemberSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamMemberSettings%22 "Search for Set-TeamMemberSettings") [Set-TeamMessagingSettings](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamMessagingSettings%22 "Search for Set-TeamMessagingSettings") [Set-Team](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-Team%22 "Search for Set-Team") [Set-TeamChannel](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamChannel%22 "Search for Set-TeamChannel") [Set-TeamPicture](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Set-TeamPicture%22 "Search for Set-TeamPicture") [Connect-MicrosoftTeams](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Connect-MicrosoftTeams%22 "Search for Connect-MicrosoftTeams") [Disconnect-MicrosoftTeams](https://www.powershellgallery.com/packages?q=Cmdlets%3A%22Disconnect-MicrosoftTeams%22 "Search for Disconnect-MicrosoftTeams")