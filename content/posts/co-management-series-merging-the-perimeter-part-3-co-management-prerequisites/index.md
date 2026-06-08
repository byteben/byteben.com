---
title: "Co-management Series \"Merging the Perimeter\" – Part 3: Co-management Prerequisites"
date: 2019-08-31
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
tags: ["aad", "co-management", "configmgr", "intune"]
---

In this part of the series we will look at the prerequisites to get our clients into a Co-managed state.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- **Part 3: Co-management Prerequisites**
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

There are 6 areas for consideration when looking at setting up co-management, lets take a look at each area in a bit more detail. Remember, we are looking at the prerequisites for Pathway 1 - Getting existing SCCM clients co-managed.

1. Licencing
2. Configuration Manager
3. Azure Active Directory (AAD)
4. Intune
5. Windows
6. Permissions

<figure>

[![](/images/2019/08/co-management_13.jpg)](https://www.pexels.com/photo/person-holding-blue-ballpoint-pen-writing-in-notebook-210661/)

<figcaption>

What do we need before we enable co-management?

</figcaption>

</figure>

### 1\. Licencing

So we need some licences. I am going to assume that you are already have an active subscription or Enterprise Agreement for Windows and SCCM. So if we are pure traditionalists and only now dipping our toe into the Intune world, what else do we need to licence?

As we mention in [Part 2](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/) of this series, we need to perform an AAD Join before we can enroll our client into Intune. For existing SCCM Domain Joined clients this is by a process called Hybrid Azure Active Directory Join, or Hybrid AAD. This gets our device identity into AAD and gives us a device authentication token (more in Part 4 and 5 on this). To Hybrid AAD join our device, we are going to need an Azure Active Directory Plan 1 (AAD P1) licence.

After we have hybrid joined our devices to AAD, the next step is to enroll them into Intune. Co-management does this and you do not need to setup separate GPO's for Intune enrollment (more on this in [Part 5 of this series "Enabling Co-management"](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)). To enroll into Intune you will need an Intune licence.

So we need an AAD P1 and an Intune licence for Co-management (as well as our existing Windows licence). The Intune licence also covers the SCCM client. It is important when purchasing subscription licences to consider any overlap in use rights - why pay twice right? More on Intune licencing can be found here:-

[https://docs.microsoft.com/en-us/intune/licenses](https://docs.microsoft.com/en-us/intune/licenses)

You should also be smart about your licencing. Normally when requiring more than 2 features it is worth looking for a SKU that covers both those features. For example you get an AAD P1 and Intune licence when you purchase any EM+S subscription. e.g. EM+S E3 includes AAD P1, Intune and Azure Information Protection (AIP). Taking that further, an M365 E3 subscription will cover the aforementioned plus Windows Enterprise and Office 365 Pro Plus SKUs.

**Important** When we enable Co-management in [Part 5](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/) of this series, the account used during the co-management setup wizard must have an assigned Intune licence or the wizard will fail.

You can read more on Co-management licencing requirements here:-

[https://docs.microsoft.com/en-us/sccm/comanage/overview#licensing](https://docs.microsoft.com/en-us/sccm/comanage/overview#licensing)

### 2\. Configuration Manager

Yes, you will need SCCM! Co-management was introduced in Current Branch 1710. We saw some great additions in 1806 and then even more in 1906. The product team have made upgrading Current Branch easier than peeling bananas so we are going to assume you have already upgraded to 1906. The stipulation in the docs is that you must be running a supported version of SCCM.

Outside of scope for this series but if you are considering Pathway 2 (Co-management for existing internet based devices) you will need a Cloud Management Gateway (CMG) - once you install the SCCM client on internet based devices they are going to need the CMG to broker communication to your Primary Site.

Lets have a brief look at the Co-management features released since 1710:-

**1806**

- Sync MDM policy from Microsoft Intune for a co-managed device
- New Workloads (Device configuration, Office 365, Client Apps)
- Support for multiple hierarchies to one Intune tenant
- Auto enrollment for clients, in certain circumstances, is not immediate. SCCM randomizes enrollment based on the number of clients enabled for Intune enrollment. Enrollment can occur over several days for 10,000+ clients

**1906**

- Improvements to co-management auto-enrollment (AAD Device Tokens)
- Co-management support for Azure US Government Cloud customers
- Multiple pilot groups for co-management workloads

<figure>

[![](/images/2019/08/co-management_10.png)](blob:https://byteben.com/e3e9b336-7bc1-4b2e-b22b-62c43d8bb55f)

<figcaption>

Workloads no longer restricted to a single device collection

</figcaption>

</figure>

You can read more on Co-management SCCM requirements here:-

[https://docs.microsoft.com/en-us/sccm/comanage/overview#configuration-manager](https://docs.microsoft.com/en-us/sccm/comanage/overview#configuration-manager)

### 3\. Azure Active Directory (Azure AD)

Windows 10 devices must be joined to Azure AD. They can be either of the following types:

- **Hybrid Azure AD-joined**

For existing SCCM clients where the device is joined to your on-premises Active Directory and registered with your Azure Active Directory.

- **Azure AD-joined only**

For internet based devices. This type is sometimes referred to as "cloud domain-joined"

If you have a qualifying M365, O365, EMS, ADP 1/2 or Intune licence you qualify and can register for Azure AD. More info here:-

[https://docs.microsoft.com/en-us/windows/client-management/mdm/register-your-free-azure-active-directory-subscription](https://docs.microsoft.com/en-us/windows/client-management/mdm/register-your-free-azure-active-directory-subscription)

### 4\. Intune

As we already covered in the Licence prerequisites, we need an Intune licence to light-up Intune on our tenant.

**MDM Authority**

The MDM authority MUST be set to Intune\*

In [Intune in the Azure portal](https://aka.ms/intuneportal), select the orange banner to open the **Mobile Device Management Authority** setting. The orange banner is only displayed if you haven't yet set the MDM authority.

Under **Mobile Device Management Authority**, choose your MDM authority from the following options:

<figure>

[![](/images/2019/08/co-management_11.png)](blob:https://byteben.com/571440d0-64b0-4cb0-b579-8061820835d7)

<figcaption>

Ensure the MDM Authority is set to Intune

</figcaption>

</figure>

\*SCCM/Intune Hybrid is a deprecated feature and support ends 1st September 2019 

**MDM User Scope**

One of the things we can easily overlook is ensuring our users are "in scope" to enroll their device into Intune. In SCCM 1906 the devices can enrol into Intune using the Device Authentication Token (this speeds up the enrollment process - before 1906 the device would not enroll unless/until an Intune licensed user logged in). As soon as an Intune licenced user logs into a device that has enrolled using the AAD Device Token they are set as the owner of that device.

<figure>

[![](/images/2019/08/co-management_12.png)](blob:https://byteben.com/ce305a21-b0b0-460d-9161-82d345ee61ff)

<figcaption>

Ensure your users are "In Scope" to complete the enrollment of the device into Intune

</figcaption>

</figure>

More information on setting up Intune can be found here:-

[https://docs.microsoft.com/en-us/intune/free-trial-sign-up](https://docs.microsoft.com/en-us/intune/free-trial-sign-up)

### 5\. Windows

Pretty straightforward this requirement - Co-management only works for Windows 10 devices that are 1709 or later

### 6\. Permissions

To enable co-management you are going to need the following permissions:-

| **Action** | **Role needed** |
| --- | --- |
| Setup a cloud management gateway in Configuration Manager | Azure **Subscription Manager** |
| Create Azure AD apps from Configuration Manager | Azure AD **Global Administrator** |
| Import Azure apps in Configuration Manager | Configuration Manager **Full Administrator** |
| Enable co-management in Configuration Manager | Both an Azure AD user and Configuration Manager **Full Administrator** with **All** scope rights. |

### Summary

In this part of the series we looked at the prerequisites to enable co-management. More information can be found here:-

[https://docs.microsoft.com/en-us/sccm/comanage/overview#prerequisites](https://docs.microsoft.com/en-us/sccm/comanage/overview#prerequisites)

In Part 4 we will look at setting up AAD Connect in order to Hybrid AD-join our existing SCCM clients in readiness for Intune enrollment.