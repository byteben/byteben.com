---
title: "Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune"
date: 2020-08-26
tags: ["co-management", "configmgr", "edge", "endpoint-analytics", "intune", "memcm", "msedge", "msintune", "proactive-remediations", "updates", "windows-updates"]
categories: ["configmgr-memcm-sccm", "intune", "microsoft", "windows-10"]
---

Many organisation are moving workloads to Intune from Configuration manger using Co-management. One of the more popular workloads to move is Windows Updates. After you move this workload to Intune, you may observe that your clients stop receiving updates for Microsoft Edge.

<!--more-->

If you deployed Microsoft Edge using ConfigMgr 1910 automatic updates for Edge were disabled. Since 2002, that setting can now be toggled during the deployment wizard to enable automatic updates. Read more here [https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/deploy-edge#configuration-manager-version-2002-and-later](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/deploy-edge#configuration-manager-version-2002-and-later)

### Background

The reason updates were disabled when deploying Microsoft Edge from ConfigMgr is the assumption that we would also want to manage the updates from ConfigMgr too. When you create the Microsoft Edge Application by following the deployment wizard, you will notice that a PowerShell script is used to install the application

![](/images/2020/08/image-17.png)

The PowerShell script will disable Microsoft Edge Automatic Updates by setting the following registry value on the client HKLM:\\SOFTWARE\\Policies\\Microsoft\\EdgeUpdate\\Update<_ChannelID_\> **0**

![](/images/2020/08/image-18.png)

### What happens when we move the Windows Update workload to Intune?

When we move the Windows Update workload to Intune, we are effectively setting a co-management capability that tells the ConfigMgr agent not to get its updates from ConfigMgr. I am going to make an assumption that you were also creating Automatic Deployment Rules to keep your Microsoft Edge instances patched right? Remember, Edge is deployed with Automatic Updates **Disabled**\* when you use ConfigMgr to create the Microsoft Edge Application - so of course you were updating Edge... right?

\*When we use ConfigMgr 2002 to create the Microsoft Edge application, we now have an option to **Enable** automatic updates

![](/images/2020/08/image-20.png)

### What options do we have now?

I guess you are reading this because the horse has already bolted. You have already migrated your Windows Update workload to Intune for some of your devices but have found out that Microsoft Edge wasn't updating.

![](/images/2020/08/image-25.png)

There is not an option in the Windows 10 Update Ring policy in Intune to **Enable** automatic updates in Microsoft Edge

![](/images/2020/08/image-21.png)

You can create a Configuration Profile to Enable automatic updates in Microsoft Edge - but you may not have the co-management workload for **Device Configuration** moved to Intune yet - in which case this policy would not apply to your co-managed devices.

![](/images/2020/08/image-22.png)

### Endpoint Analytics Proactive Remediations

I have been using Proactive Remediations a lot recently. It is a feature still in Preview and it allows you to monitor and remediate clients if certain conditions are found. Proactive Remediation requires the **Client Apps** workload to be moved to Intune or Pilot for your devices. It is safe to assume that the **Client App** co-management workload is often the first workload moved to Intune because you are not actually "moving" workloads per se. You are enabling the clients to receive apps from ConfigMgr and Intune simultaneously.

In effect, the registry value that disables updates was "tattooed" to the registry during Edge installation. We can change the value from 0 to 1 to re-enable automatic updates - it is as simple as that. Once enabled, Microsoft Edge will periodically check-in to see if there any updates and apply them.

The challenge we have is Update Channels. When we deploy Edge, we specify which Build or Update Channel we are going to deploy. There are 4 to choose from and they each have their respective GUID:-

- (Stable): {56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}
- (Beta): {2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}
- (Canary): {65C35B14-6C1D-4122-AC46-7148CC9D6497}
- (Dev): {0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}

When we create our remediation script, we are going to need to make a consideration that the following registry key could be any of the above Update Channels. **HKLM:\\SOFTWARE\\Policies\\Microsoft\\EdgeUpdate\\Update<_ChannelID_\>**

Read more on Edge Update Channels here [https://docs.microsoft.com/en-us/deployedge/microsoft-edge-update-policies#windows-information-and-settings-2](https://docs.microsoft.com/en-us/deployedge/microsoft-edge-update-policies#windows-information-and-settings-2)

**Detection Script**  
[https://github.com/byteben/Windows-10/blob/master/Detect\_EnableEdgeAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/Detect_EnableEdgeAutomaticUpdates.ps1)

```
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
$Channel = @(
    "Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}"
    "Update{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}"
    "Update{65C35B14-6C1D-4122-AC46-7148CC9D6497}"
    "Update{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}"
)
$Type = "DWORD"
$Value = 1

ForEach ($Name in $Channel) {
    If (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue) {
        $RegName = $Name
    }
}

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $RegName -ErrorAction Stop | Select-Object -ExpandProperty $RegName
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

**Remediation Script**  
[https://github.com/byteben/Windows-10/blob/master/EnableEdgeAutomaticUpdates.ps1](https://github.com/byteben/Windows-10/blob/master/EnableEdgeAutomaticUpdates.ps1)

```
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
$Channel = @(
    "Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}"
    "Update{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}"
    "Update{65C35B14-6C1D-4122-AC46-7148CC9D6497}"
    "Update{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}"
)
$Type = "DWORD"
$Value = 1

ForEach ($Name in $Channel) {
    Try {
        Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop -ErrorVariable NotExist | Out-Null
        Write-Output """$Path\$Name"" Exists"
        Write-Output "Attempting to set the Registry Value to $Value"
    }
    Catch {
        Write-Warning "Registry value for $Name not found"
    }  

    Try {
        If (!($NotExist)) {
            Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -ErrorAction Stop | Out-Null
            Write-Output "Updated Registry Value Successfully"
        }
    }
    Catch {
        Write-Warning "Could not update the registry value for $Name"
    }
}  
```

1 . Visit **[https://endpoint.microsoft.com](https://endpoint.microsoft.com/) > Reports > Endpoint Analytics (Preview)**

2 . Under Reports, click **Proactive remediations**

3 . Click **Create Script Package**

4 . Enter a Name **Enable Microsoft Edge Automatic Updates**

5 . Click **Next**

6 . In the **Detection Script** box, copy and paste in your PowerShell code for the detection logic and in the **Remediation Script** box copy and paste in your code for the remediation script

![](/images/2020/08/image-23.png)

7 . Click **Next**

8 . **Assign** the **Custom Script** to your Co-Management Pilot Group for Windows Updates or another applicable Group (Remember: Proactive Remediations will only work for co-management clients that also have the workload for **Client Apps** moved to Intune) . You can adjust the **Schedule** if you want the remediation check to occur more or less than Once Daily.

9 . Click **Next** and then **Create**

![](/images/2020/08/image-24-1024x192.png)

10 . Wait for (or force) a Policy Sync on your clients

11 . Monitor the **IntuneManagementExtension.log** in C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs

![](/images/2020/08/image-10-1024x308.png)

![](/images/2020/08/image-11-1024x210.png)

![](/images/2020/08/image-27.png)

![](/images/2020/08/image-26.png)

![](/images/2020/08/image-28-1024x627.png)

### Summary

As we observed previously with Office Updates [https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/) careful planning must be taken when moving workloads to Intune. The real challenge is understanding where your legacy policies were deployed from and drawing up a plan on how you will manage components with Intune.  
  
As with the OfficeComMgmt post above, there are many ways to remediate registry values - I personally am a big fan of Endpoint Analytics Proactive Remediations.