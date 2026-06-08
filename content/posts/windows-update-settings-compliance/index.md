---
title: "Windows Update Settings Compliance"
date: 2022-08-08
---

In this post I will show you how to use Proactive Remediations and Log Analytics, together, to ensure Windows Update Settings are Optimal and Compliant on your devices. This post comes on the back of a session both [Aria Carley](https://techcommunity.microsoft.com/t5/user/viewprofilepage/user-id/158630) and I presented at #MMSMOA this year - Fun times!

<!--more-->

<figure>

[![](/images/2022/05/image-7-1024x485.png)](/images/2022/05/image-7.png)

<figcaption>

MMSMOA 2022

</figcaption>

</figure>

## Background

I was working with a customer recently and we were having a conversation around the optimal settings to ensure a great experience when delivering Windows Update policy using Intune. It had occurred to me to mention that I had previously seen environments where legacy policy was either "breaking" updates completely or adversely affecting the update experience for the end users.

At around the same time, Aria had published a fantastic article on the Microsoft Tech community blog **Why you shouldn’t set these 25 Windows policies**

[https://techcommunity.microsoft.com/t5/windows-it-pro-blog/why-you-shouldn-t-set-these-25-windows-policies/ba-p/3066178](https://techcommunity.microsoft.com/t5/windows-it-pro-blog/why-you-shouldn-t-set-these-25-windows-policies/ba-p/3066178)

In the post Aria explains which settings will give your users a "sub optimal" experience with Windows Updates and which settings have absolutely no effect.

<figure>

[![](/images/2022/05/image-6-1024x370.png)](/images/2022/05/image-6.png)

<figcaption>

Excerpt from the Aria's post

</figcaption>

</figure>

Previous experience taught me that there are also some legacy settings that will "absolutely break" the Windows Update experience for users - especially when the Windows Update workload is moved from ConfigMgr to Intune.

## What are these bad settings you speak of?

**NoAutoUpdate** was a policy some ConfigMgr admins used to set back in the day. It was a way that some used to control duplicate Windows Update balloon notifications from appearing on Windows 7 devices. Largely, it is not used today but I still find this registry key tattooed on some of my customers devices.

<figure>

[![](/images/2022/05/image-8.png)](/images/2022/05/image-8.png)

<figcaption>

NoAutoUpdate

</figcaption>

</figure>

**DisableDualScan** is another policy setting that can adversely affect the delivery of Windows Updates when you move workloads to Intune in a Co-management scenario. ConfigMgr will set DisableDualScan to **1** when the Windows Update workload is with ConfigMgr/WSUS. When you move the workload to Intune, ConfigMgr will change this value to **0** to allow the client to Dual Scan (against both the Windows Update Service and WSUS). If we run **rsop.msc** on the client we can see this policy enforced by Local Group Policy (ConfigMgr)

<figure>

[![](/images/2022/05/image-9-1024x538.png)](/images/2022/05/image-9.png)

<figcaption>

DisableDualScan Enabled

</figcaption>

</figure>

Once we move the workload to Intune, DisableDualScan is disabled

<figure>

[![](/images/2022/05/image-10-1024x537.png)](/images/2022/05/image-10.png)

<figcaption>

DisableDualScan Disabled

</figcaption>

</figure>

If you Disable Dual Scan using GPP/Script/CI then this value can be overwritten and cause issues when the workload is move to Intune. When the workload is with ConfigMgr, this setting is OK. When I move the workload to Intune, I expect the settings to stop being enforced (and not be overwritten).

Another "breaking" policy setting, if present when the Windows Update workload is moved to Intune, is **DoNotConnectToWindowsUpdateInternetLocations** (Thanks @mauriced)

<figure>

[![](/images/2022/05/image-11-1024x607.png)](/images/2022/05/image-11.png)

<figcaption>

DoNotConnectToWindowsUpdateInternetLocations

</figcaption>

</figure>

You guessed it, this setting will stop the client reaching out to the internet for Windows Updates. Not a setting you want to see enabled if you move your Windows Update workload to Intune/WUfB.

As well as the 3 settings above, Aria also calls out the **Legacy** policy settings in her post that will either cause a non-optimal Windows Update experience or actually have no affect on Windows Updates at all - once the Windows Update workload is move to the Windows Update Service.

I have listed the registry keys below that will either cause issues, a sub-optimal experience or have no impact at all.

### **Service Breaking Settings**

| Registry Key | Registry Setting |
| --- | --- |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DisableDualScan |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DoNotConnectToWindowsUpdateInternetLocations |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | NoAutoUpdate |

### **Service Affecting Settings**

| Registry Key | Registry Setting |
| --- | --- |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | AutoInstallMinorUpdates |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | AutoRestartDeadlinePeriodInDays |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | AutoRestartNotificationSchedule |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | AutoRestartRequiredNotificationDismissal |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | BranchReadinessLevel |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | EnableFeaturedSoftware |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | EngagedRestartDeadline |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | EngagedRestartSnoozeSchedule |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | EngagedRestartTransitionSchedule |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | IncludeRecommendedUpdates |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | NoAUAsDefaultShutdownOption |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | NoAUShutdownOption |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | NoAutoRebootWithLoggedOnUsers |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | PauseFeatureUpdatesStartTime |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | PauseQualityUpdatesStartTime |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RebootRelaunchTimeout |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RebootRelaunchTimeoutEnabled |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RebootWarningTimeout |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RebootWarningTimeoutEnabled |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RescheduleWaitTime |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU | RescheduleWaitTimeEnabled |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | ScheduleImminentRestartWarning |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | ScheduleRestartWarning |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetAutoRestartDeadline |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetAutoRestartNotificationConfig |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetAutoRestartNotificationDisable |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetAutoRestartRequiredNotificationDismissal |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetEDURestart |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetEngagedRestartTransitionSchedule |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | SetRestartWarningSchd |

### **Service Settings that have no effect**

| Registry Key | Registry Setting |
| --- | --- |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DeferFeatureUpdates |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DeferFeatureUpdatesPeriodInDays |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DeferQualityUpdates |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | DeferQualityUpdatesPeriodInDays |
| Software\\Policies\\Microsoft\\Windows\\WindowsUpdate | ElevateNonAdmins |

## What Intune Reports show me if I have these bad settings in my environment?

I like your sense of humour. But seriously, there is no reporting in Intune, today, that will show us if these settings are causing adverse effects on your devices and ultimately affecting your overall Windows Update Compliance level. I personally would like to see some of this stuff come up with telemetry to Update Compliance in Log Analytics but I am not expecting to see that anytime soon.

While we wait for unicorns and rainbows in Intune, I have built my own interim solution (with the help of previous community solutions), based on my previous experience and the advice given by Aria in the Tech Community post I listed earlier.

## The Solution

The solution comes on the back of other great community solutions from the MSEndpointMgr team. We have been collecting Custom Inventory for a while now (thanks to @jankeskanke @mauriced @sandy\_tsang @nickolaja).

[Enhance Intune Inventory data with Proactive Remediations and Log Analytics - MSEndpointMgr](https://msendpointmgr.com/2021/04/12/enhance-intune-inventory-data-with-proactive-remediations-and-log-analytics/)

Running a Proactive Remediation, to inventory client Registry/WMI information and sending the results to Log Analytics for rich reporting, is what the cool kids are doing these days. It allows us to report client state information almost instantly, without having to wait for Intune reporting to get its act together.

Whilst Intune reporting leaves something to be desired today, I know the product group are working really hard to improve this experience for all of us - so thank you for your diligent and hard work. We wait excitedly for a great reporting experience natively in Intune.

Using the same methods as we do with Custom Inventory, the solution will do the following:-

- Inventory the Windows Update Registry Settings that are known to affect the Windows Update experience
- Collect other useful device information such as:-

| Setting | Function |
| --- | --- |
| Script Version | Track which script was used to collect inventory information |
| DeviceName | Name of the Device |
| ManagedDeviceID | Managed Device ID in Intune. Can be useful if joining other Log Analytics tables |
| AzureADDeviceID | Azure AD Device ID. Can be useful if joining other Log Analytics tables |
| ComputerOSVersion | Windows OS and Build Information |
| ComputerOSBuild | OS Build Information |
| DefaultAUService | Is the default AU Service Microsoft Update or Windows Server Update Services |
| CoMgmtWorkload | Returns True if the device co-management workload includes Windows Updates |
| CoMgmtValue | Which co-management workloads are set on the client |
| WSUSServer | WSUS Server client is registered to |
| WSUSStatusServer | WSUS Status Server client is registered to |

- Create a JSON payload and send the results to Log Analytics
- Visualise the results in a Workbook for easy Compliance Reporting

With this information, we can start to understand if there are any legacy settings in our environment that are adversely affecting how we expect Windows Update to behave.

### Scripts

Grab the script(s) from the [MSEndpointMgr GitHub Reporting repo](https://github.com/MSEndpointMgr/Reporting/tree/main/Scripts). One script requires you to embed the Log Analytics workspace workspace ID and shared key into the script. The other script, which is more secure, uses a Function app in Azure to authenticate your devices. It only requires you to embed the Function app URL in the script. Only devices registered in your tenant will have permission to upload to Log Analytics using the Function app (so cool).

#### Script Option 1 (Shared Key Embedded in Script)

[Reporting/Invoke-WUInventory.ps1 at main · MSEndpointMgr/Reporting (github.com)](https://github.com/MSEndpointMgr/Reporting/blob/main/Scripts/Invoke-WUInventory.ps1)

[![](/images/2022/05/image-13.png)](/images/2022/05/image-13.png)

You need to replace **CustomerID** and **SharedKey** (Lines 27 and 30) with the correct value from your Log Analytics workspace

<figure>

[![](/images/2022/05/image-14-1024x471.png)](/images/2022/05/image-14.png)

<figcaption>

Get the Log Analytics Shared Key

</figcaption>

</figure>

**CustomerID = Workspace ID**  
**SharedKey** = **Primary Key**

#### Script Option 2 (Function App URL Embedded in Script)

[Reporting/Invoke-WUInventory\_Funky.ps1 at main · MSEndpointMgr/Reporting (github.com)](https://github.com/MSEndpointMgr/Reporting/blob/main/Scripts/Invoke-WUInventory_Funky.ps1)

<figure>

[![](/images/2022/05/image-15-1024x166.png)](/images/2022/05/image-15.png)

<figcaption>

Secure Inventory

</figcaption>

</figure>

As we pointed out earlier, using the Function app is a much better approach when sending data to Log Analytics because we don't embed any secrets in the inventory script.

If you missed it, read more here about using Azure Function app to secure sending data to Log Analytics

[Securing Intune Enhanced Inventory with Azure Function - MSEndpointMgr](https://msendpointmgr.com/2022/01/17/securing-intune-enhanced-inventory-with-azure-function/)

### Proactive Remediation

Either of the scripts above can be run as a Proactive Remediation. You should **only** set the Detection Script, there is no Remediation script required as we are simply using the detection script to send data to our Log Analytics workspace. You should also set the Proactive Remediation to run in 64 bit PowerShell.

[![](/images/2022/05/image-16.png)](/images/2022/05/image-16.png)

### Log Analytics

The first device to run the script will create a custom log in your Log Analytics workspace.

The log name can be changed in either of the scripts around line 30.

<figure>

[![](/images/2022/05/image-18.png)](/images/2022/05/image-18.png)

<figcaption>

Log Name

</figcaption>

</figure>

If you change the log name from **WUDevice\_Settings,** the workbook JSON that we use later will also need updating to reflect the new log name

All custom logs you create in Log Analytics will get a **\_CL** suffix appended

<figure>

![](/images/2022/05/image-31.png)

<figcaption>

Custom Log

</figcaption>

</figure>

As data starts to get uploaded, you will see a line entry each time the client sends data. We summarise multiple entries when we do reporting so we only show the latest record the client uploads. Here is an example of what the data will look like.

<figure>

[![](/images/2022/05/image-19-1024x590.png)](/images/2022/05/image-19.png)

<figcaption>

Example Data

</figcaption>

</figure>

### Workbook

We could spend all day long writing KUSTO queries in Log Analytics - but there is a better way and someone else has done all the hard work for you. Grab the workbook source (copy as raw) from the link below so we can start to visualise the data from the logs.

[Reporting/Windows Update Device Settings.workbook at main · MSEndpointMgr/Reporting (github.com)](https://github.com/MSEndpointMgr/Reporting/blob/main/Workbooks/Windows%20Update%20Device%20Settings.workbook)

Create a new workbook in the same Log Analytics workspace

<figure>

[![](/images/2022/05/image-20.png)](/images/2022/05/image-20.png)

<figcaption>

New Workbook

</figcaption>

</figure>

Tap the advanced editor

<figure>

[![](/images/2022/05/image-21.png)](/images/2022/05/image-21.png)

<figcaption>

Tap Advanced Editor

</figcaption>

</figure>

Paste in the raw data from the JSON above and tap **Apply**

<figure>

[![](/images/2022/05/image-22.png)](/images/2022/05/image-22.png)

<figcaption>

Paste Workbook JSON

</figcaption>

</figure>

Tap the **Save** icon

<figure>

[![](/images/2022/05/image-23.png)](/images/2022/05/image-23.png)

<figcaption>

Save

</figcaption>

</figure>

Specify a workbook name and validate the workspace settings

<figure>

[![](/images/2022/05/image-24.png)](/images/2022/05/image-24.png)

<figcaption>

Validate Workbook Name and Settings

</figcaption>

</figure>

Tap **Save** and **Done Editing**

Your workbook should now start to look something like this. First we list some Windows Build Information. Remember, this is collected directly from the client and doesn't rely on Update Compliance or Windows Telemetry data (which can be slow to update).

<figure>

[![](/images/2022/05/image-25.png)](/images/2022/05/image-25.png)

<figcaption>

Dashboard Example 1

</figcaption>

</figure>

Next we show the "Service Breaking Settings". If your devices show up here and the Windows Update workload is set to Intune/WUfB - they most probably are not getting Windows Updates!

<figure>

[![](/images/2022/05/image-26-1024x633.png)](/images/2022/05/image-26.png)

<figcaption>

Service Breaking Settings

</figcaption>

</figure>

Next we show you and settings on the devices that may affect the Windows Update experience i.e. it may be sub-optimal

<figure>

[![](/images/2022/05/image-27-1024x403.png)](/images/2022/05/image-27.png)

<figcaption>

Service Affecting Settings

</figcaption>

</figure>

Finally, on the dashboard, we show you settings that are in place that have no affect on the Windows Update experience - so why are you setting them?

<figure>

[![](/images/2022/05/image-28-1024x212.png)](/images/2022/05/image-28.png)

<figcaption>

Settings with no Impact

</figcaption>

</figure>

The other tabs will also show you some useful information

<figure>

[![](/images/2022/05/image-29-1024x559.png)](/images/2022/05/image-29.png)

<figcaption>

WSUS Settings and Scan Source

</figcaption>

</figure>

<figure>

[![](/images/2022/05/image-30.png)](/images/2022/05/image-30.png)

<figcaption>

Co-management Information

</figcaption>

</figure>

## Summary

Hopefully this post has helped you understand how awesome inventory scripts and Log Analytics are. We can manipulate the inventory scripts to collect a whole host of information from our devices.

This is Version 1 of the workbook. We have big plans on collecting more Windows Update related settings from devices and hopefully Version 2 of the workbook will **TELL** you which settings (GPO/GPP/CSP) that you need to change to ensure your devices are optimally configured to received updates using WUfB.

Big thanks to Aria for always being willing to share her brain and passion with the community and to my friends at MSEndpointMgr for being inspiring!

DM me on Twitter if you want further clarification around the topics listed in this post.