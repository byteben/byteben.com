---
title: "Create an Intune App  Protection Policy to force an app \"Pin Reset\" after x days"
date: 2019-01-11
tags: ["app-protection-policy", "ems", "intune", "pin", "policy"]
categories: ["intune", "microsoft"]
---

The Intune Team announced a nifty app protection policy addition for the "Week of January 7, 2019" edition > [https://docs.microsoft.com/en-us/intune/whats-new](https://docs.microsoft.com/en-us/intune/whats-new)  

<!--more-->
  
You can now change the number of days before the app PIN must be changed. This new policy works for both IOS and Android devices.

### Create an Intune App Protection Policy

1 . Navigate to [https://devicemanagement.microsoft.com](https://devicemanagement.microsoft.com)  
2 . Navigate to "Client Apps" (1) - "App Protection Policies" (2)

![](/images/2019/01/Intune_Pin_Reset_2.jpg)

3 . Click "Create Policy"

![](/images/2019/01/Intune_Pin_Reset_3.jpg)

4 . Give the policy a Name (1) and choose the desired Platform (2)

![](/images/2019/01/Intune_Pin_Reset_4.jpg)

5 . Click "Select Required Apps" (1), choose the apps you wish to protect with this Policy (2) and click "Select" (3)

![](/images/2019/01/Intune_Pin_Reset_5.jpg)

6 . Click "Settings" (1) and then "Access Requirements" (2)

![](/images/2019/01/Intune_Pin_Reset_6.jpg)

7 . Under "PIN reset after number of days" (1) choose "Yes" and set the Number of days until the user is forced to change the app PIN (2) and click "Ok" (3)

![](/images/2019/01/Intune_Pin_Reset_7.jpg)

8\. Click "Ok" on the settings blade to commit the settings to the Policy  

![](/images/2019/01/Intune_Pin_Reset_8.jpg)

9 . Click "Create" to create the new app protection policy

![](/images/2019/01/Intune_Pin_Reset_9.jpg)

10 . Don't forget to assign the new app Protection Policy to a group so it will be deployed!

<figure>

![](/images/2019/01/Intune_Pin_Reset_10-1024x193.jpg)

<figcaption>

Policy not deployed!

</figcaption>

</figure>

Once the Policy is applied, your users will be notified when they have a pending App PIN reset coming up.

<figure>

![](/images/2019/01/Intune_Pin_Reset_12-1024x862.jpg)

<figcaption>

IOS Alert for upcoming PIN reset

</figcaption>

</figure>

That's it!  
  
If you followed my [previous post](https://byteben.com/bb/using-powershell-with-intune-graph-to-query-devices) on using Microsoft Graph API, have a play with the **Get-IntuneAppProtectionPolicy** cmdlet :)

<figure>

![](/images/2019/01/Intune_Pin_Reset_13-1024x830.jpg)

<figcaption>

  
Get-IntuneAppProtectionPolicy

</figcaption>

</figure>