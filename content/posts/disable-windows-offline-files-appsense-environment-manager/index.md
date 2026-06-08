---
title: "Disable Windows Offline Files with AppSense Environment Manager"
date: 2012-09-30
categories:
  - "AppSense"
  - "AppSense Environment Manager"
  - "AppSense Environment Manager Configurations"
  - "Microsoft"
tags: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "client-side-caching", "csc", "microsoft", "microsoft-offline-files"]
categories: ["appsense", "appsense-environmentmanager", "appsense-environmentmanager-configurations", "microsoft"]
---

Disable Windows Offline Files with AppSense Environment Manager? Easy Hey? Well, in a nutshell, yes. We had a bit of bother trying to work out why this wouldn't work just by setting the GPO. We had to do some jazzy things with the Offline Files Service or CSC (Client Side Caching). Let me show you how it works in our environment.

<!--more-->We have created a node that solely handles Offline Files. I like to have seperate node for specific tasks like this for two reasons. One, it keeps everything tidy and allows me to easily find a config item and two we make better use of the AppSense node process threading where AppSense can process more than node at a time (Speeds up boot and logon times basically).

Ok, here is a screen shot of our Offline Files config, let me explain how it works below.

[![Disable Windows Offline Files with AppSense Environment Manager](/images/2012/09/Disable-Windows-Offline-Files-with-AppSense-Environment-Manager1.jpg "Disable Windows Offline Files with AppSense Environment Manager")](http://byteben.com/bb/images/2012/09/Disable-Windows-Offline-Files-with-AppSense-Environment-Manager1.jpg)

Ok, you can see that we start with an Environment Variable condition. Does the "Chassis" variable equal "PC", "Server" or "TraingingLaptop". If either of these conditions are met we disable Offline Files in our environment. We set the Environment variable when we image our Workstations and Servers. So how do we disable offline files? First, we create an ADMX policy action that disables the Offline Files Feature (See below).

# [![Disable Windows Offline Files with AppSense Environment Manager-ADMX](/images/2012/09/Disable-Windows-Offline-Files-with-AppSense-Environment-Manager-ADMX-297x300.jpg "Disable Windows Offline Files with AppSense Environment Manager-ADMX")](http://byteben.com/bb/images/2012/09/Disable-Windows-Offline-Files-with-AppSense-Environment-Manager-ADMX.jpg)

Next (and this is the part that stumped me for a bit), we disable the Offline Files Service..simple when you think about it hey? Use a policy action "Set Registry value" and create 3 actions with the following:-

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSC ValueName: "Start" Value: DWORD 00000004
```

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSCService ValueName: "Start" Value: DWORD 00000004
```

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\CSC\Parameters Valuename: "FormaDatabase" Value: DWORD 00000001
```

Setting a service Start value of 4 basically disables the service. To keep things clean I always like to keep the Offline Files cache empty so for good measure I always delete the offline cache by adding that 3rd Registry entry.

And that is it, no smoke and mirrors. To enable Offline Files for any chassis value "Laptop" we enable the GPO we disabled above, set the CSC and CSCService Start to 000000002 (Automatic Startup), we obviously don't format the database at each boot, we set a GPO to encrypt the offline files cache and we set administratively assigned offline files.

KISS - Keep It Simple Simon

## Disable Windows Offline Files with AppSense Environment Manager

### Disable Windows Offline Files with AppSense Environment Manager