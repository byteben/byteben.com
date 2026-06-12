---
title: "Co-management Series “Merging the Perimeter” – Part 7: Co-management Capabilities"
date: 2019-09-16
tags: ["1906", "capabilities", "co-management", "comgmt", "current-branch", "sccm", "windows-10"]
categories: ["configmgr-memcm-sccm", "intune", "microsoft"]
---

In this part of the series we will look at Co-management capabilities and discuss what they are, how they work and what the numerical representation indicates.

<!--more-->

- [Part 1: What is Co-management?](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-1-what-is-co-management/)
- [Part 2: Paths to Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-2-paths-to-co-management/)
- [Part 3: Co-management Prerequisites](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-3-co-management-prerequisites/)
- [Part 4: Configuring Hybrid Azure AD](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-4-configuring-hybrid-azure-ad/)
- [Part 5: Enabling Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-5-enabling-co-management/)
- [Part 6: Switching Workloads to Intune](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/)
- **Part 7: Co-management Capabilities**
- [Part 8: Monitoring Co-management](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-8-monitoring-co-management/)
- **Troubleshooting**  
    [Microsoft Edge stops receiving updates after the Windows Update workload is moved to Intune](https://byteben.com/bb/microsoft-edge-stops-receiving-updates-after-the-windows-update-workload-is-moved-to-intune/)  
    [Using MEMCM to fix legacy GPO settings that prevent co-managed clients getting updates from Intune](https://byteben.com/bb/using-memcm-to-fix-legacy-gpo-settings-that-prevent-co-managed-clients-getting-updates-from-intune/)  
    [Office 365 updates stop working when workloads are switched to Intune](https://byteben.com/bb/office-365-updates-stop-working-when-workloads-are-switched-to-intune/)

### What are Capabilities?

<figure>

[![](/images/2019/09/co-management_30-1024x683.jpg)](https://www.pexels.com/photo/addition-black-and-white-black-and-white-chalk-374918/)

<figcaption>

What are Capabilities?

</figcaption>

</figure>

A "capability" is a numerical value associated with a co-management workload. You can see the capability value in the:-

- Client registry (**HKLM\\Software\\Microsoft\\CCM\\CoManagementFlags**)
- Client WMI
- Client CoManagementHandler.log
- SQL Database (SQL View **v\_ClientCoManagementState**)
- Client Control Panel Applet

<figure>

[![](/images/2019/09/co-management_31-1024x616.png)](blob:https://byteben.com/1fa2254d-a285-40df-b2a8-8b246f7701b2)

<figcaption>

Capabilities (MDM Workloads) in the SQL View **v\_ClientCoManagementState**

</figcaption>

</figure>

<figure>

[![](/images/2019/09/co-management_32-1.png)](/images/2019/09/co-management_32-1.png)

<figcaption>

Capabilities (CoManagementFlags) in the Client Registry **HKLM\\Software\\Microsoft\\CCM\\CoManagementFlags**

</figcaption>

</figure>

<figure>

[![](http://byteben.com/bb/images/2019/08/co-management_capabilities_3.jpg)](/images/2019/08/co-management_capabilities_3.jpg)

<figcaption>

Capabilities in the Control Panel Applet and CoManagementHandler.log

</figcaption>

</figure>

The capabilities for each Co-management workload can be found in the table below:-

| **Capability** | **Workload** |
| --- | --- |
| 1 | All Workloads with SCCM |
| 2 | Compliance Policies |
| 4 | Resource access Policies |
| 8 | Device Configuration |
| 16 | Windows Updates Policies |
| 32 | Endpoint Protection |
| 64 | Client Apps |
| 128 | Office Click-to-Run Apps |

### How Capabilities Work

As we add clients to our workload collections or move the co-management workloads fully to Intune, the capability value on the client is merged and re-calculated.

For example, as we observed during the labs in [Part 6](https://byteben.com/bb/co-management-series-merging-the-perimeter-part-6-switching-workloads-to-intune/), moving client workloads for Compliance Polices and Client Apps will give the client a new co-management capability of 67. But how do we get to this number? 67

**Co-Management Configured (1) + Compliance Policies (2) + Client Apps (64) = 67**  
We have to add 1 to any merged workload (Co-management Configured)

When the client receives new capabilities a "merge" is performed on the workload flags to get the new capabilities value. The SCCM Client and Intune Agent are now aware of what workloads they can/can't apply and an immediate Intune MDM Sync is performed to apply any applicable policies from Intune.

<figure>

[![](/images/2019/09/co-management_33.jpg)](blob:https://byteben.com/78f1a2a1-6c16-408a-903a-6dcaad8db85d)

<figcaption>

Capabilities Merged and Intune MDM Sync Triggered

</figcaption>

</figure>

### What are the numerical representations?

As we start to merge capabilities, we end up with quite a large number of possible workload combinations. The possible values are 1 (Co-management Configured) to 255 (All workloads migrated to Intune). All possible merged capabilities, for SCCM 1906, can be found in this handy table below:-

| **Capabilities** | **Workload** |
| --- | --- |
| 1 | Co-management Configured |
| 3 | Compliance Policies |
| 5 | Resource access Policies |
| 7 | Resource access Policies |
|  | Compliance Policies |
| 9 | Device Configuration |
| 11 | Device Configuration |
|  | Compliance Policies |
| 13 | Device Configuration |
|  | Resource access Policies |
| 15 | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
| 17 | Windows Updates Policies |
| 19 | Windows Updates Policies |
|  | Compliance Policies |
| 21 | Windows Updates Policies |
|  | Resource access Policies |
| 23 | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 25 | Device Configuration |
|  | Windows Updates Policies |
| 27 | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 29 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 31 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 33 | Endpoint Protection |
| 35 | Compliance Policies |
|  | Endpoint Protection |
| 37 | Resource access Policies |
|  | Endpoint Protection |
| 39 | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 41 | Device Configuration |
|  | Endpoint Protection |
| 43 | Device Configuration |
|  | Compliance Policies |
|  | Endpoint Protection |
| 45 | Device Configuration |
|  | Resource access Policies |
|  | Endpoint Protection |
| 47 | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 49 | Windows Updates Policies |
|  | Endpoint Protection |
| 51 | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 53 | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 55 | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 57 | Device Configuration |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 59 | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 61 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 63 | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 65 | Client Apps |
| 67 | Client Apps |
|  | Compliance Policies |
| 69 | Client Apps |
|  | Resource access Policies |
| 71 | Client Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 73 | Client Apps |
|  | Device Configuration |
| 75 | Client Apps |
|  | Device Configuration |
|  | Compliance Policies |
| 77 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
| 79 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
| 81 | Client Apps |
|  | Windows Updates Policies |
| 83 | Client Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 85 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 87 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 89 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
| 91 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 93 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 95 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 97 | Client Apps |
|  | Endpoint Protection |
| 99 | Client Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 101 | Client Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 103 | Client Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 105 | Client Apps |
|  | Device Configuration |
|  | Endpoint Protection |
| 107 | Client Apps |
|  | Device Configuration |
|  | Compliance Policies |
|  | Endpoint Protection |
| 109 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Endpoint Protection |
| 111 | Client Apps |
|  | Device Configuration |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 113 | Client Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 115 | Client Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 117 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 119 | Client Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 121 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 123 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 125 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 127 | Client Apps |
|  | Device Configuration |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 129 | Office Click-to-Run Apps |
| 131 | Office Click-to-Run Apps |
|  | Compliance Policies |
| 133 | Office Click-to-Run Apps |
|  | Resource access Policies |
| 135 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 137 | Device Configuration |
|  | Office Click-to-Run Apps |
| 139 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 141 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 143 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 145 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 147 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 149 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 151 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 153 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 155 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 157 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 159 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 161 | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 163 | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 165 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 167 | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 169 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 171 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 173 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 175 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 177 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 179 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 181 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 183 | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 185 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 187 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 189 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 191 | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 193 | Client Apps |
|  | Office Click-to-Run Apps |
| 195 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 197 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 199 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 201 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
| 203 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
| 205 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
| 207 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
| 209 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 211 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 213 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 215 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 217 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
| 219 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
| 221 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
| 223 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
| 225 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 227 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 229 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 231 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 233 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Endpoint Protection |
| 235 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Compliance Policies |
|  | Endpoint Protection |
| 237 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Endpoint Protection |
| 239 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 241 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 243 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 245 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 247 | Client Apps |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 249 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Endpoint Protection |
| 251 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Compliance Policies |
|  | Endpoint Protection |
| 253 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Endpoint Protection |
| 255 | Client Apps |
|  | Device Configuration |
|  | Office Click-to-Run Apps |
|  | Windows Updates Policies |
|  | Resource access Policies |
|  | Compliance Policies |
|  | Endpoint Protection |

### Summary

In this part of the series we looked at the possible co-management capability values and how the values are calculated. In the final part of our series we will discuss Monitoring Co-management