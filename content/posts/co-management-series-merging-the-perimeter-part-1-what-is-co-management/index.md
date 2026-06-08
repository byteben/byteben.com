---
title: "Co-management Series \"Merging the Perimeter\" - Part 1: What is Co-management?"
date: 2019-08-29
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
---

In the following series we will take a deep dive into Co-management. Co-management is a technology that harmonizes workloads between the the Intune and SCCM agent. It is a unique relationship that only Intune and SCCM can be part of. Other MDM vendors can only "co-exist" with SCCM - infact when the SCCM agent sees another MDM vendor managing a device, all (well nearly all) SCCM workloads are disabled, resulting in the SCCM agent performing basic inventory task - what a wasted investment.

<!--more-->

You can quickly (and easily) realize the benefits of "Cloud attaching" your existing SCCM clients by leveraging some powerful features in Intune. Flipping that concept around, you can also use SCCM to manage some workloads for your Internet based devices that are AAD Joined and enrolled into Intune.

The series will try and cover practical examples of getting your environment into a "co-managed" state. We will be running some pre-recorded labs to walk you through some configurations - a first for Byteben! It comes on the back of a session [@LeonAshtonL1983](https://twitter.com/LeonAshtonL1983) and I presented at the Microsoft Reactor in London for [WMUG](https://wmug.co.uk/) called "Just about Co-managing". We found that the more common scenario for using co-management is to start moving workloads to Intune for existing SCCM clients so that is where this series will focus. We will talk more about pathways to Co-management in Part 2 of the series.

There is an expectation that you are already familiar with SCCM and have hopefully dabbled inside the Intune portal. We will be covering the following topics, in separate posts:-

- **Part 1: What is Co-management?**
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### What is Co-Management?

Co-management is a technology that harmonizes workloads between the the Intune and SCCM agent. It is a unique relationship that only the Intune and SCCM can be part of. It was introduced in SCCM 1710 and was designed to address the issue of conflicting policies and to facilitate a managed move of workloads to Intune to maximize a M365 licence investment.

Take a common scenario:

_Sharon has a very well established environment, managed solely by SCCM. She has recently renewed her Enterprise Agreement and has replaced some of the legacy products with M365 E3. She has enrolled a pilot group of clients into Intune to investigate the new cloud capabilities on offer with the EMS SKU. Poor documentation has resulted in conflicting policies being created in Intune._

Before co-management, the SCCM client and Intune agent were working independently, unaware of what policies each were laying down. This resulted in policy conflict and was quite tiresome to troubleshoot. We were able to create a CSP to say "Intune Policies always Win" but even this wasn't ideal. We needed a clearer distinction between what policies were being delivered by either SCCM or Intune - a policy warden if you like!

<figure>

[![](/images/2019/08/co-management_3-1024x683.jpg)](https://www.pexels.com/photo/woman-standing-on-road-2599729/)

<figcaption>

Managing which Policies can be applied by which Agent

</figcaption>

</figure>

That is exactly what Co-management is designed to address. If we want SCCM to manage Configuration Items, ideally we want to tell the Intune agent not to apply them. Equally, if we want the Intune agent to manage compliance policies we would want to tell the SCCM client not to. Co-management orchestrates workload transition between the two agents in a harmonious way.

But..

One thing to make clear early on. The harmony ONLY exists between the SCCM client and Intune agent. Co-management does not address other conflicts that could occur. You could still be setting some policies with GPO or running some legacy logon scripts. This activity falls out of scope of co-management and you may still experience configuration conflicts in your environment. I would encourage you to re-evaluate what you are doing with GPO and logon scripts. As part of your strategy when looking to move workloads to Intune, consider the bigger picture. Question why you do things the way you do..just because you have always used GPO and logon scripts is that still fit for the modern world? Should you be moving these workloads to SCCM or Intune today to maximize the benefits of co-management?

### Workloads

We have talked about the harmony between the SCCM client and Intune agent. So how do we make distinctions between what SCCM should be controlling and what Intune should be in control of?

Co-management introduces the concept of workloads. Today, as of SCCM 1906, we can make a distinction between the following workloads:-

- Compliance policies
- Windows Update policies
- Resource access policies
- Endpoint Protection
- Device configuration
- Office Click-to-Run apps
- Client apps (Pre-release)

<figure>

[![](/images/2019/08/co-management_4-1024x888.jpg)](https://www.pexels.com/photo/mountains-nature-arrow-guide-66100/t&as_source=arvato)

<figcaption>

Which Workload Which Agent?

</figcaption>

</figure>

**Compliance policies**

Compliance policies define the rules and settings that a device must comply with to be considered compliant by conditional access policies. [Read More](https://docs.microsoft.com/intune/device-compliance-get-started)

**Windows Update Policies**

Windows Update for Business policies let you configure deferral policies for Windows 10 feature updates or quality updates for Windows 10 devices managed directly by Windows Update for Business. [Read More](https://docs.microsoft.com/intune/windows-update-for-business-configure)

**Resource Access Policies**

Resource access policies configure VPN, Wi-Fi, email, and certificate settings on devices. This workload is also moved to Intune when you move the Device Configuration workload. [Read More](https://docs.microsoft.com/intune/device-profiles)

**Endpoint Protection**

Endpoint Protection workload includes the Windows Defender Suite of products. This workload is also moved to Intune when you move the Device Configuration workload. [Read More](https://docs.microsoft.com/intune/endpoint-protection-windows-10)

**Device Configuration**

The Device Configuration workload includes settings that you manage for devices in your organization. Switching this workload also moves the **Resource Access** and **Endpoint Protection** workloads to Intune. After switching this workload to Intune, you can still make exceptions for particular Configuration Baselines to still be process by SCCM. [Read More](https://docs.microsoft.com/intune/device-profile-create)

<figure>

[![](/images/2019/08/co-management_6.jpg)](blob:https://byteben.com/60db8512-4ccb-43ac-b74a-c98690a29bb6)

<figcaption>

Configuration Baselines can be applied even when workloads are moved to Intune

</figcaption>

</figure>

**Office Click-to-Run Apps**

Office 365 deployment and updating is handled by Intune when this workload is moved. [Read More](https://docs.microsoft.com/intune/apps-add-office365)

**Client Apps** (Still a pre-release feature as of SCCM 1906)

This workload does not stipulate either agent has sole control over the workload. After you transition this workload, any available apps deployed from Intune are available in the Company Portal. Apps that you deploy from Configuration Manager are available in Software Center. [Read More](https://docs.microsoft.com/intune/app-management)

### Do I have to switch workloads to get any benefit from Co-management?

No! As soon as you enroll your SCCM client into Intune (more in Part 5) you immediately get the following Intune features before you move any workloads.

- Conditional access with device compliance
- Intune-based remote actions, for example: restart, remote control, or factory reset
- Centralized visibility of device health
- Link users, devices, and apps with Azure Active Directory (Azure AD)
- Modern provisioning with Windows Autopilot

#### What does the Workload flow look like?

<figure>

[![](/images/2019/08/co-management_5.jpg)](blob:https://byteben.com/3192180c-cea6-42e3-8f46-18fa8dec0fa6)

<figcaption>

Co-management Workload Flow

</figcaption>

</figure>

We can see the Windows 10 device (discussed in [Part 3](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)) has both the SCCM Client (or agent) and the Intune agent installed. We can still manage the devices from both Intune and SCCM. Co-management allows us to orchestrate workloads between the two agents. We assign workloads to devices using SCCM Collections (more in [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)).

### Summary

We should now have a good understanding of what Co-management is and the capabilities it offers. It is a feature that really does start to blur the line between on premises device management and cloud device management.

Next in the series we will look at the Paths to Co-management in [Part 2](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/).