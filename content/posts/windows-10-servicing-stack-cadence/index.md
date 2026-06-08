---
title: "Windows 10 - Servicing Stack Cadence"
date: 2019-04-05
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
---

### What are Servicing Stack Updates?

Servicing Stack Updates (SSU's) are Critical, Security Updates. They are shipped separately to the monthly Latest Cumulative Updates (LCU's) because they modify the component that installs Windows updates. Microsoft strongly recommend that you install the latest SSU before the LCU. More information on SSU's can be found at:-

<!--more-->

[https://docs.microsoft.com/en-us/windows/deployment/update/servicing-stack-updates#why-should-servicing-stack-updates-be-installed-and-kept-up-to-date](https://docs.microsoft.com/en-us/windows/deployment/update/servicing-stack-updates#why-should-servicing-stack-updates-be-installed-and-kept-up-to-date)

> Microsoft strongly recommends you install the latest servicing stack update (SSU) for your operating system before installing the LCU. SSUs improve the reliability of the update process to mitigate potential issues while installing the LCU and applying Microsoft security fixes.  
> 
> Source: Microsoft  

### How do Microsoft advertise new SSU's?

Traditionally, SSU's have been difficult to differentiate from other Security updates. In fact its only since the beginning of this year that Microsoft started using the term "Servicing Stack Update" in the update name to help us quickly identify if an update was a SSU. Before then, it was quite "challenging" for admins to stage patches - having to ensure SSU's were installed before the LCU's...but not easily being able to identify them from month to month.

In November 2018, to try and clear up some confusion around SSU's, Microsoft published Security Advisory 990001 [https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/ADV990001](https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/ADV990001)

This advisory indicates the latest SSU's available and the previous SSU's that were replaced. SSU's haven't always been cumulative to their predecessor and this has sometimes caused confusion when adopting or maintaining a patching strategy.

### SSU Cadence

To help with my understanding, and SSU history, I went through the Microsoft Update Catalog to understand the cadence of SSU's. They haven't always superseded each other.

The table below has been grafted from the Microsoft Update Catalog. Indicating the latest SSU for supported Windows 10 Operating Systems.

**_\*\* Updated 22/02/20_20 \*\***

**Windows 10 - 1909**

| **OS** | **KB** | **Last Modified** | **Size** | **Superseded By** | **Supersedes** |
| --- | --- | --- | --- | --- | --- |
| 1909 | [4538674](https://support.microsoft.com/en-us/help/4538674/compatibility-update-for-installing-windows-10-version-1903-1909) | 10/02/2020 | 14.4MB | \- | 4528759, 4521863 |
| 1909 | 4528759 | 13/01/2020 | 14.4MB | 4538674 | 4521863 |
| 1909 | 4521863 | 12/11/2019 | 14.4MB | 4538674, 4528759 | \- |

**Windows 10 - 1903**

| **OS** | **KB** | **Last Modified** | **Size** | **Superseded By** | **Supersedes** |
| --- | --- | --- | --- | --- | --- |
| 1903 | [4538674](https://support.microsoft.com/en-us/help/4538674/compatibility-update-for-installing-windows-10-version-1903-1909) | 10/02/2020 | 14.4MB | \- | 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 450010, 4498524 |
| 1903 | 4528759 | 13/01/2020 | 14.4MB | 4538674 | 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4524569 | 11/11/2019 | 14.4MB | 4538674, 4528759 | 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4525419 | 23/10/2019 | 14.4MB | 4538674, 4528759, 4524569 | 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4521863 | 07/10/2019 | 14.4MB | 4538674, 4528759, 4524569, 4525419 | 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4520390 | 26/09/2019 | 14.4MB | 4538674, 4528759, 4524569, 4525419, 4521863 | 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4515383 | 09/09/2019 | 14.4MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390 | 4515530, 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4515530 | 30/08/2019 | 14.4MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383 | 4508433, 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4508433 | 26/07/2019 | 14.6MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530 | 4509096, 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4509096 | 08/07/2019 | 14.5MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433 | 4506933, 4498523, 4500109, 4498524 |
| 1903 | 4506933 | 26/06/2019 | 14.6MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433,4509096 | 4498523, 4500109, 4498524 |
| 1903 | 4498523 | 29/05/2019 | 14.5MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933 | 4500109, 4498524 |
| 1903 | 4500109 | 11/05/2019 | 14.5MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523 | 4498524 |
| 1903 | 4498524 | 29/04/2019 | 14.5MB | 4538674, 4528759, 4524569, 4525419, 4521863, 4520390, 4515383, 4515530, 4508433, 4509096, 4506933, 4498523, 4500109 | \- |

**Windows 10 - 1809**

| **OS** | **KB** | **Last Modified** | **Size** | **Superseded By** | **Supersedes** |
| --- | --- | --- | --- | --- | --- |
| 1809 | [4523204](https://support.microsoft.com/en-gb/help/4523204/compatibility-update-for-installing-windows-10-1809) | 11/11/2019 | 13.6MB | \- | 4521862, 4512577, 4512937, 4509095, 4504369, 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4521862 | 08/10/2019 | 13.6MB | 4523204 | 4512577, 4512937, 4509095, 4504369, 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4512577 | 09/09/2019 | 13.5MB | 4523204, 4521862 | 4512937, 4509095, 4504369, 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4512937 | 22/07/2019 | 13.5MB | 4523204, 4521862, 4512577 | 4509095, 4504369, 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4509095 | 05/07/2019 | 13.6MB | 4523204, 4521862, 4512577, 4512937 | 4504369, 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4504369 | 09/06/2019 | 13.6MB | 4523204, 4521862, 4512577, 4512937, 4509095 | 4499728, 4493510, 4470788, 4465664, 4465477 |
| 1809 | [](https://support.microsoft.com/en-us/help/4499728/windows-10-update-kb4499728)[](https://support.microsoft.com/en-us/help/4499728/windows-10-update-kb4499728)[](http://support.microsoft.com/help/4499728)4499728 | 14/05/2019 | 13.6MB | 4523204, 4521862, 4512577, 4512937, 4509095, 4504369 | 4493510, 4470788, 4465664, 4465477 |
| 1809 | 4493510 | 01/04/2019 | 13.7MB | 4523204, 4521862, 4512577, 4512937, 4509095, 4504369, 4499728 | 4470788, 4465664, 4465477 |
| 1809 | 4470788 | 12/04/2018 | 13.7MB | 4523204, 4521862, 4512577, 4512937, 4509095, 4504369, 4499728, 4493510 | 4465664, 4465477 |
| 1809 | 4465664 | 09/11/2018 | 13.7MB | 4523204, 4521862, 4512577, 4512937, 4509095, 4504369, 4499728, 4493510, 4470788 | 4465477 |
| 1809 | 4465477 | 08/10/2018 | 13.6MB | 4523204, 4521862, 4512577, 4512937, 4509095, 4504369, 4499728, 4493510, 4470788, 4465664 | – |

**Windows 10 - 1803**

| **OS** | **KB** | **Last Modified** | **Size** | **Superseded By** | **Supersedes** |
| --- | --- | --- | --- | --- | --- |
| 1803 | [4523203](https://support.microsoft.com/en-us/help/4523203/compatibility-update-for-installing-windows-10-1803) | 11/11/2019 | 13.2MB | \- | 4521861, 4512576, 4509094, 4497398, 4485449, 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4521861 | 08/10/2019 | 13.2MB | 4523203 | 4512576, 4509094, 4497398, 4485449, 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4512576 | 09/09/2019    | 13.2MB | 4523203, 4521861 | 4509094, 4497398, 4485449, 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4509094 | 08/07/2019 | 13.2MB | 4523203, 4521861, 4512576 | 4497398, 4485449, 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4497398 | 11/05/2019 | 13.2MB | 4523203, 4521861, 4512576, 4509094 | 4485449, 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4485449 | 08/02/2019 | 13.7MB | 4523203, 4521861, 4512576, 4509094, 4497398 | 4477137, 4465663, 4343669, 4465663 |
| 1803 | 4477137 | 12/07/2018 | 13.3MB | 4523203, 4521861, 4512576, 4509094, 4497398, 4485449 | 4465663, 4343669, 4338853 |
| 1803 | 4465663 | 09/11/2018 | 13.3MB | 4523203, 4521861, 4512576, 4509094, 4497398, 4485449, 4477137 | 4343669, 4338853 |
| 1803 | [4456655](https://support.microsoft.com/en-gb/help/4456655/servicing-stack-update-for-windows-10-version-1803-september-11-2018) | 12/09/2018 | 13.5MB | – | 4343669, 4338853 |
| 1803 | 4343669 | 17/07/2018 | 13.3MB | 4523203, 4521861, 4512576, 4509094, 4497398, 4485449, 4477137, 4465663, 4456655 | 4338853 |
| 1803 | 4338853 | 22/06/2018 | 13.1MB | 4523203, 4521861, 4512576, 4509094, 4497398, 4485449, 4477137, 4465663, 4456655, 4343669 | – |

**Windows 10 - 1709**

| **OS** | **KB** | **Last Modified** | **Size** | **Superseded By** | **Supersedes** |
| --- | --- | --- | --- | --- | --- |
| 1709 | [4523202](https://support.microsoft.com/en-us/help/4523202/compatibility-update-for-installing-windows-10-1709) | 11/11/2019 | 13.1MB | \- | 4521860, 4512575, 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4521860 | 08/10/2019 | 13.0MB | 4523202 | 4512575, 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4512575 | 09/09/2019 | 13.1MB | 4523202, 4521860 | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4509093 | 08/07/2019 | 13.1MB | 4523202, 4521860, 4512575 | 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4500641 | 11/05/2019 | 13.1MB | 4509093 | 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4485448 | 08/02/2019 | 13.2MB | 4509093, 4500641 | 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4477136 | 07/12/2018 | 13.2MB | 4509093, 4500641, 4485448 | 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4465661 | 09/11/2018 | 13.2MB | 4509093, 4500641, 4485448, 4477136 | 4339420, 413265,0, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4339420 | 17/07/2018 | 13.1MB | 4509093, 4500641, 4485448, 4477136, 4465661 | 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4132650 | 21/05/2018 | 13.1MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420 | 4131372, 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4131372 | 07/05/2018 | 13.2MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650 | 4099989, 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4099989 | 06/04/2018 | 13.2MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372 | 4090914, 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4090914 | 05/03/2018 | 13.0MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989 | 4087256, 4074608, 4058702, 4054022 |
| 1709 | 4087256 | 13/02/2018 | 13.0MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 409998,9 4090914 | 4074608, 4058702, 4054022 |
| 1709 | 4074608 | 31/01/2018 | 13.0MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256 | 4058702, 4054022 |
| 1709 | 4058702 | 04/01/2018 | 13.0MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608 | 4054022 |
| 1709 | 4054022 | 29/11/2018 | 13.0MB | 4509093, 4500641, 4485448, 4477136, 4465661, 4339420, 4132650, 4131372, 4099989, 4090914, 4087256, 4074608, 4058702 | – |

### Final Thoughts

As we move forwards, i believe (hope) we will be able to better manage patching SSU's. Now the update name has the term "Servicing Stack Update" in the title we can start applying filters to our Automatic Deployment Rules in SCCM to ensure they get deployed before the LCU's.

Mike Terrill has a pretty cool approach using Configuration Baselines, i recommend you take a look at his blog  
[https://miketerrill.net/2018/12/20/how-to-install-a-win10-ssu-before-the-lcu-using-configuration-manager/](https://miketerrill.net/2018/12/20/how-to-install-a-win10-ssu-before-the-lcu-using-configuration-manager/)

If you haven't already checked it out, David Segura's OSDeploy tool makes light work of servicing WIMS and takes away the SSU headache from at least one aspect of your daily life  
[https://www.osdeploy.com/](https://www.osdeploy.com/)