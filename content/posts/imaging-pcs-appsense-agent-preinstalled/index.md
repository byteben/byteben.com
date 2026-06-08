---
title: "Imaging PCs with AppSense Environment Agent PreInstalled"
date: 2012-09-30
categories:
  - "AppSense"
  - "AppSense - Environment Manager - Scripts"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
  - "Scripts"
---

Lets set the scene..You are rolling out hundreds of PCs with Windows 7 and you want all the agents preinstalled..naturally. Well the AppSense Environment Manager Agent is no exception.

<!--more-->Here are a couple of reg mods I do in my imaging process. I clear the AppSense "MachineID" value to avoid duplicate entries in my database and I force the "GroupID" to ensure my client appears in the correct deployment group in my management console.

```
reg add "HKEY_LOCAL_MACHINE\Software\AppSense Technologies\Communications Agent" /v "machine id" /t REG_SZ /d "" /f
```

```
reg add "HKEY_LOCAL_MACHINE\Software\AppSense Technologies\Communications Agent" /v "group id" /t REG_SZ /d "{94ed8748-1940-4538-9dc4-02dadfa93966}" /f
```

I get the GroupID by checking the registry of a machine I have manually moved to my deployment group.

Ensure you have the option "Allow CCAs to self register with this group" selected on the settings page of your deployment group (see below) - otherwise they can't :)

[![Imaging PCs with AppSense Agent PreInstalled](/images/2012/09/Imaging-PCs-with-AppSense-Agent-PreInstalled.jpg "Imaging PCs with AppSense Agent PreInstalled")](http://byteben.com/bb/images/2012/09/Imaging-PCs-with-AppSense-Agent-PreInstalled.jpg)

I think that just about covers it. Back to my cuppa.

## Imaging PCs with AppSense Environment Agent PreInstalled

### Imaging PCs with AppSense Environment Agent PreInstalled