---
title: "Co-management Series “Merging the Perimeter” – Part 4: Configuring Hybrid Azure AD"
date: 2019-09-02
categories:
  - "Azure"
  - "ConfigMgr / MEMCM / SCCM"
  - "Identity"
  - "Intune"
  - "Microsoft"
---

In this part of the series we will look at configuring Hybrid Azure AD before we can get our clients into a Co-managed state. First we will install Azure AD Connect and then we will enable the SCCM Client Setting to facilitate the Hybrid Join.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- **Part 4: Configuring Hybrid Azure AD**
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### Why do we have to Hybrid Join our SCCM Client to Azure AD?

Typically, most of us have been working with Active Directory for a millennia..well nearly. Active Directory is our primary source of authentication and has been the bedrock on which all of domain based configurations and security policies depend on.

Along comes Azure Active Directory (AAD). Isn't that just our on premises AD stretched to the could? No. Azure AD, like it's distant cousin Active Directory, plays it's own important role as a similar bedrock for cloud based applications, security and solutions like Intune and Office 365. In order for us to use our on premises Active Directory identities to authenticate against cloud based applications and solutions we need to "Sync" them to Azure Active Directory.

We "Sync" our Active Directory identities (Users, Groups and Devices) to Azure AD using a tool called "AAD Connect".

We are not going to jump too deep in this series on the relationship between Active Directory and Azure Active Directory but I felt it was important to make a distinction between the two before we move forward.

<figure>

[![](/images/2019/09/co-management_15-1024x981.jpg)](https://www.pexels.com/photo/selective-focus-photography-of-red-and-green-reptile-751687/)

<figcaption>

What is a Hybrid Joined Device?

</figcaption>

</figure>

### What is Hybrid Azure AD Join?

Once we have our identities in sync and Azure AD knows about our Domain-Joined devices, we can perform one of the prerequisites for Co-management for existing SCCM clients - Hybrid Azure AD Join.

Think of Hybrid Azure AD Join like a club membership. Before we join the club as a member, we can participate in some club activities. Members will be familiar with us and are quite friendly, we enjoy the odd light bite and refreshment with members and non members. After we "Join" the club we have a higher, trusted identity. We can now start to take part in club meetings, go to the "All you can eat BBQ" and be given the privilege of accessing different aspects of the club that non members are unable to. Syncing our identities makes Azure AD aware of our devices - for Domain-joined devices to be given access to resources they must then "Join" Azure AD.

A "Hybrid" join means the device is already joined to an on premises AD, its identity is synced to Azure AD using Azure AD Connect and then subsequently it is also "Joined" to Azure AD. Hybrid means it is not uniquely joined to either AD or Azure AD but to both.

You can read more on Hybrid AD Join here:-

[https://docs.microsoft.com/en-us/azure/active-directory/devices/concept-azure-ad-join-hybrid](https://docs.microsoft.com/en-us/azure/active-directory/devices/concept-azure-ad-join-hybrid)

### Hybrid Azure AD Requirements

- Azure AD Connect (1.1.819.0 or higher for a better wizard) to sync our identities to Azure AD

- Access to the following resources from inside your organizations network\*

[https://enterpriseregistration.windows.net](https://enterpriseregistration.windows.net)

[https://login.microsoftonline.com](https://login.microsoftonline.com)

[https://device.login.microsoftonline.com](https://device.login.microsoftonline.com)

[https://autologon.microsoftazuread-sso.com](https://autologon.microsoftazuread-sso.com)

- The following sites added to the local intranet zone (To avoid certificate prompts when devices authenticate to Azure AD)

[https://device.login.microsoftonline.com](https://device.login.microsoftonline.com)

[https://autologon.microsoftazuread-sso.com](https://autologon.microsoftazuread-sso.com)

- Enable **Allow updates to status bar via script** in the user’s local intranet zone.

\*Careful consideration should be used if you use a Proxy Server for your "Users" to access the internet. The "Device" needs to access those URLs. Often this is overlooked and gets blocked by the firewall.

### Azure AD Connect

We now need to install Azure AD Connect. There are 3 options to allow users to sign-in to Azure AD.

1. **Password Hash** **Sync** (PHS). Passwords for Users in scope are synced to Azure AD and User authentication occurs in Azure AD
2. **Pass Through Authentication** (PTA). Users who sign-in to Azure AD are actually authenticated against Active Directory
3. **Federated** (ADFS or 3rd Party). Authentication is delegated to ADFS or 3rd Party Federation Service

More information on the different methods for Sign in with AAD Connect can be found here:-

[https://docs.microsoft.com/en-us/azure/active-directory/hybrid/plan-connect-user-signin](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/plan-connect-user-signin)

In the following lab we will do the following:-

- Install Azure AD Connect on a member server
- Configure Password Hash Sync with Seamless Single Sign-On (SSSO) - This enables our Users to authenticate directly against Azure AD instead of Active Directory for access to cloud based apps like Office 365

https://www.youtube.com/watch?v=xj4yW3eXpvs&t=4s

### Enabling Hybrid Azure AD Join

Now that we are syncing the devices and users that are in scope for Co-management, we need to tell the devices to perform a Hybrid Azure AD Join. This is done through a "Client Setting".

<figure>

![](/images/2019/09/co-management_14.jpg)

<figcaption>

Client Setting for Hybrid Azure AD Join

</figcaption>

</figure>

In the following lab we will configure the Client Settings to get our device Hybrid Azure AD Joined

<figure>

https://www.youtube.com/watch?v=15tG9hg6PnQ

<figcaption>

Client Settings for Hybrid Azure AD Join

</figcaption>

</figure>

<figure>

https://www.youtube.com/watch?v=G9qtUnaTqG8

<figcaption>

Verify Device Registration

</figcaption>

</figure>

<figure>

[![](/images/2019/09/co-management_16-1024x308.png)](/images/2019/09/co-management_16.png)

<figcaption>

Our Windows 10 lab devices have successfully registered in Azure AD as "Hybrid Azure AD Joined"

</figcaption>

</figure>

### Summary

In this part of the series we discussed the requirements to get our Windows 10 devices Hybrid Joined to Azure AD. We ran through some labs to show you how to achieve this. Now our devices are registered in Azure AD we can look at "Enabling Co-management" in the next part of the series.