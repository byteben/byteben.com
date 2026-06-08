---
title: "SCCM Report to group number of outstanding updates, for a collection, in 30 day intervals"
date: 2018-05-11
categories:
  - "ConfigMgr / MEMCM / SCCM"
  - "Microsoft"
tags: ["rdl", "reports", "sccm", "sql", "wsus"]
---

**POST UPDATED HERE**

[https://byteben.com/bb/sccm-software-compliance-report-filtered-by-update-classification-and-update-age/](https://byteben.com/bb/sccm-software-compliance-report-filtered-by-update-classification-and-update-age/)

I wasn't getting what i needed from the built in SCCM SSRS Reports. Admins were asking for it to be made easier to understand how bad the number of outstanding updates were for the systems they have ownership of. For example, how many of the outstanding updates are 0-30 days old or 60+ days old.<!--more-->

The attached report "should" clearly indicate how old the outstanding updates are. The parameters can be adjusted to fit your business SLA model for deploying updates.

The RDL also only contains one collection. Add your own collections to the report by modifying the COLLID parameter (you will need to know the Collection ID).

![](/images/2018/05/rdl_parameter.jpg)

Default date parameters/columns are:-

0 - 30 Days Old

31 - 60 Days Old

61 Days and Older

![](/images/2018/05/rdl-1024x446.jpg)

There is also a column to show if the client requires a restart. Often pending restarts can affect new updates being installed.

\*\*\* Big thanks to Eswar Koneti @eskonr and Adam Gross @adamgrosstx for their collective SSRS Examples and SQL Ninja Skills \*\*\*

[/downloads/Patches\_Required.zip](/downloads/Patches_Required.zip)