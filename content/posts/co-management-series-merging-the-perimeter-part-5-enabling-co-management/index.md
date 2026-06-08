---
title: "Co-management Series “Merging the Perimeter” – Part 5: Enabling Co-management"
date: 2019-09-07
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Intune"
  - "Microsoft"
  - "Windows 10"
---

In this part of the series we will look at enabling Co-management. We will split this part of the series into 6 sections for easy navigation.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- **Part 5: Enabling Co-management:-**

1. **[Create Device collections for workloads and Intune Auto Enrollment](#1)**
2. **[Deep Diving Workloads](#2)**
3. **[Configure Co-management](#3)**
4. **[Review Client Logs](#4)**
5. **[Review Client Intune Status](#5)**
6. **[Review Client Co-management capabilities](#6)**

- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### 1\. **Create Device collections for workloads and Intune Auto Enrollment [](https://byteben.com/bb/sccm-site-server-in-place-upgrade-from-windows-server-2012-r2-to-windows-server-2019/#NavMenu)[⏏](#0)**[](#0)

Before 1906, we only had a single collection we could use to pilot all co-management workloads. Now we can assign a different collection to each of the 7 workloads making it easier to transition workloads to Intune for different groups of devices.

In our lab for this series, we created the following Collections:-

- Co-mgmt - Client Apps
- Co-mgmt - Compliance Policies
- Co-mgmt - Device Configuration
- Co-mgmt - Endpoint Protection
- Co-mgmt - Office Click-to-Run apps
- Co-mgmt - Resource Access Policies
- Co-mgmt - Windows Update Policies

and we also created a collection for Intune Auto Enrollment

- Co-mgmt - Intune Auto Enrollment

<figure>

[![](/images/2019/09/co-management_17-1024x407.png)](/images/2019/09/co-management_17.png)

<figcaption>

Device Collections for each Co-management Workload in 1906  

</figcaption>

</figure>

### 2\. Deep Diving Workloads **[⏏](#0)**[](#0)

Collections are a great way to move workloads to Intune. When we move a workload to Intune or Pilot Intune, we are essentially saying ONLY the Intune agent can handle that workload and the SCCM client/agent should not apply any setting that falls into scope for that workload. We have to caveat this behaviour for some workloads..lets do that now.

One thing to be wary of is the relationship between the following Workloads

- Device Configuration
- Resource Access Policies
- Endpoint Protection

<figure>

[![](/images/2019/09/co-management_18.jpg)](blob:https://byteben.com/5af86774-2163-4a3e-b6d1-6e9c9e0193b7)

<figcaption>

Workload Relationships

</figcaption>

</figure>

As you can see in the graphic above, Endpoint Protection and Resource Access Policies are subordinate to Device Configuration. This means if we move the Device Configuration workload to Intune or Pilot Intune, both Endpoint Protection and Resource Access Policy workloads will also move. You also cannot move Resource Access Policy or Endpoint Protection workloads back to SCCM while Device Configuration is set to Pilot Intune or Intune.

<figure>

[![](/images/2019/09/co-management_19.jpg)](https://www.pexels.com/photo/chair-court-gavel-hammer-995266/)

<figcaption>

Stop - Hammer Time!

</figcaption>

</figure>

You **CAN** move Resource Access Policy and Endpoint Protection workloads to Intune or Pilot Intune without moving Device Configuration.

<figure>

[![](/images/2019/09/co-management_20.png)](blob:https://byteben.com/ba46b4d5-8a48-48b8-a38d-d32f3e1ecd01)

<figcaption>

Moving Resource Access Policies and Endpoint Protection Workloads independent of Device Configuration

</figcaption>

</figure>

We can add another caveat to the Device Configuration Workload. You can still allow Configuration Baselines to be evaluated when the workload for the client is set to Pilot Intune or Intune, you just need to select the following box on the baseline:-

<figure>

[![](/images/2019/09/co-management_21.jpg)](blob:https://byteben.com/05ecc3de-cac0-41a3-8fec-e13969129be6)

<figcaption>

Always apply this baseline even for co-managed clients

</figcaption>

</figure>

Another workload which bucks the normal behaviour is Client apps. When we move the workload to Intune or Pilot Intune we are enabling apps to be deployed from Intune **AS WELL AS** SCCM. We will demonstrate this later on in [Part 6](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/) of the series "Switching Workloads to Intune"

**How are Workload assignments changing the configuration on the Clients?**

When we assign a workload to a client we are effectively applying a Configuration Baseline. The Baseline is deployed to the collections and ultimately clients that we assign to each of the workloads in Co-management settings.

<figure>

[![](/images/2019/09/co-management_21-1024x576.png)](blob:https://byteben.com/722b293a-8e3f-4119-bef4-58bd689d27bd)

<figcaption>

Configuration Baselines deployed to each of the Workload Collections

</figcaption>

</figure>

### 3\. **Configure Co-management** **[⏏](#0)**

Now that we have created the collections for our workloads and Intune Auto Enrollment Pilot group, we are ready to enable co-management.

<figure>

https://www.youtube.com/watch?v=LtCYz1J3y\_4

<figcaption>

Enabling Co-management Lab

</figcaption>

</figure>

### 4\. **Review Client Logs** **[⏏](#0)**[](#0)

Once Co-management has been enabled our clients need to be enrolled into Intune before workloads will move. Let's review the client logs to understand what is going on during Intune enrollment.

https://www.youtube.com/watch?v=aSwQfl1ci9Q

<figure>

[![](/images/2019/09/co-management_22.png)](blob:https://byteben.com/4b89e103-0b89-4cb3-b309-f3f5b1db8603)

<figcaption>

Successful Intune MDM Enrollment using the Azure AD Device Credentials

</figcaption>

</figure>

### 5\. **Review Client Intune Status** **[⏏](#0)**[](#0)

When we look at the log file above we can see the device enrolled with the device credentials and not the user credentials. This is an improvement introduced in SCCM 1906. Previously, MDM enrollment could not happen until an Intune licenced user logged on to the client. Now, the device enrolls to Intune without waiting for a licenced user. The first licenced user who logs into the device becomes the owner.

In the following lab we will review how you can determine a successful Intune MDM enrollment.

<figure>

https://www.youtube.com/watch?v=ZlBfC8GSfk4

<figcaption>

Intune MDM Enrollment Client Status

</figcaption>

</figure>

### 6\. **Review Client Co-management capabilities** **[⏏](#0)**[](#0)

As we enroll our clients into Intune we can get an idea from the CoManagementHandler.log what the Co-management capabilities are. We will go into a lot more detail about capabilities in the next part of the series but for now lets review the logs to get a better understanding of "Capabilities".

Earlier on we talked about "Workloads". Each time a client is added to one of our Workload collections and performs a subsequent policy refresh it receives new capabilities. In our lab above you may have noticed in the CoManagamentHandler.log that the capabilities value was set to 3. What is this number?

Our Windows 10 lab clients were in both the "CoMgmt - Intune Auto Enrollment" and "CoMgmt - Compliancy Policies" collections. Lets have another look at that

<figure>

[![](/images/2019/09/co-management_24-1024x407.jpg)](/images/2019/09/co-management_24-1024x407.jpg)

<figcaption>

Lab Client Collection Membership

</figcaption>

</figure>

When Co-management is enabled for a device, the device gets a capabilities value of 1. The capabilities value of 2 is given to the client for the Compliance Policies workload. 2 + 1 = 3

<figure>

[![](/images/2019/09/co-management_25.jpg)](blob:https://byteben.com/1bbbba72-bfea-4144-b396-5eb2967ccd0b)

<figcaption>

Co-management Capability values merged to 3

</figcaption>

</figure>

We go into a lot more detail on capabilities in [Part 7](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/) of this series.  
  
I have also published a separate post outside of this series on Co-management capabilities here:-

https://byteben.com/bb/sccm-1906-co-management-capabilities-matrix/

### Summary

In this part of the series we discussed Enabling Co-management. We also looked in more detail at the Workloads concept. More reading can be found for enabling co-management here:-

[https://docs.microsoft.com/en-us/sccm/comanage/how-to-enable](https://docs.microsoft.com/en-us/sccm/comanage/how-to-enable)

In the next Part of our Series we will demonstrate how to switch individual workloads across to Intune