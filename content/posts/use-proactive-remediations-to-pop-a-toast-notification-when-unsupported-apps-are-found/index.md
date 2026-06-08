---
title: "Use Proactive Remediations to pop a Toast Notification when Unsupported Apps are found"
date: 2022-08-08
categories: ["uncategorized"]
---

Many organsiations, against strong advice, still allow some users to install apps on their devices. Quite often this is applicable to software developers and IT admins, both being given permission to install apps to "test it works". The old argument was that IT simply could not turn around app packages in Intune of ConfigMgr to keep up with the demand from developers

<!--more-->

In this post we won't focus on poor decision making and previous strategic approaches to app management, instead we want to give you a tool to claw back mistakes of the past :)

Sure, we can quite simply "uninstall" apps for those users that are not supported and deemed a security risk. But what if removing Java 7.x.x breaks the developers ability to support software that generates income for a company? What if the business relies on a critical lob app that still requires Adobe Flash?

The heavy handed approach works, in some situations, but sometimes simple communication is key to embrace those power users so you can begin to formalise process and change together

## Toast Notification

Allowing users to feel empowered and informed is key to keeping them "on your side". Toast Notifications have proven hugely popular over the last 2-3 years. There are many great community examples on how to use Toast Notifications to keep users informed on device state, scheduled maintenenace and company communications

Here are a few to peek at:-

- [https://msendpointmgr.com/2020/08/07/proactive-battery-replacement-with-endpoint-analytics/](https://msendpointmgr.com/2020/08/07/proactive-battery-replacement-with-endpoint-analytics/)
- [https://www.imab.dk/windows-10-toast-notification-script/](https://www.imab.dk/windows-10-toast-notification-script/)
- [https://byteben.com/bb/deploy-service-announcement-toast-notifications-in-windows-10-with-memcm/](https://byteben.com/bb/deploy-service-announcement-toast-notifications-in-windows-10-with-memcm/)
- [https://msendpointmgr.com/2021/06/06/proactive-remediations-getting-your-message-across-with-repeated-toast-notifications/](https://msendpointmgr.com/2021/06/06/proactive-remediations-getting-your-message-across-with-repeated-toast-notifications/)
- [https://www.systanddeploy.com/2022/02/display-toast-notification-with-header.html](https://www.systanddeploy.com/2022/02/display-toast-notification-with-header.html)

### Unsupported Apps Toast

The idea behind the following solution is to pop a Toast notification to show the user the software they have installed which is considered "Unsupported" by the company. This isnt a magic bullet solution and won't clean out all those unsupported apps on day 1

You will need to adopt a stratergy to deal with unsupported apps. That stratergy could look like following:-

- Day 1: Pop a toast telling users they have unsupported apps installed and should be removed
- Day 7: Pop a toast telling users the apps must be uninstalled immediately
- Day 14: Pop a toast telling users the apps must be uninstalled immediately or they will be removed automatically
- Day 28: Forcibly remove unsupported applications

**Dont Forget**  
  
As you consider a Toast Notification solution, make sure you target users who have permissions to remove the software e.g. Developers, IT Users. There is little point telling a user they have unsupported software installed if they can do nothing about it

## Proactive Remediations

Proactive Remediations have long been a favourite of mine and my peers at MSEndpointMgr. They are so versatile. The idea with this solution is to use Proactive Remediations to deliver a Pre-Remediation script to users. The script will pop a toast notification to ther user if unsupported software is found. We can then also collect the unsupported software in the script output. Collating this data allows us to make informed choices on how to approach the unsupported apps found on our devices

### Inventory Installed Software

The first challenge is to inventory installed applications in order to be able to identify ones the company deems are unsupported. Let me point you to this excellent articly where @jankeskanke and @sandy\_tsang show you how to collect Inventory items using PowerShell and Proactive Remediations and store the results in Log Analytics

[https://msendpointmgr.com/2021/04/12/enhance-intune-inventory-data-with-proactive-remediations-and-log-analytics/](https://msendpointmgr.com/2021/04/12/enhance-intune-inventory-data-with-proactive-remediations-and-log-analytics/)

That solutions gathers both hardware and application inventory. We will be using part of that solution to inventory installed software from both the 32bit and 64bit registry for User and System locations

<figure>

[![Inventory installed software](/images/2022/02/image-242-1024x266.png)](/images/2022/02/image-242.png)

<figcaption>

Inventory Software

</figcaption>

</figure>

## Solution

The full solution can be found on the MSEndpointMgr Github at:-

[https://github.com/MSEndpointMgr/ProactiveRemediations/tree/master/UnsupportedApps](https://github.com/MSEndpointMgr/ProactiveRemediations/tree/master/UnsupportedApps)

When the script is published from Intune using Proactive Remediations, and unsupported apps are found, the user will receive a toast similar to below

<figure>

[![Toast Notification for Unsupported apps](/images/2022/02/image-243.png)](/images/2022/02/image-243.png)

<figcaption>

Toast Notification

</figcaption>

</figure>

### Script Variables

Unfortunately, we cannot use script parameters with Proactive Remediations still so we need to hard code the script variables

<figure>

[![script variables](/images/2022/02/image-248-1024x506.png)](/images/2022/02/image-248.png)

<figcaption>

Script Variables

</figcaption>

</figure>

The main variable to focus on is the **$BadApps** array. We define which apps are considered unsupported and they will be flagged in the toast notification if they are found

```
$BadApps = @(
    "Adobe Shockwave Player"
    "JavaFX"
    "Java 6"
    "Java SE Development Kit 6"
    "Java(TM) SE Development Kit 6"
    "Java(TM) 6"
    "Java 7"
    "Java SE Development Kit 7"
    "Java(TM) SE Development Kit 7"
    "Java(TM) 7"
    "Adobe Flash Player"
    "Adobe Air"
)
```

The items in the $BadApps array are used later in the script with the **\-like** operator. Be mindful of this when adding items to the array

[![array variable](/images/2022/02/image-251.png)](/images/2022/02/image-251.png)

More information on the other variables can be found in **ReadMe.md** in the GitHub repository

[https://github.com/MSEndpointMgr/ProactiveRemediations/blob/master/UnsupportedApps/ReadMe.md](https://github.com/MSEndpointMgr/ProactiveRemediations/blob/master/UnsupportedApps/ReadMe.md)

<figure>

[![Github Readme.md](/images/2022/02/image-249-1024x665.png)](/images/2022/02/image-249.png)

<figcaption>

ReadMe.md

</figcaption>

</figure>

### Proactive Remediation Settings

The Proactive Remediation should be run with the **Logged On Users Credentials** and as a **64bit application** (so it can detect 64 bit software)

<figure>

[![proactive remeditation settings](/images/2022/02/image-250.png)](/images/2022/02/image-250.png)

<figcaption>

Proactive Remediation Settings

</figcaption>

</figure>

### Logs and Output

Details of the inventoried software and unsupported apps are logged locally in the users **%temp%** folder

<figure>

[![Log File](/images/2022/02/image-244.png)](/images/2022/02/image-244.png)

<figcaption>

UnsupportAppsFound.log

</figcaption>

</figure>

Any unsupported apps are also added to the pre-remediation script output and can be used for futrther analysis

<figure>

[![](/images/2022/02/image-245-1024x199.png)](/images/2022/02/image-245.png)

<figcaption>

pre-remediation detection ouput

</figcaption>

</figure>

<figure>

[![pre-remediation detection output](/images/2022/02/image-246.png)](/images/2022/02/image-246.png)

<figcaption>

JSON formatted output

</figcaption>

</figure>

You can run the script locally, in the user context, for testing

<figure>

[![Unsupported Apps Script](/images/2022/02/image-247.png)](/images/2022/02/image-247.png)

<figcaption>

Testing the script

</figcaption>

</figure>

## Summary

In this post we looked at how to use a Proactive Remediations to pop a toast notification if unsupported software is found on the device. This solution may only be part 1 in your multi-part plan to remove unsupported apps in your environment. Communication is key, especially when trying to take away user permissions granted on the back of a previous, poor, IT stratergy

**Special thanks** must go to Jan Ketil Skanke [@jankeskanke](https://twitter.com/JankeSkanke) for helping with the code and idea behind the solution and also to Damien Van Robaeys \[MVP\] [@syst\_and\_deploy](https://twitter.com/syst_and_deploy) who drew my attention to the idea of using a Custom Handler in the toast notification :)

The custom handler can be defined in HKCU which makes it ideal for this solution where the script is run in the User Context

<figure>

[![Custom Handler](/images/2022/02/image-252.png)](/images/2022/02/image-252.png)

<figcaption>

Custom Handler

</figcaption>

</figure>