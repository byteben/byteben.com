---
title: "Co-management Intune MDM enrollment failure 0x80180026"
date: 2019-07-05
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
tags: ["co-management", "comanagementhandler-log", "gpo", "intune", "mdm", "sccm"]
---

I will be posting a new blog series for co-management in the coming months. This post will highlight the undesirable effect some Group Policies will have on a successful co-management Intune enrollment.

<!--more-->

Co-management will allow you to automatically enroll your SCCM clients into Intune, if they are in scope.

<figure>

[![](/images/2019/07/co-mgmt_4.jpg)](blob:https://byteben.com/0be9e7a4-e5bd-4568-8a1d-3893cb55c2c8)

<figcaption>

Automatic enrollment in Intune

</figcaption>

</figure>

Recently I was asked to look at why some clients were failing enrollment. The customer was seeing the following error in **CoManagementHandler.log**

> Failed to enroll with RegisterDeviceWithManagementUsingAADDeviceCredentials with error code 0x80180026
> 
> Error in CoManagementHandler.log

<figure>

[![](/images/2019/07/co-mgmt_1.jpg)](blob:https://byteben.com/8a550af6-9d78-4246-ba45-9f81df2e08fc)

<figcaption>

Device enrollment failure 0x80180026

</figcaption>

</figure>

If we take a look at the Microsoft Docs:-

[https://docs.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants](https://docs.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants)

> **MENROLL\_E\_DEVICE\_MANAGEMENT\_BLOCKED**  
> 0x80180026  
> Mobile Device Management (MDM) was blocked, possibly by Group Policy or the [**SetManagedExternally**](https://docs.microsoft.com/en-us/windows/desktop/api/MDMRegistration/nf-mdmregistration-setmanagedexternally) function
> 
> Source: [https://docs.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants](https://docs.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants)

Sure enough, when we checked Group Policy, the customer had the following GPO targeted to the Co-Management Pilot group

<figure>

[![](/images/2019/07/co-mgmt_2.jpg)](/images/2019/07/co-mgmt_2.jpg)

<figcaption>

Group Policy blocking MDM Enrollment

</figcaption>

</figure>

As soon as we took the Co-Management Pilot group out of scope for the above Group Policy Item, MDM enrollment was successful

<figure>

[![](/images/2019/07/co-mgmt_3.jpg)](/images/2019/07/co-mgmt_3.jpg)

<figcaption>

MDM Enrollment was successful (Co-ManagementHandler.log)

</figcaption>

</figure>

### Conclusion

Always check you don't have any conflicting GPO's when configuring Co-management. The GPO will overrule the Configuration Item that is received by your SCCM client when it is configured for co-management

#### Whats coming...

There is an improved registration process using the Azure AD Device token in SCCM Technical Preview 1906 for MDM enrollment.

To support this new enrollment behavior, clients need to be running Windows 10 version 1803 or later

[https://docs.microsoft.com/en-us/sccm/core/get-started/2019/technical-preview-1906#bkmk\_comgmt](https://docs.microsoft.com/en-us/sccm/core/get-started/2019/technical-preview-1906#bkmk_comgmt)