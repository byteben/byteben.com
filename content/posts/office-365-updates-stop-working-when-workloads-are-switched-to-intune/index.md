---
title: "Office 365 updates stop working when workloads are switched to Intune"
date: 2020-08-03
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Office 365"
  - "Scripts"
  - "Windows 10"
tags: ["c2r", "intune", "office365", "proactive-remediation"]
---

The following post will highlight a scenario where Office 365 Updates stop working for clients that have the Office C2R Apps workload moved to Intune. This was a "Think and write it down blog" so my apologies for the structure (or lack of it) - I hope you can still follow my train of thought.

<!--more-->

### Background

In the following environment, the workload had been moved to Intune for specific clients only. We call this a "Pilot" workload.

![](/images/2020/08/image.png)

Previously, O365 had been deployed by Configuration Manager and updates were also being managed by Configuration Manager. When an Office 365 deployment was created using the Configuration Manger wizard, a Global condition was set on the client **Intune O365 ProPlus management = False**  
This means that once a client has been added to the **Office C2R Apps** co-management pilot group, they can no longer install office from the Software Centre.

![](/images/2020/08/image-1.png)

### Problem

We assumed, by moving the workload to Intune, that as well as Office installations being blocked from Configuration manager our clients would automatically start getting their updates from the CDN - but we soon noticed that some clients were not receiving Office updates. We started by checking the co-management capabilities were correct. We checked the clients **CoManagementHandler.log** and could see they were receiving the correct co-management capabilities.

![](/images/2020/08/image-13.png)

Capability 211 indicates the following workloads have been moved to Intune:-

- Client Apps
- **Office Click-to-Run Apps**
- Windows Updates Policies
- Compliance Policies

Read more about co-management capabilities here [https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)

So at this point, we still assumed that the clients \*should\* be getting their updates from the CDN because we had moved the Office C2R Apps workload to Intune.  
Queue **CMPivot** - To get an idea of the client configurations to look for anomalies, we used **CMPivot**. We started with a simple query:-

```
Office365ProPlusConfigurations
```

![](/images/2020/08/image-3-1024x540.png)

For the clients that were not receiving updates, we notice the **GPOOfficeMgmtCOM** was set to **1** \*

```
Office365ProPlusConfigurations | where (GPOOfficeMgmtCOM == '1')
```

![](/images/2020/08/image-4-1024x562.png)

If you have not already used CMPivot, go and read the docs here [https://docs.microsoft.com/en-us/mem/configmgr/core/servers/manage/cmpivot](https://docs.microsoft.com/en-us/mem/configmgr/core/servers/manage/cmpivot)

### How?

Q: How were our clients getting the **GPOOfficeMgmtCOM** set to **1** ?  
A: Couple of Reasons

When we installed Office 365 initially, we specified in our Config XML that we wanted Configuration Manager to handle the Office updates. We did this by setting the **OfficeMgmtCOM** value to **True**.

![](/images/2020/08/image-5.png)

This will set the following registry key on the client **HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Microsoft\\Office\\ClickToRun\\Configuration OfficeMgmtCOM = True**

![](/images/2020/08/image-12.png)

**Note**:

This registry key can also be set (and overridden) by Group Policy - the GPO value will win over any value set in the Config XML during your Office installation \*  
  
GPO Setting: Computer Configuration\\Administrative Templates\\Microsoft Office 2016 (Machine)\\Updates - **Office 365 Client Management** / **Management of Microsoft 365 Apps for enterprise**

- Enabled = 1 (Decimal)
- Disabled = 0 (Decimal)

The policy registry key on the client had also been set **HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Policies\\Microsoft\\office\\16.0\\common\\officeupdate OfficeMgmtCOM = 1**

![](/images/2020/08/image-6.png)

The Configuration Manager Client Setting **Enable management of the Office 365 Client Agent**, if set to **Yes**, will also set the same registry key to 1 and this also overrides any value specified in the config XML during Office installation.

![](/images/2020/08/image-16.png)

\* If you repair Microsoft Office 365, the registry key will revert back to 1 if you installed Office 365 with **OfficeMgmtCOM = True** specified in the Config XML (But it will get over-written if your GPO or Client Settings are disabling that option remember)

> The Microsoft Office Click-to-Run Service is responsible for registering and unregistering Office COM application during service startup. Change domain policy or Configuration Manager client settings require explicit **Disable** selection for Office COM to be successfully deregistered and restore default configuration. Toggling _Management of Microsoft 365 Apps for enterprise_ via Group Policy or **Client Settings** for Configuration Manager from **Enabled** to **Not Configured** is not sufficient.
> 
> [https://docs.microsoft.com/en-us/deployoffice/manage-microsoft-365-apps-updates-configuration-manager](https://docs.microsoft.com/en-us/deployoffice/manage-microsoft-365-apps-updates-configuration-manager)

### How do we address this?

In our case, the registry key set during Office 365 installation was preventing Office from getting its updates from the CDN. What compounded the issue was a legacy GPO had tattooed the GPO registry key too that enables the OfficeMgmtCOM. The Office Click 2 Run Service must disable the OfficeMgmtCOM to allow updates to come from the CDN - this is accomplished via the GPO setting (or re-installation of Office with the OfficeMgmtCOM set to False). We have options:-

1. Push a new Office 365 Config XML to the client where **OfficeMgmtCOM** is **False**
2. Set the GPO to Disable ****Office 365 Client Management** / **Management of Microsoft 365 Apps for enterprise****
3. Change/Remove the value from Intune
4. Assign Office 365 Apps to Windows 10 Devices from Intune
5. Change the Configuration Manager Client Setting **Enable management of the Office 365 Client Agent**, for the C2R Co-management workload, to **No**

Whichever of the above solutions we choose, it is imperative that your GPO or Client Settings are not going to undo your efforts.

We are moving workloads to Intune so want the solution to come from Intune.

We are going to use Option 3 (to show off a new preview feature in Intune). In our environment the clients also have the **Client Apps** workload moved to Intune so we can now leverage the new **Endpoint Analytics Proactive Remediation** feature (Preview). We will set the same key that GPO would set to disable **OfficeMgmtCOM** as this overrides the setting laid down during installation for **OfficeMgmtCOM** from the config XML

**When the GPO or Client Setting is used to disable OfficeMgmtCOM, the COM+ Application is un-registered**

![](/images/2020/08/image-14.png)

### Endpoint Analytics Proactive Remediation

Think of it like your traditional CI in Configuration Manager. You can run scripts on a schedule, from Intune, to remediate clients. Its pretty cool stuff! This feature leverages the Intune Management Extension Agent and requires your **Client Apps** workload to be moved to Intune too. Read more here [https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations](https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations)

We will use one script to remove the registry setting that is preventing our clients from getting Office updates from the Content Delivery Network (CDN) and another for our detection method. The scripts are below:-

**Remediation Script**  
[https://github.com/byteben/Windows-10/blob/master/DisableOfficeMgmtCOM.ps1](https://github.com/byteben/Windows-10/blob/master/DisableOfficeMgmtCOM.ps1)

```
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate"
$Name = "OfficeMgmtCOM"
$Type = "DWORD"
$Value = 0

Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value 
```

**Detection Script**  
[https://github.com/byteben/Windows-10/blob/master/Detect\_OfficeMgmtCOM.ps1](https://github.com/byteben/Windows-10/blob/master/Detect_OfficeMgmtCOM.ps1)

```
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate"
$Name = "OfficeMgmtCOM"
$Type = "DWORD"
$Value = 0

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    If ($Registry -eq $Value) {
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

**TIP** It's worth pointing out that once this registry setting is changed, the update will not be picked up until the **Microsoft Office Click-to-Run Service** is restarted. You could modify your remediation script to restart the Service after it changes the registry value :) (There is also a predefined Proactive Remediation Script in your Tenant that you can use to restart the Office C2R Service if it has stopped - very useful).

1 . Visit **[https://endpoint.microsoft.com](https://endpoint.microsoft.com) > Reports > Endpoint Analytics (Preview)**

2 . Under Reports, click **Proactive remediations**

3 . Click **Create Script Package**

4 . Enter a Name **Disable OfficeMgmtCOM**

5 . Click **Next**

6 . In the **Detection Script** box, copy and paste in your PowerShell code for the detection logic and in the **Remediation Script** box copy and paste in your code for the remediation script

![](/images/2020/08/image-7.png)

7 . Click **Next**

8 . **Assign** the **Custom Script** to your Co-Management Pilot Group for Office Click-to-Run Apps (Remember: Proactive Remediations will only work for co-management clients that also have the workload for **Client Apps** moved to Intune) . You can adjust the **Schedule** if you want the remediation check to occur more or less than Once Daily.

![](/images/2020/08/image-8.png)

9 . Click **Next** and then **Create**

![](/images/2020/08/image-9-1024x317.png)

10 . Wait for (or force) a Policy Sync on your clients

11 . Monitor the **IntuneManagementExtension.log** in C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs

![](/images/2020/08/image-10-1024x308.png)

![](/images/2020/08/image-11-1024x210.png)

### Summary

Moving the co-management workload for Office Click-2-Run Apps did not guarantee that updates automatically came from the CDN for our clients. Some of the clients had the OfficeMgmtCOM registry value set to 0 and others had it set to 1.

**Update 05/08/2020**

Ensuring that your devices, which are scoped for the Co-Management **Click 2 Run Apps** workload, do not have any GPO or Client Settings that enable Office MgmtCOM is very important - this is where I suspect others will run into issues. In the blog I used Proactive Remediation to set the registry value to 0 to unregister the Office MgmtCOM app. I have also now created a higher priority Client Setting in ConfigMgr that has **Enable management of the Office 365 Client Agent** set to No for the clients scoped for the Co-Management **Click 2 Run Apps** workload - call it a belt and braces approach.

Thanks to Jake [@TripleSixSeven](https://twitter.com/TripleSixSeven) for being a listening ear and sounding board #CommunityWin

Manage Office 365 Updates with Configuration Manager  
[https://docs.microsoft.com/en-us/deployoffice/manage-microsoft-365-apps-updates-configuration-manager](https://docs.microsoft.com/en-us/deployoffice/manage-microsoft-365-apps-updates-configuration-manager)  
  
Assign Office 365 Apps to Windows 10 Devices from Intune  
[https://docs.microsoft.com/en-us/mem/intune/apps/apps-add-office365](https://docs.microsoft.com/en-us/mem/intune/apps/apps-add-office365)  
  
Co-Management of Office Click-to-Run apps Workload  
[https://techcommunity.microsoft.com/t5/core](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/co-management-of-office-click-to-run-apps-workload/ba-p/871090)[\-](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/co-management-of-office-click-to-run-apps-workload/ba-p/871090)[infrastructure-and-security/co-management-of-office-click-to-run-apps-workload/ba-p/871090](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/co-management-of-office-click-to-run-apps-workload/ba-p/871090)