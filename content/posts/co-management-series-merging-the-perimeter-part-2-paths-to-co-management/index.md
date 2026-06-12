---
title: "Co-management Series \"Merging the Perimeter\" - Part 2: Paths to Co-management"
date: 2019-08-30
tags: ["co-management", "configmgr", "paths", "sccm", "workloads"]
categories: ["configmgr-memcm-sccm", "intune", "microsoft"]
---

In the previous post for this series, we looked at "What is Co-management?". In this part of the series we will look at the different paths to co-management.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- **Part 2: Paths to Co-management**
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

### Paths to Co-management

What scenarios qualify us to consider Co-management in our environment? We mentioned this briefly in the introduction to the series. Let me ask the questions below:-

1. Do you have existing SCCM clients and want to move some workloads to Intune?
2. Do you have existing SCCM clients and want to just enroll the devices into Intune to get MDM features like device wipe, factory reset and remote control\*?
3. Do you have existing Internet based clients, managed by Intune and joined to Azure AD, and you want to install the SCCM client to have some workloads managed by SCCM?
4. Do you want to install the SCCM client during an Autopilot enrollment and manage some workloads with SCCM?

If you have answered yes to either of the above, then you qualify!

\*Remote Control requires Teamviewer

<figure>

[![](/images/2019/08/co-management_7-1024x687.jpg)](https://www.pexels.com/photo/photo-of-pathway-surrounded-by-fir-trees-1578750/)

<figcaption>

There are different Pathways to reach a Co-managed state

</figcaption>

</figure>

We can summarize the posed questions into two main categories or "Pathways":-

1 . **Existing Configuration Manager clients**: You have Windows 10 devices that are already Configuration Manager clients. You set up hybrid Azure AD, and enroll them into Intune.

2 . **Internet Enrolled Clients**: You have new Windows 10 devices that join Azure AD and automatically enroll to Intune. You then install the Configuration Manager client to reach a co-management state.

One of the more common scenarios we encounter is pathway 1 "Existing Configuration Manager Clients" and this is where this series will focus.

### Series Focus: **Existing Configuration Manager clients**

We can further split our chosen pathway for this series down into a further two categories

<figure>

[![](/images/2019/08/co-management_9-1024x587.png)](blob:https://byteben.com/b0fb5ddc-db8f-402f-bf00-9aa5e3d8094d)

<figcaption>

All paths to co-management result in both the Intune and SCCM agents being installed on the client

</figcaption>

</figure>

**Existing SCCM managed devices that auto-enroll into Intune**

This pathway, sees us taking an existing SCCM Client, performing a Hybrid Azure AD Join and then enrolling it into Intune

**Modern Provisioning bootstrap SCCM agent**

This pathway would be used during Autopilot. We take a device, perform a Hybrid Azure AD Join or Azure AD Join during the Autopilot process. We then enroll the client into Intune and install the SCCM client

### Joining things up

The different pathways to co-management require our device identity to be registered in Azure AD (we talk more about this in Part 3 and [4](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/) of this series). We can achieve this by either performing a Hybrid Azure AD Join for existing SCCM clients or an Azure AD Join for existing internet based clients. If the device identity is not present, we cannot enroll our devices into Intune to leverage Co-management. Remember, for Pathway 1, Co-management requires us to install the Intune agent and this occurs during the Intune enrollment process.

### Summary

This was the shortest part in the series and I just wanted to make some distinctions between the different pathways to Co-management. We will talk more about the requirements for these pathways in [Part 3](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/) of the series "Prerequisites"