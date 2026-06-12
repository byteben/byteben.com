---
title: "Co-management Series “Merging the Perimeter” – Part 8: Monitoring Co-management"
date: 2019-09-25
tags: ["co-management", "comanagementhandler", "comgmt", "configmgr", "logs", "monitoring", "msintune", "sccm"]
categories: ["configmgr-memcm-sccm", "intune", "microsoft", "windows-10"]
---

In the final part of the series we will look at the different ways of monitoring Co-management.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- [Part 7: Co-management Capabilities](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-7-co-management-capabilities/)
- **Part 8: Monitoring Co-management**
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### Monitoring Co-Management

In the final part of our co-management series we will look at the different ways to monitor co-management in our environment.

<figure>

[![](/images/2019/09/co-management_35-1024x605.jpg)](https://www.pexels.com/photo/person-using-black-blood-pressure-monitor-905874/)

<figcaption>

Monitoring Co-Management

</figcaption>

</figure>

### Logs Glorious Logs

Co-management has it's own log file which we have used throughout this series - **CoManagementHandler.log** located on each client (Default Client Logs Directory is C:\\Windows\\CCM\\Logs) - Use it! Everything from capability changes to MDM enrollment is recorded in this log file.

As we move workloads to Intune, we can still check the relevant SCCM logs too. For example, the Co-ManagementHandler.log could show a workload shift to Intune, for Compliance Policies, evaluated by the capabilities number change.

<figure>

![](http://byteben.com/bb/images/2019/09/co-management_25.jpg)

<figcaption>

Capabilities change to 3 indicates a workload shift to Intune for Compliance Policies

</figcaption>

</figure>

We can still check the SCCM Compliance log **ComplRelayAgent.log** for any impact from a co-management workload move to Intune.

The SCCM client will evaluate if any compliance policies deployed from SCCM should be applied. In the log below we can see that there is a capabilities evaluation. Any compliance policies deployed from SCCM to the client should not be evaluated because the workload has moved to Intune.

<figure>

[![](http://byteben.com/bb/images/2019/09/co-management_34-1024x548.jpg)](/images/2019/09/co-management_34.jpg)

<figcaption>

  
ComplRelayAgent.log indicates a capabilities value of 67 (Compliance Policies and Client Apps) means any Compliance Policies deployed by SCCM should not be evaluated

</figcaption>

</figure>

Thanks Peter Vanderwoude for the heads up on this info over at [https://www.petervanderwoude.nl/post/co-management-and-the-configmgr-client/](https://www.petervanderwoude.nl/post/co-management-and-the-configmgr-client/)

### SQL Tables

There is a handy view in the CCM database you can play with if you want to report which clients have different workloads moved to Intune

The SQL View is **v\_ClientCoManagementState**

<figure>

[![](/images/2019/09/co-management_35-1024x616.png)](blob:https://byteben.com/7e46f481-de0e-43ce-8046-2f467bcc6d95)

<figcaption>

**v\_ClientCoManagementState**

</figcaption>

</figure>

### Client Registry

You can view the Co-management settings and perform Configuration Item evaluations against the client registry.

**HKLM\\Software\\Microsoft\\CCM\\CoManagementFlags**

<figure>

[![](/images/2019/09/co-management_36.jpg)](blob:https://byteben.com/037e3813-61dc-456f-ae98-fc207c6ceec9)

<figcaption>

Client Registry indicating Co-management capabilities

</figcaption>

</figure>

### SCCM Co-management Dashboard

Accessible from the Monitoring Work-space, the Co-management dashboard is a great place to head to get an overall picture of your co-management health

<figure>

[![](/images/2019/09/co-management_37-1024x568.png)](blob:https://byteben.com/abec1874-9a8f-493a-bd86-58a71ba8bcdb)

<figcaption>

Co-management dashboard in the Monitoring Work-space

</figcaption>

</figure>

## Intune

Head over to the Devices blade in Intune to view related information for Co-managed devices.  
[https://devicemanagement.microsoft.com/#blade/Microsoft\_Intune\_Devices/DeviceEntryBlade/mDMDevices](https://devicemanagement.microsoft.com/#blade/Microsoft_Intune_Devices/DeviceEntryBlade/mDMDevices)

<figure>

[![](/images/2019/09/co-management_38-1024x536.jpg)](blob:https://byteben.com/71a6e12c-d994-4d65-b9f2-550050475e7f)

<figcaption>

MDM enrolled devices blade in Intune

</figcaption>

</figure>

## WMI

Get-CimInstance -ClassName CCM\_System -Namespace 'root\\ccm\\invagt' | Select ComgmtWorkloads

![](/images/2020/03/image-1.png)

### Summary

This concludes the final part of the series for Co-management. I hope you have found the series useful. Please comment or reach out if I can unpack any of these posts in more detail for you to help you better understand the awesome power of SCCM and Intune Co-management.