---
title: "Co-management Series “Merging the Perimeter” – Part 6: Switching Workloads to Intune"
date: 2019-09-14
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
---

In this part of the series we will look at moving some of the workloads from SCCM to Intune. We will focus on the "Compliance Policies" and "Client Apps" workloads.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- **Part 6: Switching Workloads to Intune**
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### Switching Workloads

<figure>

[![](/images/2019/09/co-management_26-1024x683.jpg)](https://www.pexels.com/photo/eight-electrical-metric-meters-942316/)

<figcaption>

The series has been building up to this point - switching the workloads from SCCM to Intune!

</figcaption>

</figure>

This is the moment we have all been waiting for. We have fulfilled the prerequisites, enabled Co-management and enrolled our devices into Intune. Now comes the fun part, moving our workloads to Intune.

#### Pause for a thought...

> Careful consideration and planning should be done before you move ANY workload to Intune. You may have previously scoped some Configuration Policies or Client Apps to "All Windows 10 Devices"? Believe me, I have seen this happen - as soon as the workloads were switched there was a desperate scramble to move the workload sliders back and re-mediate some unintended Policy and App installs.
> 
> Always carefully plan the Workload move to Intune

One Workload which always strikes me as a quick win to switch is "Compliance Policies". Once the workload is switched, our clients can now be evaluated for **Compliance** based Conditional Access. Our Windows 10 device can be denied access to corporate data they are not compliant!

You can read more here about Compliance based Conditional Access:-

[https://docs.microsoft.com/en-us/intune/device-compliance-get-started](https://docs.microsoft.com/en-us/intune/device-compliance-get-started)

The other workload we will focus on in this part of the series is "Client Apps". As of 1906 this workload is still in preview but I can tell it works really well in the lab. We can push apps to devices or make apps available from both SCCM (via the Software Centre) and Intune (via the Company Portal).

#### Moving Workloads

To move the workloads to Intune, we simply add our Windows 10 clients to the Workload Device Collections we created earlier. As soon as the device is added to a Workload collection, a co-management policy is made available to the client by way of a deployment. The client simply needs to perform a Machine Policy refresh to get the new co-management capabilities.

As soon as the client processes the policy and receives a capabilities change the Intune agent is instructed to perform a policy sync. We will observe this in the labs below as we examine the log files.

### 1\. Switching the Compliance Policy Workload

Before we switch this workload to Intune, we can see that the device compliance is managed by SCCM

<figure>

[![](/images/2019/09/co-management_27.png)](/images/2019/09/co-management_27.png)

<figcaption>

"See ConfigMgr" means the Compliance workload has not been set to Inune for the device

</figcaption>

</figure>

In the following lab we will walk you through switching the workload to Intune and monitoring the client logs.

<figure>

https://www.youtube.com/watch?v=N5ICkGOgVAw

<figcaption>

Moving Compliance Workload to Intune

</figcaption>

</figure>

In this lab we looked at the "capabilities value" and saw it change from "1" to "3". We will go into more depth on Co-management capabilities in the [Part 7](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/) of this series.

When we moved the workloads we observed the 2 lab clients being marked as "Compliant" - this was because we had previously created a Compliance Policy in Intune that were in scope for our clients.

### 2\. Switching the Client Apps Workload

Strictly speaking, we are not "switching" this workload to Intune in its entirety. We are saying that Applications can be deployed or made available from both SCCM and Intune. Before co-management, if the Windows 10 client had the SCCM agent installed and the Company Portal installed, the Company Portal would always redirect the user to the Software Centre to look for available apps.

<figure>

[![](/images/2019/09/co-management_28.jpg)](blob:https://byteben.com/c27a906d-9c2d-48c0-a51c-a2cf00929580)

<figcaption>

Before switching the Client Apps Workload, users have to use the Software Centre to look for available applications

</figcaption>

</figure>

In the following lab we will walk you through switching the workload to Intune and monitoring the client logs.

<figure>

https://youtu.be/WUu4nFKOdfs

<figcaption>

Moving Client Apps workload to Intune

</figcaption>

</figure>

In this lab we observed the behavior when we switch the Client Apps workload to Intune. We saw the "Capabilities" value increase from 3 to 67. We will talk more about capabilities in [Part 7](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/) of this series. We also had a sneak preview of a 1906 feature - installing apps on devices advertised through the fast channel. More info on that feature can be found here:-

[https://docs.microsoft.com/en-us/sccm/apps/deploy-use/install-app-for-device](https://docs.microsoft.com/en-us/sccm/apps/deploy-use/install-app-for-device)

### Summary

In this part of the series we showed two examples of moving workloads to Intune for "Compliance Policies" and "Client Apps". More information on moving Workloads can be found here:-

[https://docs.microsoft.com/en-us/sccm/comanage/how-to-switch-workloads](https://docs.microsoft.com/en-us/sccm/comanage/how-to-switch-workloads)

In the next part of the series, we will look in more detail at Co-management capabilities.