---
title: "AppSense Outlook Signature and other Profile Information Lost"
date: 2014-06-12
tags: ["appsense-environmentmanager-configurations", "hkey_local_machinesoftwarewow6432nodemicrosoftoffice14-0outlooksetup", "microsoft", "outlook", "outlook-profile", "outlook-signature-missing"]
categories: ["appsense", "appsense-desktopnow", "appsense-environmentmanager"]
---

When a user logs on and launches Microsoft Outlook, some profile information is lost. The most obvious side effect for us was the user losing their Outlook Signature.<!--more-->This problem can occur if there is a mismatch between the "First-Run" key in the users personalised registry and the HKLM registry of the local machine for Microsoft Office.

As Microsoft Office gets installed across your PC/Server estate, different flavours with different updates using different MSPs and Configs result in the following HKLM registry key differing on each instance.

```
[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Outlook\Setup]
"First-Run"=hex:fb,10,46,27,95,f6,79,4d,ae,a8,10,f5,25,a1,b3,65
```

When the user logs on and launches Microsoft Office, the value in this key is compared with the value in

```
[HKEY_CURRENT_USER\Software\Microsoft\Office\14.0\Outlook\Setup]
```

If the two differ, Outlook will launch the "First-Run" wizard, resulting in some personalised information being overwritten.

We needed to ensure that the "First-Run" value persisted across our environment in both the HKLM and HKCU portion of the registry (the later being held in the AppSense Personalization Database).

First, you will need to identify what "First-Run" value you want to set across your estate. We compared the HKLM registry keys of our Terminal Servers, XenApp Servers and workstations. Ok, now lets dig out our Environment Manager config.

- Start by creating a new node under "Computer Startup" or modify any existing node that deals with Microsoft Office registry settings on Computer Startup.
- Next, create a condition that checks if Microsoft Office is installed. \*In this example, I am dealing with Microsoft Office 2010 or version "14". You will need to substitute the registry key portion with your correct value if you are dealing with another version of Office. e.g. Office 2003 is "11", Office 2007 is "12".
- Now we need to set the following registry using the action "Set Registry Value" on all of our Terminal/Citrix server and PC's as a child node to this condition:-
    
    ```
    [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Outlook\Setup]
    "First-Run"=hex:fb,10,46,27,95,f6,79,4d,ae,a8,10,f5,25,a1,b3,65
    ```
    
- Your node should look something like this:-

```

```

- Now we have set the key in the local machine registry, we are going to have to set this same key against the user to ensure the same key matches the HKLM key wherever the user launches Outlook. Jump down to the "Process Started" node and create a new process to monitor for "outlook.exe" (or add a child node if the process already exists.
- Create an action that will set the HKCU to the same value as the one we set on the HKLM key in the previous steps. The reg value should be (in this example to match the HKLM we set earlier)
- ```
    [HKEY_CURRENT_USER\Software\Microsoft\Office\14.0\Outlook\Setup]
    "First-Run"=hex:fb,10,46,27,95,f6,79,4d,ae,a8,10,f5,25,a1,b3,65
    ```
    
- Your action should look like the following:-[![AppSense Outlook Signature and other Profile Information Lost](/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-4.jpg)](http://byteben.com/bb/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-4.jpg)
- The reg value should look something like this:-[![AppSense Outlook Signature and other Profile Information Lost](/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-2.jpg)](http://byteben.com/bb/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-2.jpg)
- On the "Personalization Tab" ensure that "Policy configuration takes precedence over personalization" is selected. This ensures any existing value that has been personalized by Outlook.exe is over ruled.[![AppSense Outlook Signature and other Profile Information Lost](/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-3.jpg)](http://byteben.com/bb/images/2014/06/AppSense-Outlook-Signature-and-other-Profile-Information-Lost-3.jpg)

That is it. We have now ensured that the HKLM reg value is consistent across our estate. We have made sure that when a user runs Outlook, the reg key value in HKCU matches the HKLM key to ensure the first run wizard does not re-run when the keys mismatch.

Thanks to AppSense support with assisting on this one.