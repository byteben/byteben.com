---
title: "AppSense Environment Manager Antivirus Exclusions"
date: 2013-06-09
categories:
  - "AppSense"
  - "AppSense Environment Manager"
tags: ["antivirus", "antivirus-exclusions", "appsense", "appsense-environmentmanager", "trend-micro"]
---

Antivirus software...I liken it to those bead screens that hang down from your back door. Most of the time they don't bother you and just get on with the job of keeping out the flies but when you want to go through them you end up re-living a scene in an episode of LOST when the beads "come alive". AV is the same, most of the time it just sits there behaving nicely but every now and then it just plain becomes annoying. To avoid any "John Locke" jungle moments, below are some exclusions to add to your AV scanner when using AppSense Environment Manager:-<!--more-->

```
EmUser.exe
EmExit.exe
EMAgentAssist.exe
EMAgent.exe
EmUserLogoff.exe
EmCoreService.exe
EMNotify.exe
EmLoggedOnUser.exe
EmSystem.exe
```

If you are feeling funky, add the following exclusions for the Client Communications Agent too:-

```
Cca.exe
WatchdogAgent.exe (and WatchdogAgent64.exe on 64bit OS)
```

That is it really. I might just add some useful information regarding Trend Antivirus at this point. We had an issue with dead-locking with Trend 10.6 installed which resulted in system hangs (only experienced in our old XP environment). Trend released [OfficeScan 10 SP 1 Patch 2](http://www.trendmicro.com/ftp/products/patches/osce_10_sp1_patch2.exe) to deal with this which includes specific hotfixes for the for-mentioned problem.

## AppSense Environment Manager Antivirus Exclusions

### AppSense Environment Manager Antivirus Exclusions